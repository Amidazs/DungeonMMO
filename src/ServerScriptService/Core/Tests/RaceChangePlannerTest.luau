--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local RaceChangePlanner = require(Services:WaitForChild("RaceChangePlanner"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Race Change Planner Tests] " .. message, 2) end
end

local function base_character(race_id: string): any
    local profile = ProfileSchema.create_default(8101)
    local character = profile.Characters.Slot1
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = "Rogue",
        ClassId = "Rogue",
        CreationStage = "Complete",
    }
    character.Progression.SkillPointEntitlement = 30
    character.Progression.Attributes = if race_id == "Human"
        then {Strength=7,Dexterity=5,Vitality=7,Intellect=5,Spirit=5}
        else {Strength=7,Dexterity=8,Vitality=5,Intellect=5,Spirit=5}
    character.ClassAdvancement = {
        Version = 1,
        CompletedByRace = {
            Human = {HumanRogueDuelist = true},
            Elf = {ElfRogueWindstalker = true},
        },
        ActiveClassId = if race_id == "Human" then "HumanRogueDuelist" else "ElfRogueWindstalker",
    }
    return character
end
local human = base_character("Human")
human.Progression.Skills.QuickStrike = {
    Known = true, StarterGranted = true, PurchasedRank = 1, Proficiency = 50,
}
human.Progression.Skills.DuelistDeadlyBlow = {
    Known = true, StarterGranted = false, PurchasedRank = 2, Proficiency = 250,
}
human.Progression.Loadout[1] = "QuickStrike"
human.Progression.Loadout[2] = "DuelistDeadlyBlow"
human.RaceChange.ArchivedByRace.Elf = {
    Skills = {
        WindstalkerFlurry = {
            Known = true, StarterGranted = false, PurchasedRank = 2, Proficiency = 300,
        },
    },
    Advancement = {},
}

local first = RaceChangePlanner.preview(human, "Elf")
local second = RaceChangePlanner.preview(human, "Elf")
check(first.ok == true, "Human Rogue -> Elf preview must be allowed.")
check(first.Hash == second.Hash, "Identical input must produce deterministic preview hash.")
check(first.TargetActiveClassId == "ElfRogueWindstalker",
    "Completed Elf advancement must become target active class.")
check(#first.SkillsToArchive == 1 and first.SkillsToArchive[1] == "DuelistDeadlyBlow",
    "Human Duelist-only skill must be archived.")
check(#first.SkillsToRestore == 1 and first.SkillsToRestore[1] == "WindstalkerFlurry",
    "Compatible archived Elf skill must be offered for restoration.")
check(first.RefundableSP == 6,
    "Two purchased Rare ranks must release 6 allocated SP.")
check(#first.LoadoutSlotsToClear == 1 and first.LoadoutSlotsToClear[1] == 2,
    "Archived active skill must be removed from loadout.")
check(first.TargetAttributes.Strength == 7 and first.TargetAttributes.Dexterity == 7,
    "Attribute deltas must translate onto the target race baseline.")
local elf = base_character("Elf")
elf.Equipment.Helmet = "test_elf_helmet"
local to_human = RaceChangePlanner.preview(elf, "Human")
check(to_human.ok == true, "Elf Rogue -> Human preview must be allowed.")
check(#to_human.EquipmentSlotsToUnequip == 1
        and to_human.EquipmentSlotsToUnequip[1] == "Helmet",
    "Race-invalid equipped item must be listed for unequip.")

local same = RaceChangePlanner.preview(human, "Human")
check(same.ok == false and same.reason == "SameRace",
    "Same-race preview must reject.")
local unknown = RaceChangePlanner.preview(human, "Orc")
check(unknown.ok == false and unknown.reason == "UnknownRace",
    "Unknown target race must reject.")
local incomplete = ProfileSchema.create_default(8102).Characters.Slot1
local incomplete_result = RaceChangePlanner.preview(incomplete, "Elf")
check(incomplete_result.ok == false and incomplete_result.reason == "IdentityIncomplete",
    "Incomplete identity must reject.")

check(human.Progression.Skills.DuelistDeadlyBlow.Known == true,
    "Preview must not mutate source skill knowledge.")
check(human.Identity.RaceId == "Human", "Preview must not mutate source identity.")

print(string.format("[Race Change Planner Tests] PASS: %d assertions.", assertions))
