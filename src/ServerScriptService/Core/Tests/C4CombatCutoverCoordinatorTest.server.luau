--!strict
-- Isolated transactional C4 source-combat cutover regression.

local ServerScriptService = game:GetService("ServerScriptService")

local CoordinatorModule = require(
    ServerScriptService.Core.Services.C4CombatCutoverCoordinator
)

local checks = 0
local audit_ready = true
local resource_gate = false
local combat_gate = false
local executor_gate = false
local dispatch_gate = false
local dispatch_should_fail = false
local active_players = {}
local events = {}
local configured_scale = nil
local configured_night = nil

local FakeResources = {}
local FakeCombat = {}
local FakeExecutor = {}
local FakeDispatch = {}

--[[
Counts one cutover coordinator assertion.

Args:
    valid (boolean): Expected transactional state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Cutover] " .. label)
end

--[[
Resets all disposable gate and event state.

Args:
    None.

Returns:
    nil: Restores a clean pre-cutover fixture.
]]
local function reset_fixture()
    audit_ready = true
    resource_gate = false
    combat_gate = false
    executor_gate = false
    dispatch_gate = false
    dispatch_should_fail = false
    configured_scale = nil
    configured_night = nil
    table.clear(active_players)
    table.clear(events)
end

function FakeResources.is_enabled(): boolean
    return resource_gate
end

function FakeResources.set_enabled(enabled: boolean)
    resource_gate = enabled
    table.insert(events, "resource:" .. tostring(enabled))
    if not enabled then
        table.clear(active_players)
    end
end

function FakeResources.enable_player(
    player: any
): (boolean, string?)
    table.insert(events, "player+:" .. tostring(player.UserId))
    if player.FailCutover == true then
        return false, "FixturePlayerCutoverFailed"
    end
    active_players[player] = true
    return true, nil
end

function FakeResources.disable_player(player: any)
    table.insert(events, "player-:" .. tostring(player.UserId))
    active_players[player] = nil
end

function FakeResources.remove_player(player: any)
    table.insert(events, "player-remove:" .. tostring(player.UserId))
    active_players[player] = nil
end

function FakeResources.is_active(player: any): boolean
    return resource_gate and active_players[player] == true
end

function FakeCombat.is_enabled(): boolean
    return combat_gate
end

function FakeCombat.set_enabled(enabled: boolean)
    combat_gate = enabled
    table.insert(events, "combat:" .. tostring(enabled))
end

function FakeExecutor:is_enabled(): boolean
    return executor_gate
end

function FakeExecutor:configure_spatial_rules(
    source_units_per_stud: number,
    night_provider: any
)
    assert(source_units_per_stud > 0)
    assert(type(night_provider) == "function")
    configured_scale = source_units_per_stud
    configured_night = night_provider()
    table.insert(events, "spatial")
end

function FakeExecutor:set_enabled(
    enabled: boolean
): (boolean, string?)
    executor_gate = enabled
    table.insert(events, "executor:" .. tostring(enabled))
    return true, nil
end

function FakeDispatch.is_enabled(): boolean
    return dispatch_gate
end

function FakeDispatch.capability(): any
    return {
        ActivationAuditReady = audit_ready,
    }
end

function FakeDispatch.set_enabled(
    enabled: boolean
): (boolean, string?)
    table.insert(events, "dispatch:" .. tostring(enabled))
    if enabled and dispatch_should_fail then
        return false, "FixtureDispatchFailure"
    end
    dispatch_gate = enabled
    return true, nil
end

--[[
Creates a coordinator bound only to disposable authorities.

Args:
    None.

Returns:
    any: Fresh disabled coordinator.
]]
local function coordinator(): any
    return CoordinatorModule.new({
        ResourceAuthority = FakeResources,
        CombatProvider = FakeCombat,
        Executor = FakeExecutor,
        Dispatch = FakeDispatch,
    })
end

--[[
Runs audit, partial failure, full activation and rollback checks.

Args:
    None.

Returns:
    nil: Prints deterministic transactional acceptance evidence.
]]
local function main()
    reset_fixture()
    local cutover = coordinator()
    local capability = cutover:capability()
    check(
        not cutover:is_enabled()
            and capability.DefaultEnabled == false
            and capability.TransactionalRollback
            and capability.RequiresDispatchAuditReady
            and capability.ParticipantRemovalSupported
            and not capability.ClientAuthority,
        "coordinator starts disabled with server-only rollback authority"
    )

    audit_ready = false
    local audit_ok, audit_reason = cutover:enable(
        {},
        25,
        function(): boolean
            return false
        end
    )
    check(
        not audit_ok
            and audit_reason
                == "C4CombatDispatchAuditBlockingFamilies"
            and #events == 0,
        "failed audit mutates no source gate"
    )

    reset_fixture()
    cutover = coordinator()
    local first = {UserId = 1}
    local second = {UserId = 2, FailCutover = true}
    local player_ok, player_reason = cutover:enable(
        {first, second},
        25,
        function(): boolean
            return true
        end
    )
    check(
        not player_ok
            and player_reason == "FixturePlayerCutoverFailed"
            and not resource_gate
            and not combat_gate
            and not executor_gate
            and not dispatch_gate
            and next(active_players) == nil,
        "partial player cutover failure rolls every gate back"
    )

    reset_fixture()
    cutover = coordinator()
    dispatch_should_fail = true
    local dispatch_ok, dispatch_reason = cutover:enable(
        {{UserId = 3}},
        30,
        function(): boolean
            return false
        end
    )
    check(
        not dispatch_ok
            and dispatch_reason == "FixtureDispatchFailure"
            and not resource_gate
            and not combat_gate
            and not executor_gate
            and not dispatch_gate
            and next(active_players) == nil,
        "late dispatch failure reverses earlier resource/combat gates"
    )

    reset_fixture()
    cutover = coordinator()
    local player_a = {UserId = 4}
    local player_b = {UserId = 5}
    local enabled, enable_reason = cutover:enable(
        {player_a, player_b},
        40,
        function(): boolean
            return true
        end
    )
    check(
        enabled
            and enable_reason == nil
            and cutover:is_enabled()
            and resource_gate
            and combat_gate
            and executor_gate
            and dispatch_gate
            and active_players[player_a] == true
            and active_players[player_b] == true
            and configured_scale == 40
            and configured_night == true,
        "successful cutover enables every source authority in order"
    )

    local snapshot = cutover:snapshot()
    check(
        snapshot.Enabled
            and snapshot.ResourceGate
            and snapshot.CombatCalculationGate
            and snapshot.ExecutorGate
            and snapshot.DispatchGate
            and snapshot.ActivePlayerCount == 2,
        "cutover snapshot exposes complete active transaction state"
    )

    local removed_a, remove_a_reason =
        cutover:remove_player(player_a)
    local after_first_remove = cutover:snapshot()
    check(
        removed_a
            and remove_a_reason == nil
            and active_players[player_a] == nil
            and active_players[player_b] == true
            and after_first_remove.Enabled
            and after_first_remove.ActivePlayerCount == 1
            and dispatch_gate,
        "removing one participant keeps remaining source mode active"
    )

    local removed_b, remove_b_reason =
        cutover:remove_player(player_b)
    local after_last_remove = cutover:snapshot()
    check(
        removed_b
            and remove_b_reason == nil
            and not after_last_remove.Enabled
            and after_last_remove.ActivePlayerCount == 0
            and not resource_gate
            and not combat_gate
            and not executor_gate
            and not dispatch_gate,
        "removing the last participant disables every global source gate"
    )

    local repeated, repeated_reason =
        cutover:remove_player(player_b)
    check(
        not repeated
            and repeated_reason == "C4CutoverPlayerNotActive",
        "repeated participant removal is rejected without mutation"
    )

    reset_fixture()
    cutover = coordinator()
    local final_player = {UserId = 6}
    local final_enabled = cutover:enable(
        {final_player},
        45,
        function(): boolean
            return false
        end
    )
    check(
        final_enabled and cutover:is_enabled(),
        "coordinator can activate again after participant-cleanup coverage"
    )

    cutover:disable()
    check(
        not cutover:is_enabled()
            and not resource_gate
            and not combat_gate
            and not executor_gate
            and not dispatch_gate
            and next(active_players) == nil,
        "disable reverses every source gate and player opt-in"
    )

    print((
        "[C4 Combat Cutover] CUTOVER_PASS: %d assertions "
            .. "default_off=true rollback=true client=false"
    ):format(checks))
end

main()
