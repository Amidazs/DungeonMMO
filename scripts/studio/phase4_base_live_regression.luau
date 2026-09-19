--!strict
-- TEMP local Base Place only. Runs Play mode without publishing.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Phase 4 Base regression must run against an unpublished TEMP place.")

local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local driver = Instance.new("Script")
driver.Name = "Phase4BaseLiveRegression_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local STS = game:GetService("StudioTestService")
local function run()
    assert(RunService:IsRunning() and RunService:IsStudio(),
        "Base regression needs a live Studio simulation")
    local definition = require(RS.Core.Shared.DungeonDefinitions)
    assert(definition.get("TestDungeon").OptionalBossRuntimeEnabled == false,
        "Temple optional boss release lock changed")
    assert(definition.get("AbandonedMine").OptionalBossRuntimeEnabled == false,
        "Mine optional boss release lock changed")
    assert(SSS.Base:FindFirstChild("BaseRuntime") ~= nil,
        "Base server runtime script is missing")
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    local char = player.Character or player.CharacterAdded:Wait()
    assert(char:WaitForChild("HumanoidRootPart", 25),
        "Base player character did not spawn")
    assert(RS.Core.Remotes:FindFirstChild("ProfileSnapshot") ~= nil,
        "Base profile remote is missing")
    task.wait(8)
    print("[Phase 4 Base Live] PASS player, Base runtime, profile remote and release locks")
end
local ok, reason = pcall(run)
if not ok then warn("[Phase 4 Base Live] FAIL " .. tostring(reason)) end
STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
]=]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("Phase4BaseLiveRegression_TEMP")
end)
driver:Destroy()
assert(ok and result == "PASS", "Base live regression failed: " .. tostring(result))
print("[Phase 4 Base Live] VERIFIED_PLAY_MODE_PASS")
