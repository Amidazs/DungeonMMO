--!strict
-- Studio --task RunScript; launches a local Play Solo session, never publishes.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Play-mode smoke requires a TEMP local place with no published identity.")

local SSS = game:GetService("ServerScriptService")
local studio_tests = game:GetService("StudioTestService")
local probe = Instance.new("Script")
probe.Name = "OptionalBossPlaySmoke_TEMP"
probe.Source = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioTestService = game:GetService("StudioTestService")
assert(RunService:IsStudio() and RunService:IsRunning(),
    "Play smoke must run in a Studio simulation.")
print("[Optional Boss Live Smoke] SERVER_STARTED")
local deadline = os.clock() + 22
while #Players:GetPlayers() == 0 and os.clock() < deadline do
    task.wait(0.2)
end
local player = Players:GetPlayers()[1]
if player then
    print("[Optional Boss Live Smoke] PLAYER_JOINED UserId=" .. player.UserId)
else
    warn("[Optional Boss Live Smoke] PLAYER_MISSING")
end
task.wait(8)
print("[Optional Boss Live Smoke] SERVER_FINISHED")
StudioTestService:EndTest(if player then "PLAYER_JOINED" else "PLAYER_MISSING")
]]
probe.Parent = SSS

local ok, outcome = pcall(function()
    return studio_tests:ExecutePlayModeAsync("OptionalBossLiveSmoke_TEMP")
end)
probe:Destroy()
assert(ok, "Studio Play-mode launch failed: " .. tostring(outcome))
print("[Optional Boss Live Smoke] PLAY_RESULT " .. tostring(outcome))
assert(outcome == "PLAYER_JOINED",
    "A live Studio Play session did not admit a test player.")
