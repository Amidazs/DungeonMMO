--!strict
-- Four independent creation careers; three purchased ranks each.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local Shared = RS.Core.Shared
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Core.Adapters.InMemoryEntityAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Skills = require(Core.Services.SkillProgressionService)
local Loadout = require(Core.Services.LoadoutService)
local Market = require(Core.Services.MarketService)
local Recipes = require(Shared.ProfessionRecipes)
local Rules = require(Shared.C4ProfessionSkillRules)
local Trainers = require(Shared.TrainerCatalogues)

local SKILL_ID = "ScoutCommonItemCreation"
local SPECS = {
    {99701, "Human", "Rogue", "Mining", "Blacksmithing",
        "scout_forge_bars", "iron_ore"},
    {99702, "Elf", "Ranger", "Herbalism", "Alchemy",
        "scout_distill_oil", "silverleaf"},
    {99703, "Human", "Rogue", "Skinning", "Leatherworking",
        "scout_cure_leather", "raw_hide"},
    {99704, "Elf", "Ranger", "Mining", "Enchanting",
        "scout_inscribe_runes", "warding_essence"},
}
local checks = 0

--[[
Records a real profile, crafting, market or skill-rank assertion.

Args:
    condition (boolean): Required server-owned action or state.
    label (string): Focused Studio failure diagnostic.

Returns:
    nil: Increments the verified assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Scout Ranked Craft] " .. label)
end

--[[
Creates four isolated authoritative players and their real services.

Args:
    None.

Returns:
    any: Separate profile, inventory, skill, profession and market services.
]]
local function setup(): any
    local profiles = Profiles.new(Adapter.new())
    local inventory = Inventory.new(profiles)
    local next_id = 0
    local market = Market.new(
        EntityAdapter.new(), profiles, function(): number
            return 1000
        end, function(): string
            next_id += 1
            return "c4-scout-craft-" .. tostring(next_id)
        end
    )
    return {
        Profiles = profiles,
        Inventory = inventory,
        Professions = Professions.new(profiles, inventory),
        Skills = Skills.new(
            profiles, inventory, Loadout.new(profiles)
        ),
        Market = market,
    }
end

--[[
Initializes one valid Rogue/Ranger with exactly one profession per slot.

Args:
    context (any): Real isolated server services.
    spec (any): Race, class and independent profession choices.

Returns:
    nil: Ensures training requires real creation selection.
]]
local function seed_character(context: any, spec: any)
    local user_id = spec[1]
    check(context.Profiles:load(user_id), "Character must load")
    check(context.Profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = spec[2],
            BaseClassId = spec[3], ClassId = spec[3],
            CreationStage = "Complete",
        }
        character.Level = 20
        character.Gold = 1500
        character.Progression.SkillPointEntitlement = 250
    end), "Character identity and skill-point budget must persist")
    local trainer = spec[3] .. "Trainer"
    local character = assert(context.Profiles:get_character(user_id, 1))
    check(not Trainers.can_offer(trainer, character,
        "C4RecipeReading").ok,
        "Rogue/Scout cannot purchase reading before a career choice")
    check(context.Professions:choose_profession(
        user_id, spec[4]
    ).ok, "One gathering slot is selected")
    check(context.Professions:choose_profession(
        user_id, spec[5]
    ).ok, "Exactly one independent crafting career is selected")
    check(context.Skills:learn_trainer_skill(
        user_id, "C4RecipeReading"
    ).ok, "Selected crafter purchases its actual Recipe Reading")
end

