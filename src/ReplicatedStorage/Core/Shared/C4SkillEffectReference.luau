--!strict
-- Source-only C4 Elven Knight numeric samples through level 30.
-- These are historical skill POWER and MP, not Roblox HP damage or
-- certified engine-equivalent stats. Original names are audit-only.
local Source = {}

local REFERENCE_URL = "https://l2hub.info/c4/classes/elven_knight"
local FAMILIES = table.freeze({
    GreenwardWardenElementalHeal = table.freeze({
        SourceName = "Elemental Heal",
        C4PowerField = "Heal power",
        RuntimeField = "TOTAL_HEAL",
        SourceRankOffset = 3,
        SourcePower = table.freeze({
            95, 100, 106, 118, 124, 130, 143, 150, 157,
        }),
        SourceMp = table.freeze({
            53, 57, 59, 62, 65, 69, 75, 79, 83,
        }),
    }),
    GreenwardWardenCharm = table.freeze({
        SourceName = "Charm",
        C4PowerField = "Threat effect power",
        RuntimeField = "THREAT_REDUCTION_FRACTION",
        SourceRankOffset = 0,
        SourcePower = table.freeze({
            132, 137, 143, 153, 159, 164, 176, 182, 188,
        }),
        SourceMp = table.freeze({
            37, 38, 39, 40, 42, 43, 47, 48, 49,
        }),
    }),
    GreenwardWardenAggression = table.freeze({
        SourceName = "Aggression",
        C4PowerField = "Threat effect power",
        RuntimeField = "TAUNT_BONUS_THREAT",
        SourceRankOffset = 0,
        SourcePower = table.freeze({
            655, 679, 703, 752, 777, 803,
        }),
        SourceMp = table.freeze({
            20, 21, 22, 23, 24, 25,
        }),
    }),
})

--[[
Returns historical reference data without changing combat statistics.

Args:
    skill_id (string): Independently named DungeonMMO Warden skill.

Returns:
    any?: Historical C4 values and source URL, or nil if unreviewed.
]]
function Source.get(skill_id: string): any?
    return FAMILIES[skill_id]
end

--[[
Lists all reviewed original rank-power families and their source.

Args:
    None.

Returns:
    any: Source URL and immutable per-rank historical reference rows.
]]
function Source.all(): any
    return {SourceUrl = REFERENCE_URL, Families = FAMILIES}
end

return table.freeze(Source)
