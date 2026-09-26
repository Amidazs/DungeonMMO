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
        error("[Contribution Service Tests] " .. message, 2)
    end
end

local sessions_by_id = {
    ["session-a"] = {
        SessionId = "session-a",
        State = "Active",
        Members = {
            ["1001"] = {UserId = 1001, Connected = true, Mode = "Active"},
            ["1002"] = {UserId = 1002, Connected = true, Mode = "Active"},
        },
        InstanceState = {
            DungeonSeed = 1234,
            ExistingFlag = true,
        },
    },
    ["session-complete"] = {
        SessionId = "session-complete",
        State = "Complete",
        Members = {
            ["1001"] = {UserId = 1001, Connected = true, Mode = "Active"},
        },
        InstanceState = {},
    },
}

local fake_sessions = {}

function fake_sessions:get(session_id: string): any
    return sessions_by_id[session_id]
end

function fake_sessions:get_for_user(user_id: number): any
    for _, session in pairs(sessions_by_id) do
        if type(session.Members) == "table"
            and session.Members[tostring(user_id)] ~= nil
        then
            return session
        end
    end
    return nil
end

function fake_sessions:set_instance_state(session_id: string, instance_state: any): any
    local session = sessions_by_id[session_id]
    if not session then
        return {ok = false, reason = "SessionNotFound"}
    end
    session.InstanceState = instance_state
    return {ok = true, session = session}
end

local service = ContributionService.new(fake_sessions, ContributionConfig)

local applied = service:record({
    EventId = "damage-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "DamageDealt",
    Amount = 25,
})
check(applied.ok == true, "Valid damage event must apply.")

local snapshot = service:get_player_snapshot("session-a", 1001)
check(snapshot.ok == true, "Player snapshot must build.")
check(snapshot.Damage == 25, "Damage channel must increment.")
check(snapshot.Tank == 0, "Damage must not affect Tank.")
check(snapshot.Support == 0, "Damage must not affect Support.")
check(snapshot.Breakdown.DamageDealt == 25, "Damage breakdown must increment.")

local replay = service:record({
    EventId = "damage-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "DamageDealt",
    Amount = 25,
})
check(
    replay.ok == true and replay.already_applied == true,
    "Duplicate EventId must be an idempotent success."
)

snapshot = service:get_player_snapshot("session-a", 1001)
check(snapshot.Damage == 25, "Duplicate EventId must not double count.")

local invalid_amounts = {
    0,
    -1,
    0 / 0,
    math.huge,
    -math.huge,
}

for index, amount in ipairs(invalid_amounts) do
    local invalid = service:record({
        EventId = "invalid-" .. tostring(index),
        SessionId = "session-a",
        UserId = 1001,
        Type = "DamageDealt",
        Amount = amount,
    })
    check(
        invalid.ok == false and invalid.reason == "InvalidContributionEvent",
        "Invalid contribution amount must reject."
    )
end

local unknown_type = service:record({
    EventId = "unknown-type",
    SessionId = "session-a",
    UserId = 1001,
    Type = "UnknownType",
    Amount = 1,
})
check(
    unknown_type.ok == false and unknown_type.reason == "UnknownContributionType",
    "Unknown contribution type must reject."
)

local unknown_session = service:record({
    EventId = "unknown-session",
    SessionId = "missing",
    UserId = 1001,
    Type = "DamageDealt",
    Amount = 1,
})
check(
    unknown_session.ok == false and unknown_session.reason == "UnknownSession",
    "Missing session must reject."
)

local non_member = service:record({
    EventId = "non-member",
    SessionId = "session-a",
    UserId = 9999,
    Type = "DamageDealt",
    Amount = 1,
})
check(
    non_member.ok == false and non_member.reason == "UserNotInSession",
    "Non-member contribution must reject."
)

local inactive = service:record({
    EventId = "inactive",
    SessionId = "session-complete",
    UserId = 1001,
    Type = "DamageDealt",
    Amount = 1,
})
check(
    inactive.ok == false and inactive.reason == "InactiveSession",
    "Completed session contribution must reject."
)

local mitigation = service:record({
    EventId = "mitigation-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "DamageMitigated",
    Amount = 8,
})
check(mitigation.ok == true, "Damage mitigation must apply.")

local aggro = service:record({
    EventId = "aggro-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "AggroHeld",
    Amount = 3,
})
check(aggro.ok == true, "Aggro contribution must apply.")

local heal = service:record({
    EventId = "heal-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "EffectiveHealing",
    Amount = 12,
})
check(heal.ok == true, "Effective healing must apply.")

local ward = service:record({
    EventId = "ward-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "EffectiveWard",
    Amount = 7,
})
check(ward.ok == true, "Effective ward must apply.")

local utility = service:record({
    EventId = "utility-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "UtilitySupport",
    Amount = 4,
})
check(utility.ok == true, "Utility support must apply.")

snapshot = service:get_player_snapshot("session-a", 1001)
check(snapshot.Damage == 25, "Non-damage events must not change Damage.")
check(snapshot.Tank == 11, "Mitigation + aggro must map to Tank.")
check(snapshot.Support == 23, "Heal + ward + utility must map to Support.")
check(snapshot.Breakdown.DamageMitigated == 8, "Mitigation breakdown mismatch.")
check(snapshot.Breakdown.AggroHeld == 3, "Aggro breakdown mismatch.")
check(snapshot.Breakdown.EffectiveHealing == 12, "Healing breakdown mismatch.")
check(snapshot.Breakdown.EffectiveWard == 7, "Ward breakdown mismatch.")
check(snapshot.Breakdown.UtilitySupport == 4, "Utility breakdown mismatch.")

local second = service:record({
    EventId = "damage-2",
    SessionId = "session-a",
    UserId = 1002,
    Type = "DamageDealt",
    Amount = 5,
})
check(second.ok == true, "Second member contribution must apply.")

local session_snapshot = service:get_session_snapshot("session-a")
check(session_snapshot.ok == true, "Session snapshot must build.")
check(#session_snapshot.OrderedUserIds == 2, "Session snapshot must include two contributors.")
check(
    session_snapshot.OrderedUserIds[1] == 1001
        and session_snapshot.OrderedUserIds[2] == 1002,
    "Session snapshot contributor ordering must be deterministic."
)

session_snapshot.Players["1001"].Damage = 999
local fresh = service:get_player_snapshot("session-a", 1001)
check(fresh.Damage == 25, "Snapshot mutation must not alter persisted state.")

check(
    sessions_by_id["session-a"].InstanceState.DungeonSeed == 1234
        and sessions_by_id["session-a"].InstanceState.ExistingFlag == true,
    "Contribution persistence must preserve unrelated InstanceState."
)

print(string.format("[Contribution Service Tests] PASS: %d assertions.", assertions))
