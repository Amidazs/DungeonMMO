--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")
local TeleportCoordinator = require(
    Services:WaitForChild("TeleportCoordinator")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Teleport Tests] " .. message,
            2
        )
    end
end

local captured_difficulty: string? = nil
local captured_teleport_data: any = nil
local reserve_calls = 0

local teleport: any = {}
function teleport:reserve_server(_place_id: number)
    reserve_calls += 1
    return true, "reserved-depth"
end
function teleport:teleport(
    _place_id: number,
    _players: {any},
    _code: string?,
    data: any
)
    captured_teleport_data = data
    return true, nil
end
function teleport:connect_init_failed(_handler: (...any) -> ())
    return nil
end

local profiles: any = {}
function profiles:save(_user_id: number, _reason: string)
    return true, nil
end

local leases: any = {}
function leases:begin_handoff(
    _user_id: number,
    _nonce: string,
    _destination: string
)
    return {ok = true}
end
function leases:cancel_handoff(_user_id: number, _nonce: string)
    return {ok = true}
end

local sessions: any = {}
function sessions:get_for_user(_user_id: number)
    return nil
end
function sessions:create(
    dungeon_id: string,
    member_ids: {number},
    return_place_id: number,
    reserved_code: string,
    difficulty_id: string
)
    captured_difficulty = difficulty_id
    return {
        SessionId = "difficulty-session",
        DungeonId = dungeon_id,
        Difficulty = {
            Id = difficulty_id,
            Order = 1,
            Version = 1,
        },
        MemberUserIds = member_ids,
        ReturnPlaceId = return_place_id,
        ReservedAccessCode = reserved_code,
        State = "Creating",
        Members = {
            ["701"] = {
                UserId = 701,
                Connected = false,
                Mode = "Active",
            },
        },
    }, nil
end
function sessions:set_instance_state(_session_id: string, state: any)
    return {
        ok = true,
        session = {
            SessionId = "difficulty-session",
            DungeonId = "TestDungeon",
            Difficulty = {
                Id = "Depth1",
                Order = 1,
                Version = 1,
            },
            MemberUserIds = {701},
            ReturnPlaceId = game.PlaceId,
            ReservedAccessCode = "reserved-depth",
            State = "Creating",
            Members = {
                ["701"] = {
                    UserId = 701,
                    Connected = false,
                    Mode = "Active",
                },
            },
            InstanceState = state,
        },
    }
end
function sessions:set_handoff_nonce(
    _session_id: string,
    _user_id: number,
    _nonce: string
)
    return {ok = true}
end
function sessions:mark_failed(_session_id: string, _reason: string)
    return {ok = true}
end

local coordinator = TeleportCoordinator.new(
    teleport,
    profiles,
    leases,
    sessions
)
local player: any = {UserId = 701}

local entered = coordinator:start_dungeon(
    {player},
    "TestDungeon",
    12345,
    "Depth1"
)
check(entered.ok == true, "Depth1 start must succeed.")
check(
    captured_difficulty == "Depth1",
    "Difficulty must be passed into session creation."
)
check(
    captured_teleport_data.DifficultyId == "Depth1",
    "TeleportData must carry difficulty routing ID."
)
check(
    captured_teleport_data.Gold == nil
        and captured_teleport_data.EnemyHealthMultiplier == nil,
    "TeleportData must not carry gameplay value authority."
)
local before_block = reserve_calls
local blocked = coordinator:start_dungeon(
    {{UserId = 702}},
    "TestDungeon",
    12345,
    "Depth2"
)
check(
    blocked.reason == "DifficultyContentNotReady",
    "Unbuilt higher depth must fail closed at teleport authority."
)
check(
    reserve_calls == before_block,
    "Fail-closed difficulty must not reserve a server."
)

local unknown = coordinator:start_dungeon(
    {{UserId = 703}},
    "TestDungeon",
    12345,
    "Unknown"
)
check(
    unknown.reason == "UnknownDifficulty",
    "Unknown difficulty must be rejected."
)

print(string.format(
    "[Dungeon Difficulty Teleport Tests] PASS: %d assertions.",
    assertion_count
))
