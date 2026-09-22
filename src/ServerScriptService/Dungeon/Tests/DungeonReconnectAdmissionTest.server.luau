--!strict
-- Same-server reconnect contract against real session/admission/lease services.
-- No Studio fixture impersonates a real Roblox network reconnect.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Dungeon = SSS:WaitForChild("Dungeon")
local InMemoryMapAdapter = require(
    Core.Adapters:WaitForChild("InMemoryMapAdapter")
)
local Sessions = require(
    Core.Services:WaitForChild("DungeonSessionService")
)
local Leases = require(
    Core.Services:WaitForChild("ProfileLeaseService")
)
local Admission = require(
    Dungeon:WaitForChild("DungeonAdmissionRules")
)
local DeathService = require(
    Dungeon:WaitForChild("DungeonDeathService")
)
local Recovery = require(
    Dungeon:WaitForChild("DungeonRecoveryRules")
)

local NOW = 1000
local USER_ID = 98451
local OTHER_USER_ID = 98452
local SERVER_ID = "Dungeon:ReconnectSameServer_TEMP"
local assertions = 0

-- Args:
--   condition (boolean): Required server-owned invariant.
--   message (string): Diagnostic explaining a regression.
-- Returns:
--   nil: Records one verified invariant or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Dungeon Reconnect Admission] " .. message)
end

-- Args: None.
-- Returns:
--   number: Deterministic time for in-memory service fixtures.
local function clock(): number
    return NOW
end

local sessions = Sessions.new(InMemoryMapAdapter.new(clock), clock)
local original = assert(sessions:create(
    "TestDungeon", {USER_ID, OTHER_USER_ID},
    100, "ReconnectReservation_TEMP"
))
local session_id = original.SessionId
local routing = {
    SessionId = session_id,
    DungeonId = original.DungeonId,
    DifficultyId = original.Difficulty.Id,
}
check(
    not Admission.same_server_reconnect(
        original, USER_ID, session_id
    ).ok,
    "Initial admission can never bypass its handoff nonce."
)
check(sessions:mark_connected(session_id, USER_ID).ok,
    "The original authenticated member must enter the run.")
check(sessions:mark_connected(session_id, OTHER_USER_ID).ok,
    "A second party member must keep the live run active.")
check(
    sessions:activate_checkpoint(
        session_id, "EncounterStart:CombatRoom2", 2
    ).ok,
    "The checkpoint must be set before a member departs."
)
check(
    sessions:set_member_mode(session_id, USER_ID, "Dead").ok
        and sessions:consume_free_revive(session_id, USER_ID).ok,
    "A consumed free revive must be persisted before the disconnect."
)
check(
    sessions:set_member_mode(
        session_id, USER_ID, "Spectating"
    ).ok,
    "The exhausted member must remain spectating during absence."
)
check(
    not Admission.same_server_reconnect(
        sessions:get(session_id), USER_ID, session_id
    ).ok,
    "A connected member cannot claim a duplicate admission."
)
check(sessions:mark_disconnected(session_id, USER_ID).ok,
    "PlayerRemoving must mark that same member disconnected.")
local departed = assert(sessions:get(session_id))
check(
    Admission.same_server_reconnect(
        departed, USER_ID, session_id
    ).ok,
    "A departed authenticated member may rejoin the SAME active server."
)
check(
    not Admission.same_server_reconnect(
        departed, USER_ID, nil
    ).ok
        and not Admission.same_server_reconnect(
            departed, USER_ID, "DifferentRun"
        ).ok,
    "An unbound or different server cannot skip the original nonce."
)
check(
    not Admission.same_server_reconnect(
        departed, OTHER_USER_ID, session_id
    ).ok
        and not Admission.same_server_reconnect(
            departed, 987654, session_id
        ).ok,
    "An actively connected peer and a stranger cannot use this route."
)
check(
    Admission.validate(
        departed, routing, USER_ID, departed.DungeonId
    ).ok,
    "The returning user must satisfy the regular admission contract."
)
check(
    Admission.validate(
        departed, {SessionId = "ForgedRun", DungeonId = departed.DungeonId},
        USER_ID, departed.DungeonId
    ).reason == "SessionIdMismatch",
    "A returning player cannot route into a different run."
)
check(
    Admission.validate(
        departed, {SessionId = session_id, DungeonId = "AbandonedMine"},
        USER_ID, departed.DungeonId
    ).reason == "DungeonIdMismatch",
    "Reconnection must preserve the server-authoritative dungeon."
)
local no_departure_stamp = table.clone(departed)
no_departure_stamp.Members = table.clone(departed.Members)
no_departure_stamp.Members[tostring(USER_ID)] = table.clone(
    departed.Members[tostring(USER_ID)]
)
no_departure_stamp.Members[tostring(USER_ID)].LastDisconnectedAt = nil
check(
    not Admission.same_server_reconnect(
        no_departure_stamp, USER_ID, session_id
    ).ok,
    "An unrecorded departure cannot unlock the nonce-free route."
)

