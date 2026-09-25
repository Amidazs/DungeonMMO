--!strict
-- Read-only nine-class source-scaled stat snapshot before live migration.
-- Equipment kind gates are C4 reference names, not untrusted item tags.
local Shared = script.Parent
local Primary = require(Shared.C4PrimaryStatReference)
local Derived = require(Shared.C4DerivedStatReference)
local Passives = require(Shared.C4PassiveStatReference)
local CombinedEffects = require(
    Shared.C4CombinedStatEffectReference
)
local ResourceRegen = require(
    Shared.C4ResourceRegenSourceRules
)
local Tree = require(Shared.C4Level30SkillTreeSource)
local Items = require(Shared.C4SourceItemReference)
local Gear = require(Shared.C4EquippedStatReference)

local C4UnifiedStatReference = {}

local BASE_MAGICAL_CRITICAL_RATE = 8

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
local function source_stats(
    naked: any,
    race_id: string,
    class_id: string,
    level: number
): any
    local regen = assert(
        ResourceRegen.base_calculator_stats(
            race_id,
            class_id,
            level
        )
    )

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
        MAGICAL_CRITICAL_RATE = BASE_MAGICAL_CRITICAL_RATE,
        PHYSICAL_CRITICAL_POWER = 1,
        PHYSICAL_CRITICAL_POWER_ADD = 0,
        FIRE_VULN = 1,
        WIND_VULN = 1,
        WATER_VULN = 1,
        EARTH_VULN = 1,
        HOLY_VULN = 1,
        DARK_VULN = 1,
        MAX_HP = naked.MaxHP,
        MAX_MP = naked.MaxMP,
        MAX_CP = naked.MaxCP,
        REG_HP_RATE = regen.REG_HP_RATE,
        REG_MP_RATE = regen.REG_MP_RATE,
        REG_CP_RATE = regen.REG_CP_RATE,
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
        source_stats(naked, race_id, class_id, level), loadout, source_ranks
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

--[[
Builds a nine-path C4 item-and-passive source stat comparison.

Only original item IDs present in the pinned reference may be used.
Weapon base stat sets and armour paperdoll adjustments run BEFORE
the source class multiplier; item MP order 0x60 runs after passives.
This remains independent of Roblox inventory, profiles and combat.

Args:
    race_id (string): Original Human or Elf race.
    class_id (string): One current original starter or first transfer.
    level (number): Supported historical class level through 30.
    item_ids (any): Reviewed C4 original six-slot source item IDs.
    source_ranks (any): Claimed original owned passive skill/rank pairs.

Returns:
    (any?, string?): Staged source stats or strict rejection reason.
]]
function C4UnifiedStatReference.get_with_source_items(
    race_id: string, class_id: string, level: number,
    item_ids: any, source_ranks: any
): (any?, string?)
    if type(source_ranks) ~= "table" then
        return nil, "UnreviewedClassOrSourceRanks"
    end
    local resolved, item_reason = Items.resolve(item_ids)
    if not resolved then return nil, item_reason end
    local reference = Primary.get(race_id, class_id)
    if not reference then return nil, "UnreviewedClassOrSourceRanks" end
    local naked, naked_reason = Derived.get_naked_combat(
        race_id, class_id, level, resolved.Items.Weapon ~= nil
    )
    if not naked then return nil, naked_reason end
    for _, rank_id in ipairs(source_ranks) do
        if not is_learnable(reference.ScopeId, rank_id, level) then
            return nil, "OriginalPassiveNotLearnableByClassOrLevel"
        end
    end
    local staged = Gear.stage(
        source_stats(naked, race_id, class_id, level), naked, resolved, class_id == "Mage"
    )
    local passive, passive_reason = Passives.apply_loadout(
        staged.Stats, resolved.Kinds, source_ranks
    )
    if not passive then return nil, passive_reason end
    local values = table.clone(passive.Stats)
    values.MAX_MP += staged.DeferredMaxMp
    return {
        ScopeId = reference.ScopeId, Level = level,
        SourceItemIds = table.clone(item_ids),
        SourceKinds = resolved.Kinds, SourceCommit = resolved.SourceCommit,
        Naked = naked, EquippedStats = values,
        AppliedSourceModifiers = passive.AppliedModifiers,
        CurrentSixSlotPaperdollIntegrated = true,
        OriginalBodyLegSemanticsIntegrated =
            staged.OriginalLegsSemanticsIntegrated,
        FullOriginalPaperdollIntegrated = false,
        EnchantmentsIntegrated = false, ActiveBuffsIntegrated = false,
        LiveCombatIntegrated = false,
        ExactFinalC4StatsCertified = false,
    }, nil
