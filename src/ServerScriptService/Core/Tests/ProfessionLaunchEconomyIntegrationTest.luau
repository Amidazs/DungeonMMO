--!strict
-- Real-service launch economy integration from tier-three materials to a
-- level-five crafted component across four exclusive profession owners.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Core.Adapters.InMemoryEntityAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Market = require(Core.Services.MarketService)

local SMITH_ID = 964101
local ALCHEMIST_ID = 964102
local LEATHERWORKER_ID = 964103
local ENCHANTER_ID = 964104
local MAX_PROFESSION_XP = 340
local checks = 0

--[[
Counts one launch-economy integration assertion.

Args:
    condition (boolean): Expected inventory, trade, or crafting result.
    label (string): Failure context for the focused Studio run.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Launch Economy] " .. label)
end

--[[
Raises selected professions to launch level five for focused economy testing.

Args:
    profiles (any): Loaded authoritative profile service.
    user_id (number): Disposable profile owner.
    profession_ids ({string}): Selected careers to advance.

Returns:
    nil: Mutates only the disposable in-memory profile.
]]
local function set_profession_levels(
    profiles: any,
    user_id: number,
    profession_ids: {string}
)
    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            for _, profession_id in ipairs(profession_ids) do
                local state = character.Professions[profession_id]
                state.XP = MAX_PROFESSION_XP
                state.Level = 5
            end
        end),
        "selected profession XP advances for focused integration"
    )
end

--[[
Adds one fixed low-tier prerequisite through real inventory authority.

Args:
    inventory (any): Authoritative inventory service.
    user_id (number): Item owner.
    item_id (string): Registered input item.
    quantity (number): Positive quantity to grant.

Returns:
    nil: Raises if inventory mutation fails.
]]
local function seed_input(
    inventory: any,
    user_id: number,
    item_id: string,
    quantity: number
)
    local result = inventory:add_item(user_id, item_id, quantity)
    check(
        result.ok == true,
        "seed prerequisite " .. item_id
    )
end

--[[
Gathers one authored high-tier material repeatedly.

Args:
    professions (any): Authoritative profession service.
    user_id (number): Selected gathering owner.
    profession_id (string): Required gathering profession.
    item_id (string): Registered gathered material.
    count (number): Number of successful gathers.

Returns:
    nil: Raises on any rejected gather.
]]
local function gather_many(
    professions: any,
    user_id: number,
    profession_id: string,
    item_id: string,
    count: number
)
    for _ = 1, count do
        local result = professions:gather(user_id, {
            ProfessionId = profession_id,
            ItemId = item_id,
            Quantity = 1,
            XP = 0,
            RequiredLevel = 3,
        })
        check(
            result.ok == true,
            profession_id .. " gathers " .. item_id
        )
    end
end

--[[
Completes one recipe through prepare and authoritative minigame completion.

Args:
    professions (any): Authoritative profession service.
    user_id (number): Selected crafting owner.
    recipe_id (string): Registered recipe identifier.

Returns:
    any: Successful craft result.
]]
local function craft(
    professions: any,
    user_id: number,
    recipe_id: string
): any
    local prepared = professions:prepare_craft(user_id, recipe_id)
    check(prepared.ok == true, recipe_id .. " prepares")

    local result = professions:complete_craft(
        user_id,
        recipe_id,
        Professions.foundation_success_outcome(
            prepared.minigame_id
        )
    )
    check(result.ok == true, recipe_id .. " commits")
    return result
end

--[[
Trades one crafted component through the existing market escrow service.

Args:
    market (any): Authoritative market service.
    seller_id (number): Current component owner.
    buyer_id (number): Required downstream profession owner.
    item_id (string): Tradeable component.
    quantity (number): Positive quantity to transfer.
    serial (number): Stable request/listing suffix.

Returns:
    nil: Raises if listing or purchase fails.
]]
local function trade(
    market: any,
    seller_id: number,
    buyer_id: number,
    item_id: string,
    quantity: number,
    serial: number
)
    local request_id =
        "launch-economy-sell-" .. tostring(serial)
    local listing = market:create_listing(
        seller_id,
        item_id,
        quantity,
        10,
        request_id
    )
    check(listing.ok == true, item_id .. " lists")

    local purchase = market:buy(
        buyer_id,
        listing.listing.ListingId,
        "launch-economy-buy-" .. tostring(serial)
    )
    check(purchase.ok == true, item_id .. " trades")
end

--[[
Returns the current quantity of one item on one loaded character.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Inventory owner.
    item_id (string): Registered item identifier.

Returns:
    number: Authoritative inventory quantity.
]]
local function quantity(
    profiles: any,
    user_id: number,
    item_id: string
): number
    local character = assert(profiles:get_character(user_id, 1))
    return Inventory.count_item(character, item_id)
end

