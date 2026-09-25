--!strict
-- FOCUSED_EDIT_ONLY_SINGLETON_TEST
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    print(
        "[C4 Resource Cutover] SKIP: singleton regression runs in focused Edit mode"
    )
    return
end
-- Disabled-by-default C4 resource cutover surface regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Cutover = require(
    ServerScriptService.Core.Services.C4ResourceCutoverService
)

local checks = 0

--[[
Counts one resource-cutover safety assertion.

Args:
    valid (boolean): Expected default or fail-closed condition.
    label (string): Diagnostic text for an unexpected result.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Resource Cutover] " .. label)
end

--[[
Builds a disposable non-Player owner for inactive-path checks.

Args:
    None.

Returns:
    any: Minimal table-shaped owner that cannot pass live Player checks.
]]
local function fake_owner(): any
    return {
        UserId = 938180,
        Character = {},
    }
end

--[[
Checks the production cutover starts disabled and inert.

Args:
    None.

Returns:
    nil: Confirms requiring the service cannot change current live resources.
]]
local function check_default_safety()
    local capability = Cutover.capability()
    local owner = fake_owner()

    check(
        not Cutover.is_enabled()
            and capability.Available
            and capability.DefaultEnabled == false
            and capability.CurrentlyEnabled == false,
        "service is available but disabled by default"
    )
    check(
        capability.ExplicitPerPlayerEnable
            and capability.FractionPreservingTransitions
            and capability.SourceThreeSecondRegen
            and capability.PlayableDamageUsesCP
            and capability.NpcDamageBypassesCP
            and capability.RespawnReapplySupported
            and capability.RollbackSupported,
        "capability advertises every required reversible cutover contract"
    )

    local hp_damage, cp_absorbed =
        Cutover.resolve_player_damage(owner, 37, true)
    check(
        hp_damage == 37 and cp_absorbed == 0,
        "inactive resolver leaves existing damage completely unchanged"
    )

    local snapshot = Cutover.snapshot(owner)
    check(
        not snapshot.GateEnabled
            and not snapshot.Active
            and not snapshot.CombatPoints.Configured,
        "inactive owner has no hidden CP or source-resource state"
    )
end

--[[
Checks explicit gate changes still require a real live Player.

Args:
    None.

Returns:
    nil: Confirms the global gate alone cannot activate source resources.
]]
local function check_explicit_gate()
    local owner = fake_owner()

    Cutover.set_enabled(true)
    check(
        Cutover.is_enabled()
            and Cutover.capability().CurrentlyEnabled,
        "server can explicitly enable the test gate"
    )

    local enabled, reason = Cutover.enable_player(owner)
    check(
        not enabled
            and reason == "C4ResourceOwnerUnavailable"
            and not Cutover.is_active(owner),
        "non-Player owner cannot opt into source resources"
    )

    Cutover.set_enabled(false)
    check(
        not Cutover.is_enabled()
            and not Cutover.snapshot(owner).Active,
        "disabling the gate returns the service to inert state"
    )
end

--[[
Runs cutover default-safety acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_default_safety()
    check_explicit_gate()

    print((
        "[C4 Resource Cutover] SOURCE_ONLY_PASS: %d assertions "
        .. "default_off=true reversible=true"
    ):format(checks))
end

main()