end

--[[
Builds a source stat snapshot with owned passives and active effects merged.

Passive and active/toggle modifiers share one C4 calculator queue, so every
0x30 function executes before every 0x40 function regardless of origin.
The active-rank list must describe effects that are actually active; this
function does not infer active state from learned skills.

Args:
    race_id (string): Original Human or Elf race.
    class_id (string): Current original starter or first-transfer class.
    level (number): Supported historical class level through 30.
    item_ids (any): Reviewed six-slot source item IDs.
    passive_ranks (any): Actually owned historical passive ranks.
    active_ranks (any): Actually active historical ACTIVE/TOGGLE ranks.

Returns:
    (any?, string?): Ordered source stat snapshot or strict rejection reason.
]]
function C4UnifiedStatReference.get_with_source_effects(
    race_id: string,
    class_id: string,
    level: number,
    item_ids: any,
    passive_ranks: any,
    active_ranks: any
): (any?, string?)
    if type(passive_ranks) ~= "table"
        or type(active_ranks) ~= "table"
    then
        return nil, "UnreviewedClassOrSourceRanks"
    end

    local resolved, item_reason = Items.resolve(item_ids)
    if not resolved then
        return nil, item_reason
    end

    local reference = Primary.get(race_id, class_id)
    if not reference then
        return nil, "UnreviewedClassOrSourceRanks"
    end

    local naked, naked_reason = Derived.get_naked_combat(
        race_id,
        class_id,
        level,
        resolved.Items.Weapon ~= nil
    )
    if not naked then
        return nil, naked_reason
    end

    for _, rank_id in ipairs(passive_ranks) do
        if not is_learnable(reference.ScopeId, rank_id, level) then
            return nil, "OriginalPassiveNotLearnableByClassOrLevel"
        end
    end

    for _, rank_id in ipairs(active_ranks) do
        if not is_learnable(reference.ScopeId, rank_id, level) then
            return nil, "OriginalActiveNotLearnableByClassOrLevel"
        end
    end

    local staged = Gear.stage(
        source_stats(naked, race_id, class_id, level),
        naked,
        resolved,
        class_id == "Mage"
    )
    local combined, combined_reason = CombinedEffects.apply(
        staged.Stats,
        resolved.Kinds,
        passive_ranks,
        active_ranks
    )
    if not combined then
        return nil, combined_reason
    end

    local values = table.clone(combined.Stats)
    values.MAX_MP += staged.DeferredMaxMp

    return {
        ScopeId = reference.ScopeId,
        Level = level,
        SourceItemIds = table.clone(item_ids),
        SourceKinds = resolved.Kinds,
        SourceCommit = resolved.SourceCommit,
        Naked = naked,
        EquippedStats = values,
        AppliedSourceModifiers = combined.AppliedModifiers,
        SelectedActiveEffects = combined.SelectedActiveEffects,
        CurrentSixSlotPaperdollIntegrated = true,
        ActiveEffectOrderingIntegrated = true,
        ActiveEffectStateAuthoritative = false,
        FullOriginalPaperdollIntegrated = false,
        EnchantmentsIntegrated = false,
        LiveCombatIntegrated = false,
        ExactFinalC4StatsCertified = false,
    }, nil
end

return table.freeze(C4UnifiedStatReference)
