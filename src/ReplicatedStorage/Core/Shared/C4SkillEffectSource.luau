--!strict
-- C4 source-effect catalogue for every source skill used by the nine
-- currently implemented original paths through character level 30.
local Data1 = require(script.Parent.C4SkillEffectSourceData01)
local Data2 = require(script.Parent.C4SkillEffectSourceData02)
local Data3 = require(script.Parent.C4SkillEffectSourceData03)
local Data4 = require(script.Parent.C4SkillEffectSourceData04)
local Data5 = require(script.Parent.C4SkillEffectSourceData05)
local Data6 = require(script.Parent.C4SkillEffectSourceData06)
local Data7 = require(script.Parent.C4SkillEffectSourceData07)
local Data8 = require(script.Parent.C4SkillEffectSourceData08)

local C4SkillEffectSource = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local SOURCES = table.freeze({
    Data1,
    Data2,
    Data3,
    Data4,
    Data5,
    Data6,
    Data7,
    Data8,
})

local BY_ID = {}
for _, source in ipairs(SOURCES) do
    for skill_id, definition in pairs(source) do
        assert(BY_ID[skill_id] == nil,
            "Duplicate C4 source skill " .. tostring(skill_id))
        BY_ID[skill_id] = definition
    end
end

--[[
Returns one immutable, rank-resolved Chronicle 4 source skill.

Args:
    skill_id (number): Original C4 skill identifier.

Returns:
    any?: Exact source skill metadata used by the current level-30 scope.
]]
function C4SkillEffectSource.get(skill_id: number): any?
    return BY_ID[skill_id]
end

--[[
Returns one exact rank-resolved Chronicle 4 source definition.

Args:
    skill_id (number): Original C4 skill identifier.
    skill_level (number): Original C4 skill level.

Returns:
    any?: Sets, passive modifiers, effects and conditions at that rank.
]]
function C4SkillEffectSource.get_rank(
    skill_id: number, skill_level: number
): any?
    local skill = BY_ID[skill_id]
    return skill and skill.Ranks[skill_level] or nil
end

--[[
Reports complete effect-source coverage for the current C4 learning tree.

Args:
    None.

Returns:
    any: Source skill and rank counts with pinned C4 provenance.
]]
function C4SkillEffectSource.coverage(): any
    local skills = 0
    local ranks = 0
    for _, skill in pairs(BY_ID) do
        skills += 1
        for _ in pairs(skill.Ranks) do
            ranks += 1
        end
    end
    return {
        SourceCommit = SOURCE_COMMIT,
        SkillCount = skills,
        RequiredSkillRankPairs = ranks,
        LiveCombatIntegrated = false,
    }
end

return table.freeze(C4SkillEffectSource)
