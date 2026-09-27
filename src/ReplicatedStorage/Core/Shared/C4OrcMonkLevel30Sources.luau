--!strict
-- Historical Orc Monk source-rank inventory through level 30.
-- Category keys are audit metadata, not player-facing skill names.

local Sources = {}

local ORC_MONK = table.freeze({
    SourceClass = "Orc Monk",
    SourceClassId = 47,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 47",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            IronPunch = 3,
            WolfTotem = 1,
            Cripple = 1,
            StunningFist = 3,
            FistMastery = 1,
            LightArmorMastery = 2,
            AgileMovement = 1,
        }),
        [24] = table.freeze({
            IronPunch = 3,
            FocusForce = 1,
            ForceBlaster = 3,
            Cripple = 1,
            StunningFist = 3,
            FistMastery = 1,
            LightArmorMastery = 2,
        }),
        [28] = table.freeze({
            IronPunch = 3,
            ForceBlaster = 3,
            BearTotem = 1,
            Cripple = 1,
            StunningFist = 3,
            FistMastery = 2,
            LightArmorMastery = 2,
        }),
    }),
})

--[[
Returns the independently counted Orc Monk source inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return ORC_MONK
end

return table.freeze(Sources)
