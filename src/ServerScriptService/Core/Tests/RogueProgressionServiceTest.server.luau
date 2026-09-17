--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(
    Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(Services:WaitForChild("ProfileService"))
local IdentityService = require(Services:WaitForChild("IdentityService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local LoadoutService = require(Services:WaitForChild("LoadoutService"))
local SkillProgressionService = require(
    Services:WaitForChild("SkillProgressionService")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Rogue Progression Tests] " .. message, 2)
    end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(73101))
local identity = IdentityService.new(profiles)
check(identity:select_race(73101, "Human").ok == true, "Human race selection failed.")
check(identity:select_base_class(73101, "Rogue").ok == true, "Rogue class selection failed.")

local character = assert(profiles:get_character(73101, 1))
check(character.Identity.BaseClassId == "Rogue", "Rogue base identity must persist.")
check(character.Identity.ClassId == "Rogue", "Rogue current identity must remain base class.")
check(character.Progression.Skills.QuickStrike.Known == true, "Quick Strike starter missing.")
check(character.Progression.Skills.Backstab.Known == true, "Backstab starter missing.")
check(character.Progression.Skills.EvasiveStep.Known == true, "Evasive Step starter missing.")
check(character.Equipment.Weapon == "marauder_sword", "Rogue starter sword must equip.")

assert(profiles:mutate(73101, function(profile: any)
    local live = profile.Characters.Slot1
    live.Progression.SkillPointEntitlement = 20
end))

local loadout = LoadoutService.new(profiles)
local inventory = InventoryService.new(profiles)
local skills = SkillProgressionService.new(profiles, inventory, loadout)

local learned_feint = skills:learn_trainer_skill(73101, "Feint")
check(learned_feint.ok == true, "Rogue trainer skill must learn without a Skill Book.")
character = assert(profiles:get_character(73101, 1))
check(character.Progression.Skills.Feint.Known == true, "Feint knowledge must persist.")
local learned_passive = skills:learn_trainer_skill(73101, "CriticalFocus")
check(learned_passive.ok == true, "Rogue passive must learn through trainer progression.")
character = assert(profiles:get_character(73101, 1))
check(character.Progression.Skills.CriticalFocus.Known == true, "Critical Focus must persist.")

local passive_loadout = loadout:set(73101, {"CriticalFocus"}, "Base")
check(
    passive_loadout.ok == false
        and passive_loadout.reason == "PassiveSkillNotLoadoutEligible",
    "Passive skills must not occupy active loadout slots."
)

local wrong_class = profiles:load(73102)
check(wrong_class == true, "Fighter fixture profile load failed.")
check(identity:select_race(73102, "Human").ok == true, "Fighter fixture race failed.")
check(identity:select_base_class(73102, "Fighter").ok == true, "Fighter fixture class failed.")
local fighter_learn = skills:learn_trainer_skill(73102, "Feint")
check(
    fighter_learn.ok == false and fighter_learn.reason == "ClassCannotTeachSkill",
    "Non-Rogue must not learn Rogue trainer skills."
)

print(string.format("[Rogue Progression Tests] PASS: %d assertions.", assertions))
