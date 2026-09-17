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
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))

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
    end)
    check(ok == true, "Test identity mutation failed: " .. tostring(reason))
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
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

print(string.format("[Quest Service Tests] PASS: %d assertions.", assertions))
