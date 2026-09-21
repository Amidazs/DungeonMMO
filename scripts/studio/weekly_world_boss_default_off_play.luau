--!strict
-- Test an unpublished dedicated place with its default-off switch.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World boss default-off Play requires unpublished Studio")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
assert(SSS:GetAttribute("DungeonMMOWorldBossPlaceEnabled") ~= true,
    "Dedicated boss place must not auto-enable on a new build")

local driver = Instance.new("Script")
driver.Name = "WorldBossDefaultOffDriver_TEMP"
driver.Source = [==[
local STS = game:GetService("StudioTestService")
local SSS = game:GetService("ServerScriptService")
task.wait(3)
local ok, reason = pcall(function()
    assert(SSS:GetAttribute("DungeonMMOWorldBossPlaceEnabled") ~= true,
        "world boss was enabled without a published release flag")
    assert(workspace:FindFirstChild("AncientGuardianPlaceholder") == nil,
        "disabled destination must not spawn a world boss")
    assert(workspace:FindFirstChild("WorldBossReturnPrompt", true) == nil,
        "disabled destination must not expose an inert return portal")
end)
if not ok then
    warn("[World Boss Default Off] FAIL " .. tostring(reason))
end
print("[World Boss Default Off] " .. (if ok then "PASS" else "FAIL"))
STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("WorldBossDefaultOff_TEMP")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Default-off world boss Play failed: " .. tostring(result))
print("[World Boss Default Off] VERIFIED_PLAY_MODE_PASS")
