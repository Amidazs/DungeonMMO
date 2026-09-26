--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local InMemoryProfileAdapter = require(
    Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(Services:WaitForChild("ProfileService"))
local QuestService = require(Services:WaitForChild("QuestService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))
local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))


local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Quest Service Tests] " .. message, 2)
    end
end

local function set_identity(
    profiles: any,
    user_id: number,
    race_id: string,
    base_class_id: string,
    level: number
)
    local ok, reason = profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = base_class_id,
            ClassId = base_class_id,
            CreationStage = "Complete",
        }
        if base_class_id == "Mage" then
            local trial = assert(QuestDefinitions.get(
                "MageAdvancementTrial"
            ))
            character.Progression.SkillPointEntitlement = 60
            for _, required in ipairs(trial.SkillPrerequisites) do
                character.Progression.Skills[required.SkillId] = {
                    Known = true,
                    PurchasedRank = required.Rank,
                    Proficiency = required.Proficiency,
                    StarterGranted = false,
                }
            end
        end
    end)
    check(ok == true, "Test identity mutation failed: " .. tostring(reason))
end

local store = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(store)
assert(profiles:load(5101))
assert(profiles:load(5102))
assert(profiles:load(5103))

set_identity(profiles, 5101, "Human", "Mage", 19)
set_identity(profiles, 5102, "Human", "Mage", 20)
set_identity(profiles, 5103, "Human", "Fighter", 20)

local quests = QuestService.new(profiles)

local low_level = quests:start(5101, "MageAdvancementTrial")
check(
    low_level.ok == false and low_level.reason == "QuestUnavailable",
    "Level 19 Mage must not start the Level 20 advancement trial."
)

local wrong_class = quests:start(5103, "MageAdvancementTrial")
check(
    wrong_class.ok == false and wrong_class.reason == "QuestUnavailable",
    "Fighter must not start the Mage advancement trial."
)

local unknown = quests:start(5102, "MissingQuest")
check(
    unknown.ok == false and unknown.reason == "UnknownQuest",
    "Unknown quest must fail closed."
)

local started = quests:start(5102, "MageAdvancementTrial")
check(started.ok == true, "Eligible Human Mage must start the advancement trial.")

local duplicate_start = quests:start(5102, "MageAdvancementTrial")
check(
    duplicate_start.ok == false and duplicate_start.reason == "QuestAlreadyActive",
    "Duplicate active quest start must reject."
)

local unrelated = quests:record_event(5102, {
    EventId = "session-other:DungeonClear",
    Type = "DungeonClear",
    TargetId = "AbandonedMine",
    Amount = 1,
})
check(unrelated.ok == true, "Trusted unrelated event should be accepted as a no-op.")
local snapshot = quests:build_snapshot(5102)
check(snapshot.ok == true, "Quest snapshot must build.")
check(
    snapshot.Active.MageAdvancementTrial.Ready == false,
    "Unrelated dungeon clear must not ready the Temple advancement quest."
)

