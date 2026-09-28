--!strict
-- Unpublished Studio backend focus for live Dungeon Skinning supply.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Live Skinning focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")

local TESTS = table.freeze({
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEncounterSpawnCatalogTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonWolfFactoryTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEnemyCleanupTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "CombatPackEncounterExecutorTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEncounterExecutionBootstrapTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEncounterExecutorsTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEnemyFactoryRegistryTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "Depth1EncounterBindingsTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "Depth1EncounterFlowTest",
    }),
    table.freeze({
        Group = "Dungeon",
        Name = "DungeonEncounterFlowTest",
    }),
    table.freeze({
        Group = "Core",
        Name = "SkinningEligibilityTest",
    }),
    table.freeze({
        Group = "Core",
        Name = "CorpseSkinningRuntimeTest",
    }),
    table.freeze({
        Group = "Core",
        Name = "CorpseSkinningTwoUserTest",
    }),
    table.freeze({
        Group = "Core",
        Name = "ProfessionGatherTierTest",
    }),
})

--[[
Runs one source-controlled backend test through a disposable ModuleScript.

Args:
    test_spec (any): Group and test name under ServerScriptService.

Returns:
    (boolean, string?): Success or captured failure text.
]]
local function run_test(
    test_spec: any
): (boolean, string?)
    local group = ServerScriptService:FindFirstChild(
        test_spec.Group
    )
    local tests = group and group:FindFirstChild("Tests")
    local source = tests and tests:FindFirstChild(
        test_spec.Name
    )

    if not source
        or not source:IsA("LuaSourceContainer")
    then
        return false, "MissingTest:" .. test_spec.Name
    end

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_LiveSkinning_" .. test_spec.Name
    holder.Source = source.Source .. "\nreturn true\n"
    holder.Parent = ServerScriptService

    local ok, result = pcall(require, holder)
    holder:Destroy()

    if not ok or result ~= true then
        return false, tostring(result)
    end

    return true, nil
end

--[[
Runs the complete live-Skinning backend regression package.

Args:
    None.

Returns:
    nil: Prints a stable marker only when all focused suites pass.
]]
local function main()
    local failures = {}

    for _, test_spec in ipairs(TESTS) do
        local ok, reason = run_test(test_spec)

        if ok then
            print(
                "[Live Skinning Focus] PASS "
                    .. test_spec.Name
            )
        else
            table.insert(
                failures,
                test_spec.Name
                    .. ": "
                    .. tostring(reason)
            )
        end
    end

    print(
        ("[Live Skinning Focus] "
            .. "RESULT passed=%d total=%d failed=%d")
            :format(
                #TESTS - #failures,
                #TESTS,
                #failures
            )
    )

    assert(
        #failures == 0,
        table.concat(failures, " | ")
    )
    print(
        "VERIFIED_LIVE_SKINNING_BACKEND_FOCUS_PASS "
            .. tostring(#TESTS)
    )
end

main()
