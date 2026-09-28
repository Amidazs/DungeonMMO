--!strict
-- Real mixed-objective Adventure integration using trusted Dungeon publishers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Dungeon = ServerScriptService.Dungeon
local Shared = ReplicatedStorage.Core.Shared

local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Quests = require(Core.Services.QuestService)
local Definitions = require(Shared.QuestDefinitions)
local CompletionService = require(Dungeon.CompletionService)
local CheckpointBridge = require(Dungeon.DungeonCheckpointQuestBridge)

local USER_ID = 965201
local SESSION_ID = "fracture-trail-mine-clear"

local SessionStub = {}
SessionStub.__index = SessionStub

local RewardStub = {}
RewardStub.__index = RewardStub

local checks = 0

--[[
Creates one disposable completed Mine session.

Args:
    user_id (number): Quest owner who receives the trusted clear.

Returns:
    any: Session stub compatible with CompletionService.
]]
function SessionStub.new(user_id: number): any
    local self = setmetatable({}, SessionStub)
    self.session = {
        State = "Complete",
        DungeonId = "AbandonedMine",
        CompletionRecipients = {user_id},
        CompletionRewardsCommitted = false,
    }
    return self
end

--[[
Returns the disposable session for its stable ID.

Args:
    session_id (string): Requested completion-session identifier.

Returns:
    any?: Matching session, otherwise nil.
]]
function SessionStub:get(session_id: string): any?
    if session_id == SESSION_ID then
        return self.session
    end
    return nil
end

--[[
Marks completion rewards and quest progress as committed.

Args:
    session_id (string): Stable completion-session identifier.
    member_results (any): Completion results keyed by user.

Returns:
    any: Successful CompletionService-compatible result.
]]
function SessionStub:mark_completion_rewards_committed(
    session_id: string,
    member_results: any
): any
    assert(session_id == SESSION_ID, "unexpected completion session")
    self.session.CompletionRewardsCommitted = true
    self.session.CompletionRewardSummary = member_results
    return {ok = true}
end

--[[
Creates a no-op dungeon reward provider for quest integration.

Args:
    None.

Returns:
    any: Reward stub compatible with CompletionService.
]]
function RewardStub.new(): any
    return setmetatable({}, RewardStub)
end

--[[
Accepts the normal dungeon reward call without adding unrelated rewards.

Args:
    ... (any): CompletionService reward arguments.

Returns:
    any: Successful zero-value reward result.
]]
function RewardStub:grant_completion(...: any): any
    return {
        ok = true,
        gold_granted = 0,
    }
end

