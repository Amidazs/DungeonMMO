--!strict
-- Focused four-path class advancement check, in an unpublished Base.
assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Advanced class regression requires an unpublished Studio place"
)

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "ClassAdvancementServiceTest"
)

local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_ClassAdvancementExpansion"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()

if not ok then
    warn("[Class Advancement Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[Class Advancement Focus] RESULT passed=1 total=1 failed=0")
