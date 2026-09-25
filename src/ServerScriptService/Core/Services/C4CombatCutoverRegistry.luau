--!strict
-- Server-only access point for the actual runtime C4 cutover coordinator.

local C4CombatCutoverRegistry = {}

local bound_coordinator = nil

--[[
Binds the one coordinator owned by the active server runtime.

This module lives only in ServerScriptService. It creates no RemoteEvent or
client-callable path and exists so trusted server/admin/test code can operate
the exact coordinator composed by RuntimeServices.

Args:
    coordinator (any): Actual server runtime cutover coordinator.

Returns:
    nil: Replaces the current server-local binding.
]]
function C4CombatCutoverRegistry.bind(coordinator: any)
    assert(
        type(coordinator) == "table"
            and type(coordinator.enable) == "function"
            and type(coordinator.disable) == "function"
            and type(coordinator.snapshot) == "function",
        "C4 cutover registry requires a valid coordinator"
    )

    bound_coordinator = coordinator
end

--[[
Returns the actual server runtime cutover coordinator.

Args:
    None.

Returns:
    any?: Current bound coordinator, otherwise nil.
]]
function C4CombatCutoverRegistry.get(): any?
    return bound_coordinator
end

--[[
Clears the current server-local coordinator binding.

This is primarily useful for isolated tests and shutdown/reset flows.

Args:
    None.

Returns:
    nil: Removes the current binding without changing coordinator gates.
]]
function C4CombatCutoverRegistry.clear()
    bound_coordinator = nil
end

return table.freeze(C4CombatCutoverRegistry)
