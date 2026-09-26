--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local QuestService = require(Services:WaitForChild("QuestService"))
local ClassAdvancementService = require(Services:WaitForChild("ClassAdvancementService"))
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))
local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Rogue Advancement Tests] " .. message, 2)
    end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
local quests = QuestService.new(profiles)
local advancement = ClassAdvancementService.new(profiles, quests, "Base")
local function prepare(user_id: number, race_id: string)
    assert(profiles:load(user_id))
    assert(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = "Rogue",
            ClassId = "Rogue",
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 60
        for _, required in ipairs(
            QuestDefinitions.get("RogueAdvancementTrial")
                .SkillPrerequisites
        ) do
            character.Progression.Skills[required.SkillId] = {
                Known = true,
                StarterGranted = false,
                PurchasedRank = required.Rank,
                Proficiency = required.Proficiency,
            }
        end
    end))
end

prepare(73201, "Human")
prepare(73202, "Elf")

for _, user_id in ipairs({73201, 73202}) do
    local started = advancement:start_trial(user_id)
    check(started.ok == true, "Rogue advancement trial must start.")
    check(started.quest_id == "RogueAdvancementTrial", "Rogue trial id mismatch.")
    check(quests:record_event(user_id, {
        EventId = tostring(user_id) .. ":mine-clear",
        Type = "DungeonClear",
        TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
        Amount = 1,
    }).ok == true, "Abandoned Mine clear must progress Rogue trial.")
end
local human = advancement:claim(73201)
local elf = advancement:claim(73202)
check(human.ok == true and human.class_id == "HumanRogueDuelist", "Human Rogue must become Duelist.")
check(elf.ok == true and elf.class_id == "ElfRogueWindstalker", "Elf Rogue must become Windstalker.")

local human_character = assert(profiles:get_character(73201, 1))
local elf_character = assert(profiles:get_character(73202, 1))
check(
    human_character.Identity.ClassId == "Rogue"
        and human_character.ClassAdvancement.ActiveClassId == "HumanRogueDuelist",
    "Human secondary class must remain separate from base identity."
)
check(
    elf_character.Identity.ClassId == "Rogue"
        and elf_character.ClassAdvancement.ActiveClassId == "ElfRogueWindstalker",
    "Elf secondary class must remain separate from base identity."
)
check(
    human_character.ClassAdvancement.CompletedByRace.Human.HumanRogueDuelist == true,
    "Human Rogue advancement history must persist by race."
)
check(
    elf_character.ClassAdvancement.CompletedByRace.Elf.ElfRogueWindstalker == true,
    "Elf Rogue advancement history must persist by race."
)

print(string.format("[Rogue Advancement Tests] PASS: %d assertions.", assertions))
