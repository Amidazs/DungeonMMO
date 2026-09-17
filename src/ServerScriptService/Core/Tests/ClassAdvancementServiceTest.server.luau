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
local ClassAdvancementService = require(
    Services:WaitForChild("ClassAdvancementService")
)
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Class Advancement Tests] " .. message, 2)
    end
end

local function set_mage(
    profiles: any,
    user_id: number,
    race_id: string
)
    local ok, reason = profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
    end)
    check(ok == true, "Mage fixture mutation failed: " .. tostring(reason))
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(5201))
assert(profiles:load(5202))
assert(profiles:load(5203))
set_mage(profiles, 5201, "Human")
set_mage(profiles, 5202, "Elf")

local fixture_ok = profiles:mutate(5203, function(profile: any)
    local character = profile.Characters.Slot1
    character.Level = 20
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "Fighter",
        CreationStage = "Complete",
    }
end)
check(fixture_ok == true, "Fighter fixture mutation failed.")

local quests = QuestService.new(profiles)
local base = ClassAdvancementService.new(profiles, quests, "Base")
local dungeon = ClassAdvancementService.new(profiles, quests, "Dungeon")

local dungeon_reject = dungeon:start_trial(5201)
check(
    dungeon_reject.ok == false and dungeon_reject.reason == "BaseOnlyAction",
    "Advancement trial must not start in Dungeon context."
)

local unavailable = base:start_trial(5203)
check(
    unavailable.ok == false and unavailable.reason == "AdvancementUnavailable",
    "Unapproved Fighter advancement must reject."
)

local human_start = base:start_trial(5201)
check(human_start.ok == true, "Human Mage trial must start.")

local early_claim = base:claim(5201)
check(
    early_claim.ok == false
        and early_claim.reason == "AdvancementQuestNotReady",
    "Advancement claim before objective completion must reject."
)

local human_event = quests:record_event(5201, {
    EventId = "human-session:DungeonClear",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(human_event.ok == true, "Human Temple clear must progress quest.")

local human_claim = base:claim(5201)
check(human_claim.ok == true, "Ready Human Mage advancement must claim.")
check(
    human_claim.class_id == "HumanArcanist",
    "Human Mage must advance to HumanArcanist."
)

local human_character = assert(profiles:get_character(5201, 1))
check(
    human_character.Identity.ClassId == "Mage"
        and human_character.Identity.BaseClassId == "Mage",
    "Advancement must preserve accepted Mage base-family identity."
)
check(
    human_character.ClassAdvancement.ActiveClassId == "HumanArcanist",
    "Human advanced identity must persist separately."
)
check(
    human_character.ClassAdvancement.CompletedByRace.Human.HumanArcanist
        == true,
    "Human advancement history must persist by race."
)
check(
    human_character.Quests.Active.MageAdvancementTrial == nil
        and human_character.Quests.Completed.MageAdvancementTrial == true,
    "Claim must atomically consume the ready quest into Completed."
)

local duplicate_claim = base:claim(5201)
check(
    duplicate_claim.ok == false
        and duplicate_claim.reason == "AdvancementAlreadyCompleted",
    "Duplicate Human advancement claim must reject."
)

check(base:start_trial(5202).ok == true, "Elf Mage trial must start.")
check(quests:record_event(5202, {
    EventId = "elf-session:DungeonClear",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
}).ok == true, "Elf Temple clear must progress quest.")

local elf_claim = base:claim(5202)
check(elf_claim.ok == true, "Ready Elf Mage advancement must claim.")
check(
    elf_claim.class_id == "ElfSpellweaver",
    "Elf Mage must advance to ElfSpellweaver."
)
local elf_character = assert(profiles:get_character(5202, 1))
check(
    elf_character.ClassAdvancement.ActiveClassId == "ElfSpellweaver",
    "Elf advanced identity must persist."
)
check(
    elf_character.ClassAdvancement.CompletedByRace.Elf.ElfSpellweaver
        == true,
    "Elf advancement history must persist by race."
)

local race_change = RaceChangeService.new(profiles, "TEST", function() return 888 end)
local elf_preview = race_change:preview(5201, "Elf")
check(elf_preview.ok == true, "Human advanced Mage must preview Elf Race Change.")
check(race_change:apply(5201, "Elf", elf_preview.Hash, "adv-human-to-elf").ok == true,
    "Human advanced Mage must apply Elf Race Change.")
local changed_snapshot = base:build_snapshot(5201)
check(changed_snapshot.ActiveClassId == nil,
    "HumanArcanist completion must not activate as an Elf class.")
check(changed_snapshot.CandidateClassId == "ElfSpellweaver" and changed_snapshot.Completed == false,
    "Human advancement must not manufacture equivalent Elf completion.")
check(assert(profiles:get_character(5201, 1)).ClassAdvancement.CompletedByRace.Human.HumanArcanist == true,
    "Human advancement history must remain stored while Elf.")

local human_preview = race_change:preview(5201, "Human")
check(human_preview.ok == true, "Elf Mage must preview return to Human.")
check(race_change:apply(5201, "Human", human_preview.Hash, "adv-elf-to-human").ok == true,
    "Elf Mage must return to Human.")
local restored_snapshot = base:build_snapshot(5201)
check(restored_snapshot.ActiveClassId == "HumanArcanist" and restored_snapshot.Completed == true,
    "Returning race must reactivate historical Human advancement without re-claiming.")

print(string.format("[Class Advancement Tests] PASS: %d assertions.", assertions))
