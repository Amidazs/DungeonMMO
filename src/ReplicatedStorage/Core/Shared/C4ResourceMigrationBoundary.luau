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

local C4ResourceMigrationBoundary = {}

local ACTIVATION_BLOCKERS = table.freeze({
    "OriginalOwnedPassiveMappingIncomplete",
    "ActiveEffectOrderingIncomplete",
    "LiveCPRuntimeUnavailable",
})

--[[
Copies the fixed activation blockers so callers cannot mutate shared state.

Args:
    None.

Returns:
    {string}: Independent list of unresolved live-migration requirements.
]]
local function copy_activation_blockers(): {string}
    local result = {}

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
        OriginalOwnedPassivesIntegrated = false,
        ActiveEffectsIntegrated = false,
        LiveHealthIntegrated = false,
        LiveManaIntegrated = false,
        LiveCPIntegrated = false,
        CanApplyLive = false,
        ActivationBlockers = copy_activation_blockers(),
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
    return copy_activation_blockers()
end

return table.freeze(C4ResourceMigrationBoundary)
