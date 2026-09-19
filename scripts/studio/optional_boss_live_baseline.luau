--!strict
-- Execute with Studio --task RunScript against a local TEMP Rojo place.
-- Starts actual Play mode; does not change any published game or rollout flag.
local StudioTestService = game:GetService("StudioTestService")
local ServerScriptService = game:GetService("ServerScriptService")
local runner = Instance.new("Script")
runner.Name = "DungeonMMOOptionalBossTemporaryPlaySmoke"
runner.Source = [=[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioTestService = game:GetService("StudioTestService")
local SSS = game:GetService("ServerScriptService")
local Shared = game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
local Definitions = require(Shared:WaitForChild("DungeonDefinitions"))
local function finish(ok, detail)
    print("[Optional Boss Live Baseline] "
        .. (if ok then "PASS " else "FAIL ") .. detail)
    StudioTestService:EndTest(if ok then "PASS" else "FAIL: " .. detail)
end
task.spawn(function()
    local ok, err = pcall(function()
        assert(RunService:IsRunning() and RunService:IsStudio(),
            "must execute in live Studio play session")
        for _, id in ipairs({"TestDungeon", "AbandonedMine"}) do
            assert(Definitions.get(id).OptionalBossRuntimeEnabled == false,
                id .. " optional rollout must remain disabled")
        end
        local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
        local char = player.Character or player.CharacterAdded:Wait()
        assert(char:WaitForChild("HumanoidRootPart", 25),
            "player character did not spawn into live Dungeon")
        local runtime = workspace:WaitForChild("DungeonGameplayRuntime", 25)
        assert(runtime:FindFirstChild("DungeonEnemies"),
            "Dungeon gameplay runtime did not initialize")
        print("[Optional Boss Live Baseline] Player="
            .. player.Name .. " Character=" .. char.Name)
        task.wait(3)
    end)
    finish(ok, if ok then "player spawned, Dungeon runtime present, optional rollout locked"
        else tostring(err))
end)
task.delay(55, function()
    finish(false, "live baseline timed out")
end)
]=]
runner.Parent = ServerScriptService
local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync("DungeonMMOOptionalBossBaseline")
end)
runner:Destroy()
assert(ok, "Could not start Studio Play mode: " .. tostring(result))
assert(result == "PASS", "Live baseline did not pass: " .. tostring(result))
print("[Optional Boss Live Baseline] VERIFIED_PLAY_MODE_PASS")
