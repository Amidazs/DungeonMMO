--!strict
-- Prints measured C4 skill rank gaps without claiming full parity.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 volume audit requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("C4SkillVolumeAuditTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4SkillVolumeAudit"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Volume Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Volume Focus] RESULT report=complete parity=false")
