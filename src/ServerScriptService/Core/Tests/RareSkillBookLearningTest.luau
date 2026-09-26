--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local LoadoutService = require(Services:WaitForChild("LoadoutService"))
local SkillProgressionService = require(Services:WaitForChild("SkillProgressionService"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Rare Skill Book Learning Tests] " .. message, 2)
    end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(9801))
assert(profiles:load(9802))

local function seed(user_id: number, class_id: string)
    assert(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = class_id,
            ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 10
        character.Progression.Skills = {}
        character.Progression.Loadout = {}
    end))
end

seed(9801, "Fighter")
seed(9802, "Mage")

local inventory = InventoryService.new(profiles)
local loadout = LoadoutService.new(profiles)
local skills = SkillProgressionService.new(profiles, inventory, loadout)

check(inventory:add_item(9801, "arc_slash_book", 1).ok, "Fighter must be able to own tradable book.")
check(inventory:add_item(9802, "arc_slash_book", 1).ok, "Mage must be able to own off-class tradable book.")

local fighter = skills:learn_skill(9801, "ArcSlash", "arc_slash_book")
check(fighter.ok == true, "Fighter must learn Arc Slash from new tradable book.")
check(
    InventoryService.count_item(assert(profiles:get_character(9801, 1)), "arc_slash_book") == 0,
    "successful learning must consume one book."
)

local mage = skills:learn_skill(9802, "ArcSlash", "arc_slash_book")
check(
    mage.ok == false and mage.reason == "ClassCannotTeachSkill",
    "Mage must not learn Fighter Arc Slash."
)
check(
    InventoryService.count_item(assert(profiles:get_character(9802, 1)), "arc_slash_book") == 1,
    "rejected off-class learning must preserve book."
)

check(inventory:add_item(9801, "arc_slash_book", 2).ok, "known Fighter may still own duplicate books.")
check(
    InventoryService.count_item(assert(profiles:get_character(9801, 1)), "arc_slash_book") == 2,
    "duplicate tradable books must stack."
)

print(string.format("[Rare Skill Book Learning Tests] PASS: %d assertions.", assertions))
