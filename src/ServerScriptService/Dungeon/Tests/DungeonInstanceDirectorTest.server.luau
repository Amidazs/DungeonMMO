--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local module = Services:FindFirstChild("DungeonInstanceDirector")

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Dungeon Instance Director Tests] " .. message, 2)
    end
end

check(module ~= nil and module:IsA("ModuleScript"), "DungeonInstanceDirector module exists")
if not module or not module:IsA("ModuleScript") then return end

local Director = require(module)
local normal = Director.resolve("AbandonedMine", "session-normal", 1000, {
    force_rare = false,
    force_event = false,
})
check(normal.DungeonId == "AbandonedMine", "state carries dungeon id")
check(normal.RareStateId == nil, "forced normal has no rare state")
check(normal.EventActive == false, "forced normal has no event")
check(type(normal.Module1Id) == "string", "module 1 selected")
check(type(normal.Module2Id) == "string", "module 2 selected")

local special = Director.resolve("AbandonedMine", "session-special", 1000, {
    force_rare = true,
    force_event = true,
})
check(special.RareStateId == "CrystalBloom", "rare state can be forced")
check(special.EventId == "DeepEchoes" and special.EventActive == true, "event can be forced")

local a = Director.resolve("AbandonedMine", "stable-session", 1000, {force_event = false})
local b = Director.resolve("AbandonedMine", "stable-session", 1000, {force_event = false})
check(a.Module1Id == b.Module1Id, "module 1 deterministic")
check(a.Module2Id == b.Module2Id, "module 2 deterministic")
check(a.RareStateId == b.RareStateId, "rare roll deterministic")

local window = Director.resolve("AbandonedMine", "window-session", 150, {
    force_rare = false,
    event_start = 100,
    event_end = 200,
})
check(window.EventActive == true, "session inside event window receives event")

local outside = Director.resolve("AbandonedMine", "outside-session", 250, {
    force_rare = false,
    event_start = 100,
    event_end = 200,
})
check(outside.EventActive == false, "session outside event window does not receive event")

print(string.format("[Dungeon Instance Director Tests] PASS: %d assertions.", assertions))
