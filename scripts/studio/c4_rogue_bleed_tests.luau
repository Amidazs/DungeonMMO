--!strict
-- Run only the new bleed progression test in an unpublished Studio place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Rogue bleed focus requires a disposable unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4RogueBleedTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4RogueBleed"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Rogue Bleed Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Rogue Bleed Focus] RESULT passed=1 total=1 failed=0")
