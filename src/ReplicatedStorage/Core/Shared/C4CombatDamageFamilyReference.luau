--!strict
-- Audited current DamageService source-kind routing for C4 cutover.

local C4CombatDamageFamilyReference = {}

local FAMILIES = table.freeze({
    Melee = table.freeze({
        Route = "SourceNormal",
        PlayerToNpc = true,
        ActivationBlocker = false,
    }),
    RangedPhysical = table.freeze({
        Route = "SourcePhysicalByRank",
        PlayerToNpc = true,
        ActivationBlocker = false,
    }),
    Skill = table.freeze({
        Route = "SourcePDAM",
        PlayerToNpc = true,
        ActivationBlocker = false,
    }),
    MagicSkill = table.freeze({
        Route = "SourceMDAM",
        PlayerToNpc = true,
        ActivationBlocker = false,
    }),
    RangerArea = table.freeze({
        Route = "LegacyC4ScopeExcluded",
        PlayerToNpc = true,
        ActivationBlocker = false,
        Reason = "C4LegacyRangerAreaOutsideLevel30Scope",
    }),
    MagicBasic = table.freeze({
        Route = "SourceNormal",
        PlayerToNpc = true,
        ActivationBlocker = false,
    }),
    StatusPhysical = table.freeze({
        Route = "LegacyPeriodicTickSuppressed",
        PlayerToNpc = true,
        ActivationBlocker = false,
        Reason = "C4LegacyPeriodicTickSuppressed",
    }),
    StatusMagic = table.freeze({
        Route = "LegacyPeriodicTickSuppressed",
        PlayerToNpc = true,
        ActivationBlocker = false,
        Reason = "C4LegacyPeriodicTickSuppressed",
    }),
    EnemyMelee = table.freeze({
        Route = "LegacyEnemyOutgoing",
        PlayerToNpc = false,
        ActivationBlocker = false,
    }),
    EnemyArea = table.freeze({
        Route = "LegacyEnemyOutgoing",
        PlayerToNpc = false,
        ActivationBlocker = false,
    }),
    EnemyBow = table.freeze({
        Route = "LegacyEnemyOutgoing",
        PlayerToNpc = false,
        ActivationBlocker = false,
    }),
    EnemyMagic = table.freeze({
        Route = "LegacyEnemyOutgoing",
        PlayerToNpc = false,
        ActivationBlocker = false,
    }),
    AreaEffect = table.freeze({
        Route = "LegacyTestOnly",
        PlayerToNpc = false,
        ActivationBlocker = false,
    }),
})

local BLOCKING_PLAYER_TO_NPC_FAMILIES = table.freeze({})

local PERIODIC_STATUS_SKILLS = table.freeze({
    WayfinderWound = true,
    MysticPoisonCurse = true,
})

--[[
Returns the reviewed classification for one current DamageService source kind.

Args:
    source_kind (string): Existing server-owned damage-family identifier.

Returns:
    any?: Frozen audit row, or nil when the kind has not been reviewed.
]]
function C4CombatDamageFamilyReference.get(
    source_kind: string
): any?
    if type(source_kind) ~= "string" then
        return nil
    end

    return FAMILIES[source_kind]
end

--[[
Returns whether one source kind may route through player-to-NPC C4 combat.

Args:
    source_kind (string): Existing server-owned damage-family identifier.

Returns:
    boolean: True only for reviewed player-to-NPC families.
]]
function C4CombatDamageFamilyReference.is_player_to_npc(
    source_kind: string
): boolean
    local family = C4CombatDamageFamilyReference.get(source_kind)
    return family ~= nil and family.PlayerToNpc == true
end

--[[
Returns whether one creative damage source is actually a reviewed DEBUFF cast.

These casts arrive through the existing Skill/MagicSkill delivery paths. They
must be intercepted before generic PDAM/MDAM routing so source mode never
applies the creative direct-damage placeholder.

Args:
    source_id (string): Existing server-owned creative skill identifier.

Returns:
    boolean: True only for reviewed periodic source DEBUFF skills.
]]
function C4CombatDamageFamilyReference.is_periodic_status_skill(
    source_id: string
): boolean
    return type(source_id) == "string"
        and PERIODIC_STATUS_SKILLS[source_id] == true
end

--[[
Returns the explicit activation blocker reason for one reviewed family.

Args:
    source_kind (string): Existing server-owned damage-family identifier.

Returns:
    string?: Stable blocker reason, otherwise nil.
]]
function C4CombatDamageFamilyReference.blocker_reason(
    source_kind: string
): string?
    local family = C4CombatDamageFamilyReference.get(source_kind)
    if not family or family.ActivationBlocker ~= true then
        return nil
    end

    return family.Reason
end

--[[
Returns all currently known player-to-NPC activation blockers.

The returned array is detached so callers cannot mutate the pinned audit.

Args:
    None.

Returns:
    {string}: Sorted current blocker family identifiers.
]]
function C4CombatDamageFamilyReference.activation_blockers(): {string}
    local blockers = {}

    for _, source_kind in ipairs(
        BLOCKING_PLAYER_TO_NPC_FAMILIES
    ) do
        table.insert(blockers, source_kind)
    end

    return blockers
end

--[[
Reports whether every current player-to-NPC damage family is source-routable.

Args:
    None.

Returns:
    boolean: False while any reviewed activation blocker remains.
]]
function C4CombatDamageFamilyReference.activation_ready(): boolean
    return #BLOCKING_PLAYER_TO_NPC_FAMILIES == 0
end

return table.freeze(C4CombatDamageFamilyReference)
