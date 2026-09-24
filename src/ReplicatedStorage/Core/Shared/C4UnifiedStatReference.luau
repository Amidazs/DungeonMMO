--!strict
-- Read-only nine-class source-scaled stat snapshot before live migration.
-- Equipment kind gates are C4 reference names, not untrusted item tags.
local Shared = script.Parent
local Primary = require(Shared.C4PrimaryStatReference)
local Derived = require(Shared.C4DerivedStatReference)
local Passives = require(Shared.C4PassiveStatReference)
local Tree = require(Shared.C4Level30SkillTreeSource)

local C4UnifiedStatReference = {}

--[[
Finds a learned source rank in its original class or inherited starter.

Args:
    scope_id (string): Verified original race/class learning-tree path.
    source_rank (any): Original SkillId and Rank pair.
    level (number): Current C4 character level.

Returns:
    boolean: True only for an actually learnable source rank at level.
]]
local function is_learnable(
    scope_id: string, source_rank: any, level: number
): boolean
    if type(source_rank) ~= "table" then return false end
    local scope = Tree.get(scope_id)
    if not scope then return false end
    local paths = {scope}
    if scope.ClassId ~= "Fighter" and scope.ClassId ~= "Mage" then
        local starter = if scope.RaceId == "Elf"
            then "Elven" else "Human"
        local base = if scope.ClassId == "GreenwardScout"
            or scope.ClassId == "GreenwardWarden"
            or scope.ClassId == "Ashenblade"
            or scope.ClassId == "Ironvow"
            or scope.ClassId == "Oathguard"
            then "Fighter" else "Mystic"
        table.insert(paths, assert(Tree.get(starter .. base)))
    end
    for _, current in ipairs(paths) do
        for _, row in ipairs(current.Rows) do
            if row.SkillId == source_rank.SkillId
                and row.SkillLevel == source_rank.Rank
                and row.MinLevel <= level
            then return true end
        end
    end
    return false
end

--[[
Uses exactly the source-defined naked stats as passive calculator inputs.

No item additive stats, enchantments or active buff results are guessed.

Args:
    naked (any): Verified C4 nine-path naked derived-stat record.

Returns:
    any: Fresh source-name stat table suitable for C4 passive functions.
]]
local function source_stats(naked: any): any
    return {
        PHYSICAL_ATTACK = naked.NakedPAtk,
        PHYSICAL_DEFENCE = naked.NakedPDef,
        MAGICAL_ATTACK = naked.NakedMAtk,
        MAGICAL_DEFENCE = naked.NakedMDef,
        PHYSICAL_ATTACK_SPEED = naked.PhysicalAttackSpeed,
        MAGICAL_ATTACK_SPEED = naked.MagicalAttackSpeed,
        RUN_SPEED = naked.RunSpeed,
        ACCURACY_COMBAT = naked.Accuracy,
        EVASION_RATE = naked.Evasion,
        CRITICAL_RATE = naked.PhysicalCriticalRate,
        MAX_HP = naked.MaxHP,
        MAX_MP = naked.MaxMP,
        MAX_CP = naked.MaxCP,
    }
end

--[[
Composes one full source HP/MP/CP and naked-to-passive snapshot.

The caller supplies original class identity, exact original item kinds
and authentic original passive ranks. This does not calculate item stat
bonuses or enable live character combat, equipment, buffs or CP.

Args:
    race_id (string): Human or Elf C4 race identifier.
    class_id (string): Current creative original class identifier.
    level (number): Supported C4 level through initial level 30.
    loadout (any): Trusted C4 Weapon, Body and OffHand kinds.
    source_ranks (any): Distinct historical passive skill/rank pairs.

Returns:
    (any?, string?): Source-scaled snapshot or fail-closed reason.
]]
function C4UnifiedStatReference.get(
    race_id: string, class_id: string, level: number,
    loadout: any, source_ranks: any
): (any?, string?)
    local primary = Primary.get(race_id, class_id)
    local scope = primary and primary.ScopeId
    if not scope or type(source_ranks) ~= "table" then
        return nil, "UnreviewedClassOrSourceRanks"
    end
    local naked, reason = Derived.get_naked_combat(
        race_id, class_id, level,
        type(loadout) == "table" and loadout.Weapon ~= nil
    )
    if not naked then return nil, reason end
    for _, rank_id in ipairs(source_ranks) do
        if not is_learnable(scope, rank_id, level) then
            return nil, "OriginalPassiveNotLearnableByClassOrLevel"
        end
    end
    local result, issue = Passives.apply_loadout(
        source_stats(naked), loadout, source_ranks
    )
    if not result then return nil, issue end
    return {
        ScopeId = scope,
        Level = level,
        PrimaryStats = primary.Stats,
        Naked = naked,
        PassiveStatSnapshot = result.Stats,
        AppliedSourceModifiers = result.AppliedModifiers,
        SourceCommit = primary.SourceCommit,
        -- Source item additive stats and active buffs MUST be applied
        -- before treating this as a complete C4 damage/HP/MP input.
        OriginalItemStatsIntegrated = false,
        ActiveBuffsIntegrated = false,
        LiveCombatIntegrated = false,
        ExactFinalC4StatsCertified = false,
    }, nil
end

return table.freeze(C4UnifiedStatReference)