--[[
Buys one earned rank at the original C4 first-transfer bracket.

Args:
    context (any): Actual authoritative skill service.
    user_id (number): Character buying its sequential next rank.
    rank (number): One, two or three.

Returns:
    nil: Verifies class, level and genuine previous-rank gates.
]]
local function purchase_rank(
    context: any, user_id: number, rank: number
)
    local level = ({20, 28, 36})[rank]
    check(context.Profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level - 1
    end), "Character must remain authoritative")
    local early = if rank == 1
        then context.Skills:learn_trainer_skill(user_id, SKILL_ID)
        else context.Skills:purchase_rank(user_id, SKILL_ID)
    check(not early.ok,
        "Cannot buy a rank before its original source level")
    check(context.Profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "Earned C4 source character level must persist")
    local result = if rank == 1
        then context.Skills:learn_trainer_skill(user_id, SKILL_ID)
        else context.Skills:purchase_rank(user_id, SKILL_ID)
    check(result.ok and result.rank == rank,
        "Actual class trainer must purchase correct sequential rank")
end

--[[
Adds each missing real ingredient for one isolated crafting test.

Args:
    context (any): Real server inventory and character services.
    user_id (number): Craftsperson owning exactly one chosen career.
    recipe (any): Authored material-backed current-rank recipe.

Returns:
    nil: Supplies consumable inputs without manufacturing an output.
]]
local function stock_inputs(
    context: any, user_id: number, recipe: any
)
    for _, input in ipairs(recipe.Inputs) do
        local character = assert(context.Profiles:get_character(user_id, 1))
        local available = Inventory.count_item(
            character, input.ItemId
        )
        local needed = math.max(0, input.Quantity - available)
        if needed > 0 then
            check(context.Inventory:add_item(
                user_id, input.ItemId, needed
            ).ok, "Test inventory can hold the real required input")
        end
    end
end

--[[
Completes one real atomic craft with actual input consumption and XP.

Args:
    context (any): Profile, inventory and profession services.
    user_id (number): One selected craftsperson.
    recipe (any): Authored original-rank material recipe.

Returns:
    nil: Verifies output, inventory consumption and earned profession XP.
]]
local function craft_recipe(context: any, user_id: number, recipe: any)
    stock_inputs(context, user_id, recipe)
    local character = assert(context.Profiles:get_character(user_id, 1))
    local previous = Inventory.count_item(
        character, recipe.Output.ItemId
    )
    local prepared = context.Professions:prepare_craft(user_id, recipe.Id)
    check(prepared.ok, "Actual selected station prepares " .. recipe.Id)
    local result = context.Professions:complete_craft(
        user_id, recipe.Id,
        Professions.foundation_success_outcome(prepared.minigame_id)
    )
    check(result.ok and result.xp == recipe.XP,
        "Actual server minigame awards profession XP for " .. recipe.Id)
    character = assert(context.Profiles:get_character(user_id, 1))
    check(Inventory.count_item(
        character, recipe.Output.ItemId
    ) == previous + recipe.Output.Quantity,
        "Material-backed output quantity is correct for " .. recipe.Id)
end

--[[
Verifies three distinct gated rank recipes within exactly one career.

Args:
    context (any): Genuine training and crafting authorities.
    spec (any): One isolated source class/profession row.

Returns:
    nil: Refuses early/high-rank crafts and buys three source ranks.
]]
local function exercise_career(context: any, spec: any)
    local owner = spec[1]
    seed_character(context, spec)
    local first = assert(Recipes.get(spec[6] .. "_rank_1"))
    local second = assert(Recipes.get(spec[6] .. "_rank_2"))
    local third = assert(Recipes.get(spec[6] .. "_rank_3"))
    check(not context.Professions:prepare_craft(
        owner, first.Id
    ).ok, "Recipe Reading alone cannot grant first-transfer crafting")
    purchase_rank(context, owner, 1)
    local character = assert(context.Profiles:get_character(owner, 1))
    check(Rules.can_make_scout_common(character, spec[5], 1)
        and not Rules.can_make_scout_common(character, spec[5], 2),
        "Only the actually bought source rank is available")
    check(not context.Professions:prepare_craft(
        owner, second.Id
    ).ok, "Second recipe is locked before bought source rank two")
    for _ = 1, 5 do
        craft_recipe(context, owner, first)
    end
    purchase_rank(context, owner, 2)
    craft_recipe(context, owner, second)
    check(not context.Professions:prepare_craft(
        owner, third.Id
    ).ok, "Final recipe is locked before purchased source rank three")
    purchase_rank(context, owner, 3)
    craft_recipe(context, owner, third)
    character = assert(context.Profiles:get_character(owner, 1))
    check(Rules.can_make_scout_common(character, spec[5], 3),
        "Paid final rank authorizes only the selected creation career")
    check(character.ProfessionSlots.Creation == spec[5]
        and character.ProfessionSlots.Gathering == spec[4],
        "Ranked crafting never adds another profession slot")
    check(not context.Professions:can_use(
        owner, if spec[5] == "Blacksmithing"
            then "Alchemy" else "Blacksmithing"
    ), "Earned source rank does not bypass other creation careers")