local forbidden = table.clone(departed)
forbidden.Members = table.clone(departed.Members)
forbidden.Members[tostring(USER_ID)] = table.clone(
    departed.Members[tostring(USER_ID)]
)
forbidden.Members[tostring(USER_ID)].Abandoned = true
check(
    not Admission.same_server_reconnect(
        forbidden, USER_ID, session_id
    ).ok
        and Admission.validate(
            forbidden, routing, USER_ID, departed.DungeonId
        ).reason == "MemberAbandoned",
    "Abandoned members cannot regain entry through stale routing."
)
forbidden.State = "Failed"
check(
    not Admission.same_server_reconnect(
        forbidden, USER_ID, session_id
    ).ok,
    "Terminal runs cannot be reopened by a returning player."
)

local lease_map = InMemoryMapAdapter.new(clock)
local dungeon_lease = Leases.new(lease_map, SERVER_ID, clock)
local other_server = Leases.new(
    lease_map, "Dungeon:AnotherServer_TEMP", clock
)
check(dungeon_lease:claim(USER_ID).ok,
    "The original dungeon server owns the player's profile.")
check(
    not other_server:claim(USER_ID).ok,
    "Another server cannot take the original live profile lease."
)
check(dungeon_lease:release(USER_ID).ok,
    "PlayerRemoving releases its profile writer lease.")
check(dungeon_lease:claim(USER_ID).ok,
    "Re-admission reacquires the same server's profile writer lease.")
check(
    not other_server:claim(USER_ID).ok,
    "The reconnected player must still have a single profile writer."
)

check(sessions:mark_connected(session_id, USER_ID).ok,
    "Re-admission must mark the original member connected again.")
local resumed = assert(sessions:get(session_id))
local member = resumed.Members[tostring(USER_ID)]
check(
    member.Mode == "Spectating"
        and member.FreeReviveUsed == true
        and Recovery.member_mode_on_reconnect(member) == "Spectating",
    "Rejoining cannot grant a spectator another free revive."
)
check(
    resumed.SessionId == session_id
        and resumed.Checkpoint.Id == departed.Checkpoint.Id
        and resumed.Checkpoint.Sequence == departed.Checkpoint.Sequence
        and resumed.Members[tostring(OTHER_USER_ID)].Connected,
    "Rejoining must not replace the run, checkpoint or remaining party."
)
check(
    Recovery.member_mode_on_reconnect({
        Mode = "Reviving", FreeReviveUsed = true,
    }) == "Active",
    "Interrupted automatic revive restores Active without a free-life refund."
)
check(
    not Admission.same_server_reconnect(
        resumed, USER_ID, session_id
    ).ok,
    "An admitted member cannot immediately reuse the reconnect gate."
)
local revive_payload = nil
local death = DeathService.new(
    sessions,
    {
        get_active_checkpoint = function()
            return {
                Id = resumed.Checkpoint.Id,
                CFrame = CFrame.new(3, 4, 5),
            }
        end,
    },
    session_id,
    {
        emit_state = function(_user_id: number, payload: any)
            revive_payload = payload
        end,
    }
)
check(
    death:send_member_state({UserId = USER_ID}).ok == true
        and revive_payload.member_mode == "Spectating"
        and revive_payload.free_available == false
        and revive_payload.session_state == "Active",
    "The returning member must receive the persisted spectator UI state."
)
check(
    not death:send_member_state({UserId = 987654}).ok,
    "A nonmember cannot request a connected player's revive state."
)
check(dungeon_lease:release(USER_ID).ok,
    "The fixture must leave its in-memory profile lease released.")

print(string.format(
    "[Dungeon Reconnect Admission] PASS: %d assertions.", assertions
))
