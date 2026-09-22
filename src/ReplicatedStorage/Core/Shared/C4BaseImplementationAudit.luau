--!strict
-- Verified functional coverage for the C4 Human/Elf starting classes.
-- A rank counts only if its server-authored effect exists at that level.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared

local Source = require(Shared.C4BaseSkillInventory)
local Progression = require(Shared.SkillProgressionDefinitions)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local C4BaseImplementationAudit = {}

-- Different original C4 level-one and later Mystic rows may use the
-- same source family but two different DungeonMMO authored skills.
local MAPPINGS = table.freeze({
    Fighter = table.freeze({
        SwordBluntStrike = table.freeze({
            [5] = "IronCleave",
            [10] = "IronCleave",
            [15] = "IronCleave",
        }),
        BowShot = table.freeze({
            [5] = "FighterBowShot",
            [10] = "FighterBowShot",
            [15] = "FighterBowShot",
        }),
        DaggerStrike = table.freeze({
            [5] = "FighterDaggerStrike",
            [10] = "FighterDaggerStrike",
            [15] = "FighterDaggerStrike",
        }),
    }),
    Mage = table.freeze({
        WindAttack = table.freeze({
            [1] = "WindStrike",
            [7] = "MysticWindBolt",
            [14] = "MysticWindBolt",
        }),
        Heal = table.freeze({
            [1] = "MageHeal",
            [7] = "MysticHealingPrayer",
            [14] = "MysticHealingPrayer",
        }),
    }),
})

--[[
Counts actual authored ranks of a combat family at the stated level.
Missing metadata or an effect with no damage or healing earns no credit.

Args:
    skill_id (string): Actual existing server-owned combat skill ID.
    level (number): Source level whose exact rank volume is checked.

Returns:
    number: Number of valid source-level ranks with real combat effects.
]]
local function executable_ranks_at_level(
    skill_id: string, level: number
): number
    local definition = Progression.get(skill_id)
    if not definition then
        return 0
    end

    local count = 0
    for rank = 1, definition.MaxRank do
        if definition.RankLevels[rank] == level then
            local effect = Combat.get_for_rank(skill_id, rank)
            local damage = effect and effect.BASE_DAMAGE or 0
            local heal = effect and effect.TOTAL_HEAL or 0
            if type(damage) == "number" and damage > 0
                or type(heal) == "number" and heal > 0
            then
                count += 1
            end
        end
    end
    return count
end

--[[
Returns source-validated combat mappings for the given base class.

Args:
    class_id (string): Fighter or Mage.

Returns:
    any?: Immutable map of C4 source category and level to game skill ID.
]]
function C4BaseImplementationAudit.mappings(class_id: string): any?
    return MAPPINGS[class_id]
end

--[[
Compares every early C4 skill family to actual source-level effects.

A category is either fully matched in the requested bracket or
remains missing. No family is credited for a partial rank count.

Args:
    race_id (string): Human or Elf.
    class_id (string): Fighter or Mage.

Returns:
    any?: Source, functional analogue and still-missing rank counts
        plus missing families, or nil if source class is unsupported.
]]
function C4BaseImplementationAudit.audit(
    race_id: string, class_id: string
): any?
    local source = Source.get(race_id, class_id)
    local mapped = MAPPINGS[class_id]
    if not source or not mapped then
        return nil
    end

    local result = {
        Raw = 0,
        Functional = 0,
        Missing = 0,
        MissingFamilies = {},
        Levels = {},
    }
    for level, families in pairs(source.Levels) do
        local bracket = {Raw = 0, Functional = 0, Missing = 0}
        for family, count in pairs(families) do
            bracket.Raw += count
            local skill_id = mapped[family] and mapped[family][level]
            local actual = if skill_id then executable_ranks_at_level(
                skill_id, level
            ) else 0
            if actual == count then
                bracket.Functional += count
            else
                bracket.Missing += count
                result.MissingFamilies[family] = (
                    result.MissingFamilies[family] or 0
                ) + count
            end
        end
        result.Levels[level] = bracket
        result.Raw += bracket.Raw
        result.Functional += bracket.Functional
        result.Missing += bracket.Missing
    end
    return result
end

return table.freeze(C4BaseImplementationAudit)
