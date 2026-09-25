--!strict
-- Fail-closed boundary for the eventual live Chronicle 4 resource migration.

local Shared = script.Parent

local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)
local C4PrimaryStatReference = require(
    Shared:WaitForChild("C4PrimaryStatReference")
)
local C4CreativeItemSourceMap = require(
    Shared:WaitForChild("C4CreativeItemSourceMap")
)
local C4EquipmentExpertiseRules = require(
    Shared:WaitForChild("C4EquipmentExpertiseRules")
)
local C4OwnedPassiveSourceResolver = require(
    Shared:WaitForChild("C4OwnedPassiveSourceResolver")
)
local C4UnifiedStatReference = require(
    Shared:WaitForChild("C4UnifiedStatReference")
)

local C4ResourceMigrationBoundary = {}

local FIXED_ACTIVATION_BLOCKERS = table.freeze({
    "LiveCPRuntimeUnavailable",
})

--[[
Validates a server-owned active-source snapshot before source composition.

The snapshot is produced by the private server registry. Validation here is
still strict so an internal caller cannot accidentally pass malformed or
duplicate source ranks into the migration candidate.

Args:
    snapshot (any): Server-owned active source-effect state snapshot.

Returns:
    (boolean, string?): Ready state and stable denial reason.
]]
local function validate_active_snapshot(
    snapshot: any
): (boolean, string?)
    if type(snapshot) ~= "table"
        or snapshot.Authoritative ~= true
    then
        return false, "AuthoritativeActiveEffectStateUnavailable"
    end

    if snapshot.Ready ~= true then
        return false, "OriginalActiveEffectMappingIncomplete"
    end

    if type(snapshot.SourceRanks) ~= "table"
        or type(snapshot.UnresolvedEffects) ~= "table"
        or #snapshot.UnresolvedEffects > 0
    then
        return false, "InvalidAuthoritativeActiveEffectState"
    end

    local seen = {}

    for _, row in ipairs(snapshot.SourceRanks) do
        if type(row) ~= "table"
            or type(row.SkillId) ~= "number"
            or row.SkillId % 1 ~= 0
            or row.SkillId < 1
            or type(row.Rank) ~= "number"
            or row.Rank % 1 ~= 0
            or row.Rank < 1
            or seen[row.SkillId]
        then
            return false, "InvalidAuthoritativeActiveEffectState"
        end

        seen[row.SkillId] = true
    end

    return true, nil
end

--[[
Copies activation blockers so callers cannot mutate shared state.

Equipment, owned-passive and active-effect readiness are character-specific.
CP authority remains the final fixed coordinated blocker.

Args:
    equipment_ready (boolean): Reviewed equipment and Expertise are ready.
    passives_ready (boolean): Actually owned source passives are ready.
    active_effects_ready (boolean): Authoritative active source state is ready.

Returns:
    {string}: Independent list of unresolved live-migration requirements.
]]
local function copy_activation_blockers(
    equipment_ready: boolean,
    passives_ready: boolean,
    active_effects_ready: boolean
): {string}
    local result = {}

    if not equipment_ready then
        table.insert(result, "OriginalEquipmentMigrationIncomplete")
    end

    if not passives_ready then
        table.insert(result, "OriginalOwnedPassiveMappingIncomplete")
    end

    if not active_effects_ready then
        table.insert(result, "ActiveEffectOrderingIncomplete")
    end

    for _, blocker in ipairs(FIXED_ACTIVATION_BLOCKERS) do
        table.insert(result, blocker)
    end

    return result
end

