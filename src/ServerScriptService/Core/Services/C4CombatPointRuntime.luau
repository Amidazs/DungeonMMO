--!strict
-- Server-authoritative Combat Point lifecycle for the C4 resource migration.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SourceRules = require(
    ReplicatedStorage.Core.Shared.C4CombatPointSourceRules
)

local C4CombatPointRuntime = {}

local state_by_owner: {[any]: any} = setmetatable(
    {},
    {__mode = "k"}
)

--[[
Checks the concrete owner fields without trusting client resource values.

Args:
    owner (any): Player or disposable test owner.

Returns:
    boolean: True when owner exposes numerical UserId and current Character.
]]
local function has_owner_identity(owner: any): boolean
    if owner == nil then
        return false
    end

    local ok_user, user_id = pcall(function()
        return owner.UserId
    end)
    local ok_character, character = pcall(function()
        return owner.Character
    end)

    return ok_user
        and ok_character
        and type(user_id) == "number"
        and user_id == user_id
        and user_id % 1 == 0
        and character ~= nil
end

--[[
Removes an owner's stale record after character replacement.

Args:
    owner (any): Server-owned resource owner.

Returns:
    any?: Current record when still bound to the same character.
]]
local function current_record(owner: any): any?
    local record = state_by_owner[owner]

    if not record then
        return nil
    end

    local ok_character, character = pcall(function()
        return owner.Character
    end)

    if not ok_character or character ~= record.Character then
        state_by_owner[owner] = nil
        return nil
    end

    return record
end

--[[
Extracts the certified maximum CP from a coordinated source boundary.

The runtime never accepts an arbitrary maximum from a client or gameplay
caller. Its public configuration route requires the reviewed C4 source
candidate and matching pinned-source provenance.

Args:
    boundary (any): Authenticated C4 resource migration boundary.

Returns:
    (number?, string?): Certified source maximum CP or denial reason.
]]
local function source_max_cp(boundary: any): (number?, string?)
    local metadata = SourceRules.metadata()

    if type(boundary) ~= "table"
        or boundary.CutoverPrerequisitesReady ~= true
        or boundary.SourceStatCandidateReady ~= true
        or boundary.ExactBaseVitalsCertified ~= true
        or boundary.SourceCommit ~= metadata.SourceCommit
        or type(boundary.SourceStatCandidate) ~= "table"
    then
        return nil, "UncertifiedCombatPointSourceBoundary"
    end

    local max_cp = boundary.SourceStatCandidate.MAX_CP

    if type(max_cp) ~= "number"
        or max_cp ~= max_cp
        or max_cp < 0
        or math.abs(max_cp) >= math.huge
    then
        return nil, "InvalidCombatPointMaximum"
    end

    return max_cp, nil
end

--[[
Configures current/max CP from a certified C4 source boundary.

This is not called automatically before the deliberate live resource cutover.
The accepted maximum can only come from the authenticated source-stat
candidate; arbitrary Roblox or client-selected maximums are rejected.

Args:
    owner (any): Player or disposable server-owned test owner.
    boundary (any): Authenticated source-ready C4 migration boundary.
    refill (boolean): True to fill CP, false to preserve/clamp prior current CP.

Returns:
    (boolean, string?): Success or strict validation reason.
]]
function C4CombatPointRuntime.configure_from_boundary(
    owner: any,
    boundary: any,
    refill: boolean
): (boolean, string?)
    if not has_owner_identity(owner) then
        return false, "InvalidCombatPointOwner"
    end

    if type(refill) ~= "boolean" then
        return false, "InvalidCombatPointRefillMode"
    end

    local max_cp, source_reason = source_max_cp(boundary)

    if not max_cp then
        return false, source_reason
    end

    local prior = current_record(owner)
    local current_cp = if refill or not prior
        then max_cp
        else math.min(prior.CurrentCP, max_cp)

    state_by_owner[owner] = {
        Character = owner.Character,
        CurrentCP = current_cp,
        MaxCP = max_cp,
    }

    return true, nil
end

--[[
Reconfigures CP from a certified boundary while preserving resource fraction.

This is used when live source maxima change because of an authenticated source
effect. The fraction is measured from prior authoritative server state; it is
never supplied by a client request.

Args:
    owner (any): Player or disposable server-owned test owner.
    boundary (any): Authenticated source-ready C4 migration boundary.
    fraction (number): Server-measured current/max CP ratio from zero to one.

Returns:
    (boolean, string?): Success or strict validation reason.
]]
function C4CombatPointRuntime.configure_fraction_from_boundary(
    owner: any,
    boundary: any,
    fraction: number
): (boolean, string?)
    if not has_owner_identity(owner) then
        return false, "InvalidCombatPointOwner"
    end

    if type(fraction) ~= "number"
        or fraction ~= fraction
        or fraction < 0
        or fraction > 1
        or math.abs(fraction) >= math.huge
    then
        return false, "InvalidCombatPointFraction"
    end

    local max_cp, source_reason = source_max_cp(boundary)

    if not max_cp then
        return false, source_reason
    end

    state_by_owner[owner] = {
        Character = owner.Character,
        CurrentCP = max_cp * fraction,
        MaxCP = max_cp,
    }

    return true, nil
