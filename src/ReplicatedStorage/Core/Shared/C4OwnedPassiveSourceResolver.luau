--!strict
-- Resolves only actually owned creative passive ranks to C4 source ranks.

local Shared = script.Parent

local Effects = require(Shared.C4SkillEffectSource)
local Identity = require(Shared.CharacterIdentityRules)
local Map = require(Shared.C4CreativeSkillSourceMap)
local Primary = require(Shared.C4PrimaryStatReference)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local Tree = require(Shared.C4Level30SkillTreeSource)

local C4OwnedPassiveSourceResolver = {}

local SAFE_NON_STAT_PASSIVES = table.freeze({
    C4RecipeReading = true,
})

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
Builds the authenticated current and inherited starter source scopes.

Args:
    character (any): Verified original Human/Elf character.
    current_scope_id (string): Current original class source scope.

Returns:
    {string}: Starter scope first, then current first-transfer scope if distinct.
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
Returns true when a source passive has calculator modifiers to migrate.

Automatic/passive utility skills with no stat modifiers are still recognized
as mapped ownership, but they are not sent to the stat modifier calculator.

Args:
    effect (any): Pinned C4 skill-effect rank.

Returns:
    boolean: True only for passive source ranks with stat modifiers.
]]
local function has_stat_modifiers(effect: any): boolean
    return effect.Sets.operateType == "PASSIVE"
        and type(effect.Modifiers) == "table"
        and #effect.Modifiers > 0
end

--[[
Records the highest actually owned source rank for one passive family.

Args:
    owned_by_source (any): Mutable source-skill result dictionary.
    row (any): C4 learning-tree row.
    link (any): Reviewed creative candidate for that source rank.
    creative_owned_rank (number): Actual purchased creative rank.

Returns:
    nil: Replaces only an older source rank from the same source skill.
]]
local function record_owned_source_rank(
    owned_by_source: any,
    row: any,
    link: any,
    creative_owned_rank: number
)
    if type(link.CreativeRank) ~= "number"
        or link.CreativeRank < 1
        or creative_owned_rank < link.CreativeRank
    then
        return
    end

    local current = owned_by_source[row.SkillId]
    if current and current.Rank >= row.SkillLevel then
        return
    end

    owned_by_source[row.SkillId] = {
        SkillId = row.SkillId,
        Rank = row.SkillLevel,
        CreativeSkillId = link.CreativeSkillId,
        CreativeRank = link.CreativeRank,
    }
end

--[[
Inspects one source scope for passive candidate ownership at current level.

Args:
    scope_id (string): Authenticated starter or first-transfer source scope.
    level (number): Current authoritative character level.
    character (any): Server-owned progression state.
    owned_by_source (any): Mutable highest-source-rank dictionary.
    mapped_creative (any): Mutable reviewed creative passive dictionary.
    max_mapped_rank (any): Mutable max reviewed creative rank by skill ID.

Returns:
    (boolean, string?): True on complete source inspection, or strict reason.
]]
local function inspect_scope(
    scope_id: string,
    level: number,
    character: any,
    owned_by_source: any,
    mapped_creative: any,
    max_mapped_rank: any
): (boolean, string?)
    local tree = Tree.get(scope_id)
    if not tree then
        return false, "OriginalSkillTreeUnavailable"
    end

    for _, row in ipairs(tree.Rows) do
        if row.MinLevel <= level then
            local effect = Effects.get_rank(row.SkillId, row.SkillLevel)
            if not effect then
                return false, "OriginalPassiveEffectUnavailable"
            end

            if effect.Sets.operateType == "PASSIVE" then
                local link = Map.resolve(
                    scope_id,
                    row.SkillId,
                    row.SkillLevel
                )

                if link and link.Status == "Candidate"
                    and type(link.CreativeSkillId) == "string"
                then
                    local definition = SkillDefinitions.get(
                        link.CreativeSkillId
                    )

                    if definition and definition.Kind == "Passive" then
                        mapped_creative[link.CreativeSkillId] = true
                        local rank = tonumber(link.CreativeRank) or 0
                        max_mapped_rank[link.CreativeSkillId] = math.max(
                            max_mapped_rank[link.CreativeSkillId] or 0,
                            rank
                        )

                        if has_stat_modifiers(effect) then
                            record_owned_source_rank(
                                owned_by_source,
                                row,
                                link,
                                owned_rank(
                                    character,
                                    link.CreativeSkillId
                                )
                            )
                        end
                    end
                end
            end
        end
    end

    return true, nil
end

--[[
Audits owned creative passives not safely represented by current source scope.

Args:
    character (any): Server-owned purchased skill state.
    mapped_creative (any): Creative passives represented by source rows.
    max_mapped_rank (any): Highest reviewed creative rank at this level.

Returns:
    (any, any): Unsupported passive IDs and mapped-rank overflow rows.
]]
local function audit_owned_passives(
    character: any,
    mapped_creative: any,
    max_mapped_rank: any
): (any, any)
    local unsupported = {}
    local overflow = {}
    local progression = character.Progression
    local skills = type(progression) == "table"
        and progression.Skills
        or {}

    for skill_id, state in pairs(skills) do
        local definition = SkillDefinitions.get(skill_id)
        local rank = owned_rank(character, skill_id)

        if rank >= 1
            and definition
            and definition.Kind == "Passive"
        then
            if SAFE_NON_STAT_PASSIVES[skill_id] then
                continue
            end

            if not mapped_creative[skill_id] then
                table.insert(unsupported, skill_id)
            elseif rank > (max_mapped_rank[skill_id] or 0) then
                table.insert(overflow, {
                    SkillId = skill_id,
                    OwnedRank = rank,
                    MaxReviewedRank = max_mapped_rank[skill_id] or 0,
                })
            end
        end
    end

    table.sort(unsupported)
    table.sort(overflow, function(left, right)
        return left.SkillId < right.SkillId
    end)

    return unsupported, overflow
end

--[[
Converts actually owned current passive ranks to highest owned C4 source ranks.

Level merely limits which historical ranks may be reviewed; it never grants a
rank by itself. First-transfer characters also inspect their inherited starter
scope. Unmapped custom passives and saved ranks beyond the reviewed C4 mapping
are surfaced explicitly and keep the result non-ready.

Args:
    character (any): Authoritative server-owned original character.

Returns:
    (any?, string?): Owned passive migration snapshot or strict denial reason.
]]
function C4OwnedPassiveSourceResolver.for_character(
    character: any
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

    local owned_by_source = {}
    local mapped_creative = {}
    local max_mapped_rank = {}

    for _, scope_id in ipairs(
        source_scopes(character, reference.ScopeId)
    ) do
        local ok, reason = inspect_scope(
            scope_id,
            level,
            character,
            owned_by_source,
            mapped_creative,
            max_mapped_rank
        )
        if not ok then
            return nil, reason
        end
    end

    local source_ranks = {}
    for _, row in pairs(owned_by_source) do
        table.insert(source_ranks, row)
    end
    table.sort(source_ranks, function(left, right)
        return left.SkillId < right.SkillId
    end)

    local unsupported, overflow = audit_owned_passives(
        character,
        mapped_creative,
        max_mapped_rank
    )

    return {
        ScopeId = reference.ScopeId,
        SourceRanks = source_ranks,
        UnsupportedOwnedCreativePassives = unsupported,
        UnresolvedOwnedPassiveRanks = overflow,
        Ready = #unsupported == 0 and #overflow == 0,
        SourceOnly = true,
        LiveIntegrated = false,
    }, nil
end

return table.freeze(C4OwnedPassiveSourceResolver)
