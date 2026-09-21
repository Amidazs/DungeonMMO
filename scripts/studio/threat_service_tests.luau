--!strict
assert(game.PlaceId == 0 and game.GameId == 0,
    "Threat service tests require unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Combat.Tests:WaitForChild("ThreatServiceTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_ThreatServiceTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Threat Service Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Threat Service Focus] RESULT passed=1 total=1 failed=0")
