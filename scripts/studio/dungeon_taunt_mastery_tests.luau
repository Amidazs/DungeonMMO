--!strict
-- Run only the newly added tank-taunt mastery contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Tank mastery tests require an unpublished Studio place")

local ServerScriptService = game:GetService("ServerScriptService")
local source = ServerScriptService.Dungeon.Tests:WaitForChild(
    "DungeonTauntMasteryTest"
)

local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_DungeonTauntMastery"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = ServerScriptService

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Dungeon Taunt Mastery Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Dungeon Taunt Mastery Focus] RESULT passed=1 total=1 failed=0")
