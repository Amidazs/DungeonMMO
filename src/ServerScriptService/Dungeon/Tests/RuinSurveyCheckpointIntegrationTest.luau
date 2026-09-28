--!strict
-- Real QuestService integration for the checkpoint-driven Ruin Survey.

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
local Bridge = require(Dungeon.DungeonCheckpointQuestBridge)

local USER_ID = 965101
local checks = 0

--[[
Counts one Ruin Survey integration assertion.

Args:
    condition (boolean): Expected quest, reward, or persistence result.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Ruin Survey Integration] " .. label)
end

--[[
Installs one eligible launch character with Mine Echoes completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates the disposable profile into an eligible Dark Elf Fighter.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 8
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
Runs checkpoint progress, idempotency, reward and persistence checks.

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
    local definition = assert(Definitions.get("RuinSurvey"))

    check(
        definition.MinimumLevel == 8
            and definition.PrerequisiteQuestId == "MineEchoes"
            and #definition.Objectives == 2,
        "Ruin Survey keeps reviewed eligibility and two checkpoints"
    )
    check(
        quests:start(USER_ID, "RuinSurvey").ok,
        "eligible character starts Ruin Survey"
    )

    local wrong = Bridge.record(
        quests,
        "TestDungeon",
        "survey-session-wrong",
        {USER_ID},
        "EncounterStart:CombatRoom1"
    )
    check(wrong.ok == true, "unrelated trusted checkpoint is harmless")

    local snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.RuinSurvey.Ready == false
            and snapshot.Active.RuinSurvey.Objectives
                .ReachTempleInnerApproach == 0
            and snapshot.Active.RuinSurvey.Objectives
                .ReachMineLowerWorks == 0,
        "wrong checkpoint progresses neither survey objective"
    )

    local temple = Bridge.record(
        quests,
        "TestDungeon",
        "survey-session-temple",
        {USER_ID, USER_ID},
        "EncounterStart:CombatRoom2"
    )
    check(temple.ok == true, "Temple inner approach records")

    snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.RuinSurvey.Ready == false
            and snapshot.Active.RuinSurvey.Objectives
                .ReachTempleInnerApproach == 1
            and snapshot.Active.RuinSurvey.Objectives
                .ReachMineLowerWorks == 0,
        "one checkpoint cannot complete the two-site survey"
    )

    local replay = Bridge.record(
        quests,
        "TestDungeon",
        "survey-session-temple",
        {USER_ID},
        "EncounterStart:CombatRoom2"
    )
    check(replay.ok == true, "replayed checkpoint event is accepted")

    snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.RuinSurvey.Objectives
            .ReachTempleInnerApproach == 1,
        "stable EventId prevents duplicate checkpoint progress"
    )

    local mine = Bridge.record(
        quests,
        "AbandonedMine",
        "survey-session-mine",
        {USER_ID},
        "EncounterStart:CombatRoom2"
    )
    check(mine.ok == true, "Mine lower works records")

    snapshot = quests:build_snapshot(USER_ID)
    check(
        snapshot.Active.RuinSurvey.Ready == true
            and snapshot.Active.RuinSurvey.Objectives
                .ReachMineLowerWorks == 1,
        "both released checkpoints ready the survey"
    )

    local claimed = quests:claim_reward(USER_ID, "RuinSurvey")
    check(
        claimed.ok == true
            and claimed.gold_granted == 60
            and type(claimed.items_granted) == "table"
            and #claimed.items_granted == 4,
        "survey grants one Gold plus four-component reward atomically"
    )

    check(
        quantity(profiles, "deep_iron_bar") == 1
            and quantity(profiles, "moonpetal_extract") == 1
            and quantity(profiles, "reinforced_leather") == 1
            and quantity(profiles, "resonant_rune") == 1,
        "survey grants exactly one of each level-three trade component"
    )

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        character.Gold == 60
            and character.ProfessionSlots.Gathering == ""
            and character.ProfessionSlots.Creation == "",
        "survey remains profession-optional"
    )

    check(
        quests:claim_reward(USER_ID, "RuinSurvey").reason
            == "QuestAlreadyCompleted",
        "survey reward cannot be claimed twice"
    )

    check(
        profiles:save(USER_ID, "RuinSurveyIntegration"),
        "survey completion saves"
    )
    local restored = Profiles.new(adapter)
    check(restored:load(USER_ID), "survey profile reloads")
    local restored_character = assert(
        restored:get_character(USER_ID, 1)
    )
    check(
        restored_character.Quests.Completed.RuinSurvey == true
            and restored_character.Gold == 60
            and Inventory.count_item(
                restored_character,
                "deep_iron_bar"
            ) == 1
            and Inventory.count_item(
                restored_character,
                "resonant_rune"
            ) == 1,
        "survey completion and representative rewards persist"
    )

    print(
        ("[Ruin Survey Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