--[[
Runs the four-player level-three through level-five economy chain.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after the real market/craft path succeeds.
]]
local function main()
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)

    for _, user_id in {
        SMITH_ID,
        ALCHEMIST_ID,
        LEATHERWORKER_ID,
        ENCHANTER_ID,
    } do
        check(profiles:load(user_id), "disposable profile loads")
        check(
            profiles:mutate(user_id, function(profile: any)
                profile.Characters.Slot1.Gold = 10000
            end),
            "trade participant receives disposable gold"
        )
    end

    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)

    for _, choice in {
        {SMITH_ID, "Mining"},
        {SMITH_ID, "Blacksmithing"},
        {ALCHEMIST_ID, "Herbalism"},
        {ALCHEMIST_ID, "Alchemy"},
        {LEATHERWORKER_ID, "Skinning"},
        {LEATHERWORKER_ID, "Leatherworking"},
        {ENCHANTER_ID, "Mining"},
        {ENCHANTER_ID, "Enchanting"},
    } do
        check(
            professions:choose_profession(
                choice[1],
                choice[2]
            ).ok,
            "each participant selects only its legal careers"
        )
    end

    set_profession_levels(
        profiles,
        SMITH_ID,
        {"Mining", "Blacksmithing"}
    )
    set_profession_levels(
        profiles,
        ALCHEMIST_ID,
        {"Herbalism", "Alchemy"}
    )
    set_profession_levels(
        profiles,
        LEATHERWORKER_ID,
        {"Skinning", "Leatherworking"}
    )
    set_profession_levels(
        profiles,
        ENCHANTER_ID,
        {"Mining", "Enchanting"}
    )

    seed_input(inventory, SMITH_ID, "forging_flux", 11)
    seed_input(inventory, ALCHEMIST_ID, "iron_bar", 12)
    seed_input(inventory, ENCHANTER_ID, "warding_essence", 4)

    gather_many(
        professions,
        SMITH_ID,
        "Mining",
        "deep_iron_ore",
        22
    )
    gather_many(
        professions,
        ALCHEMIST_ID,
        "Herbalism",
        "moonpetal",
        36
    )
    gather_many(
        professions,
        LEATHERWORKER_ID,
        "Skinning",
        "thick_hide",
        24
    )

    for _ = 1, 11 do
        craft(professions, SMITH_ID, "smelt_deep_iron_bar")
    end
    for _ = 1, 12 do
        craft(
            professions,
            ALCHEMIST_ID,
            "distill_moonpetal_extract"
        )
    end

    local listing_counter = 0
    local market = Market.new(
        EntityAdapter.new(),
        profiles,
        function(): number
            return 1000
        end,
        function(): string
            listing_counter += 1
            return "launch-economy-"
                .. tostring(listing_counter)
        end
    )

    local trade_serial = 1
    trade(
        market,
        SMITH_ID,
        ENCHANTER_ID,
        "deep_iron_bar",
        4,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        SMITH_ID,
        ALCHEMIST_ID,
        "deep_iron_bar",
        2,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        SMITH_ID,
        LEATHERWORKER_ID,
        "deep_iron_bar",
        1,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        ALCHEMIST_ID,
        LEATHERWORKER_ID,
        "moonpetal_extract",
        8,
        trade_serial
    )

    for _ = 1, 8 do
        craft(
            professions,
            LEATHERWORKER_ID,
            "cure_thick_hide"
        )
    end

    trade_serial += 1
    trade(
        market,
        LEATHERWORKER_ID,
        SMITH_ID,
        "reinforced_leather",
        2,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        LEATHERWORKER_ID,
        ENCHANTER_ID,
        "reinforced_leather",
        4,
        trade_serial
    )

    for _ = 1, 4 do
        craft(
            professions,
            ENCHANTER_ID,
            "inscribe_resonant_rune"
        )
    end

    trade_serial += 1
    trade(
        market,
        ENCHANTER_ID,
        SMITH_ID,
        "resonant_rune",
        2,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        ENCHANTER_ID,
        ALCHEMIST_ID,
        "resonant_rune",
        2,
        trade_serial
    )

    for _ = 1, 2 do
        craft(
            professions,
            SMITH_ID,
            "forge_hardened_fittings"
        )
        craft(
            professions,
            ALCHEMIST_ID,
            "distill_prismatic_catalyst"
        )
    end

    trade_serial += 1
    trade(
        market,
        ALCHEMIST_ID,
        LEATHERWORKER_ID,
        "prismatic_catalyst",
        1,
        trade_serial
    )
    trade_serial += 1
    trade(
        market,
        ALCHEMIST_ID,
        SMITH_ID,
        "prismatic_catalyst",
        1,
        trade_serial
    )

    craft(
        professions,
        LEATHERWORKER_ID,
        "stitch_rune_binding"
    )
    trade_serial += 1
    trade(
        market,
        LEATHERWORKER_ID,
        SMITH_ID,
        "rune_binding",
        1,
        trade_serial
    )

    local masterwork = craft(
        professions,
        SMITH_ID,
        "forge_masterwork_frame"
    )
    check(
        masterwork.output_item_id == "masterwork_frame"
            and quantity(
                profiles,
                SMITH_ID,
                "masterwork_frame"
            ) == 1,
        "four-profession chain completes one level-five component"
    )

    local premium_denied = professions:prepare_craft(
        SMITH_ID,
        "gearwright_precision_assembly"
    )
    check(
        not premium_denied.ok
            and premium_denied.reason
                == "GearwrightBlueprintNotLearned",
        "ordinary level-five smith cannot use Gearwright premium recipes"
    )

    check(
        profiles:save(SMITH_ID, "ProfessionLaunchEconomyIntegration"),
        "finished level-five component persists"
    )
    local restored = Profiles.new(adapter)
    check(restored:load(SMITH_ID), "smith reloads after economy chain")
    check(
        Inventory.count_item(
            assert(restored:get_character(SMITH_ID, 1)),
            "masterwork_frame"
        ) == 1,
        "level-five output survives profile reload"
    )

    print(
        ("[Profession Launch Economy] PASS: %d assertions")
            :format(checks)
    )
end

main()
