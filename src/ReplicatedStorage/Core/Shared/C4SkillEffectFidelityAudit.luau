--!strict
-- Report source/runtime discrepancies; do not claim C4 formula parity.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared
local Combat = ReplicatedStorage.Combat.Shared
local Source = require(Shared.C4SkillEffectReference)
local Progression = require(Shared.SkillProgressionDefinitions)
local Skills = require(Combat.SkillDefinitions)

local Audit = {}

--[[
Checks a specific source rank against authored runtime skill parameters.

The source skill power and current Roblox runtime field intentionally
have different units and meanings. A numeric difference is evidence
of a different implementation, not a proposed HP conversion formula.

Args:
    skill_id (string): Audited independent Warden skill identifier.
    family (any): Verified C4 power, MP and rank offset reference.
    rank (number): One purchased DungeonMMO skill rank.

Returns:
    any: Source and runtime values and explicit parity limitation.
]]
local function compare_rank(
    skill_id: string, family: any, rank: number
): any
    local current = assert(Skills.get_for_rank(skill_id, rank))
    local source_power = assert(family.SourcePower[rank])
    local source_mp = assert(family.SourceMp[rank])
    return {
        SkillId = skill_id,
        DungeonRank = rank,
        OriginalRank = rank + family.SourceRankOffset,
        OriginalPower = source_power,
        OriginalMp = source_mp,
        OriginalField = family.C4PowerField,
        RuntimeField = family.RuntimeField,
        RuntimeMagnitude = current[family.RuntimeField],
        RuntimeMana = current.MANA_COST,
        ManaNumberMatches = current.MANA_COST == source_mp,
        MagnitudesAreComparable = false,
        ExactMechanicCertified = false,
    }
end

--[[
Audits reviewed C4 reference rows against actual resolved runtime ranks.

Args:
    None.

Returns:
    any: Reviewed rank count, MP mismatches and uncertified mechanics.
]]
function Audit.report(): any
    local source = Source.all()
    local rows = {}
    local different_mp = 0
    local skills_checked = 0
    for skill_id, family in pairs(source.Families) do
        local progression = assert(Progression.get(skill_id))
        assert(progression.MaxRank == #family.SourcePower
            and #family.SourcePower == #family.SourceMp,
            "C4 reference ranks differ from current skill schedule")
        skills_checked += 1
        for rank = 1, progression.MaxRank do
            local row = compare_rank(skill_id, family, rank)
            table.insert(rows, row)
            if not row.ManaNumberMatches then
                different_mp += 1
            end
        end
    end
    table.sort(rows, function(left, right)
        if left.SkillId == right.SkillId then
            return left.DungeonRank < right.DungeonRank
        end
        return left.SkillId < right.SkillId
    end)
    return {
        SourceUrl = source.SourceUrl,
        ReviewedFamilies = skills_checked,
        ReviewedRankRows = #rows,
        DifferentManaNumbers = different_mp,
        Rows = rows,
        SourceAndRuntimeMagnitudesAreNotEquivalentUnits = true,
        ExactC4ParityCertified = false,
        OtherSkillFamiliesStillNeedFullReview = true,
    }
end

return table.freeze(Audit)
