--!strict
-- Independent optional profession-blueprint reward distribution.

local ProfessionBlueprintDropConfig = {}

local FOUNDATION_POOL = table.freeze({
    table.freeze({
        Weight = 1,
        ItemId = "blacksmith_iron_guard_blueprint",
    }),
    table.freeze({
        Weight = 1,
        ItemId = "alchemy_restorative_tonic_recipe",
    }),
})

local BOSS = table.freeze({
    TempleEventBoss = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
    TempleSecretBoss = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
    AbandonedMineEventBoss = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
    AbandonedMineSecretBoss = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
    MarauderCaptain = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
    CorruptedForeman = table.freeze({
        Chance = 0.02,
        Pool = FOUNDATION_POOL,
    }),
})

local COMPLETION = table.freeze({
    TestDungeon = table.freeze({
        Chance = 0.01,
        Pool = FOUNDATION_POOL,
    }),
    AbandonedMine = table.freeze({
        Chance = 0.01,
        Pool = FOUNDATION_POOL,
    }),
})

--[[
Returns the optional blueprint definition for one boss.

Args:
    boss_id (string): Stable server-owned boss identifier.

Returns:
    any?: Immutable drop definition or nil when unsupported.
]]
function ProfessionBlueprintDropConfig.get_boss(
    boss_id: string
): any?
    return BOSS[boss_id]
end

--[[
Returns the optional blueprint definition for one dungeon completion.

Args:
    dungeon_id (string): Stable server-owned dungeon identifier.

Returns:
    any?: Immutable drop definition or nil when unsupported.
]]
function ProfessionBlueprintDropConfig.get_completion(
    dungeon_id: string
): any?
    return COMPLETION[dungeon_id]
end

--[[
Returns the first valid configured blueprint item.

Args:
    definition (any): Candidate drop definition.

Returns:
    string?: First configured item identifier or nil.
]]
function ProfessionBlueprintDropConfig.first_item(
    definition: any
): string?
    if type(definition) ~= "table"
        or type(definition.Pool) ~= "table"
    then
        return nil
    end

    local first = definition.Pool[1]
    return if type(first) == "table"
            and type(first.ItemId) == "string"
        then first.ItemId
        else nil
end

--[[
Rolls one independent optional profession-blueprint reward.

Args:
    definition (any): Reviewed chance and weighted pool.
    rng (any): Server-owned random provider.

Returns:
    string?: Selected blueprint item or nil when the chance misses.
]]
function ProfessionBlueprintDropConfig.roll(
    definition: any,
    rng: any
): string?
    if type(definition) ~= "table"
        or type(definition.Chance) ~= "number"
        or definition.Chance <= 0
        or type(definition.Pool) ~= "table"
        or #definition.Pool == 0
        or rng == nil
    then
        return nil
    end

    if rng:NextNumber(0, 1) >= definition.Chance then
        return nil
    end

    local total_weight = 0
    for _, entry in ipairs(definition.Pool) do
        if type(entry) == "table"
            and type(entry.Weight) == "number"
            and entry.Weight > 0
            and type(entry.ItemId) == "string"
            and entry.ItemId ~= ""
        then
            total_weight += entry.Weight
        end
    end

    if total_weight <= 0 then
        return nil
    end

    local roll = rng:NextNumber(0, total_weight)
    local cumulative = 0
    local fallback: string? = nil

    for _, entry in ipairs(definition.Pool) do
        if type(entry) == "table"
            and type(entry.Weight) == "number"
            and entry.Weight > 0
            and type(entry.ItemId) == "string"
            and entry.ItemId ~= ""
        then
            fallback = entry.ItemId
            cumulative += entry.Weight
            if roll < cumulative then
                return entry.ItemId
            end
        end
    end

    return fallback
end

return table.freeze(ProfessionBlueprintDropConfig)
