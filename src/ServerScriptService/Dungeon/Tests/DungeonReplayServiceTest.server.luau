--!strict
local SSS = game:GetService("ServerScriptService")
local ReplayService = require(
    SSS.Dungeon:WaitForChild("DungeonReplayService")
)

local assertions = 0
-- Args:
--   condition: boolean; gameplay replay invariant to validate.
--   message: string; diagnostic if the assertion fails.
-- Returns:
--   nil: increments passed assertion count or fails immediately.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Dungeon Replay Tests] " .. message)
end

local tank = {UserId = 101}
local healer = {UserId = 102}
local stranger = {UserId = 999}
local session = {
    SessionId = "replay-old-run",
    State = "Complete",
    CompletionRewardsCommitted = true,
    DungeonId = "TestDungeon",
    Difficulty = {Id = "Depth2"},
    ReturnPlaceId = 135,
    Members = {
        ["101"] = {UserId = 101, Connected = true},
        ["102"] = {UserId = 102, Connected = true},
    },
}
local sessions = {}
-- Args:
--   _session_id: string; fixture session identifier.
-- Returns:
--   any: active fake session state.
function sessions:get(_session_id: string): any
    return session
end

local starts = 0
local last_start = {}
local coordinator = {}
-- Args:
--   players: {any}; consenting participants.
--   dungeon_id: string; selected dungeon.
--   place_id: number; destination Dungeon place.
--   difficulty_id: string?; existing run difficulty.
--   return_place_id: number?; original Base destination.
-- Returns:
--   any: new-run routing call record.
function coordinator:start_dungeon(
    players: {any},
    dungeon_id: string,
    place_id: number,
    difficulty_id: string?,
    return_place_id: number?
): any
    starts += 1
    last_start = {
        players = players,
        dungeon_id = dungeon_id,
        place_id = place_id,
        difficulty_id = difficulty_id,
        return_place_id = return_place_id,
    }
    return {ok = true, session = {SessionId = "new-run"}}
end

local replay = ReplayService.new(sessions, coordinator, {
    destination_place_id = 245,
    is_player_ready = function(_player: any): boolean
        return true
    end,
})
check(
    replay:request(session.SessionId, stranger, {tank, healer}).reason
        == "NotConnectedMember",
    "Non-members cannot vote or start an instance replay."
)
local waiting = replay:request(
    session.SessionId, tank, {tank, healer}
)
check(
    waiting.ok and waiting.waiting == 1 and starts == 0,
    "A single party member cannot force a group into a new run."
)
local begun = replay:request(
    session.SessionId, healer, {tank, healer}
)
check(
    begun.ok and begun.party_size == 2 and starts == 1,
    "The last consenting party member should start one new run."
)
check(
    last_start.dungeon_id == "TestDungeon"
        and last_start.difficulty_id == "Depth2"
        and last_start.return_place_id == 135
        and last_start.place_id == 245,
    "A replay preserves dungeon difficulty and the original Base."
)
check(
    last_start.players[1] == tank and last_start.players[2] == healer,
    "All current party members enter the same reserved run."
)
check(
    replay:request(session.SessionId, healer, {tank, healer}).reason
        == "ReplayAlreadyStarting"
        and starts == 1,
    "Repeated clicks cannot create multiple reservations."
)

local failed = ReplayService.new(sessions, coordinator, {
    destination_place_id = 245,
    is_player_ready = function(_player: any): boolean
        return true
    end,
})
session.State = "Failed"
session.CompletionRewardsCommitted = false
check(
    failed:request(session.SessionId, tank, {tank, healer}).waiting == 1,
    "A failed run should expose the same group-consent flow."
)
check(
    failed:request(session.SessionId, healer, {tank, healer}).ok
        and starts == 2,
    "A full wipe may start a new run, never reactivate the old one."
)
session.State = "Complete"
check(
    ReplayService.new(sessions, coordinator, {
        destination_place_id = 245,
        is_player_ready = function(_player: any): boolean
            return true
        end,
    }):request(session.SessionId, tank, {tank, healer}).reason
        == "SessionNotReplayable",
    "An uncommitted completion cannot be replayed to dodge reward saves."
)

session.State = "Failed"
session.Members["102"].Connected = false
local solo = ReplayService.new(sessions, coordinator, {
    destination_place_id = 245,
    is_player_ready = function(_player: any): boolean
        return true
    end,
})
check(
    solo:request(session.SessionId, tank, {tank}).ok
        and starts == 3
        and #last_start.players == 1,
    "A disconnected player must not block remaining members' replay."
)
session.Members["102"].Connected = true
local missing = ReplayService.new(sessions, coordinator, {
    destination_place_id = 245,
    is_player_ready = function(_player: any): boolean
        return true
    end,
})
check(
    missing:request(session.SessionId, tank, {tank}).reason
        == "PartyMemberNotReady",
    "An unaccounted connected member must not be silently abandoned."
)

local studio = ReplayService.new(sessions, coordinator, {
    is_studio = true,
    destination_place_id = 0,
    is_player_ready = function(_player: any): boolean
        return true
    end,
})
check(
    studio:request(session.SessionId, tank, {tank, healer}).waiting == 1,
    "Studio must still require whole-party consent."
)
check(
    studio:request(session.SessionId, healer, {tank, healer}).simulated
        and starts == 3,
    "Studio must simulate replay without a published reserved teleport."
)
print(string.format(
    "[Dungeon Replay Tests] PASS: %d assertions.", assertions
))
