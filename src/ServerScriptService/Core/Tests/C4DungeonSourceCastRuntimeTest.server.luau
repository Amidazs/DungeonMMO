--!strict
-- FOCUSED_EDIT_ONLY_RUNTIME_COMPOSITION_TEST
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    print(
        "[C4 Dungeon Cast Runtime] SKIP: runtime composition regression "
            .. "runs in focused Edit mode"
    )
    return
end

-- Real RuntimeServices Dungeon composition regression for staged C4 casts.

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Core.Services
local RuntimeServices = require(
    Services.RuntimeServices
)

local checks = 0

--[[
Counts one real Dungeon runtime composition assertion.

Args:
    condition (boolean): Observed staged runtime state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Dungeon Cast Runtime] " .. label)
end

--[[
Runs real Studio-safe Dungeon RuntimeServices composition acceptance.

RunService:IsStudio makes RuntimeServices use in-memory persistence adapters, so
this test creates no production DataStore state and never enables source combat.

Args:
    None.

Returns:
    nil: Prints pending-Studio evidence after all composition checks pass.
]]
local function main()
    local runtime = RuntimeServices.new("Dungeon")
    local cast_runtime = runtime.C4SourceCastRuntime

    check(
        runtime.C4CombatCutoverCoordinator ~= nil
            and runtime.C4SourceCombatExecutor ~= nil
            and runtime.C4SourceShotService ~= nil,
        "Dungeon RuntimeServices creates existing C4 combat authorities"
    )
    check(
        cast_runtime ~= nil
            and cast_runtime.SourceShots
                == runtime.C4SourceShotService,
        "Dungeon RuntimeServices composes cast runtime around shared shots"
    )

    local capability = cast_runtime:capability()
    check(
        capability.Available
            and capability.SourceCastResources
            and capability.SourceCastTiming
            and capability.SourceCastScheduler
            and capability.DirectMagicBridge
            and capability.PeriodicMagicBridge
            and not capability.DirectMagicDefaultEnabled
            and not capability.DirectMagicCurrentlyEnabled
            and not capability.PeriodicMagicDefaultEnabled
            and not capability.PeriodicMagicCurrentlyEnabled,
        "real Dungeon cast bridges remain default-off after composition"
    )

    check(
        not cast_runtime.DirectMagic:is_enabled()
            and not cast_runtime.PeriodicMagic:is_enabled()
            and not runtime.C4SourceCombatExecutor:is_enabled()
            and not runtime.C4CombatCutoverCoordinator:is_enabled(),
        "real staged cast/combat gates remain disabled"
    )

    print((
        "[C4 Dungeon Cast Runtime] TEST_PASS_PENDING_STUDIO: "
        .. "%d assertions composition=true default_off=true"
    ):format(checks))
end

main()
