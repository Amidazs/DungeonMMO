--!strict
-- Run only Elf-specific first-transfer skill gating and rank effects.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Elf support test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4ElvenScoutSupportTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ElfSupport"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Elf Support Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Elf Support Focus] RESULT passed=1 total=1 failed=0")
