--!strict
local SkillProgressionConfig = {}

SkillProgressionConfig.MAX_ACTIVE_SLOTS = 6

local COSTS = table.freeze({
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
})

local THRESHOLDS = table.freeze({
    Common = table.freeze({[2] = 100, [3] = 300}),
    Uncommon = table.freeze({[2] = 150, [3] = 400}),
    Rare = table.freeze({[2] = 200, [3] = 500}),
    Epic = table.freeze({[2] = 300, [3] = 700}),
    Legendary = table.freeze({[2] = 400, [3] = 900}),
})

function SkillProgressionConfig.get_rank_cost(tier: string, _rank: number): number?
    return COSTS[tier]
end

function SkillProgressionConfig.get_threshold(tier: string, target_rank: number): number?
    local tier_thresholds = THRESHOLDS[tier]
    return if tier_thresholds then tier_thresholds[target_rank] else nil
end

function SkillProgressionConfig.get_max_threshold(tier: string): number
    local tier_thresholds = THRESHOLDS[tier]
    if not tier_thresholds then return 0 end
    local maximum = 0
    for _, value in pairs(tier_thresholds) do
        maximum = math.max(maximum, value)
    end
    return maximum
end

-- Gets an authored skill's next proficiency milestone; longer skill
-- families can add more ranks without changing legacy tier thresholds.
--
-- Args:
--   definition (any): Server-registered skill metadata.
--   target_rank (number): Rank the character is learning next.
-- Returns:
--   number?: Earned proficiency required for that rank.
function SkillProgressionConfig.get_skill_threshold(
    definition: any,
    target_rank: number
): number?
    local thresholds = definition.RankThresholds
    if type(thresholds) == "table" then
        return thresholds[target_rank]
    end
    return SkillProgressionConfig.get_threshold(
        definition.Tier, target_rank
    )
end

-- Caps mastery at the last authored rank's proficiency milestone.
--
-- Args:
--   definition (any): Registered skill with a declared maximum rank.
-- Returns:
--   number: Highest reachable proficiency for this skill.
function SkillProgressionConfig.get_skill_max_threshold(
    definition: any
): number
    if type(definition.RankThresholds) == "table" then
        return definition.RankThresholds[definition.MaxRank] or 0
    end
    return SkillProgressionConfig.get_max_threshold(definition.Tier)
end

return table.freeze(SkillProgressionConfig)