end

--[[
Trades actual rank-produced materials between two chosen professions.

Args:
    context (any): Four genuine character profiles and market escrow.
    seller (number): Player who crafted, rather than received, the good.
    buyer (number): Different character with its own profession choices.
    item_id (string): Crafted tradeable material.

Returns:
    nil: Proves real escrow delivery without a duplicated seller output.
]]
local function trade(
    context: any, seller: number, buyer: number, item_id: string
)
    local before_seller = Inventory.count_item(
        assert(context.Profiles:get_character(seller, 1)), item_id
    )
    local before_buyer = Inventory.count_item(
        assert(context.Profiles:get_character(buyer, 1)), item_id
    )
    check(before_seller >= 1, "Seller must own its produced material")
    local listing = context.Market:create_listing(
        seller, item_id, 1, 100, "scout-" .. tostring(seller)
            .. "-" .. item_id
    )
    check(listing.ok, "Real seller listing must escrow the output")
    check(context.Market:buy(
        buyer, listing.listing.ListingId,
        "scout-buy-" .. tostring(buyer) .. "-" .. item_id
    ).ok, "Another selected career buys the genuine escrowed good")
    check(Inventory.count_item(
        assert(context.Profiles:get_character(seller, 1)), item_id
    ) == before_seller - 1, "Seller loses the exact sold quantity")
    check(Inventory.count_item(
        assert(context.Profiles:get_character(buyer, 1)), item_id
    ) == before_buyer + 1, "Buyer receives the genuine traded good")
end

--[[
Runs isolated progression and four-person cross-profession acceptance.

Args:
    None.

Returns:
    nil: Prints the count of real source rank/craft/market assertions.
]]
local function main()
    local context = setup()
    for _, spec in ipairs(SPECS) do
        exercise_career(context, spec)
    end
    trade(context, 99701, 99702, "iron_bar")
    trade(context, 99702, 99703, "tempering_oil")
    trade(context, 99703, 99704, "cured_leather")
    trade(context, 99704, 99701, "warding_rune")

    -- Purchased materials now supply the *next actual recipe*, rather
    -- than merely being listed and received after all crafting is over.
    -- For each chosen career the server consumes the traded input.
    for _, dependency in ipairs({
        {99701, "warding_rune", "scout_forge_bars_rank_3"},
        {99702, "iron_bar", "scout_distill_oil_rank_2"},
        {99703, "tempering_oil", "scout_cure_leather_rank_2"},
        {99704, "cured_leather", "scout_inscribe_runes_rank_3"},
    }) do
        local owner = dependency[1]
        local ingredient = dependency[2]
        local recipe = assert(Recipes.get(dependency[3]))
        local current = Inventory.count_item(
            assert(context.Profiles:get_character(owner, 1)), ingredient
        )
        check(current >= 1, "Other career's actual traded input exists")
        craft_recipe(context, owner, recipe)
        local after = Inventory.count_item(
            assert(context.Profiles:get_character(owner, 1)), ingredient
        )
        check(after == current - 1,
            "Ranked recipe consumed the other player's traded input")
    end
    print(("[C4 Scout Ranked Craft] PASS: %d assertions")
        :format(checks))
end

main()
