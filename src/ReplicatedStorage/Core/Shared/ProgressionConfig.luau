--!strict

local ProgressionConfig = {}

-- First extended progression bracket: initial class transfer at 20,
-- specialist ranks through 32 and room for the next transfer at 40.
ProgressionConfig.MAX_LEVEL = 40

local XP_TO_NEXT_LEVEL = table.freeze({
    [1] = 100,
    [2] = 150,
    [3] = 200,
    [4] = 275,
    [5] = 350,
    [6] = 450,
    [7] = 575,
    [8] = 725,
    [9] = 900,

    [10] = 1100,
    [11] = 1325,
    [12] = 1575,
    [13] = 1850,
    [14] = 2150,
    [15] = 2475,
    [16] = 2825,
    [17] = 3200,
    [18] = 3600,
    [19] = 4025,
})

-- Returns the exact established early-level thresholds, then extends
-- the curve deterministically through the next class-transfer bracket.
--
-- Args:
--   level (number): Current integer character level.
-- Returns:
--   number?: XP required for the next level, or nil at level cap.
function ProgressionConfig.get_required_xp(
    level: number
): number?
    assert(
        level >= 1 and level % 1 == 0,
        "level must be a positive integer"
    )

    if level >= ProgressionConfig.MAX_LEVEL then
        return nil
    end
    if level <= 19 then
        return XP_TO_NEXT_LEVEL[level]
    end

    -- Do not retroactively retune the established 1-20 progression.
    local growth_steps = level - 19
    local required = XP_TO_NEXT_LEVEL[19] * (1.12 ^ growth_steps)
    return math.floor(required + 0.5)
end

function ProgressionConfig.level_entitlement(
    level: number
): number
    return math.clamp(
        math.floor(level) - 1,
        0,
        ProgressionConfig.MAX_LEVEL - 1
    )
end

return table.freeze(ProgressionConfig)