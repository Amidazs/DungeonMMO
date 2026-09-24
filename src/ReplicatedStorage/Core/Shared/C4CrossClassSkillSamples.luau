--!strict
-- Verified example C4 ranks for EVERY implemented original class path.
-- This is a source sample, not a complete rank-power or formula archive.
local Samples = {}

local ROWS = table.freeze({
    HumanFighter = table.freeze({
        SkillId = "IronCleave", Rank = 1, C4Rank = 1,
        SourceSkill = "Power Strike", Power = 25, Mp = 10,
        SourceUrl = "https://l2hub.info/c4/classes/fighter",
    }),
    ElvenFighter = table.freeze({
        SkillId = "IronCleave", Rank = 1, C4Rank = 1,
        SourceSkill = "Power Strike", Power = 25, Mp = 10,
        SourceUrl = "https://l2hub.info/c4/classes/elven_fighter",
    }),
    HumanMystic = table.freeze({
        SkillId = "WindStrike", Rank = 1, C4Rank = 1,
        SourceSkill = "Wind Strike", Power = 12, Mp = 9,
        SourceUrl = "https://l2hub.info/c4/classes/mage",
    }),
    ElvenMystic = table.freeze({
        SkillId = "WindStrike", Rank = 1, C4Rank = 1,
        SourceSkill = "Wind Strike", Power = 12, Mp = 9,
        SourceUrl = "https://l2hub.info/c4/classes/elven_mage",
    }),
    HumanRogue = table.freeze({
        SkillId = "WayfinderArrow", Rank = 1, C4Rank = 10,
        SourceSkill = "Power Shot", Power = 239, Mp = 43,
        SourceUrl = "https://l2hub.info/c4/classes/rogue",
    }),
    ElvenScout = table.freeze({
        SkillId = "WayfinderArrow", Rank = 1, C4Rank = 10,
        SourceSkill = "Power Shot", Power = 239, Mp = 43,
        SourceUrl = "https://l2hub.info/c4/classes/elven_scout",
    }),
    HumanWarrior = table.freeze({
        SkillId = "IronvowDrivingStrike", Rank = 1, C4Rank = 1,
        SourceSkill = "Power Smash", Power = 90, Mp = 22,
        SourceUrl = "https://l2hub.info/c4/classes/warrior",
    }),
    HumanKnight = table.freeze({
        SkillId = "OathguardShieldImpact", Rank = 1, C4Rank = 1,
        SourceSkill = "Shield Stun", Power = nil, Mp = 22,
        SourceUrl = "https://l2hub.info/c4/classes/knight",
    }),
    ElvenKnight = table.freeze({
        SkillId = "GreenwardWardenElementalHeal",
        Rank = 1, C4Rank = 4,
        SourceSkill = "Elemental Heal", Power = 95, Mp = 53,
        SourceUrl = "https://l2hub.info/c4/classes/elven_knight",
    }),
})

--[[
Looks up one reviewed original class/rank example, if authored.

Args:
    original_path (string): Human/Elven starter or first-transfer path.

Returns:
    any?: Historic rank and source URL or nil for unreviewed paths.
]]
function Samples.get(original_path: string): any?
    return ROWS[original_path]
end

return table.freeze(Samples)
