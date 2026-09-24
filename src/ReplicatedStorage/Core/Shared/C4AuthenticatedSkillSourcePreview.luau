--!strict
-- Original C4 learning/effect previews for actual nine-path identities.
-- This does not add skills, modify SP, or replace live combat executors.
local Shared = script.Parent

local Identity = require(Shared.CharacterIdentityRules)
local Primary = require(Shared.C4PrimaryStatReference)
local Tree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)
local Map = require(Shared.C4CreativeSkillSourceMap)

local C4AuthenticatedSkillSourcePreview = {}

--[[
Resolves one original skill source row and its creative implementation gap.

C4 source power is kept separate from current Roblox HP/damage units.
A candidate creative skill is not treated as mechanically equivalent.

Args:
    scope_id (string): Authenticated historical class path.
    row (any): Source learning row whose minimum level was reached.

Returns:
    any: Original cost/target/timing/effects and candidate/gap status.
]]
local function inspect_row(scope_id: string, row: any): any
    local effect = assert(Effects.get_rank(row.SkillId, row.SkillLevel),
        "Missing pinned original C4 rank " .. tostring(row.SkillId))
    local link = assert(Map.resolve(
        scope_id, row.SkillId, row.SkillLevel
    ), "Unexamined original C4 source row " .. tostring(row.SkillId))
    local sets = effect.Sets
    local initial_mp = sets.mpInitialConsume or 0
    local ongoing_mp = sets.mpConsume or 0
    return {
        SourceSkillId = row.SkillId,
        SourceSkillName = row.SkillName,
        SourceSkillLevel = row.SkillLevel,
        SourceLearnLevel = row.MinLevel,
        SourceSP = row.SP,
        SourceTarget = sets.target,
        SourceSkillType = sets.skillType,
        SourceInitialMP = initial_mp,
        SourceOngoingMP = ongoing_mp,
        SourceTotalMP = initial_mp + ongoing_mp,
        SourceReuseMs = sets.reuseDelay,
        SourceCastMs = sets.hitTime,
        OriginalEffects = effect.Effects,
        OriginalModifiers = effect.Modifiers,
        OriginalConditions = effect.Conditions,
        CreativeLinkStatus = link.Status,
        CreativeSkillId = link.CreativeSkillId,
        CreativeSkillRank = link.CreativeRank,
        MissingReason = link.Reason,
        ExactC4EffectCertified = false,
        LiveIntegrated = false,
    }
end

--[[
Shows only source skills reachable by an authoritative original class.

A returned rank means "historically learnable at this level"; it does
NOT mean the player has purchased it or has sufficient original SP.

Args:
    character (any): Full server-owned race/class/level/mentor profile.

Returns:
    (any?, string?): Source tree snapshot or fail-closed reason.
]]
function C4AuthenticatedSkillSourcePreview.for_character(
    character: any
): (any?, string?)
    if not Identity.is_complete(character) then
        return nil, "OriginalCharacterIdentityNotVerified"
    end
    local reference = Primary.for_character(character)
    if not reference then return nil, "OriginalClassNotVerified" end
    local level = character.Level
    if type(level) ~= "number" or level % 1 ~= 0
        or level < 1 or level > 30
    then return nil, "UnreviewedClassOrLevel" end
    local tree = Tree.get(reference.ScopeId)
    if not tree then return nil, "OriginalSkillTreeUnavailable" end
    local rows = {}
    local candidate_count = 0
    local gap_count = 0
    for _, row in ipairs(tree.Rows) do
        if row.MinLevel <= level then
            local skill = inspect_row(reference.ScopeId, row)
            table.insert(rows, skill)
            if skill.CreativeLinkStatus == "Candidate" then
                candidate_count += 1
            else
                gap_count += 1
            end
        end
    end
    return {
        ScopeId = reference.ScopeId,
        CharacterLevel = level,
        SourceCommit = reference.SourceCommit,
        SourceRowsAtLevel = #rows,
        CreativeCandidateRows = candidate_count,
        ExplicitMissingRows = gap_count,
        Rows = rows,
        SourceOnly = true,
        LiveIntegrated = false,
        ExactC4EffectCertified = false,
    }, nil
end

return table.freeze(C4AuthenticatedSkillSourcePreview)
