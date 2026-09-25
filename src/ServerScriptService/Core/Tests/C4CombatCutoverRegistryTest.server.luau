--!strict
-- Server-only runtime cutover registry regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(
    ServerScriptService.Core.Services.C4CombatCutoverRegistry
)

local checks = 0

--[[
Counts one registry assertion.

Args:
    valid (boolean): Expected server-only registry state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Cutover Registry] " .. label)
end

--[[
Runs bind/get/clear checks without exposing any client path.

Args:
    None.

Returns:
    nil: Prints deterministic registry acceptance evidence.
]]
local function main()
    Registry.clear()
    check(
        Registry.get() == nil,
        "registry starts clear in isolated test"
    )

    local coordinator = {
        enable = function() end,
        disable = function() end,
        snapshot = function() end,
    }

    Registry.bind(coordinator)
    check(
        Registry.get() == coordinator,
        "registry returns the exact server-owned coordinator"
    )

    Registry.clear()
    check(
        Registry.get() == nil,
        "registry clear removes only the server-local binding"
    )

    print((
        "[C4 Combat Cutover Registry] REGISTRY_PASS: %d assertions "
            .. "client=false"
    ):format(checks))
end

main()
