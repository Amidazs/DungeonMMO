--!strict
-- Pure contract coverage for optional profession blueprint distribution.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local DropConfig = require(Shared.ProfessionBlueprintDropConfig)
local Items = require(Shared.ItemDefinitions)
local Recipes = require(Shared.ProfessionRecipes)

local checks = 0

local ADVANCED_RECIPES = table.freeze({
    blacksmith_masterwork_batch_blueprint = table.freeze({
        Batch = "forge_masterwork_frame_batch",
        Base = "forge_masterwork_frame",
    }),
    alchemy_aetheric_batch_recipe = table.freeze({
        Batch = "distill_aetheric_catalyst_batch",
        Base = "distill_aetheric_catalyst",
    }),
    leatherworking_masterwork_batch_pattern = table.freeze({
        Batch = "stitch_masterwork_lining_batch",
        Base = "stitch_masterwork_lining",
    }),
    enchanting_arcane_batch_inscription = table.freeze({
        Batch = "inscribe_arcane_matrix_batch",
        Base = "inscribe_arcane_matrix",
    }),
})

--[[
Counts one blueprint-distribution assertion.

Args:
    condition (boolean): Expected configuration or recipe invariant.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Blueprint Config] " .. label)
end

--[[
Returns one recipe input quantity by stable item identifier.

Args:
    recipe (any): Registered profession recipe.
    item_id (string): Input item to locate.

Returns:
    number?: Authored quantity, or nil when the input is absent.
]]
local function input_quantity(
    recipe: any,
    item_id: string
): number?
    for _, input in ipairs(recipe.Inputs) do
        if input.ItemId == item_id then
            return input.Quantity
        end
    end

    return nil
end

--[[
Verifies one optional batch recipe is a zero-efficiency convenience variant.

Args:
    blueprint_id (string): Tradeable blueprint knowledge identifier.
    recipe_ids (any): Batch and normal recipe identifiers.

Returns:
    nil: Raises on any economy or knowledge mismatch.
]]
local function check_batch_recipe(
    blueprint_id: string,
    recipe_ids: any
)
    local item = assert(Items.get(blueprint_id))
    local batch = assert(Recipes.get(recipe_ids.Batch))
    local base = assert(Recipes.get(recipe_ids.Base))

    check(
        item.Kind == "RecipeBlueprint"
            and item.Rarity == "Rare"
            and item.Tradeable == true
            and item.Bound == false,
        blueprint_id .. " is a tradeable rare blueprint"
    )
    check(
        item.RecipeLearning.RecipeId == blueprint_id
            and item.RecipeLearning.ProfessionId
                == batch.ProfessionId
            and item.RecipeLearning.RequiredProfessionLevel == 5,
        blueprint_id .. " teaches its level-five profession"
    )
    check(
        batch.RequiredLevel == 5
            and batch.Knowledge.Mode == "Learned"
            and batch.Knowledge.RecipeId == blueprint_id,
        recipe_ids.Batch .. " is gated only by learned recipe knowledge"
    )
    check(
        base.RequiredLevel == 5
            and base.Knowledge.Mode == "Default",
        recipe_ids.Base .. " stays baseline and default-known"
    )
    check(
        batch.Output.ItemId == base.Output.ItemId
            and batch.Output.Quantity == base.Output.Quantity * 2
            and batch.XP == base.XP * 2,
        recipe_ids.Batch .. " doubles output and XP exactly"
    )
    check(
        #batch.Inputs == #base.Inputs,
        recipe_ids.Batch .. " keeps the same dependency set"
    )

    for _, input in ipairs(base.Inputs) do
        check(
            input_quantity(batch, input.ItemId)
                == input.Quantity * 2,
            recipe_ids.Batch
                .. " doubles "
                .. input.ItemId
                .. " exactly"
        )
    end
end

--[[
Runs the complete profession-blueprint distribution contract.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local valid, reason = DropConfig.validate()
    check(
        valid == true and reason == nil,
        "all configured blueprint sources validate"
    )

    local foundation = assert(
        DropConfig.get_boss("MarauderCaptain")
    )
    check(
        foundation.Chance == 0.02
            and DropConfig.first_item(foundation)
                == "blacksmith_iron_guard_blueprint",
        "Depth-one boss uses the foundation blueprint pool"
    )

    local completion = assert(
        DropConfig.get_completion("TestDungeon")
    )
    check(
        completion.Chance == 0.01
            and DropConfig.first_item(completion)
                == "blacksmith_iron_guard_blueprint",
        "normal completion uses the foundation pool"
    )

    local advanced = assert(
        DropConfig.get_boss("TempleDepth2Boss")
    )
    check(
        advanced.Chance == 0.02
            and #advanced.Pool == 4
            and DropConfig.first_item(advanced)
                == "blacksmith_masterwork_batch_blueprint",
        "higher-depth boss uses the advanced four-profession pool"
    )
    check(
        DropConfig.get_boss("TempleDepth4Boss") ~= nil
            and DropConfig.get_boss("TempleEventBoss") ~= nil
            and DropConfig.get_boss("TempleSecretBoss") ~= nil,
        "final and optional boss families expose advanced drops"
    )
    check(
        DropConfig.get_boss("UnknownBoss") == nil
            and DropConfig.get_completion("UnknownDungeon") == nil,
        "unsupported sources never invent blueprint drops"
    )

    for blueprint_id, recipe_ids in pairs(
        ADVANCED_RECIPES
    ) do
        check_batch_recipe(blueprint_id, recipe_ids)
    end

    local success_rng = {
        NextNumber = function(
            _self: any,
            minimum: number,
            _maximum: number
        ): number
            return minimum
        end,
    }
    local fail_rng = {
        NextNumber = function(
            _self: any,
            _minimum: number,
            maximum: number
        ): number
            return maximum
        end,
    }

    check(
        DropConfig.roll(advanced, success_rng)
            == "blacksmith_masterwork_batch_blueprint",
        "successful advanced roll selects a configured blueprint"
    )
    check(
        DropConfig.roll(advanced, fail_rng) == nil,
        "failed chance roll grants no blueprint"
    )

    print(
        ("[Profession Blueprint Config] PASS: %d assertions")
            :format(checks)
    )
end

main()
