--!strict
-- Dedicated ordinary-Dungeon admission check against boss routing.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Dungeon admission contract requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild("DungeonAdmissionTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossOrdinaryDungeonAdmission"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Ordinary Admission] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Ordinary Admission] RESULT passed=1 total=1 failed=0")
