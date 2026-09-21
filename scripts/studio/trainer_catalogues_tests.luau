--!strict
assert(game.PlaceId == 0 and game.GameId == 0,
    "Trainer catalogue tests require unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("TrainerCataloguesTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_TrainerCataloguesTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Trainer Catalogues Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Trainer Catalogues Focus] RESULT passed=1 total=1 failed=0")
