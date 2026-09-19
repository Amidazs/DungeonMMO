--!strict
local SkillBookDropConfig = {}

local ARC_SLASH_POOL = table.freeze({
    table.freeze({
        Weight = 1,
        ItemId = "arc_slash_book",
    }),
})

local BOSS = table.freeze({
    TempleEventBoss = table.freeze({Chance = 0.02, Pool = ARC_SLASH_POOL}),
    TempleSecretBoss = table.freeze({Chance = 0.02, Pool = ARC_SLASH_POOL}),
    AbandonedMineEventBoss = table.freeze({Chance = 0.02, Pool = ARC_SLASH_POOL}),
    AbandonedMineSecretBoss = table.freeze({Chance = 0.02, Pool = ARC_SLASH_POOL}),
    MarauderCaptain = table.freeze({
        Chance = 0.02,
        Pool = ARC_SLASH_POOL,
    }),
    CorruptedForeman = table.freeze({
        Chance = 0.02,
        Pool = ARC_SLASH_POOL,
    }),
})

local COMPLETION = table.freeze({
    TestDungeon = table.freeze({
        Chance = 0.01,
        Pool = ARC_SLASH_POOL,
    }),
    AbandonedMine = table.freeze({
        Chance = 0.01,
        Pool = ARC_SLASH_POOL,
    }),
})

function SkillBookDropConfig.get_boss(boss_id: string): any?
    return BOSS[boss_id]
end

function SkillBookDropConfig.get_completion(dungeon_id: string): any?
    return COMPLETION[dungeon_id]
end

function SkillBookDropConfig.first_item(definition: any): string?
    if type(definition) ~= "table" or type(definition.Pool) ~= "table" then
        return nil
    end
    local first = definition.Pool[1]
    return if type(first) == "table" and type(first.ItemId) == "string"
        then first.ItemId
        else nil
end

function SkillBookDropConfig.roll(definition: any, rng: any): string?
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

return table.freeze(SkillBookDropConfig)
