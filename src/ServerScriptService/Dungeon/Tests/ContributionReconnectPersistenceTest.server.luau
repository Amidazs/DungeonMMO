--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ContributionConfig = require(Shared:WaitForChild("ContributionConfig"))
local ContributionService = require(Services:WaitForChild("ContributionService"))

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Contribution Reconnect Persistence Tests] " .. message, 2)
    end
end

local session = {
    SessionId = "reconnect-session",
    State = "Active",
    Members = {
        ["7001"] = {
            UserId = 7001,
            Connected = true,
            Mode = "Active",
        },
    },
    InstanceState = {
        DungeonSeed = 8842,
        ExistingFlag = "keep-me",
    },
}

local sessions = {}

function sessions:get(session_id: string): any
    if session_id == session.SessionId then
        return session
    end
    return nil
end

function sessions:get_for_user(user_id: number): any
    if session.Members[tostring(user_id)] then
        return session
    end
    return nil
end

function sessions:set_instance_state(session_id: string, instance_state: any): any
    if session_id ~= session.SessionId then
        return {ok = false, reason = "SessionNotFound"}
    end
    session.InstanceState = instance_state
    return {ok = true, session = session}
end

local first_service = ContributionService.new(sessions, ContributionConfig)

local recorded = first_service:record({
    EventId = "reconnect-damage",
    SessionId = session.SessionId,
    UserId = 7001,
    Type = "DamageDealt",
    Amount = 37,
})
check(recorded.ok == true, "Initial contribution must record.")

session.Members["7001"].Connected = false
session.Members["7001"].Connected = true

local reconstructed_service = ContributionService.new(sessions, ContributionConfig)
local snapshot = reconstructed_service:get_player_snapshot(
    session.SessionId,
    7001
)

check(snapshot.ok == true, "Reconstructed service must read persisted contribution.")
check(snapshot.Damage == 37, "Reconnect must preserve contribution value.")
check(
    session.InstanceState.DungeonSeed == 8842
        and session.InstanceState.ExistingFlag == "keep-me",
    "Reconnect contribution state must preserve unrelated InstanceState."
)

local replay = reconstructed_service:record({
    EventId = "reconnect-damage",
    SessionId = session.SessionId,
    UserId = 7001,
    Type = "DamageDealt",
    Amount = 37,
})
check(
    replay.ok == true and replay.already_applied == true,
    "Persisted event dedupe must survive service reconstruction."
)

print(string.format(
    "[Contribution Reconnect Persistence Tests] PASS: %d assertions.",
    assertions
))
