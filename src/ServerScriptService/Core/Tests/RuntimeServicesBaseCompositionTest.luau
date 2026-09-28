--!strict
-- Base place must not require Dungeon-only source combat composition.

local SSS = game:GetService("ServerScriptService")

local RuntimeServices = require(
    SSS.Core.Services.RuntimeServices
)

local checks = 0

--[[
Counts one Base runtime-composition assertion.

Args:
    valid (boolean): Expected Base-only runtime condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Base Runtime Composition] " .. label)
end

--[[
Runs Base composition without importing Dungeon-only combat services.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after Base runtime composition succeeds.
]]
local function main()
    local runtime = RuntimeServices.new("Base")

    check(
        runtime.ProfileService ~= nil,
        "Base still composes shared profile authority"
    )
    check(
        runtime.InventoryService ~= nil,
        "Base still composes shared inventory authority"
    )
    check(
        runtime.C4SourceCombatExecutor == nil,
        "Base does not compose Dungeon source combat executor"
    )
    check(
        runtime.C4SourceCastRuntime == nil,
        "Base does not compose Dungeon source cast runtime"
    )
    check(
        runtime.C4CombatCutoverCoordinator == nil,
        "Base does not compose Dungeon combat cutover coordinator"
    )

    print(
        ("[Base Runtime Composition] PASS: %d assertions")
            :format(checks)
    )
end

main()
