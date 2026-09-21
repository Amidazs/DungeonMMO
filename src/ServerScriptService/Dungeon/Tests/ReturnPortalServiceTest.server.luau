--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("ReturnPortalService")
if not module then
    error("[Return Portal Tests] RED: ReturnPortalService is missing.")
end
local ReturnPortalService = require(module)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Return Portal Tests] " .. message, 2)
    end
end

local now = 100
local session = {
    SessionId = "s",
    State = "Complete",
    CompletionRewardsCommitted = true,
    ReturnPlaceId = 123,
    Members = {[
        "101"
    ] = {UserId = 101, Connected = true, Mode = "Active"}},
}
local fake_sessions: any = {}
function fake_sessions:get(_id: string)
    return session
end
function fake_sessions:abandon_member(
    _session_id: string,
    user_id: number
): any
    local member = session.Members[tostring(user_id)]
    if not member then
        return {ok = false, reason = "NotMember", session = session}
    end
    member.Abandoned = true
    member.Mode = "Spectating"
    if session.State == "Active" and user_id == 101 then
        session.State = "Failed"
    end
    return {ok = true, session = session}
end

local calls = 0
local fake_coordinator: any = {}
function fake_coordinator:return_to_base(players: {any}, _session: any)
    calls += 1
    return {ok = true, players = players}
end

local service = ReturnPortalService.new(fake_sessions, fake_coordinator, {
    clock = function()
        return now
    end,
    is_studio = false,
    auto_return_seconds = 60,
})
local opened = service:open("s", {ok = true})
check(
    opened.ok == true and opened.return_at == 160,
    "Completion must start a 60-second auto-return timer."
)
check(
    service:request_return("s", {{UserId = 101}}).ok == true and calls == 1,
    "Manual completion return must work immediately after reward commit."
)
now = 159
check(
    service:tick("s", {{UserId = 101}}).triggered == false,
    "Auto return must not fire early."
)
now = 160
check(
    service:tick("s", {{UserId = 101}}).triggered == true and calls == 2,
    "Auto return must fire at 60 seconds."
)

local studio = ReturnPortalService.new(fake_sessions, fake_coordinator, {
    clock = function()
        return now
    end,
    is_studio = true,
    auto_return_seconds = 60,
})
studio:open("s", {ok = true})
local simulated = studio:request_return("s", {{UserId = 101}})
check(
    simulated.ok == true and simulated.simulated == true,
    "Studio completion return must simulate instead of real teleport."
)

session = {
    SessionId = "abandon-s",
    State = "Active",
    ReturnPlaceId = 123,
    Members = {[
        "101"
    ] = {UserId = 101, Connected = true, Mode = "Dead"}},
}
local abandon_service = ReturnPortalService.new(
    fake_sessions,
    fake_coordinator,
    {is_studio = false}
)
local abandoned = abandon_service:request_abandon(
    "abandon-s",
    {{UserId = 101}}
)
check(abandoned.ok == true, "A dead player must be able to Return to Lobby.")
check(
    session.Members["101"].Abandoned == true,
    "Return to Lobby must persist member abandonment before return."
)
check(
    session.State == "Failed",
    "Solo Return to Lobby must fail the unfinished run."
)
check(calls == 3, "Return to Lobby must use the same Base teleport boundary.")

-- A terminal wipe cannot be abandoned again; its participants can
-- return to Base and request a new dungeon session from the Base.
session = {
    SessionId = "failed-run",
    State = "Failed",
    FailureReason = "WipeReviveTimeout",
    ReturnPlaceId = 123,
    Members = {
        ["101"] = {
            UserId = 101, Connected = true, Mode = "Spectating",
        },
    },
}
local failed = abandon_service:request_failed_return(
    "failed-run",
    {{UserId = 101}}
)
check(
    failed.ok == true and failed.simulated == false
        and calls == 4,
    "A connected member can return from a failed run to Base."
)
check(
    session.State == "Failed"
        and session.FailureReason == "WipeReviveTimeout",
    "Returning after a wipe must never revive or overwrite its run."
)

local unauthorized = abandon_service:request_failed_return(
    "failed-run",
    {{UserId = 102}}
)
check(
    unauthorized.ok == false
        and unauthorized.reason == "NotConnectedMember"
        and calls == 4,
    "Non-members must not be teleported through a failed run."
)
session.Members["101"].Connected = false
local departed = abandon_service:request_failed_return(
    "failed-run",
    {{UserId = 101}}
)
check(
    departed.ok == false
        and departed.reason == "NotConnectedMember"
        and calls == 4,
    "A disconnected member cannot reuse a stale return request."
)
session.Members["101"].Connected = true

local studio_return = studio:request_failed_return(
    "failed-run",
    {{UserId = 101}}
)
check(
    studio_return.ok == true
        and studio_return.simulated == true
        and calls == 4,
    "Studio must simulate a failed-run return without a teleport."
)
session.State = "Active"
local not_failed = abandon_service:request_failed_return(
    "failed-run",
    {{UserId = 101}}
)
check(
    not_failed.ok == false
        and not_failed.reason == "SessionNotFailed"
        and calls == 4,
    "An active run cannot use the failed-run return bypass."
)

print(string.format("[Return Portal Tests] PASS: %d assertions.", assertions))
