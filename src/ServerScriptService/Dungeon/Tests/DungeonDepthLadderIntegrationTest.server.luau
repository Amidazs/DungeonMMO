--!strict
-- Verifies the existing four-depth ladder without enabling unreleased content.
local SSS = game:GetService("ServerScriptService")
local Shared = game:GetService("ReplicatedStorage").Core.Shared
local Core = SSS.Core
local Dungeon = SSS.Dungeon

local Definitions = require(Shared.DungeonDefinitions)
local Difficulties = require(Shared.DungeonDifficultyDefinitions)
local Map = require(Core.Adapters.InMemoryMapAdapter)
local ProfileMap = require(Core.Adapters.InMemoryProfileAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Profiles = require(Core.Services.ProfileService)
local Progression = require(Core.Services.DungeonDifficultyProgressionService)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)
local Completion = require(Dungeon.CompletionService)
local Rewards = require(Core.Services.RewardService)
local Experience = require(Core.Services.ProgressionService)
local Inventory = require(Core.Services.InventoryService)
local Tuning = require(Core.Services.DungeonDifficultyTuning)

local assertions = 0

-- Checks one progression invariant with a useful Studio failure message.
-- Args: passed (boolean): Whether the required condition holds.
--       message (string): Specific expectation that failed.
-- Returns: nil: Raises when the condition is false.
local function check(passed: boolean, message: string)
    assertions += 1
    assert(passed, "[Depth Ladder Integration] " .. message)
end

