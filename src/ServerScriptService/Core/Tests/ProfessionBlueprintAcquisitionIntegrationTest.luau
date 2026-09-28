--!strict
-- Real-service profession blueprint acquisition, trade, learning and use.

local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Adapters = Core.Adapters
local Services = Core.Services

local ProfileAdapter = require(Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Adapters.InMemoryEntityAdapter)
local Profiles = require(Services.ProfileService)
local Inventory = require(Services.InventoryService)
local Progression = require(Services.ProgressionService)
local Professions = require(Services.ProfessionService)
local Market = require(Services.MarketService)
local Rewards = require(Services.RewardService)
local RecipeKnowledge = require(Services.RecipeKnowledgeService)

local SELLER_ID = 965101
local BUYER_ID = 965102
local MISS_ID = 965103
local BLUEPRINT_ID = "blacksmith_masterwork_batch_blueprint"
local BATCH_RECIPE_ID = "forge_masterwork_frame_batch"
local BASE_RECIPE_ID = "forge_masterwork_frame"
local MAX_PROFESSION_XP = 340

local checks = 0

local success_rng: any = {}

--[[
Returns the lower bound for every deterministic success roll.

Args:
    minimum (number?): Optional lower bound.
    maximum (number?): Optional upper bound.

Returns:
    number: The supplied minimum, or zero when omitted.
]]
function success_rng:NextNumber(
    minimum: number?,
    _maximum: number?
): number
    return minimum or 0
end

--[[
Returns the lower bound for deterministic integer rolls.

Args:
    minimum (number): Inclusive lower bound.
    maximum (number): Inclusive upper bound.

Returns:
    number: The supplied lower bound.
]]
function success_rng:NextInteger(
    minimum: number,
    _maximum: number
): number
    return minimum
end

local fail_rng: any = {}

--[[
Returns the upper bound so optional chance checks fail.

Args:
    minimum (number?): Optional lower bound.
    maximum (number?): Optional upper bound.

Returns:
    number: The supplied maximum, or one when omitted.
]]
function fail_rng:NextNumber(
    _minimum: number?,
    maximum: number?
): number
    return maximum or 1
end

--[[
Returns the lower integer bound for unrelated reward rolls.

Args:
    minimum (number): Inclusive lower bound.
    maximum (number): Inclusive upper bound.

Returns:
    number: The supplied lower bound.
]]
function fail_rng:NextInteger(
    minimum: number,
    _maximum: number
): number
    return minimum
end

--[[
Counts one blueprint acquisition assertion.

Args:
    condition (boolean): Expected reward, market, or recipe result.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Blueprint Acquisition] " .. label)
end

--[[
Returns one authoritative item quantity for a loaded character.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Inventory owner.
    item_id (string): Registered item identifier.

Returns:
    number: Current inventory quantity.
]]
local function quantity(
    profiles: any,
    user_id: number,
    item_id: string
): number
    local character = assert(
        profiles:get_character(user_id, 1)
    )
    return Inventory.count_item(character, item_id)
end

--[[
Installs level-five Blacksmithing and Recipe Reading on the buyer.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Buyer profile owner.

Returns:
    nil: Mutates only the disposable buyer profile.
]]
local function prepare_blacksmith(
    profiles: any,
    user_id: number
)
    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            character.Professions.Blacksmithing.XP =
                MAX_PROFESSION_XP
            character.Professions.Blacksmithing.Level = 5
            character.Progression =
                character.Progression or {}
            character.Progression.Skills =
                character.Progression.Skills or {}
            character.Progression.Skills.C4RecipeReading = {
                Known = true,
                PurchasedRank = 1,
            }
        end),
        "buyer receives focused level-five recipe literacy"
    )
end

--[[
Seeds the exact double-batch ingredients through inventory authority.

Args:
    inventory (any): Authoritative inventory service.
    user_id (number): Buyer inventory owner.

Returns:
    nil: Adds only the inputs used by both normal and batch recipes.
]]
local function seed_batch_inputs(
    inventory: any,
    user_id: number
)
    for _, input in {
        {"hardened_fittings", 4},
        {"rune_binding", 2},
        {"prismatic_catalyst", 2},
    } do
        local result = inventory:add_item(
            user_id,
            input[1],
            input[2]
        )
        check(
            result.ok == true,
            "batch input " .. tostring(input[1]) .. " is seeded"
        )
    end
end

