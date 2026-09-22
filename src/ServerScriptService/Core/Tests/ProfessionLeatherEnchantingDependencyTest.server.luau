--!strict
-- Four isolated characters must trade, not learn extra professions.
local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Core.Adapters.InMemoryEntityAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Market = require(Core.Services.MarketService)

local SMITH = 67101
local ALCHEMIST = 67102
local LEATHERWORKER = 67103
local ENCHANTER = 67104
local assertions = 0

--[[
Checks a real service result with a useful failure explanation.

Args:
    condition (boolean): Required server-owned invariant.
    label (string): Description of the assertion.

Returns:
    nil: Records the passing assertion or raises on failure.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[Leather/Enchant Trade] " .. label)
end

--[[
Creates four different character careers and a real escrow market.

Args:
    None.

Returns:
    any: Four loaded profiles and their real profession/market services.
]]
local function setup(): any
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)
    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)
    local next_id = 0
    local market = Market.new(
        EntityAdapter.new(), profiles,
        function(): number return 1000 end,
        function(): string
            next_id += 1
            return "leather-trade-" .. tostring(next_id)
        end
    )
    local choices = {
        {SMITH, "Mining", "Blacksmithing"},
        {ALCHEMIST, "Herbalism", "Alchemy"},
        {LEATHERWORKER, "Skinning", "Leatherworking"},
        {ENCHANTER, "Mining", "Enchanting"},
    }
    for _, choice in ipairs(choices) do
        local owner = choice[1]
        check(profiles:load(owner), "Character loads")
        check(professions:choose_profession(owner, choice[2]).ok,
            "Gathering choice succeeds")
        check(professions:choose_profession(owner, choice[3]).ok,
            "Creation choice succeeds")
        check(profiles:mutate(owner, function(profile: any)
            profile.Characters.Slot1.Gold = 500
        end), "Buyer receives disposable test gold")
    end
    return {
        Adapter = adapter,
        Profiles = profiles,
        Inventory = inventory,
        Professions = professions,
        Market = market,
    }
end

--[[
Returns the authoritative count in one character's inventory.

Args:
    context (any): Loaded authoritative profile service.
    user_id (number): Owner of the inventory.
    item_id (string): Registered inventory item.

Returns:
    number: The number of items actually owned.
]]
local function quantity(context: any, user_id: number, item_id: string): number
    return Inventory.count_item(
        assert(context.Profiles:get_character(user_id, 1)), item_id
    )
end

--[[
Gathers one selected resource per authoritative service call.

Args:
    context (any): Real profession service.
    owner (number): Selected gatherer.
    profession_id (string): Its one gathering profession.
    item_id (string): Valid authored material.
    amount (number): Number of independent gathers.

Returns:
    nil: Fails if any resource or XP grant is rejected.
]]
local function gather(
    context: any, owner: number, profession_id: string,
    item_id: string, amount: number
)
    for _ = 1, amount do
        check(context.Professions:gather(owner, {
            ProfessionId = profession_id, ItemId = item_id,
            Quantity = 1, XP = 8,
        }).ok, "Selected gatherer produces " .. item_id)
    end
end

--[[
Executes the selected crafting profession's real recipe.

Args:
    context (any): Real crafting service.
    owner (number): Selected craftsperson.
    recipe_id (string): Authored recipe name.

Returns:
    nil: Verifies the full authoritative craft succeeded.
]]
local function craft(context: any, owner: number, recipe_id: string)
    check(context.Professions:craft(owner, recipe_id).ok,
        "Selected crafter completes " .. recipe_id)
end

--[[
Moves a career-specific input using the real market escrow and buyer.

Args:
    context (any): Real marketplace and profile services.
    seller (number): Character who currently owns the item.
    buyer (number): Other character buying the item.
    item_id (string): Tradeable ingredient or equipment.
    amount (number): Exact quantity being sold.

Returns:
    nil: Proves the item changes hands once without a fake inventory grant.
]]
local function trade(
    context: any, seller: number, buyer: number,
    item_id: string, amount: number
)
    local reference = tostring(seller) .. "-" .. tostring(buyer)
        .. "-" .. item_id
    local seller_before = quantity(context, seller, item_id)
    local buyer_before = quantity(context, buyer, item_id)
    local listed = context.Market:create_listing(
        seller, item_id, amount, 100, "list-" .. reference
    )
    check(listed.ok, "Seller lists owned " .. item_id)
    check(context.Market:buy(
        buyer, listed.listing.ListingId, "buy-" .. reference
    ).ok, "Buyer purchases the genuine market listing")
    check(quantity(context, seller, item_id) == seller_before - amount,
        "Seller loses only the sold quantity")
    check(quantity(context, buyer, item_id) == buyer_before + amount,
        "Buyer receives only the purchased quantity")
