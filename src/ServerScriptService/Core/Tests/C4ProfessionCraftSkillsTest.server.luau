--!strict
-- Real C4 first-tier trainer purchase, blueprint reading and crafting.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Core = SSS.Core

local Profiles = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local Skills = require(Core.Services.SkillProgressionService)
local Professions = require(Core.Services.ProfessionService)
local Knowledge = require(Core.Services.RecipeKnowledgeService)
local Trainers = require(Shared.TrainerCatalogues)
local C4Rules = require(Shared.C4ProfessionSkillRules)

local assertions = 0
local SPECS = {
    {99101, "Fighter", "Human", "Mining", "Blacksmithing",
        "c4_common_iron_bar", "iron_ore", 1, nil, nil, "iron_bar"},
    {99102, "Mage", "Elf", "Herbalism", "Alchemy",
        "c4_common_tempering_oil", "silverleaf", 2,
        nil, nil, "tempering_oil"},
    {99103, "Fighter", "Elf", "Skinning", "Leatherworking",
        "c4_common_cured_leather", "raw_hide", 2,
        "tempering_oil", 1, "cured_leather"},
    {99104, "Mage", "Human", "Mining", "Enchanting",
        "c4_common_warding_rune", "warding_essence", 1,
        nil, nil, "warding_rune"},
}

