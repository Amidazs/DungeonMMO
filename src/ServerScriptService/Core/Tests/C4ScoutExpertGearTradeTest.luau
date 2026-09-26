--!strict
-- A genuine single-career Leatherworker crafts expert gear for a Rogue.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Entities = require(SSS.Core.Adapters.InMemoryEntityAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Inventory = require(SSS.Core.Services.InventoryService)
local Professions = require(SSS.Core.Services.ProfessionService)
local Market = require(SSS.Core.Services.MarketService)
local Equipment = require(SSS.Core.Services.EquipmentService)
local Skills = require(SSS.Core.Services.SkillProgressionService)
local Loadout = require(SSS.Core.Services.LoadoutService)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Recipe = require(RS.Core.Shared.ProfessionRecipes)

local SELLER = 99385
local BUYER = 99386
local VEST_ID = "scout_expert_leather_vest"
local checks = 0

--[[
Records a genuine independent-profession or real equipping assertion.

Args:
    condition (boolean): Required actual economy or equipment action.
    description (string): Specific rejection or persistence failure.

Returns:
    nil: Counts the assertion or fails the actual Studio test.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 Expert Gear Trade] " .. description)
end

--[[
Creates two separate real profile holders on the same economy adapter.

Args:
    None.

Returns:
    any: Real inventory, crafting, market, skill and equipment services.
]]
local function create_services(): any
    local profiles = Profiles.new(Adapter.new())
    local inventory = Inventory.new(profiles)
    local next_id = 0
    return {
        Profiles = profiles,
        Inventory = inventory,
        Profession = Professions.new(profiles, inventory),
        Market = Market.new(
            Entities.new(), profiles, function(): number
                return 1000
            end, function(): string
                next_id += 1
                return "scout-vest-trade-" .. tostring(next_id)
            end
        ),
        Skill = Skills.new(
            profiles, inventory, Loadout.new(profiles)
        ),
        Equipment = Equipment.new(profiles, "Base"),
    }
end

--[[
Prepares one source character with only its own gathering/crafting choices.

Args:
    context (any): Real authoritative services.
    owner (number): Seller or buyer independent profile.
    race_id (string): Authored original race.
    class_id (string): Original class branch.
    gathering_id (string): One chosen gathering profession.
    creation_id (string): One chosen crafting profession.

Returns:
    nil: Persists identity, gold and the two exclusive career selections.
]]
local function prepare_character(
    context: any, owner: number, race_id: string, class_id: string,
    gathering_id: string, creation_id: string
)
    check(context.Profiles:load(owner), "Source profile must load")
    check(context.Profiles:mutate(owner, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = race_id,
            BaseClassId = class_id, ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Level = 20
        character.Gold = 1500
        character.Progression.SkillPointEntitlement = 250
    end), "Selected class identity and economy must save")
    check(context.Profession:choose_profession(
        owner, gathering_id
    ).ok, "One gathering career must be chosen")
    check(context.Profession:choose_profession(
        owner, creation_id
    ).ok, "One independent crafting career must be chosen")
end

--[[
Produces one actual expert vest by consuming other-profession ingredients.

Args:
    context (any): Real Level-two Leatherworking crafting authority.

Returns:
    nil: Checks material debit, crafted output and actual profession XP.
]]
local function craft_vest(context: any)
    local recipe = assert(Recipe.get("stitch_scout_expert_vest"))
    check(context.Profiles:mutate(SELLER, function(profile: any)
        profile.Characters.Slot1.Professions.Leatherworking.XP = 30
    end), "Disposable Leatherworking level-two source XP must save")
    for _, ingredient in ipairs(recipe.Inputs) do
        check(context.Inventory:add_item(
            SELLER, ingredient.ItemId, ingredient.Quantity
        ).ok, "Seller must receive test starting ingredients")
    end
    local prepared = context.Profession:prepare_craft(
        SELLER, recipe.Id
    )
    check(prepared.ok, "Seller must prepare authentic vest recipe")
    local output = context.Profession:complete_craft(
        SELLER, recipe.Id,
        Professions.foundation_success_outcome(prepared.minigame_id)
    )
    check(output.ok and output.xp == recipe.XP,
        "Actual material-consuming minigame must craft the expert vest")
    local seller = assert(context.Profiles:get_character(SELLER, 1))
    check(Inventory.count_item(seller, VEST_ID) == 1,
        "One actual expert vest must exist in the crafter inventory")
    for _, ingredient in ipairs(recipe.Inputs) do
        check(Inventory.count_item(seller, ingredient.ItemId) == 0,
            "The real crafted output must consume every ingredient")
    end
end

--[[
Trades the manufactured vest and equips only after real Rogue training.

Args:
    context (any): Actual shared seller/buyer economy and equipment authority.

Returns:
    nil: Confirms profession-exclusive crafting and purchased gear gating.
]]
local function trade_and_equip(context: any)
    check(not context.Profession:prepare_craft(
        BUYER, "stitch_scout_expert_vest"
    ).ok, "Rogue with Blacksmithing cannot craft Leatherworking items")
    local listing = context.Market:create_listing(
        SELLER, VEST_ID, 1, 100, "scout-vest-selling"
    )
    check(listing.ok, "Real seller must escrow the manufactured vest")
    check(context.Market:buy(
        BUYER, listing.listing.ListingId, "scout-vest-purchase"
    ).ok, "Other career must purchase the genuine escrowed vest")
    local buyer = assert(context.Profiles:get_character(BUYER, 1))
    check(Inventory.count_item(buyer, VEST_ID) == 1,
        "Actual marketplace must deliver the craft to its new owner")
    check(Inventory.count_item(
        assert(context.Profiles:get_character(SELLER, 1)), VEST_ID
    ) == 0, "The seller must not retain the sold gear")
    check(context.Equipment:equip(BUYER, VEST_ID, "Body").reason
        == "ScoutEquipmentExpertiseRequired",
        "Actual traded gear cannot equip before paid C4 expertise")
    check(context.Skill:learn_trainer_skill(
        BUYER, "ScoutEquipmentExpertise"
    ).ok, "Buyer must genuinely train its own source equipment rank")
    Runtime.set_character(BUYER, buyer)
    local before = Runtime.get_max_health(BUYER)
    check(context.Equipment:equip(BUYER, VEST_ID, "Body").ok,
        "After buying the source rank, actual market gear must equip")
    buyer = assert(context.Profiles:get_character(BUYER, 1))
    Runtime.set_character(BUYER, buyer)
    check(Runtime.get_max_health(BUYER) == before + 12,
        "Real traded and equipped expert gear must add twelve maximum HP")
    check(buyer.ProfessionSlots.Creation == "Blacksmithing"
        and buyer.ProfessionSlots.Gathering == "Mining",
        "Traded expert gear must not silently add Leatherworking career")
    Runtime.clear_character(BUYER)
end

--[[
Runs authenticated one-gathering/one-crafting production and real market.

Args:
    None.

Returns:
    nil: Prints actual material, trade and paid equipment assertion total.
]]
local function main()
    local context = create_services()
    prepare_character(
        context, SELLER, "Elf", "Ranger", "Skinning", "Leatherworking"
    )
    prepare_character(
        context, BUYER, "Human", "Rogue", "Mining", "Blacksmithing"
    )
    craft_vest(context)
    trade_and_equip(context)
    print(("[C4 Expert Gear Trade] PASS: %d assertions")
        :format(checks))
end

main()