end

--[[
Builds four-bar, nine-herb and three-hide cross-career inputs.

Args:
    context (any): Four real selected-career services.

Returns:
    nil: Uses market purchases to prepare Leatherworking equipment.
]]
local function prepare_goods(context: any)
    gather(context, SMITH, "Mining", "iron_ore", 8)
    gather(context, ALCHEMIST, "Herbalism", "silverleaf", 9)
    gather(context, LEATHERWORKER, "Skinning", "raw_hide", 3)
    for _ = 1, 4 do
        craft(context, SMITH, "smelt_iron_bar")
    end
    check(quantity(context, SMITH, "iron_bar") == 4,
        "Four iron bars came from the only selected smith")
    trade(context, SMITH, LEATHERWORKER, "iron_bar", 1)
    trade(context, SMITH, ALCHEMIST, "iron_bar", 2)
    trade(context, SMITH, ENCHANTER, "iron_bar", 1)
    craft(context, ALCHEMIST, "distill_tempering_oil")
    trade(context, ALCHEMIST, LEATHERWORKER, "tempering_oil", 1)
    craft(context, LEATHERWORKER, "cure_raw_hide")
    craft(context, LEATHERWORKER, "stitch_leatherbound_gloves")
    trade(context, LEATHERWORKER, ENCHANTER,
        "leatherbound_gloves", 1)
end

--[[
Makes a final enchant require both Alchemy and Leatherworking trades.

Args:
    context (any): Four real players' inventory, profession and market.

Returns:
    nil: Verifies production, equipped-item denial and nonduplication.
]]
local function complete_enchant(context: any)
    craft(context, ALCHEMIST, "distill_forging_flux")
    craft(context, ALCHEMIST, "distill_warding_essence")
    craft(context, ALCHEMIST, "distill_forging_flux")
    trade(context, ALCHEMIST, ENCHANTER, "warding_essence", 1)
    trade(context, ALCHEMIST, ENCHANTER, "forging_flux", 1)
    craft(context, ENCHANTER, "inscribe_warding_rune")

    check(context.Profiles:mutate(ENCHANTER, function(profile: any)
        profile.Characters.Slot1.Equipment.Gloves = "leatherbound_gloves"
    end), "Enchanting test equips the source equipment")
    local denied = context.Professions:craft(
        ENCHANTER, "enchant_leatherbound_gloves"
    )
    check(not denied.ok and denied.reason == "IngredientEquipped",
        "Enchanting cannot consume equipped source equipment")
    check(context.Profiles:mutate(ENCHANTER, function(profile: any)
        profile.Characters.Slot1.Equipment.Gloves = nil
    end), "Enchanting test unequips source equipment")
    craft(context, ENCHANTER, "enchant_leatherbound_gloves")
    check(quantity(context, ENCHANTER,
        "warded_leatherbound_gloves") == 1,
        "Market-dependent enchanted equipment exists exactly once")
    check(quantity(context, ENCHANTER, "forging_flux") == 0
        and quantity(context, ENCHANTER, "warding_rune") == 0
        and quantity(context, ENCHANTER, "leatherbound_gloves") == 0,
        "All three purchased/crafted components were consumed")
    check(not context.Professions:can_use(ENCHANTER, "Alchemy")
        and not context.Professions:can_use(
            ALCHEMIST, "Leatherworking"),
        "Market trading never unlocks another crafting career")
end

--[[
Runs the isolated real-market four-profession integration test.

Args:
    None.

Returns:
    nil: Reports targeted assertions and no old dungeon-suite results.
]]
local function main()
    local context = setup()
    prepare_goods(context)
    complete_enchant(context)
    print(("[Leather/Enchant Trade] PASS: %d assertions.")
        :format(assertions))
end

main()
