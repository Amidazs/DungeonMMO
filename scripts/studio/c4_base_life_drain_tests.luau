--!strict
-- Human first-tier Life Drain ranks in unpublished Roblox Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 Life Drain tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseLifeDrainTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseLifeDrain"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Life Drain Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Life Drain Focus] RESULT passed=1 total=1 failed=0")
