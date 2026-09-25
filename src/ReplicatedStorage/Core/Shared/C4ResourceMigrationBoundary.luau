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

local ACTIVATION_BLOCKERS = table.freeze({
    "ActiveEffectOrderingIncomplete",
    "LiveCPRuntimeUnavailable",
})

--[[
Copies the activation blockers so callers cannot mutate shared state.

Args:
    equipment_ready (boolean): Whether the current equipment migration is
        source-mapped and valid for the character's C4 Expertise level.
    passives_ready (boolean): Whether actually owned creative passives map
        cleanly to source ranks and compose into the source stat candidate.

Returns:
    {string}: Independent list of unresolved live-migration requirements.
]]
local function copy_activation_blockers(
    equipment_ready: boolean,
    passives_ready: boolean
): {string}
    local result = {}

    if not equipment_ready then
        table.insert(result, "OriginalEquipmentMigrationIncomplete")
    end

    if not passives_ready then
        table.insert(result, "OriginalOwnedPassiveMappingIncomplete")
    end

    for _, blocker in ipairs(ACTIVATION_BLOCKERS) do
        table.insert(result, blocker)
    end

    return result
end

--[[
Builds an authenticated C4 resource migration boundary for one character.

This deliberately exposes exact source HP/MP/CP without applying them to the
Humanoid, ManaService or a CP runtime. The boundary stays fail-closed until
original equipment, actually owned passive ranks, active-effect ordering and
CP authority are all integrated coherently.

Args:
    character (any): Server-owned selected character snapshot.

Returns:
    (any?, string?): Exact source-resource plan or strict denial reason.
]]
function C4ResourceMigrationBoundary.for_character(
    character: any
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

    local stat_candidate = nil
    local stat_reason = passive_reason

    if inventory_ready and passive_mapping_ready then
        stat_candidate, stat_reason =
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
        passives_ready = stat_candidate ~= nil
    end

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
        SourceStatCandidateReady = stat_candidate ~= nil,
        SourceStatCandidateReason = stat_reason,
        SourceStatCandidate = if stat_candidate
            then stat_candidate.EquippedStats
            else nil,
        SourcePassiveModifiersApplied = if stat_candidate
            then stat_candidate.AppliedSourceModifiers
            else nil,
        OriginalOwnedPassiveMappingIntegrated =
            passive_mapping_ready,
        OriginalOwnedPassivesIntegrated = passives_ready,
        ActiveEffectsIntegrated = false,
        LiveHealthIntegrated = false,
        LiveManaIntegrated = false,
        LiveCPIntegrated = false,
        CanApplyLive = false,
        ActivationBlockers = copy_activation_blockers(
            inventory_ready,
            passives_ready
        ),
    }, nil
end

--[[
Reports the fixed migration blockers shared by all nine original paths.

Args:
    None.

Returns:
    {string}: Independent list of current fail-closed blockers.
]]
function C4ResourceMigrationBoundary.blockers(): {string}
    return copy_activation_blockers(true, false)
end

return table.freeze(C4ResourceMigrationBoundary)
