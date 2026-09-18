--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")

local ContributionConfig = require(Shared:WaitForChild("ContributionConfig"))
local ContributionService = require(Services:WaitForChild("ContributionService"))
local DungeonSessionService = require(Services:WaitForChild("DungeonSessionService"))
local InMemoryMapAdapter = require(Adapters:WaitForChild("InMemoryMapAdapter"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Contribution Real Session Persistence Tests] " .. message, 2)
    end
end

local now = 1000
local map = InMemoryMapAdapter.new(function() return now end)
local sessions = DungeonSessionService.new(map, function() return now end)

local session, create_error = sessions:create(
    "TestDungeon",
    {8123},
    0,
    "ContributionRealSession"
)
check(session ~= nil, "Real session must create: " .. tostring(create_error))

local seeded = sessions:set_instance_state(session.SessionId, {
    DungeonSeed = 8842,
    ExistingFlag = "keep-me",
})
check(seeded.ok == true, "Authored InstanceState must seed once.")

local connected = sessions:mark_connected(session.SessionId, 8123)
check(connected.ok == true, "Member must become active.")

local service = ContributionService.new(sessions, ContributionConfig)
local recorded = service:record({
    EventId = "real-session-damage",
    SessionId = session.SessionId,
    UserId = 8123,
    Type = "DamageDealt",
    Amount = 37,
})
check(recorded.ok == true, "Contribution must persist into an already-authored real InstanceState.")

local latest = sessions:get(session.SessionId)
check(latest ~= nil, "Session must remain readable.")
check(latest.InstanceState.DungeonSeed == 8842, "Contribution update must preserve DungeonSeed.")
check(latest.InstanceState.ExistingFlag == "keep-me", "Contribution update must preserve unrelated authored state.")

local snapshot = service:get_player_snapshot(session.SessionId, 8123)
check(snapshot.ok == true, "Contribution snapshot must build.")
check(snapshot.Damage == 37, "Persisted contribution damage must equal 37.")
check(snapshot.Breakdown.DamageDealt == 37, "Persisted damage breakdown must equal 37.")

print(string.format(
    "[Contribution Real Session Persistence Tests] PASS: %d assertions.",
    assertions
))