--[[
Checks a genuine selected-career and purchased-skill invariant.

Args:
    condition (boolean): Expected server-owned outcome.
    description (string): Focused Studio diagnostic.

Returns:
    nil: Adds a passing assertion or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Profession Skills] " .. description)
end

--[[
Loads a character with an earned-style skill point budget and class.

Args:
    profiles (any): Isolated server profile service.
    spec (any): Source race/class and distinct crafting career row.

Returns:
    nil: Establishes an authoritative server character for the test.
]]
local function seed(profiles: any, spec: any)
    local owner = spec[1]
    check(profiles:load(owner), "Isolated source character must load")
    check(profiles:mutate(owner, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = spec[3],
            BaseClassId = spec[2],
            ClassId = spec[2],
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 100
        character.Level = 1
    end), "Source character identity and points must persist")
end

--[[
Checks that only the selected career can grant the source passive.

Args:
    spec (any): One Fighter or Mage/crafting profession tuple.
    context (any): Real trainer, profile and profession services.

Returns:
    nil: Buys literacy and denies both missing choice and early rank 5.
]]
local function train_literacy(spec: any, context: any)
    local owner = spec[1]
    local trainer = if spec[2] == "Mage"
        then "MageTrainer" else "FighterTrainer"
    local character = assert(context.Profiles:get_character(owner, 1))
    check(not Trainers.can_offer(
        trainer, character, "C4RecipeReading"
    ).ok, "Reading cannot be trained before choosing crafting")
    check(not context.Skills:learn_trainer_skill(
        owner, "C4RecipeReading"
    ).ok, "Direct trainer request must not skip profession choice")

    check(context.Professions:choose_profession(owner, spec[4]).ok,
        "Gathering slot must accept its first choice")
    check(context.Professions:choose_profession(owner, spec[5]).ok,
        "Creation slot must accept its independent first choice")
    character = assert(context.Profiles:get_character(owner, 1))
    check(Trainers.can_offer(
        trainer, character, "C4RecipeReading"
    ).ok, "Source trainer must offer recipe literacy after selection")
    check(context.Skills:learn_trainer_skill(
        owner, "C4RecipeReading"
    ).ok, "Real trainer purchase must grant recipe literacy")
    check(C4Rules.can_read(
        assert(context.Profiles:get_character(owner, 1)), spec[5]
    ), "Purchased literacy must authorize only selected career")
    check(not context.Skills:learn_trainer_skill(
        owner, "C4CommonItemCreation"
    ).ok, "Source level-five rank must reject level one")
    check(not context.Professions:prepare_craft(
        owner, spec[6]
    ).ok, "Common crafting must reject before its actual purchased rank")
end

--[[
Purchases the rank-five passive and crafts a real inventory output.

Args:
    spec (any): Career-specific material and recipe quantities.
    context (any): Actual inventory, trainer and profession authorities.

Returns:
    nil: Verifies input consumption, output grant and forbidden career.
]]
local function craft_common(spec: any, context: any)
    local owner = spec[1]
    check(context.Profiles:mutate(owner, function(profile: any)
        profile.Characters.Slot1.Level = 5
    end), "Character must reach C4 source level five")
    local trainer = if spec[2] == "Mage"
        then "MageTrainer" else "FighterTrainer"
    local character = assert(context.Profiles:get_character(owner, 1))
    check(Trainers.can_offer(
        trainer, character, "C4CommonItemCreation"
    ).ok, "Bought literacy must reveal common-item skill at level five")
    check(context.Skills:learn_trainer_skill(
        owner, "C4CommonItemCreation"
    ).ok, "Actual trainer must sell common-item creation")

    check(context.Inventory:add_item(owner, spec[7], spec[8]).ok,
        "Selected career requires genuine server-owned input")
    if spec[9] then
        check(context.Inventory:add_item(owner, spec[9], spec[10]).ok,
            "Cross-career input must enter inventory")
    end
    local prepared = context.Professions:prepare_craft(owner, spec[6])
    check(prepared.ok, "Selected profession must prepare its common recipe")
    check(context.Professions:craft(owner, spec[6]).ok,
        "Purchased skill must craft genuine material-backed output")
    character = assert(context.Profiles:get_character(owner, 1))
    check(Inventory.count_item(character, spec[7]) == 0,
        "Common craft must consume its exact principal input")
    check(Inventory.count_item(character, spec[11]) == 1,
        "Common craft must grant its exact authored output")
    if spec[9] then
        check(Inventory.count_item(character, spec[9]) == 0,
            "Common craft cannot duplicate purchased secondary input")
    end
    check(character.ProfessionSlots.Creation == spec[5],
        "Common creation must not grant a second creation slot")
    local other_recipe = if spec[5] == "Blacksmithing"
        then "c4_common_tempering_oil" else "c4_common_iron_bar"
    local denial = context.Professions:prepare_craft(owner, other_recipe)
    check(not denial.ok and denial.reason == "ProfessionNotSelected",
        "Forged recipe must not cross the owned crafting profession")
end

--[[
Verifies blueprint study depends on the actually purchased reading rank.

Args:
    context (any): Real smith, inventory and knowledge authorities.

Returns:
    nil: Denies untrained reading, then learns and crafts a real blueprint.
]]
local function study_blueprint(context: any)
    local owner = 99105
    seed(context.Profiles, {
        owner, "Fighter", "Human", "Mining", "Blacksmithing",
    })
    check(context.Professions:choose_profession(
        owner, "Blacksmithing"
    ).ok, "Blueprint owner chooses Blacksmithing")
    check(context.Profiles:mutate(owner, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 5
        character.Professions.Blacksmithing.XP = 30
    end), "Blueprint owner earns level-two Blacksmithing")
    check(context.Inventory:add_item(
        owner, "blacksmith_iron_guard_blueprint", 1
    ).ok, "Blueprint enters real inventory")
    local unread = context.Knowledge:learn_from_item(
        owner, "blacksmith_iron_guard_blueprint"
    )
    check(not unread.ok
        and unread.reason == "RecipeReadingNotLearned",
        "A selected smith cannot consume a blueprint without reading")
    check(context.Skills:learn_trainer_skill(
        owner, "C4RecipeReading"
    ).ok, "Smith purchases real literacy at the trainer")
    local learned = context.Knowledge:learn_from_item(
        owner, "blacksmith_iron_guard_blueprint"
    )
    check(learned.ok, "Real learned literacy must consume the blueprint")
    local character = assert(context.Profiles:get_character(owner, 1))
    check(Inventory.count_item(
        character, "blacksmith_iron_guard_blueprint"
    ) == 0, "One successfully read blueprint was consumed once")
    check(character.CraftingKnowledge.LearnedRecipes[
        "blacksmith_iron_guard_blueprint"
    ] == true, "Recipe reading records actual persistent recipe knowledge")
end

--[[
Runs focused genuine Trainer -> Profession -> Inventory acceptance.

Args:
    None.

Returns:
    nil: Prints the new C4 rank and actual craft assertion count.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local inventory = Inventory.new(profiles)
    local context = {
        Profiles = profiles,
        Inventory = inventory,
        Professions = Professions.new(profiles, inventory),
        Knowledge = Knowledge.new(profiles, inventory),
        Skills = Skills.new(
            profiles, inventory, Loadout.new(profiles)
        ),
    }
    for _, spec in ipairs(SPECS) do
        seed(profiles, spec)
        train_literacy(spec, context)
        craft_common(spec, context)
    end
    study_blueprint(context)
    print(("[C4 Profession Skills] PASS: %d assertions.")
        :format(assertions))
end

main()
