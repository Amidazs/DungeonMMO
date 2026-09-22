--!strict
-- Focused Rogue catalogue test in an unpublished local Studio place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Rogue catalogue focus requires an unpublished Studio place")

local tests = game:GetService("ServerScriptService")
    .Combat.Tests
local source = tests:WaitForChild("RogueDefinitionsTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_RogueCatalogueFocus"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = tests

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Rogue Catalogue Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Rogue Catalogue Focus] RESULT passed=1 total=1 failed=0")
