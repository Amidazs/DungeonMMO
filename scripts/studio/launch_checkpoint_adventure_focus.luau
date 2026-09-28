--!strict
-- Unpublished Dungeon acceptance for trusted checkpoint Adventures.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Checkpoint Adventure focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService.Dungeon.Tests

local TESTS = table.freeze({
    "CheckpointServiceTest",
    "CompletionQuestBridgeTest",
    "DungeonCheckpointQuestBridgeTest",
    "RuinSurveyCheckpointIntegrationTest",
    "FractureTrailMixedIntegrationTest",
})

--[[
Runs one Dungeon checkpoint/quest test through a disposable module copy.

Args:
    test_name (string): Exact Dungeon.Tests child name.

Returns:
    nil: Raises when the test is missing or fails.
]]
local function run_test(test_name: string)
    local source = assert(
        Tests:FindFirstChild(test_name),
        "Checkpoint Adventure test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Checkpoint Adventure fixture must contain Luau: " .. test_name
    )

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_CheckpointAdventure_" .. test_name
    holder.Source = source.Source .. "\nreturn true\n"
    holder.Parent = ServerScriptService

    local ok, result = pcall(require, holder)
    holder:Destroy()

    assert(
        ok and result == true,
        test_name .. " failed: " .. tostring(result)
    )
end

--[[
Runs trusted checkpoint and mixed-objective Adventure acceptance.

Args:
    None.

Returns:
    nil: Prints a stable marker only after every suite passes.
]]
local function main()
    for _, test_name in ipairs(TESTS) do
        run_test(test_name)
    end

    print("[Checkpoint Adventure Focus] 5/5 PASS")
    print("VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5")
end

main()
