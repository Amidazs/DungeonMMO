--!strict
-- Run with Roblox Studio --task RunScript against a TEMP local Rojo build.
-- This tests backend modules in edit mode; it does not simulate live gameplay.
local ServerScriptService = game:GetService("ServerScriptService")

local test_paths = {
    {"Core", "Tests", "DungeonOptionalBossRunStateTest"},
    {"Core", "Tests", "DungeonOptionalBossScheduleTest"},
    {"Core", "Tests", "DungeonSecretDiscoveryTest"},
    {"Dungeon", "Tests", "DungeonOptionalBossRewardTest"},
}

local failures = {}
for _, path in ipairs(test_paths) do
    local node: Instance = ServerScriptService
    for _, name in ipairs(path) do
        node = node:WaitForChild(name)
    end

    assert(node:IsA("LuaSourceContainer"),
        "Expected Lua test script at " .. table.concat(path, "/"))

    local test = Instance.new("ModuleScript")
    test.Name = node.Name .. "EditModeTest"
    -- A required ModuleScript must return exactly one value after the test.
    test.Source = node.Source .. "\nreturn true\n"
    test.Parent = ServerScriptService

    local ok, err = pcall(require, test)
    test:Destroy()

    local label = table.concat(path, "/")
    if ok then
        print("[Optional Boss Studio Focus] PASS " .. label)
    else
        local failure = label .. ": " .. tostring(err)
        table.insert(failures, failure)
        warn("[Optional Boss Studio Focus] FAIL " .. failure)
    end
end

if #failures > 0 then
    error(string.format(
        "[Optional Boss Studio Focus] FAIL: %d/%d suites failed. %s",
        #failures, #test_paths, table.concat(failures, " | ")
    ))
end

print(string.format(
    "[Optional Boss Studio Focus] PASS: %d edit-mode suites.",
    #test_paths
))
