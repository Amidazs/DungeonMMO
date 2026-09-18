--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local DungeonDifficultyDefinitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local DungeonModifierDefinitions = require(
    Shared:WaitForChild("DungeonModifierDefinitions")
)

local DungeonDifficultyTuning = {}

local function rounded(value: number, multiplier: number): number
    return math.max(0, math.floor(value * multiplier + 0.5))
end

local function shallow_copy(source: any): any
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end
-- Resolves server-owned difficulty and modifier tuning for one run.
function DungeonDifficultyTuning.resolve(
    dungeon_id: string,
    difficulty_id: string?,
    modifier_id: string?
): any?
    local difficulty = DungeonDifficultyDefinitions.resolve(
        dungeon_id,
        difficulty_id
    )
    if not difficulty then
        return nil
    end

    local modifier = if type(modifier_id) == "string"
        then DungeonModifierDefinitions.get(modifier_id)
        else nil
    local modifier_health = if modifier
        then tonumber(modifier.EnemyHealthMultiplier) or 1
        else 1

    return {
        DifficultyId = difficulty.Id,
        DifficultyOrder = difficulty.Order,
        EnemyHealthMultiplier =
            difficulty.EnemyHealthMultiplier * modifier_health,
        EnemyDamageMultiplier =
            difficulty.EnemyDamageMultiplier,
        MonsterRewardMultiplier =
            difficulty.MonsterRewardMultiplier,
        CompletionGoldMultiplier =
            difficulty.CompletionGoldMultiplier,
    }
end

-- Returns a detached monster reward with difficulty scaling applied.
function DungeonDifficultyTuning.scale_monster_reward(
    reward: any,
    tuning: any
): any
    local result = shallow_copy(reward)
    local multiplier =
        tonumber(tuning.MonsterRewardMultiplier) or 1

    result.XP = rounded(tonumber(reward.XP) or 0, multiplier)
    result.GoldMin = rounded(
        tonumber(reward.GoldMin) or 0,
        multiplier
    )
    result.GoldMax = rounded(
        tonumber(reward.GoldMax) or 0,
        multiplier
    )
    return result
end
-- Returns a detached completion reward with difficulty Gold scaling.
function DungeonDifficultyTuning.scale_completion_reward(
    reward: any,
    tuning: any
): any
    local result = shallow_copy(reward)
    local multiplier =
        tonumber(tuning.CompletionGoldMultiplier) or 1

    result.Gold = rounded(
        tonumber(reward.Gold) or 0,
        multiplier
    )
    return result
end

return table.freeze(DungeonDifficultyTuning)
