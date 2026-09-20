--!strict
-- Unpublished local Studio runner: difficulty ladder and recovery contracts.
local ServerScriptService = game:GetService("ServerScriptService")

local test_paths = {
    {"Core", "Tests", "DungeonDifficultyProgressionServiceTest"},
    {"Core", "Tests", "DungeonDifficultySessionPersistenceTest"},
    {"Dungeon", "Tests", "DungeonEncounterRuntimeControllerTest"},
    {"Dungeon", "Tests", "DungeonEncounterRecoveryTest"},
    {"Dungeon", "Tests", "DungeonDepthLadderIntegrationTest"},
}
local failures = {}

-- Executes a source-controlled server test as an isolated edit-mode module.
-- Args: path ({string}): Script path inside ServerScriptService.
-- Returns: boolean, string?: Success and any failure message.
local function run_test(path: {string}): (boolean, string?)
    local node: Instance = ServerScriptService
    for _, name in ipairs(path) do
        node = node:WaitForChild(name)
    end
    assert(node:IsA("LuaSourceContainer"),
        "Missing server test " .. table.concat(path, "/"))
    local test = Instance.new("ModuleScript")
    test.Name = node.Name .. "EditMode"
    test.Source = node.Source .. "\nreturn true\n"
    test.Parent = ServerScriptService
    local ok, problem = pcall(require, test)
    test:Destroy()
    return ok, if ok then nil else tostring(problem)
end

for _, path in ipairs(test_paths) do
    local label = table.concat(path, "/")
    local ok, problem = run_test(path)
    if ok then
        print("[Depth Ladder Studio Focus] PASS " .. label)
    else
        table.insert(failures, label .. ": " .. tostring(problem))
        warn("[Depth Ladder Studio Focus] FAIL " .. label
            .. ": " .. tostring(problem))
    end
end
assert(#failures == 0,
    "[Depth Ladder Studio Focus] FAIL: "
        .. table.concat(failures, " | "))
print("[Depth Ladder Studio Focus] PASS: "
    .. tostring(#test_paths) .. " suites.")
