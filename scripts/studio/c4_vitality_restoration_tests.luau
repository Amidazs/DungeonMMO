--!strict
-- Run only the new health and healing passive tests in unpublished Base.
assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Vitality and restoration tests require an unpublished Studio place"
)

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("C4VitalityRestorationTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4VitalityRestorationTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()

if not ok then
    warn("[C4 Vitality Restoration Focus] FAIL " .. tostring(reason))
    error(reason)
end

print(
    "[C4 Vitality Restoration Focus] RESULT passed=1 total=1 failed=0"
)
