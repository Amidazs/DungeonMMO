--!strict
-- Focus only on the new quest-content/reward milestone in local Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Story quest regression requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("QuestServiceTest")

local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_StoryQuestFocusedRunner"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Story Quest Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[Story Quest Focus] RESULT passed=1 total=1 failed=0")
