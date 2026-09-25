--!strict
-- Resolves an actually owned creative active/toggle rank to its C4 source rank.

local Shared = script.Parent

local Effects = require(Shared.C4SkillEffectSource)
local Identity = require(Shared.CharacterIdentityRules)
local Map = require(Shared.C4CreativeSkillSourceMap)
local Primary = require(Shared.C4PrimaryStatReference)
local Tree = require(Shared.C4Level30SkillTreeSource)

local C4ActiveSourceEffectResolver = {}

--[[
Returns the purchased rank of one genuinely known creative skill.

Args:
    character (any): Server-owned character progression snapshot.
    skill_id (string): Creative skill identifier.

Returns:
    number: Purchased rank, or zero when the skill is not actually owned.
]]
local function owned_rank(character: any, skill_id: string): number
    local progression = type(character) == "table"
        and character.Progression
    local skills = type(progression) == "table"
        and progression.Skills
    local state = type(skills) == "table"
        and skills[skill_id]

    if type(state) ~= "table" or state.Known ~= true then
        return 0
    end

    local rank = tonumber(state.PurchasedRank) or 0
    if rank < 1 or rank % 1 ~= 0 then
        return 0
    end

    return rank
end

--[[
Builds the current and inherited starter source scopes.

Args:
    character (any): Verified original Human/Elf character.
    current_scope_id (string): Current original source class scope.

Returns:
    {string}: Starter scope first, then transfer scope when distinct.
]]
local function source_scopes(
    character: any,
    current_scope_id: string
): {string}
    local identity = character.Identity
    local race_prefix = if identity.RaceId == "Elf"
        then "Elven"
        else "Human"
    local base_suffix = if identity.BaseClassId == "Mage"
        then "Mystic"
        else "Fighter"
    local starter_scope = race_prefix .. base_suffix

    if starter_scope == current_scope_id then
        return {current_scope_id}
    end

    return {starter_scope, current_scope_id}
end

--[[
Finds one exact source active/toggle candidate for a creative rank.

Args:
    scope_id (string): Authenticated starter or transfer source scope.
    level (number): Current authoritative character level.
    creative_skill_id (string): Actually activated creative skill ID.
    creative_rank (number): Actually activated purchased creative rank.

Returns:
    (any?, string?): Matching source row or strict source-data reason.
]]
local function find_in_scope(
    scope_id: string,
    level: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local tree = Tree.get(scope_id)
    if not tree then
        return nil, "OriginalSkillTreeUnavailable"
    end

    local match = nil

    for _, row in ipairs(tree.Rows) do
        if row.MinLevel <= level then
            local link = Map.resolve(
                scope_id,
                row.SkillId,
                row.SkillLevel
            )

            if link
                and link.Status == "Candidate"
                and link.CreativeSkillId == creative_skill_id
                and link.CreativeRank == creative_rank
            then
                local effect = Effects.get_rank(
                    row.SkillId,
                    row.SkillLevel
                )
                if not effect then
                    return nil, "OriginalActiveEffectUnavailable"
                end

                local operate_type = effect.Sets.operateType
                if operate_type == "ACTIVE"
                    or operate_type == "TOGGLE"
                then
                    local candidate = {
                        ScopeId = scope_id,
                        SkillId = row.SkillId,
                        Rank = row.SkillLevel,
                        CreativeSkillId = creative_skill_id,
                        CreativeRank = creative_rank,
                        OperateType = operate_type,
                        SourceOnly = true,
                    }

                    if match
                        and (
                            match.SkillId ~= candidate.SkillId
                            or match.Rank ~= candidate.Rank
                        )
                    then
                        return nil, "AmbiguousOriginalActiveSourceRank"
                    end

                    match = candidate
                end
            end
        end
    end

    return match, nil
end

--[[
Resolves one genuinely owned active creative rank to a C4 source rank.

The resolver checks ownership separately from source learnability. A skill being
learnable at the character's level is never enough to create active state.

Args:
    character (any): Authoritative server-owned original character.
    creative_skill_id (string): Creative skill that actually activated.
    creative_rank (number): Server-resolved creative rank that activated.

Returns:
    (any?, string?): Exact ACTIVE/TOGGLE source rank or denial reason.
]]
function C4ActiveSourceEffectResolver.resolve(
    character: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not Identity.is_complete(character) then
        return nil, "OriginalCharacterIdentityNotVerified"
    end

    local reference = Primary.for_character(character)
    if not reference then
        return nil, "OriginalClassNotVerified"
    end

    local level = character.Level
    if type(level) ~= "number"
        or level % 1 ~= 0
        or level < 1
        or level > 30
    then
        return nil, "UnreviewedClassOrLevel"
    end

    if type(creative_skill_id) ~= "string"
        or creative_skill_id == ""
        or type(creative_rank) ~= "number"
        or creative_rank % 1 ~= 0
        or creative_rank < 1
    then
        return nil, "InvalidCreativeActiveSkillRank"
    end

    if owned_rank(character, creative_skill_id) < creative_rank then
        return nil, "CreativeActiveSkillRankNotOwned"
    end

    local result = nil

    for _, scope_id in ipairs(
        source_scopes(character, reference.ScopeId)
    ) do
        local candidate, reason = find_in_scope(
            scope_id,
            level,
            creative_skill_id,
            creative_rank
        )
        if reason then
            return nil, reason
        end

        if candidate then
            if result
                and (
                    result.SkillId ~= candidate.SkillId
                    or result.Rank ~= candidate.Rank
                )
            then
                return nil, "AmbiguousOriginalActiveSourceRank"
            end

            result = candidate
        end
    end

    if not result then
        return nil, "CreativeSkillNotActiveSourceCandidate"
    end

    return result, nil
end

return table.freeze(C4ActiveSourceEffectResolver)