--[[
Builds an authenticated C4 resource migration boundary for one character.

This deliberately exposes source HP/MP/CP and staged stat candidates without
applying them to Humanoid, ManaService or a CP runtime. The active snapshot is
optional so callers without the private server registry remain fail-closed.

Args:
    character (any): Server-owned selected character snapshot.
    active_snapshot (any?): Private authoritative active-effect snapshot.

Returns:
    (any?, string?): Exact source-resource plan or strict denial reason.
]]
function C4ResourceMigrationBoundary.for_character(
    character: any,
    active_snapshot: any?
): (any?, string?)
    if not CharacterIdentityRules.is_complete(character) then
        return nil, "OriginalCharacterIdentityNotVerified"
    end

    local reference = C4PrimaryStatReference.for_character(character)
    if not reference then
        return nil, "OriginalClassNotVerified"
    end

    local identity = character.Identity
    local vitals, reason = C4PrimaryStatReference.get_level_vitals(
        identity.RaceId,
        identity.ClassId,
        character.Level
    )

    if not vitals then
        return nil, reason
    end

    local reviewed_loadout, loadout_reason =
        C4CreativeItemSourceMap.resolve_loadout(
            character.Equipment or {}
        )
    local equipment_expertise = nil
    local equipment_reason = loadout_reason

    if reviewed_loadout then
        equipment_expertise, equipment_reason =
            C4EquipmentExpertiseRules.validate(
                character.Level,
                reviewed_loadout.SourceItemIds
            )
    end

    local inventory_ready = reviewed_loadout ~= nil
        and equipment_expertise ~= nil

    local passive_plan, passive_reason =
        C4OwnedPassiveSourceResolver.for_character(character)
    local passive_mapping_ready = passive_plan ~= nil
        and passive_plan.Ready

    local passive_candidate = nil
    local passive_candidate_reason = passive_reason

    if inventory_ready and passive_mapping_ready then
        passive_candidate, passive_candidate_reason =
            C4UnifiedStatReference.get_with_source_items(
                identity.RaceId,
                identity.ClassId,
                character.Level,
                reviewed_loadout.SourceItemIds,
                passive_plan.SourceRanks
            )
    end

    local passives_ready = passive_mapping_ready

    if inventory_ready and passive_mapping_ready then
        passives_ready = passive_candidate ~= nil
    end

    local active_state_ready, active_state_reason =
        validate_active_snapshot(active_snapshot)
    local combined_candidate = nil
    local combined_reason = active_state_reason

    if inventory_ready
        and passives_ready
        and active_state_ready
    then
        combined_candidate, combined_reason =
            C4UnifiedStatReference.get_with_source_effects(
                identity.RaceId,
                identity.ClassId,
                character.Level,
                reviewed_loadout.SourceItemIds,
                passive_plan.SourceRanks,
                active_snapshot.SourceRanks
            )
    end

    local active_effects_ready = active_state_ready

    if inventory_ready
        and passives_ready
        and active_state_ready
    then
        active_effects_ready = combined_candidate ~= nil
        if not active_effects_ready then
            active_state_reason = combined_reason
        end
    end

    local best_candidate = combined_candidate
        or passive_candidate

    return {
        RaceId = identity.RaceId,
        ClassId = identity.ClassId,
        ScopeId = reference.ScopeId,
        Level = vitals.Level,
        SourceCommit = vitals.SourceCommit,
        SourceBaseMaxHealth = vitals.MaxHP,
        SourceBaseMaxMana = vitals.MaxMP,
        SourceBaseMaxCP = vitals.MaxCP,
        ExactBaseVitalsCertified = true,

        ReviewedSixSlotLoadoutReady = reviewed_loadout ~= nil,
        ReviewedSixSlotLoadoutReason = loadout_reason,
        ReviewedSourceItemIds = if reviewed_loadout
            then reviewed_loadout.SourceItemIds
            else nil,
        ReviewedSourceKinds = if reviewed_loadout
            then reviewed_loadout.SourceKinds
            else nil,
        OriginalEquipmentExpertiseReady =
            equipment_expertise ~= nil,
        OriginalEquipmentExpertiseReason = equipment_reason,
        OriginalInventoryIntegrated = inventory_ready,

        OwnedPassiveSourceMappingReady = passive_mapping_ready,
        OwnedPassiveSourceReason = passive_reason,
        ReviewedOwnedSourcePassiveRanks = if passive_plan
            then passive_plan.SourceRanks
            else nil,
        UnsupportedOwnedCreativePassives = if passive_plan
            then passive_plan.UnsupportedOwnedCreativePassives
            else nil,
        UnresolvedOwnedPassiveRanks = if passive_plan
            then passive_plan.UnresolvedOwnedPassiveRanks
            else nil,
        PassiveSourceStatCandidateReady =
            passive_candidate ~= nil,
        OriginalOwnedPassiveMappingIntegrated =
            passive_mapping_ready,
        OriginalOwnedPassivesIntegrated = passives_ready,

        ActiveEffectSourceStateAuthoritative =
            type(active_snapshot) == "table"
            and active_snapshot.Authoritative == true,
        ActiveEffectSourceStateReady = active_effects_ready,
        ActiveEffectSourceStateReason = active_state_reason,
        ReviewedActiveSourceRanks = if type(active_snapshot) == "table"
            and type(active_snapshot.SourceRanks) == "table"
            then table.clone(active_snapshot.SourceRanks)
            else nil,
        UnresolvedActiveSourceEffects =
            if type(active_snapshot) == "table"
                and type(active_snapshot.UnresolvedEffects) == "table"
            then table.clone(active_snapshot.UnresolvedEffects)
            else nil,
        ActiveSourceEffectCount =
            if type(active_snapshot) == "table"
                and type(active_snapshot.ActiveCount) == "number"
            then active_snapshot.ActiveCount
            else nil,
        CombinedSourceStatCandidateReady =
            combined_candidate ~= nil,
        CombinedSourceStatCandidateReason = combined_reason,
        ActiveEffectsIntegrated = active_effects_ready,

        SourceStatCandidateReady = best_candidate ~= nil,
        SourceStatCandidateIncludesActiveEffects =
            combined_candidate ~= nil,
        SourceStatCandidateReason = if combined_candidate
            then nil
            else passive_candidate_reason or combined_reason,
        SourceStatCandidate = if best_candidate
            then best_candidate.EquippedStats
            else nil,
        SourceModifiersApplied = if best_candidate
            then best_candidate.AppliedSourceModifiers
            else nil,

        LiveHealthIntegrated = false,
        LiveManaIntegrated = false,
        LiveCPIntegrated = false,
        CanApplyLive = false,
        ActivationBlockers = copy_activation_blockers(
            inventory_ready,
            passives_ready,
            active_effects_ready
        ),
    }, nil
end

--[[
Reports fixed migration blockers after per-character source readiness.

Args:
    None.

Returns:
    {string}: Independent list of fixed coordinated cutover blockers.
]]
function C4ResourceMigrationBoundary.blockers(): {string}
    return copy_activation_blockers(true, true, true)
end

return table.freeze(C4ResourceMigrationBoundary)