--[[
Counts one mixed-objective integration assertion.

Args:
    condition (boolean): Expected quest, reward, or persistence result.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Fracture Trail Integration] " .. label)
end

--[[
Installs one eligible launch character with Ruin Survey completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates the disposable profile into an eligible character.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 12
            character.Identity = {
                Version = 1,
                RaceId = "DarkElf",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
            character.Quests = {
                Version = 1,
                Active = {},
                Completed = {
                    WorldrootRelic = true,
                    MineEchoes = true,
                    RuinSurvey = true,
                },
            }
        end),
        "eligible character state installs"
    )
end

--[[
Returns current inventory quantity for one reward item.

Args:
    profiles (any): Loaded authoritative profile service.
    item_id (string): Registered item identifier.

Returns:
    number: Current authoritative item quantity.
]]
local function quantity(
    profiles: any,
    item_id: string
): number
    local character = assert(profiles:get_character(USER_ID, 1))
    return Inventory.count_item(character, item_id)
end

--[[
Records the trusted Temple checkpoint through the real bridge.

Args:
    quests (any): Authoritative QuestService.

Returns:
    nil: Raises when checkpoint progress is rejected.
]]
local function record_temple_checkpoint(quests: any)
    local result = CheckpointBridge.record(
        quests,
        "TestDungeon",
        "fracture-trail-temple",
        {USER_ID, USER_ID},
        "EncounterStart:CombatRoom2"
    )
    check(result.ok == true, "Temple checkpoint records")
end

--[[
Records the trusted Mine clear through CompletionService.

Args:
    profiles (any): Loaded authoritative profile service.
    quests (any): Authoritative QuestService.

Returns:
    any: First successful completion result.
]]
local function record_mine_clear(
    profiles: any,
    quests: any
): any
    local sessions = SessionStub.new(USER_ID)
    local completion = CompletionService.new(
        sessions,
        RewardStub.new(),
        profiles,
        {Gold = 0},
        nil,
        quests
    )

    local result = completion:commit(SESSION_ID)
    check(result.ok == true, "Mine completion commits")

    local replay = completion:commit(SESSION_ID)
    check(
        replay.ok == true and replay.already_applied == true,
        "Mine completion retry remains idempotent"
    )
    return result
end

--[[
Runs mixed checkpoint, clear, reward, and persistence acceptance.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after the full Adventure succeeds.
]]
local function main()
    local adapter = Adapter.new()
    local profiles = Profiles.new(adapter)
    check(profiles:load(USER_ID), "profile loads")
    install_character(profiles)

    local quests = Quests.new(profiles)
    local definition = assert(Definitions.get("FractureTrail"))

    check(
        definition.MinimumLevel == 12
            and definition.PrerequisiteQuestId == "RuinSurvey"
            and #definition.Objectives == 2,
        "Fracture Trail keeps reviewed eligibility and two objectives"
    )
    check(
        quests:start(USER_ID, "FractureTrail").ok,
        "eligible character starts Fracture Trail"
    )

    record_mine_clear(profiles, quests)

    local snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.FractureTrail.Ready == false
            and snapshot.Active.FractureTrail.Objectives
                .TraceTempleFracture == 0
            and snapshot.Active.FractureTrail.Objectives
                .PurgeMineSource == 1,
        "Mine clear alone cannot finish the mixed Adventure"
    )

    record_temple_checkpoint(quests)
    snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.FractureTrail.Ready == true
            and snapshot.Active.FractureTrail.Objectives
                .TraceTempleFracture == 1
            and snapshot.Active.FractureTrail.Objectives
                .PurgeMineSource == 1,
        "checkpoint plus Mine clear readies the Adventure"
    )

    record_temple_checkpoint(quests)
    snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.FractureTrail.Objectives
            .TraceTempleFracture == 1,
        "stable checkpoint event prevents duplicate progress"
    )

    local claimed = quests:claim_reward(USER_ID, "FractureTrail")
    check(
        claimed.ok == true
            and claimed.gold_granted == 90
            and type(claimed.items_granted) == "table"
            and #claimed.items_granted == 1,
        "Fracture Trail grants the reviewed reward atomically"
    )
    check(
        quantity(profiles, "warding_essence") == 2,
        "Fracture Trail grants exactly two Warding Essence"
    )

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        character.Gold == 90
            and character.ProfessionSlots.Gathering == ""
            and character.ProfessionSlots.Creation == "",
        "Fracture Trail remains profession-optional"
    )
    check(
        quests:claim_reward(USER_ID, "FractureTrail").reason
            == "QuestAlreadyCompleted",
        "Fracture Trail reward cannot be claimed twice"
    )

    check(
        profiles:save(USER_ID, "FractureTrailIntegration"),
        "Fracture Trail completion saves"
    )
    local restored = Profiles.new(adapter)
    check(restored:load(USER_ID), "Fracture Trail profile reloads")

    local restored_character = assert(
        restored:get_character(USER_ID, 1)
    )
    check(
        restored_character.Quests.Completed.FractureTrail == true
            and restored_character.Gold == 90
            and Inventory.count_item(
                restored_character,
                "warding_essence"
            ) == 2,
        "completion and reward persist after reload"
    )

    print(
        ("[Fracture Trail Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