local event_id = "session-temple:DungeonClear"
local clear = quests:record_event(5102, {
    EventId = event_id,
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(clear.ok == true, "Temple DungeonClear event must be accepted.")
snapshot = quests:build_snapshot(5102)
check(
    snapshot.Active.MageAdvancementTrial.Ready == true,
    "Temple clear must ready the advancement quest."
)
check(
    snapshot.Active.MageAdvancementTrial.Objectives.ClearTemple == 1,
    "Temple objective must clamp at one clear."
)

local replay = quests:record_event(5102, {
    EventId = event_id,
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(replay.ok == true, "Replayed trusted event should be idempotent.")
snapshot = quests:build_snapshot(5102)
check(
    snapshot.Active.MageAdvancementTrial.Objectives.ClearTemple == 1,
    "Replayed EventId must not increment objective progress."
)

local invalid = quests:record_event(5102, {
    EventId = "",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(
    invalid.ok == false and invalid.reason == "InvalidQuestEvent",
    "Missing stable EventId must be rejected."
)

-- New story content reuses the existing trusted DungeonClear event, the
-- persisted quest state and the atomic inventory/profile mutation.
local premature = quests:start(5103, "MineEchoes")
check(
    premature.reason == "QuestUnavailable",
    "Mine follow-up must require the character's own completed relic quest."
)
check(
    quests:start(5103, "WorldrootRelic").ok,
    "Fighter must be able to start the first cross-class story quest."
)
check(
    quests:claim_reward(5103, "WorldrootRelic").reason == "QuestNotReady",
    "Starting a quest must never immediately grant its reward."
)
check(
    not quests:claim_reward(5103, "MageAdvancementTrial").ok,
    "The adventure reward API must never complete class advancement."
)
local wrong_story_clear = quests:record_event(5103, {
    EventId = "story:mine-first",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
    Amount = 1,
})
check(wrong_story_clear.ok, "Unrelated trusted events must be harmless.")
check(
    quests:claim_reward(5103, "WorldrootRelic").reason == "QuestNotReady",
    "Mine completion must not count as Temple story progress."
)
local temple_story_clear = quests:record_event(5103, {
    EventId = "story:temple-first",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(temple_story_clear.ok, "Temple clear must ready the relic quest.")
local relic_claim = quests:claim_reward(5103, "WorldrootRelic")
check(
    relic_claim.ok and relic_claim.gold_granted == 25
        and relic_claim.item_id == "worldroot_relic",
    "Relic claim must grant the configured server-owned reward."
)
local rewarded = profiles:get_character(5103)
check(
    rewarded.Gold == 25
        and InventoryService.count_item(
            rewarded, "worldroot_relic"
        ) == 1,
    "Relic and gold must be committed to the same character."
)
check(
    quests:claim_reward(5103, "WorldrootRelic").reason
        == "QuestAlreadyCompleted",
    "Repeating an already-claimed story quest cannot grant more loot."
)
check(
    quests:start(5103, "WorldrootRelic").reason
        == "QuestAlreadyCompleted",
    "The one-time relic quest cannot be restarted for extra rewards."
)
check(
    quests:start(5103, "MineEchoes").ok,
    "Completing the first quest must unlock its follow-up."
)
check(
    quests:claim_reward(5103, "MineEchoes").reason == "QuestNotReady",
    "Follow-up must require a new valid Mine clear after it was started."
)
local mine_story_clear = quests:record_event(5103, {
    EventId = "story:mine-after-unlock",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
    Amount = 1,
})
check(mine_story_clear.ok, "Mine clear must ready the follow-up quest.")
local mine_claim = quests:claim_reward(5103, "MineEchoes")
check(
    mine_claim.ok and mine_claim.gold_granted == 50
        and mine_claim.item_id == "iron_ore"
        and mine_claim.quantity == 5,
    "Mine follow-up must grant its own server-defined materials and gold."
)
rewarded = profiles:get_character(5103)
check(
    rewarded.Gold == 75
        and InventoryService.count_item(rewarded, "iron_ore") == 5
        and InventoryService.count_item(
            rewarded, "worldroot_relic"
        ) == 1,
    "Both one-time quest rewards must coexist without duplicating items."
)
check(
    quests:claim_reward(5103, "MineEchoes").reason
        == "QuestAlreadyCompleted",
    "A second Mine reward request must not double-pay the quest."
)

local saved, save_error = profiles:save(5103, "StoryQuestTest")
check(saved, "Story quest rewards must save: " .. tostring(save_error))
local released, release_error = profiles:release(
    5103, "StoryQuestTest"
)
check(
    released, "Story quest profile must release: "
        .. tostring(release_error)
)
check(profiles:load(5103) ~= nil, "Claimed quest profile must reload.")
local restored = profiles:get_character(5103)
check(
    restored.Quests.Completed.WorldrootRelic == true
        and restored.Quests.Completed.MineEchoes == true
        and restored.Gold == 75
        and InventoryService.count_item(
            restored, "worldroot_relic"
        ) == 1,
    "Both story completions and the relic must persist after reload."
)
check(
    quests:claim_reward(5103, "WorldrootRelic").reason
        == "QuestAlreadyCompleted"
        and quests:claim_reward(5103, "MineEchoes").reason
            == "QuestAlreadyCompleted",
    "Reloading a profile must never reset either claimed reward."
)
check(
    profiles:get_character(5102).Quests.Completed.MineEchoes ~= true,
    "Quest completion must remain independent for each party member."
)

print(string.format("[Quest Service Tests] PASS: %d assertions.", assertions))
