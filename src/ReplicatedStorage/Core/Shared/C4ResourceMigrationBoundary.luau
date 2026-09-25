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

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"

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
Validates the server-only C4 Combat Point runtime capability.

The migration boundary checks code-path guarantees, not a configured live
player. CP must remain disabled by default until the coordinated cutover.

Args:
    capability (any): Detached C4CombatPointRuntime capability snapshot.

Returns:
    (boolean, string?): Readiness and stable denial reason.
]]
local function validate_cp_capability(
    capability: any
): (boolean, string?)
    if type(capability) ~= "table"
        or capability.Authoritative ~= true
        or capability.RuntimeAvailable ~= true
        or capability.CharacterBound ~= true
        or capability.SourceMaxCPConfigurable ~= true
        or capability.PlayableAttackerOnly ~= true
        or capability.NpcDamageBypassesCP ~= true
        or capability.RegenPeriodSeconds ~= 3
        or capability.LifecycleClearSupported ~= true
        or capability.LiveConfiguredByDefault ~= false
        or capability.SourceCommit ~= SOURCE_COMMIT
    then
        return false, "LiveCPRuntimeUnavailable"
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
    cp_ready (boolean): Server C4 CP runtime capability is source-safe.

Returns:
    {string}: Independent list of unresolved live-migration requirements.
]]
local function copy_activation_blockers(
    equipment_ready: boolean,
    passives_ready: boolean,
    active_effects_ready: boolean,
    cp_ready: boolean
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

    if not cp_ready then
        table.insert(result, "LiveCPRuntimeUnavailable")
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
    cp_capability (any?): Server-only Combat Point runtime capability.

Returns:
    (any?, string?): Exact source-resource plan or strict denial reason.
]]
function C4ResourceMigrationBoundary.for_character(
    character: any,
    active_snapshot: any?,
    cp_capability: any?
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

    local body_leg_semantics_ready = reviewed_loadout ~= nil
        and reviewed_loadout.OriginalBodyLegSemanticsIntegrated == true
    local inventory_ready = reviewed_loadout ~= nil
        and equipment_expertise ~= nil
        and body_leg_semantics_ready

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
    local cp_ready, cp_reason = validate_cp_capability(
        cp_capability
    )
    local prerequisites_ready = inventory_ready
        and passives_ready
        and active_effects_ready
        and cp_ready

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
        OriginalBodyLegSemanticsReady = body_leg_semantics_ready,
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
        SourceStrBonus = if best_candidate
            and best_candidate.Naked
            then best_candidate.Naked.STRBonus
            else nil,
        SourceConBonus = if best_candidate
            and best_candidate.Naked
            then best_candidate.Naked.CONBonus
            else nil,
        SourceDexBonus = if best_candidate
            and best_candidate.Naked
            then best_candidate.Naked.DEXBonus
            else nil,
        SourceMenBonus = if best_candidate
            and best_candidate.Naked
            then best_candidate.Naked.MENBonus
            else nil,
        SourceModifiersApplied = if best_candidate
            then best_candidate.AppliedSourceModifiers
            else nil,

        CombatPointRuntimeAuthoritative =
            type(cp_capability) == "table"
            and cp_capability.Authoritative == true,
        CombatPointRuntimeReady = cp_ready,
        CombatPointRuntimeReason = cp_reason,
        CombatPointRuntimeCapability = if type(cp_capability) == "table"
            then table.clone(cp_capability)
            else nil,
        CutoverPrerequisitesReady = prerequisites_ready,

        LiveHealthIntegrated = false,
        LiveManaIntegrated = false,
        LiveCPIntegrated = false,
        CanApplyLive = false,
        ActivationBlockers = copy_activation_blockers(
            inventory_ready,
            passives_ready,
            active_effects_ready,
            cp_ready
        ),
    }, nil
end

--[[
Reports coordinated blockers after per-character source readiness.

Args:
    cp_capability (any?): Server-only Combat Point runtime capability.

Returns:
    {string}: Independent list of remaining coordinated cutover blockers.
]]
function C4ResourceMigrationBoundary.blockers(
    cp_capability: any?
): {string}
    local cp_ready = validate_cp_capability(cp_capability)

    return copy_activation_blockers(
        true,
        true,
        true,
        cp_ready
    )
end

return table.freeze(C4ResourceMigrationBoundary)
