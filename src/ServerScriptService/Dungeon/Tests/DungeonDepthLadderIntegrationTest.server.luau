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
--       map (any): Disposable storage shared across reconstructed services.
--       clock (() -> number): Stable test clock for session services.
-- Returns: nil: Checks ordering, checkpoint and interrupted-boss recovery.
local function clear_run(
    sessions: any,
    session_id: string,
    plan: {any},
    map: any,
    clock: () -> number
)
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
            local rebuilt = Sessions.new(map, clock)
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

-- Checks entry prerequisites without enabling unreleased content.
-- Args: context (any): Current profile, progression and dungeon services.
--       depth_id (string): Authoritative difficulty identifier.
--       index (number): One-based position in the four-depth ladder.
--       order ({string}): Immutable progression order for this dungeon.
-- Returns: any: Existing difficulty definition and encounter sequence.
local function validate_depth(
    context: any, depth_id: string, index: number, order: {string}
): any
    local difficulty = assert(Difficulties.get(context.dungeon_id, depth_id))
    check(#difficulty.EncounterSequence == index + 2,
        context.dungeon_id .. " has the expected room count")
    check(context.progression:is_unlocked(
        context.user_id, context.dungeon_id, depth_id
    ), "current depth must be logically unlocked")
    if index < #order then
        local next_id = order[index + 1]
        check(not context.progression:is_unlocked(
            context.user_id, context.dungeon_id, next_id
        ), "later depth cannot skip an uncleared prerequisite")
        check(context.progression:record_clear(
            context.user_id, context.dungeon_id, next_id
        ).reason == "PreviousDifficultyNotCleared",
            "premature higher-depth completion must be rejected")
    end
    check(context.progression:validate_entry(
        context.user_id, context.dungeon_id, depth_id
    ).ok, "logical entry passes only the isolated readiness contract")
    if index > 1 then
        check(not difficulty.RuntimeReleaseEnabled
            and context.release:validate_entry(
                context.user_id, context.dungeon_id, depth_id
            ).reason == "DifficultyContentNotReady",
            "normal unreleased high-depth entry stays blocked")
    end
    return difficulty
end

-- Runs and commits one depth using the existing dungeon authorities.
-- Args: context (any): Current disposable session/profile services.
--       depth_id (string): Selected depth for the simulated session.
--       difficulty (any): Frozen authoritative encounter definition.
-- Returns: nil: Checks completion, reward idempotency and saved unlock.
local function complete_depth(
    context: any, depth_id: string, difficulty: any
)
    local created = assert(context.sessions:create(
        context.dungeon_id, {context.user_id}, 0,
        "depth-ladder-" .. context.dungeon_id, depth_id
    ))
    check(created.Difficulty.Id == depth_id,
        "session must store the selected difficulty")
    check(context.sessions:mark_connected(
        created.SessionId, context.user_id
    ).ok, "dungeon session becomes active")
    clear_run(context.sessions, created.SessionId,
        difficulty.EncounterSequence, context.map, context.clock)
    check(context.sessions:mark_complete(
        created.SessionId, {context.user_id}
    ).ok, "completed run saves its reward recipient")
    local initial_gold = context.profiles:get_character(
        context.user_id, 1
    ).Gold
    local first_clear = commit_depth(
        context.sessions, created.SessionId, context.profiles,
        context.progression, context.dungeon_id, depth_id
    )
    local recorded = first_clear.member_results[
        tostring(context.user_id)
    ].difficulty_progress
    check(recorded.ok and not recorded.already_completed
        and recorded.completed_difficulty_id == depth_id,
        "actual completion records the correct depth exactly once")
    check(context.profiles:get_character(
        context.user_id, 1
    ).Gold > initial_gold, "completion rewards are granted once")
    check(context.progression:record_clear(
        context.user_id, context.dungeon_id, depth_id
    ).already_completed, "repeat clear must remain idempotent")
    check(context.profiles:save(
        context.user_id, "DepthLadderTest"
    ), "difficulty unlock must be stored in the profile")
end

-- Exercises the four-depth unlock ladder and cross-session persistence.
-- Args: dungeon_id (string): One independently tracked dungeon ladder.
--       user_id (number): Disposable in-memory player identity.
--       profiles (any): Loaded profile service shared across both ladders.
--       profile_store (any): Disposable persistent profile adapter.
-- Returns: nil: Checks all depth clears after independent reloads.
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
    local function clock(): number
        return 1000
    end
    local context = {
        dungeon_id = dungeon_id,
        user_id = user_id,
        profile_store = profile_store,
        profiles = profiles,
        ready = ready,
        clock = clock,
        map = Map.new(clock),
    }
    context.sessions = Sessions.new(context.map, clock)
    context.progression = Progression.new(profiles, ready)
    context.release = Progression.new(profiles)

    local order = Difficulties.order()
    for index, depth_id in ipairs(order) do
        local difficulty = validate_depth(context, depth_id, index, order)
        complete_depth(context, depth_id, difficulty)
        context.profiles = Profiles.new(profile_store)
        check(context.profiles:load(user_id) ~= nil,
            "saved player profile reloads before the next depth")
        context.progression = Progression.new(context.profiles, ready)
        context.release = Progression.new(context.profiles)
    end
    local progress = context.progression:get_snapshot(user_id).progress
    local dungeon = progress.Dungeons[dungeon_id]
    check(dungeon.HighestClearedOrder == 4
        and dungeon.Completed.Depth4 == true,
        "profile reload retains all four difficulty clears")
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