end

--[[
Clears all CP state for one owner.

Args:
    owner (any): Player or disposable server-owned test owner.

Returns:
    nil: Removes only this owner's server record.
]]
function C4CombatPointRuntime.clear(owner: any)
    state_by_owner[owner] = nil
end

--[[
Returns a detached authoritative CP snapshot.

Args:
    owner (any): Player or disposable server-owned test owner.

Returns:
    any: Current/max CP and lifecycle metadata, or an unconfigured snapshot.
]]
function C4CombatPointRuntime.snapshot(owner: any): any
    local record = current_record(owner)

    if not record then
        return {
            Configured = false,
            CurrentCP = 0,
            MaxCP = 0,
            CharacterBound = false,
            Authoritative = true,
            PvPOnly = true,
        }
    end

    return {
        Configured = true,
        CurrentCP = record.CurrentCP,
        MaxCP = record.MaxCP,
        CharacterBound = true,
        Authoritative = true,
        PvPOnly = true,
    }
end

--[[
Applies one source CP regeneration amount to a configured owner.

The caller supplies the already source-calculated tick amount. This keeps
movement/class formula authority separate from mutable runtime state.

Args:
    owner (any): Server-owned configured CP owner.
    amount (number): Non-negative source regeneration amount.

Returns:
    (number?, string?): New current CP, or strict runtime reason.
]]
function C4CombatPointRuntime.restore(
    owner: any,
    amount: number
): (number?, string?)
    local record = current_record(owner)

    if not record then
        return nil, "CombatPointRuntimeNotConfigured"
    end

    if type(amount) ~= "number"
        or amount ~= amount
        or amount < 0
        or math.abs(amount) >= math.huge
    then
        return nil, "InvalidCombatPointRestore"
    end

    record.CurrentCP = math.min(
        record.MaxCP,
        record.CurrentCP + amount
    )

    return record.CurrentCP, nil
end

--[[
Resolves one hit against configured CP using exact C4 attacker semantics.

NPC/non-playable damage bypasses CP. A playable attacker consumes CP first.
Unconfigured owners return the incoming damage unchanged so merely installing
this runtime cannot alter current pre-cutover combat.

Args:
    owner (any): Server-owned defender.
    damage (number): Non-negative incoming damage.
    attacker_is_playable (boolean): Server-known attacker category.

Returns:
    (any?, string?): Remaining HP damage/absorbed CP and runtime metadata.
]]
function C4CombatPointRuntime.resolve_damage(
    owner: any,
    damage: number,
    attacker_is_playable: boolean
): (any?, string?)
    if type(damage) ~= "number"
        or damage ~= damage
        or damage < 0
        or math.abs(damage) >= math.huge
        or type(attacker_is_playable) ~= "boolean"
    then
        return nil, "InvalidCombatPointDamage"
    end

    local record = current_record(owner)

    if not record then
        return {
            CurrentCP = 0,
            HealthDamage = damage,
            CPAbsorbed = 0,
            Configured = false,
        }, nil
    end

    local resolved, reason = SourceRules.resolve_damage(
        record.CurrentCP,
        damage,
        attacker_is_playable
    )

    if not resolved then
        return nil, reason
    end

    record.CurrentCP = resolved.CurrentCP

    return {
        CurrentCP = resolved.CurrentCP,
        HealthDamage = resolved.HealthDamage,
        CPAbsorbed = resolved.CPAbsorbed,
        Configured = true,
    }, nil
end

--[[
Returns immutable runtime-capability metadata for migration gating.

The capability describes code-path authority, not a live configured player.
Production characters remain unconfigured until the deliberate resource
cutover.

Args:
    None.

Returns:
    any: Server runtime guarantees required by the C4 migration boundary.
]]
function C4CombatPointRuntime.capability(): any
    local metadata = SourceRules.metadata()

    return {
        Authoritative = true,
        RuntimeAvailable = true,
        CharacterBound = true,
        SourceMaxCPConfigurable = true,
        PlayableAttackerOnly = metadata.PlayableAttackerOnly,
        NpcDamageBypassesCP = metadata.NpcDamageBypassesCP,
        RegenPeriodSeconds = metadata.RegenPeriodSeconds,
        SourceCommit = metadata.SourceCommit,
        LifecycleClearSupported = true,
        LiveConfiguredByDefault = false,
    }
end

return table.freeze(C4CombatPointRuntime)
