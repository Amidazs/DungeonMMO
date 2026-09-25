--!strict
-- Unpublished Studio-only C4 cutover rehearsal bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Bridge = require(
    ServerScriptService.Core.Services.C4CombatCutoverStudioBridge
)

local BRIDGE_NAME = "TEMP_C4CombatCutoverRehearsalBridge"
local checks = 0
local enabled = false

local FakeCoordinator = {}

--[[
Counts one rehearsal-bridge assertion.

Args:
    valid (boolean): Expected bridge state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Cutover Studio Bridge] " .. label)
end

--[[
Returns disposable coordinator state.

Args:
    None.

Returns:
    any: Detached fake gate snapshot.
]]
function FakeCoordinator:snapshot(): any
    return {
        Enabled = enabled,
    }
end

--[[
Provides the minimum enable contract required by the bridge.

Args:
    _players ({any}): Connected players selected by trusted tooling.
    _scale (number): Explicit source-units-per-stud scale.
    _night_provider (any): Server night-state callback.

Returns:
    (boolean, string?): Successful disposable activation.
]]
function FakeCoordinator:enable(
    _players: {any},
    _scale: number,
    _night_provider: any
): (boolean, string?)
    enabled = true
    return true, nil
end

--[[
Disables the disposable coordinator.

Args:
    None.

Returns:
    boolean: True after the fake gate is disabled.
]]
function FakeCoordinator:disable(): boolean
    enabled = false
    return true
end

--[[
Runs isolated ServerStorage bridge checks.

Args:
    None.

Returns:
    nil: Prints deterministic server-only bridge evidence.
]]
local function main()
    Bridge.clear(BRIDGE_NAME)

    local bridge = Bridge.bind(
        FakeCoordinator,
        BRIDGE_NAME
    )
    check(
        bridge ~= nil
            and bridge.Parent == ServerStorage
            and bridge:IsA("BindableFunction"),
        "local unpublished Studio creates a server-only BindableFunction"
    )

    local snapshot = bridge:Invoke("snapshot")
    check(
        snapshot.ok
            and snapshot.snapshot.Enabled == false,
        "snapshot invokes the exact bound coordinator"
    )

    local unknown = bridge:Invoke("unknown")
    check(
        not unknown.ok
            and unknown.reason == "UnknownC4RehearsalAction",
        "unknown rehearsal action fails closed"
    )

    enabled = true
    local disabled = bridge:Invoke("disable")
    check(
        disabled.ok
            and disabled.snapshot.Enabled == false,
        "disable routes through the bound coordinator"
    )

    Bridge.clear(BRIDGE_NAME)
    check(
        ServerStorage:FindFirstChild(BRIDGE_NAME) == nil,
        "isolated rehearsal bridge cleans up without touching runtime bridge"
    )

    print((
        "[C4 Cutover Studio Bridge] STUDIO_BRIDGE_PASS: %d assertions "
            .. "server_storage=true client=false"
    ):format(checks))
end

main()