--[[
Runs the complete rare blueprint acquisition-to-crafting path.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after every authority succeeds.
]]
local function main()
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)

    for _, user_id in {SELLER_ID, BUYER_ID, MISS_ID} do
        check(profiles:load(user_id), "disposable profile loads")
    end

    check(
        profiles:mutate(BUYER_ID, function(profile: any)
            profile.Characters.Slot1.Gold = 1000
        end),
        "buyer receives disposable market gold"
    )

    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)

    check(
        professions:choose_profession(
            BUYER_ID,
            "Blacksmithing"
        ).ok,
        "buyer selects Blacksmithing"
    )
    prepare_blacksmith(profiles, BUYER_ID)

    local rewards = Rewards.new(
        profiles,
        Progression.new(profiles),
        inventory,
        nil,
        success_rng,
        function(): number
            return 8000
        end
    )

    local drop = rewards:grant_monster_reward(
        {SELLER_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-depth2-1"
    )
    check(drop.ok == true, "higher-depth boss reward succeeds")
    check(
        drop.member_results[tostring(SELLER_ID)]
            .profession_blueprint_item_id == BLUEPRINT_ID,
        "higher-depth reward grants the advanced blueprint"
    )
    check(
        quantity(profiles, SELLER_ID, BLUEPRINT_ID) == 1,
        "off-profession seller owns exactly one blueprint"
    )

    local replay = rewards:grant_monster_reward(
        {SELLER_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-depth2-1"
    )
    check(
        replay.ok == true and replay.already_applied == true,
        "same runtime reward replays without duplication"
    )
    check(
        quantity(profiles, SELLER_ID, BLUEPRINT_ID) == 1,
        "runtime replay leaves one blueprint"
    )

    check(
        profiles:save(
            SELLER_ID,
            "ProfessionBlueprintAcquisition"
        ),
        "seller reward history saves"
    )
    check(
        profiles:release(
            SELLER_ID,
            "ProfessionBlueprintAcquisition"
        ),
        "seller profile releases"
    )
    check(profiles:load(SELLER_ID), "seller profile reloads")

    local rewards_after_reload = Rewards.new(
        profiles,
        Progression.new(profiles),
        Inventory.new(profiles),
        nil,
        success_rng,
        function(): number
            return 8001
        end
    )
    local persisted_replay =
        rewards_after_reload:grant_monster_reward(
            {SELLER_ID},
            {
                XP = 1,
                GoldMin = 0,
                GoldMax = 0,
                BossId = "TempleDepth2Boss",
            },
            "profession-blueprint-depth2-1"
        )
    check(
        persisted_replay.ok == true
            and persisted_replay.already_applied == true,
        "reward history prevents duplication after reload"
    )
    check(
        quantity(profiles, SELLER_ID, BLUEPRINT_ID) == 1,
        "persistent replay still leaves one blueprint"
    )

    local miss_rewards = Rewards.new(
        profiles,
        Progression.new(profiles),
        inventory,
        nil,
        fail_rng,
        function(): number
            return 8002
        end
    )
    local miss = miss_rewards:grant_monster_reward(
        {MISS_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-depth2-miss"
    )
    check(
        miss.ok == true
            and miss.member_results[tostring(MISS_ID)]
                .profession_blueprint_item_id == nil,
        "failed rare roll grants no blueprint"
    )
    check(
        quantity(profiles, MISS_ID, BLUEPRINT_ID) == 0,
        "failed rare roll leaves inventory unchanged"
    )

    seed_batch_inputs(inventory, BUYER_ID)

    local base_prepare = professions:prepare_craft(
        BUYER_ID,
        BASE_RECIPE_ID
    )
    check(
        base_prepare.ok == true,
        "normal level-five recipe remains usable without blueprint"
    )

    local locked_batch = professions:prepare_craft(
        BUYER_ID,
        BATCH_RECIPE_ID
    )
    check(
        not locked_batch.ok
            and locked_batch.reason == "RecipeNotLearned",
        "batch recipe is knowledge-gated before acquisition"
    )

    local listing_counter = 0
    local market = Market.new(
        EntityAdapter.new(),
        profiles,
        function(): number
            return 1000
        end,
        function(): string
            listing_counter += 1
            return "profession-blueprint-"
                .. tostring(listing_counter)
        end
    )
    local listing = market:create_listing(
        SELLER_ID,
        BLUEPRINT_ID,
        1,
        100,
        "profession-blueprint-list"
    )
    check(listing.ok == true, "seller lists the rare blueprint")

    local bought = market:buy(
        BUYER_ID,
        listing.listing.ListingId,
        "profession-blueprint-buy"
    )
    check(bought.ok == true, "Blacksmith buys the rare blueprint")
    check(
        quantity(profiles, SELLER_ID, BLUEPRINT_ID) == 0
            and quantity(
                profiles,
                BUYER_ID,
                BLUEPRINT_ID
            ) == 1,
        "market escrow transfers exactly one blueprint"
    )

    local knowledge = RecipeKnowledge.new(
        profiles,
        inventory
    )
    local learned = knowledge:learn_from_item(
        BUYER_ID,
        BLUEPRINT_ID
    )
    check(
        learned.ok == true
            and learned.CraftRecipeId == BATCH_RECIPE_ID,
        "buyer consumes blueprint and learns the batch recipe"
    )
    check(
        quantity(profiles, BUYER_ID, BLUEPRINT_ID) == 0,
        "learning consumes the physical blueprint once"
    )

    local known = knowledge:knows_recipe(
        BUYER_ID,
        BATCH_RECIPE_ID
    )
    check(
        known.ok == true and known.known == true,
        "learned knowledge is visible server-side"
    )

    local prepared = professions:prepare_craft(
        BUYER_ID,
        BATCH_RECIPE_ID
    )
    check(
        prepared.ok == true
            and prepared.output_quantity == 2,
        "learned batch recipe prepares two outputs"
    )

    local crafted = professions:complete_craft(
        BUYER_ID,
        BATCH_RECIPE_ID,
        Professions.foundation_success_outcome(
            prepared.minigame_id
        )
    )
    check(
        crafted.ok == true
            and crafted.output_item_id
                == "masterwork_frame"
            and crafted.output_quantity == 2,
        "learned batch recipe commits exactly two frames"
    )
    check(
        quantity(
            profiles,
            BUYER_ID,
            "masterwork_frame"
        ) == 2,
        "buyer receives exactly two Masterwork Frames"
    )
    check(
        quantity(
            profiles,
            BUYER_ID,
            "hardened_fittings"
        ) == 0
            and quantity(
                profiles,
                BUYER_ID,
                "rune_binding"
            ) == 0
            and quantity(
                profiles,
                BUYER_ID,
                "prismatic_catalyst"
            ) == 0,
        "batch craft consumes exactly double normal inputs"
    )

    print(
        ("[Profession Blueprint Acquisition] PASS: %d assertions")
            :format(checks)
    )
end

main()
