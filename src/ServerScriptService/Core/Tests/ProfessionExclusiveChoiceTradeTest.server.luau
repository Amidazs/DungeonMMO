--!strict
-- Two real isolated characters must trade across exclusive professions.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Core = SSS.Core

local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Market = require(Core.Services.MarketService)
local Migration = require(Core.Services.ProfileMigration)
local Schema = require(Shared.ProfileSchema)
local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Core.Adapters.InMemoryEntityAdapter)

local checks = 0
local SELLER = 932101
local BUYER = 932102

--[[
Asserts one profession ownership, migration or real trade invariant.

Args:
    condition (boolean): Expected server-authoritative result.
    description (string): Failure context for the targeted Studio run.

Returns:
    nil: Counts the check or raises immediately.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[Profession Exclusive Choice] " .. description)
end

--[[
Builds an in-memory, two-character test economy.

Args:
    None.

Returns:
    any: Loaded shared profiles and profession service.
    any: Authoritative inventory service.
    any: Existing market service, not a mocked trade grant.
]]
local function make_services(): (any, any, any)
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)
    check(profiles:load(SELLER), "Seller profile must load")
    check(profiles:load(BUYER), "Buyer profile must load")
    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)
    local serial = 0
    local market = Market.new(
        EntityAdapter.new(), profiles,
        function(): number return 1000 end,
        function(): string
            serial += 1
            return "profession-trade-" .. tostring(serial)
        end
    )
    for _, user_id in {SELLER, BUYER} do
        check(profiles:mutate(user_id, function(profile: any)
            profile.Characters.Slot1.Gold = 500
        end), "Disposable market buyer must have earned-style gold")
    end
    return {
        Profiles = profiles,
        Professions = professions,
        Adapter = adapter,
    }, inventory, market
end

--[[
Enforces exactly one slot per category, including malformed requests.

Args:
    services (any): Real profile/profession authorities.

Returns:
    nil: Verifies selection and rejection without granting goods.
]]
local function check_choices(services: any)
    local professions = services.Professions
    local seller = SELLER
    local buyer = BUYER
    local no_choice = professions:gather(seller, {
        ProfessionId = "Mining", ItemId = "iron_ore",
        Quantity = 1, XP = 8,
    })
    check(not no_choice.ok
        and no_choice.reason == "ProfessionNotSelected",
        "Unselected character cannot gather ore")
    check(not professions:prepare_craft(
        seller, "smelt_iron_bar"
    ).ok, "Unselected character cannot use crafting station")

    check(professions:choose_profession(seller, "Mining").ok,
        "Seller selects Mining")
    check(professions:choose_profession(seller, "Blacksmithing").ok,
        "Seller independently selects Blacksmithing")
    check(professions:choose_profession(buyer, "Herbalism").ok,
        "Buyer selects a different gathering career")
    check(professions:choose_profession(buyer, "Alchemy").ok,
        "Buyer selects a different crafting career")
    for _, profession_id in {"Herbalism", "Skinning", "Alchemy",
        "Leatherworking", "Enchanting"} do
        local denied = professions:choose_profession(seller, profession_id)
        check(not denied.ok
            and denied.reason == "ProfessionSlotAlreadyFilled",
            "Seller cannot replace an occupied slot")
    end
    check(not professions:choose_profession(
        buyer, "MadeUpProfession"
    ).ok, "Unknown profession must fail closed")
    check(not professions:can_use(seller, "Alchemy"),
        "Seller cannot gain a second crafting career")
    check(not professions:can_use(buyer, "Mining"),
        "Buyer cannot gain a second gathering career")
end

--[[
Gathers and crafts only through each character's purchased careers.

Args:
    services (any): Genuine profession and profile authorities.

Returns:
    nil: Produces smith bars and alchemist herbs without cheating slots.
]]
local function prepare_traders(services: any)
    local professions = services.Professions
    for _ = 1, 18 do
        check(professions:gather(SELLER, {
            ProfessionId = "Mining", ItemId = "iron_ore",
            Quantity = 1, XP = 8,
        }).ok, "Smith must gather own ore")
    end
    for _ = 1, 3 do
        check(professions:gather(BUYER, {
            ProfessionId = "Herbalism", ItemId = "silverleaf",
            Quantity = 1, XP = 8,
        }).ok, "Alchemist must gather own herbs")
    end
    local unauthorized = professions:gather(SELLER, {
        ProfessionId = "Herbalism", ItemId = "silverleaf",
        Quantity = 1, XP = 8,
    })
    check(not unauthorized.ok
        and unauthorized.reason == "ProfessionNotSelected",
        "Having inventory space cannot bypass gathering ownership")
    for _ = 1, 9 do
        check(professions:craft(SELLER, "smelt_iron_bar").ok,
            "Blacksmithing produces tradeable bars")
    end
    check(professions:craft(SELLER, "forge_ironbound_gloves").ok,
        "Smith crafts base gear with own selected career")
    check(not professions:craft(SELLER, "distill_forging_flux").ok,
        "Smith cannot craft the Alchemist's reagent")
    check(not professions:craft(BUYER, "smelt_iron_bar").ok,
        "Alchemist cannot use Blacksmithing recipes")
