--!strict
-- Unpublished focused contract for post-terminal Depth2/Depth4 wipe ticks.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Optional depth wipe tests require an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild(
    "DungeonOptionalDepthPartyWipeTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_OptionalDepthWipeContract"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Optional Depth Wipe Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Optional Depth Wipe Focus] RESULT passed=1 total=1 failed=0")