-- Resolves the expected boss identity at every depth.
-- Args: dungeon_id (string): Authoritative Temple or Mine definition ID.
-- Returns: nil: Raises if the Depth4 boss lineage or room order changes.
local function verify_boss_lineage(dungeon_id: string)
    local source = assert(Definitions.get(dungeon_id))
    local depth4 = assert(Difficulties.get(dungeon_id, "Depth4"))
    local plan = depth4.EncounterSequence
    check(#plan == 6, dungeon_id .. " Depth4 has six rooms")
    for position, previous_depth in ipairs({1, 2, 3}) do
        local room_index = if position == 1 then 2
            elseif position == 2 then 4 else 5
        local boss = plan[room_index]
        check(boss.Kind == "MiniBoss"
            and boss.BossId == source.DifficultyBossIds[previous_depth],
            dungeon_id .. " Depth4 reuses each previous boss as miniboss")
    end
    check(plan[6].Kind == "FinalBoss"
        and plan[6].BossId == source.DifficultyBossIds[4],
        dungeon_id .. " Depth4 final boss is distinct and last")
end

-- Starts and clears every planned encounter using the existing controller.
-- Args: sessions (any): Service backed by disposable shared session storage.
--       session_id (string): Newly created instance of one depth.
--       plan ({any}): That depth's authoritative encounter descriptors.
-- Returns: nil: Checks ordering, checkpoint and interrupted-boss recovery.
local function clear_run(sessions: any, session_id: string, plan: {any})
    local controller = assert(Controller.new({
        session_service = sessions,
        session_id = session_id,
        base_sequence = plan,
        optional_encounters = {},
    }))
    for index, encounter in ipairs(plan) do
        local encounter_id = encounter.Id
        check(controller:next_id() == encounter_id,
            "required encounter must be next in the ordered plan")
        if index < #plan then
            check(not controller:start(plan[#plan].Id).ok,
                "later boss must not bypass required room")
        end
        check(sessions:activate_checkpoint(
            session_id, "EncounterStart:" .. encounter_id, index
        ).ok, "room-start checkpoint must persist monotonically")
        check(controller:start(encounter_id).ok,
            "required encounter must start exactly once")
        check(not controller:start(encounter_id).ok,
            "an active encounter cannot spawn a second copy")
        if encounter.Kind == "MiniBoss" then
            local rebuilt = Sessions.new(sessions._map, sessions._clock)
            controller = assert(Controller.new({
                session_service = rebuilt,
                session_id = session_id,
                base_sequence = plan,
                optional_encounters = {},
            }))
            sessions = rebuilt
            check(controller:state_of(encounter_id) == "Pending"
                and controller:next_id() == encounter_id,
                "interrupted miniboss must restart as Pending")
            check(sessions:get(session_id).Checkpoint.Id
                == "EncounterStart:" .. encounter_id,
                "miniboss interruption must not regress checkpoint")
            check(controller:start(encounter_id).ok,
                "recovered miniboss must remain playable")
        end
        check(controller:clear(encounter_id).ok,
            "encounter must clear once after a valid start")
        check(controller:state_of(encounter_id) == "Cleared",
            "cleared encounter must persist")
        check(not controller:start(encounter_id).ok,
            "previously cleared encounter must never spawn again")
    end
    check(controller:is_complete(), "all required rooms must be complete")
end

-- Commits the actual completion reward and depth unlock for one run.
-- Args: sessions (any): The saved session service for this run.
--       session_id (string): Completed dungeon run.
--       profiles (any): Current loaded player profiles.
--       progression (any): Real difficulty progression service.
--       dungeon_id (string): Dungeon whose completion reward is scaled.
--       depth_id (string): Selected difficulty of the completed run.
-- Returns: any: First successful committed completion result.
local function commit_depth(
    sessions: any,
    session_id: string,
    profiles: any,
    progression: any,
    dungeon_id: string,
    depth_id: string
): any
    local definition = assert(Definitions.get(dungeon_id))
    local tuning = assert(Tuning.resolve(dungeon_id, depth_id, nil))
    local reward = Tuning.scale_completion_reward(
        definition.CompletionReward, tuning
    )
    local rng = {
        NextInteger = function(_, low: number) return low end,
        NextNumber = function(_, low: number) return low end,
    }
    local rewards = Rewards.new(profiles, Experience.new(profiles),
        Inventory.new(profiles), sessions, rng, function() return 1000 end)
    local completion = Completion.new(
        sessions, rewards, profiles, reward, nil, nil, nil, progression
    )
    local first = completion:commit(session_id)
    check(first.ok and not first.already_applied,
        "first completion commits rewards and difficulty unlock")
    local replay = completion:commit(session_id)
    check(replay.ok and replay.already_applied,
        "same session cannot grant completion rewards again")
    check(sessions:get(session_id).CompletionRewardsCommitted == true,
        "session commits only after profile completion save")
    return first
end

-- Exercises logical unlocks while preserving actual release/content locks.
-- Args: dungeon_id (string): One independently tracked dungeon ladder.
--       user_id (number): Disposable in-memory test profile identity.
--       profiles (any): Loaded profile service shared across both ladders.
--       profile_store (any): Persistent in-memory test profile adapter.
-- Returns: nil: Checks all depth unlocks, clears and profile reloads.
local function verify_ladder(
    dungeon_id: string,
    user_id: number,
    profiles: any,
    profile_store: any
)
    local ready = {
        analyze = function()
            return {ok = true, Ready = true}
        end,
    }
    local progression = Progression.new(profiles, ready)
    local release = Progression.new(profiles)
    local map = Map.new(function() return 1000 end)
    local sessions = Sessions.new(map, function() return 1000 end)
    local order = Difficulties.order()
    for index, depth_id in ipairs(order) do
        local difficulty = assert(Difficulties.get(dungeon_id, depth_id))
        check(#difficulty.EncounterSequence == index + 2,
            dungeon_id .. " has the expected depth-specific room count")
        check(progression:is_unlocked(user_id, dungeon_id, depth_id),
            dungeon_id .. " current depth must be logically unlocked")
        if index < #order then
            local next_id = order[index + 1]
            check(not progression:is_unlocked(user_id, dungeon_id, next_id),
                dungeon_id .. " cannot skip an uncleared depth")
            check(progression:record_clear(
                user_id, dungeon_id, next_id
            ).reason == "PreviousDifficultyNotCleared",
                "higher depth clear must reject missing prerequisite")
        end
        check(progression:validate_entry(
            user_id, dungeon_id, depth_id
        ).ok, "eligible depth passes an isolated readiness contract")
        if index > 1 then
            check(not difficulty.RuntimeReleaseEnabled
                and release:validate_entry(
                    user_id, dungeon_id, depth_id
                ).reason == "DifficultyContentNotReady",
                "actual unreleased high-depth entry must remain blocked")
        end
        local created = assert(sessions:create(
            dungeon_id, {user_id}, 0,
            "depth-ladder-" .. dungeon_id, depth_id
        ))
        check(created.Difficulty.Id == depth_id,
            "session must store the selected difficulty")
        check(sessions:mark_connected(created.SessionId, user_id).ok,
            "dungeon session must become active")
        clear_run(sessions, created.SessionId, difficulty.EncounterSequence)
        check(sessions:mark_complete(
            created.SessionId, {user_id}
        ).ok, "completed session must persist the reward recipient")
        local initial_gold = profiles:get_character(user_id, 1).Gold
        local first_clear = commit_depth(
            sessions, created.SessionId, profiles, progression,
            dungeon_id, depth_id
        )
        local recorded = first_clear.member_results[tostring(user_id)]
            .difficulty_progress
        check(recorded.ok and not recorded.already_completed
            and recorded.completed_difficulty_id == depth_id,
            "completion must unlock the correct depth exactly once")
        check(profiles:get_character(user_id, 1).Gold > initial_gold,
            "completion must grant scaled gold once before saving")
        check(progression:record_clear(
            user_id, dungeon_id, depth_id
        ).already_completed, "repeat clear must not unlock twice")
        check(profiles:save(user_id, "DepthLadderTest"),
            "difficulty clear must persist in the player profile")
        profiles = Profiles.new(profile_store)
        check(profiles:load(user_id) ~= nil,
            "new profile service must load the saved difficulty clear")
        progression = Progression.new(profiles, ready)
        release = Progression.new(profiles)
    end
    local progress = progression:get_snapshot(user_id).progress
    local dungeon = progress.Dungeons[dungeon_id]
    check(dungeon.HighestClearedOrder == 4
        and dungeon.Completed.Depth4 == true,
        "profile reload must retain all four difficulty clears")
end

local profile_store = ProfileMap.new()
local profiles = Profiles.new(profile_store)
local user_id = 99741
check(profiles:load(user_id) ~= nil, "disposable test profile loads")
check(not Progression.new(profiles):is_unlocked(
    user_id, "TestDungeon", "Depth2"
), "Temple Depth2 starts locked")
check(not Progression.new(profiles):is_unlocked(
    user_id, "AbandonedMine", "Depth2"
), "Mine Depth2 starts independently locked")

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    verify_boss_lineage(dungeon_id)
    verify_ladder(dungeon_id, user_id, profiles, profile_store)
    profiles = Profiles.new(profile_store)
    check(profiles:load(user_id) ~= nil, "saved profile loads for next dungeon")
end
check(Progression.new(profiles):is_unlocked(
    user_id, "TestDungeon", "Depth4"
) and Progression.new(profiles):is_unlocked(
    user_id, "AbandonedMine", "Depth4"
), "Temple and Mine difficulty clears persist independently")
print(string.format(
    "[Depth Ladder Integration Tests] PASS: %d assertions.", assertions
))