end

--[[
Completes real two-way market sales and the dependent final craft.

Args:
    services (any): Genuine profile and profession authorities.
    inventory (any): Genuine inventory module.
    market (any): Genuine market sale and escrow authority.

Returns:
    nil: Proves a smith needs another player's reagent to finish gear.
]]
local function trade_and_craft(
    services: any, inventory: any, market: any
)
    local professions = services.Professions
    local profiles = services.Profiles
    local bar_listing = market:create_listing(
        SELLER, "iron_bar", 1, 100, "seller-bar"
    )
    check(bar_listing.ok, "Smith can list a produced iron bar")
    check(market:buy(
        BUYER, bar_listing.listing.ListingId, "buyer-bar"
    ).ok, "Alchemist buys a smith-produced input")
    check(professions:craft(BUYER, "distill_forging_flux").ok,
        "Alchemist crafts cross-profession reagent after buying bar")
    local flux_listing = market:create_listing(
        BUYER, "forging_flux", 1, 100, "buyer-flux"
    )
    check(flux_listing.ok, "Alchemist lists its produced reagent")
    check(market:buy(
        SELLER, flux_listing.listing.ListingId, "seller-flux"
    ).ok, "Smith buys the alchemist's reagent")
    local finished = professions:craft(
        SELLER, "forge_runic_ironbound_gloves"
    )
    check(finished.ok, "Smith completes gear only after real trade")
    local seller = assert(profiles:get_character(SELLER, 1))
    local buyer = assert(profiles:get_character(BUYER, 1))
    check(inventory.count_item(
        seller, "runic_ironbound_gloves"
    ) == 1, "Trade-dependent crafted equipment must exist once")
    check(inventory.count_item(buyer, "forging_flux") == 0,
        "Market escrow and crafting cannot duplicate reagent")
    check(seller.ProfessionSlots.Gathering == "Mining"
        and seller.ProfessionSlots.Creation == "Blacksmithing"
        and buyer.ProfessionSlots.Gathering == "Herbalism"
        and buyer.ProfessionSlots.Creation == "Alchemy",
        "Trading cannot silently alter saved profession choices")
end

--[[
Verifies the selected professions and completed gear survive profile reload.

Args:
    services (any): Two loaded characters and their in-memory adapter.

Returns:
    nil: Confirms the saved slots cannot be replaced after reconnect.
]]
local function check_persistence(services: any)
    local profiles = services.Profiles
    check(profiles:save(SELLER, "ProfessionChoiceTradeTest"),
        "Seller choices and earned output must persist")
    check(profiles:save(BUYER, "ProfessionChoiceTradeTest"),
        "Buyer choices must persist")
    local restored = Profiles.new(services.Adapter)
    check(restored:load(SELLER), "Seller must reload")
    check(restored:load(BUYER), "Buyer must reload")
    local professions = Professions.new(restored, Inventory.new(restored))
    local seller = assert(restored:get_character(SELLER, 1))
    local buyer = assert(restored:get_character(BUYER, 1))
    check(seller.ProfessionSlots.Gathering == "Mining"
        and seller.ProfessionSlots.Creation == "Blacksmithing"
        and buyer.ProfessionSlots.Gathering == "Herbalism"
        and buyer.ProfessionSlots.Creation == "Alchemy",
        "Profession selections must survive a fresh service load")
    check(not professions:choose_profession(SELLER, "Alchemy").ok,
        "Reconnect cannot grant a second crafting profession")
    check(Inventory.count_item(
        seller, "runic_ironbound_gloves"
    ) == 1, "Market-dependent gear must survive reload")
end

--[[
Ensures older profiles retain XP without gaining all seven careers.

Args:
    None.

Returns:
    nil: Verifies explicit migration, no auto-selection and lockout.
]]
local function check_legacy()
    local legacy = Schema.create_default(932103)
    legacy.SchemaVersion = 13
    legacy.Characters.Slot1.ProfessionSlots = nil
    legacy.Characters.Slot1.Professions.Alchemy.XP = 65
    legacy.Characters.Slot1.Professions.Blacksmithing.XP = 120
    local migrated = Migration.migrate(legacy).Characters.Slot1
    check(migrated.ProfessionSlots.Gathering == ""
        and migrated.ProfessionSlots.Creation == "",
        "Legacy multiple-profession XP cannot auto-select a career")
    check(migrated.Professions.Alchemy.XP == 65
        and migrated.Professions.Blacksmithing.XP == 120,
        "Migration cannot destroy already-earned profession XP")
end

--[[
Runs a focused two-character server-only trade and profession contract.

Args:
    None.

Returns:
    nil: Reports targeted assertions without old dungeon regressions.
]]
local function main()
    check_legacy()
    local services, inventory, market = make_services()
    check_choices(services)
    prepare_traders(services)
    trade_and_craft(services, inventory, market)
    check_persistence(services)
    print(("[Profession Exclusive Choice] PASS: %d assertions.")
        :format(checks))
end

main()
