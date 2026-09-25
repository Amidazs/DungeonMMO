--!strict
-- Atomic, disabled-by-default orchestration for C4 source combat cutover.

local C4CombatCutoverCoordinator = {}
C4CombatCutoverCoordinator.__index = C4CombatCutoverCoordinator

--[[
Validates one dependency method before constructing the coordinator.

Args:
    dependency (any): Injected server-only authority.
    method_name (string): Required method name.
    label (string): Stable assertion label.

Returns:
    nil: Raises when the dependency contract is incomplete.
]]
local function require_method(
    dependency: any,
    method_name: string,
    label: string
)
    assert(
        type(dependency) == "table"
            and type(dependency[method_name]) == "function",
        label .. " must implement " .. method_name
    )
end

--[[
Creates one disabled C4 cutover coordinator.

The coordinator owns sequencing only. Formula, resource, executor and dispatch
authorities remain separate modules so rollback never depends on client state.

Args:
    options (any): Resource, calculation, executor and dispatch authorities.

Returns:
    any: Disabled coordinator instance.
]]
function C4CombatCutoverCoordinator.new(options: any): any
    assert(type(options) == "table", "C4 cutover options are required")

    local resources = options.ResourceAuthority
    local combat = options.CombatProvider
    local executor = options.Executor
    local dispatch = options.Dispatch

    require_method(resources, "is_enabled", "Resource authority")
    require_method(resources, "set_enabled", "Resource authority")
    require_method(resources, "enable_player", "Resource authority")
    require_method(resources, "disable_player", "Resource authority")
    require_method(resources, "is_active", "Resource authority")
    require_method(combat, "is_enabled", "Combat provider")
    require_method(combat, "set_enabled", "Combat provider")
    require_method(executor, "is_enabled", "Combat executor")
    require_method(executor, "set_enabled", "Combat executor")
    require_method(
        executor,
        "configure_spatial_rules",
        "Combat executor"
    )
    require_method(dispatch, "is_enabled", "Combat dispatch")
    require_method(dispatch, "set_enabled", "Combat dispatch")
    require_method(dispatch, "capability", "Combat dispatch")

    return setmetatable({
        _resources = resources,
        _combat = combat,
        _executor = executor,
        _dispatch = dispatch,
        _enabled = false,
        _active_players = {},
    }, C4CombatCutoverCoordinator)
end

--[[
Disables every source-combat layer in reverse mutation order.

Resource disable is last because it rolls active players back to the current
resource model. This method is safe to call after a partial enable failure.

Args:
    None.

Returns:
    nil: Leaves every owned source gate disabled.
]]
function C4CombatCutoverCoordinator:_rollback()
    self._dispatch.set_enabled(false)
    self._executor:set_enabled(false)
    self._combat.set_enabled(false)

    for _, player in ipairs(self._active_players) do
        if self._resources.is_active(player) then
            self._resources.disable_player(player)
        end
    end
    table.clear(self._active_players)

    self._resources.set_enabled(false)
    self._enabled = false
end

--[[
Reports whether this coordinator completed a full source-combat activation.

Args:
    None.

Returns:
    boolean: True only after every independent gate accepted activation.
]]
function C4CombatCutoverCoordinator:is_enabled(): boolean
    return self._enabled
end

--[[
Atomically enables source combat for an explicit set of server players.

The operation starts only when all independent gates are off and the dispatch
audit is ready. Any failure rolls every already-mutated layer back.

Args:
    players ({any}): Explicit authenticated players to opt into resources.
    source_units_per_stud (number): Reviewed Roblox-to-source height scale.
    night_provider (any): Server callback returning source-equivalent night.

Returns:
    (boolean, string?): Success or the strict failing-gate reason.
]]
function C4CombatCutoverCoordinator:enable(
    players: {any},
    source_units_per_stud: number,
    night_provider: any
): (boolean, string?)
    if self._enabled then
        return true, nil
    end
    if type(players) ~= "table" then
        return false, "InvalidC4CutoverPlayers"
    end
    if self._resources.is_enabled()
        or self._combat.is_enabled()
        or self._executor:is_enabled()
        or self._dispatch.is_enabled()
    then
        return false, "C4CutoverRequiresAllGatesOff"
    end

    local dispatch_capability = self._dispatch.capability()
    if type(dispatch_capability) ~= "table"
        or dispatch_capability.ActivationAuditReady ~= true
    then
        return false, "C4CombatDispatchAuditBlockingFamilies"
    end

    local configure_ok, configure_reason = pcall(
        self._executor.configure_spatial_rules,
        self._executor,
        source_units_per_stud,
        night_provider
    )
    if not configure_ok then
        return false, tostring(configure_reason)
    end

    self._resources.set_enabled(true)

    for _, player in ipairs(players) do
        local ok, reason = self._resources.enable_player(player)
        if not ok then
            self:_rollback()
            return false, reason or "C4ResourceCutoverPlayerFailed"
        end
        table.insert(self._active_players, player)
    end

    self._combat.set_enabled(true)

    local executor_ok, executor_reason =
        self._executor:set_enabled(true)
    if not executor_ok then
        self:_rollback()
        return false, executor_reason
            or "C4LiveCombatExecutorEnableFailed"
    end

    local dispatch_ok, dispatch_reason =
        self._dispatch.set_enabled(true)
    if not dispatch_ok then
        self:_rollback()
        return false, dispatch_reason
            or "C4CombatDispatchEnableFailed"
    end

    self._enabled = true
    return true, nil
end

--[[
Reverses source combat and returns opted-in players to the current model.

Args:
    None.

Returns:
    boolean: True after every source gate is disabled.
]]
function C4CombatCutoverCoordinator:disable(): boolean
    self:_rollback()
    return true
end

--[[
Returns detached cutover-state evidence.

Args:
    None.

Returns:
    any: Coordinator and underlying gate state.
]]
function C4CombatCutoverCoordinator:snapshot(): any
    return {
        Enabled = self._enabled,
        ResourceGate = self._resources.is_enabled(),
        CombatCalculationGate = self._combat.is_enabled(),
        ExecutorGate = self._executor:is_enabled(),
        DispatchGate = self._dispatch.is_enabled(),
        ActivePlayerCount = #self._active_players,
    }
end

--[[
Returns immutable cutover capability metadata.

Args:
    None.

Returns:
    any: Server-only atomicity and rollback guarantees.
]]
function C4CombatCutoverCoordinator:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        RequiresAllGatesOff = true,
        RequiresDispatchAuditReady = true,
        RequiresExplicitPlayers = true,
        RequiresExplicitSpatialRules = true,
        TransactionalRollback = true,
        ReverseOrderDisable = true,
        ClientAuthority = false,
    }
end

return C4CombatCutoverCoordinator
