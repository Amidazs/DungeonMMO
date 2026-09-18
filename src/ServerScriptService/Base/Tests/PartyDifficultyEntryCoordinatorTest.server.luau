--!strict
local Base = script.Parent.Parent
local PartyService = require(Base:WaitForChild("PartyService"))
local PartyEntryCoordinator = require(
    Base:WaitForChild("PartyEntryCoordinator")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Party Difficulty Entry Tests] " .. message,
            2
        )
    end
end

local function player(user_id: number, name: string): any
    return {
        UserId = user_id,
        Name = name,
        DisplayName = name,
    }
end

local function build_party(): (any, {any})
    local service = PartyService.new({
        is_valid_dungeon = function(id: string): boolean
            return id == "TestDungeon"
        end,
        default_difficulty = function(_id: string): string
            return "Depth1"
        end,
        is_valid_difficulty = function(
            _dungeon_id: string,
            difficulty_id: string
        ): boolean
            return difficulty_id == "Depth1"
                or difficulty_id == "Depth2"
        end,
    })

    local players = {
        player(501, "Leader"),
        player(502, "Member"),
    }

    check(service:create(players[1]).ok, "Create party.")
    check(
        service:invite(players[1], players[2], 100).ok,
        "Invite member."
    )
    check(
        service:accept_invite(players[2], 101).ok,
        "Accept member."
    )
    check(
        service:select_difficulty(players[1], "Depth2").ok,
        "Select Depth2."
    )
    check(service:set_ready(players[1], true).ok, "Ready leader.")
    check(service:set_ready(players[2], true).ok, "Ready member.")
    return service, players
end

local function provider(players: {any}): any
    local by_id = {}
    for _, current in ipairs(players) do
        by_id[current.UserId] = current
    end
    return function(user_id: number): any
        return by_id[user_id]
    end
end

local locked_service, locked_players = build_party()
local locked_calls = 0
local locked = PartyEntryCoordinator.new({
    party_service = locked_service,
    player_provider = provider(locked_players),
    validate_member = function(
        current: any,
        dungeon_id: string,
        difficulty_id: string
    ): any
        check(dungeon_id == "TestDungeon", "Dungeon context mismatch.")
        check(difficulty_id == "Depth2", "Difficulty context mismatch.")
        if current.UserId == 502 then
            return {ok = false, reason = "DifficultyLocked"}
        end
        return {ok = true}
    end,
    coordinator = {
        start_dungeon = function()
            locked_calls += 1
            return {ok = true}
        end,
    },
    place_id_provider = function()
        return 123, nil
    end,
    is_studio = false,
})

local blocked = locked:start(locked_players[1])
check(
    blocked.reason == "DifficultyLocked",
    "One locked member must block the whole party."
)
check(
    blocked.MemberUserId == 502,
    "Blocked entry must identify the locked member."
)
check(
    blocked.DifficultyId == "Depth2",
    "Blocked result must preserve selected difficulty."
)
check(locked_calls == 0, "Blocked party must not call teleport.")

local ready_service, ready_players = build_party()
local production_call: any = nil
local ready = PartyEntryCoordinator.new({
    party_service = ready_service,
    player_provider = provider(ready_players),
    validate_member = function(
        _current: any,
        _dungeon_id: string,
        _difficulty_id: string
    ): any
        return {ok = true}
    end,
    coordinator = {
        start_dungeon = function(
            _self: any,
            players: {any},
            dungeon_id: string,
            place_id: number,
            difficulty_id: string
        ): any
            production_call = {
                Players = players,
                DungeonId = dungeon_id,
                PlaceId = place_id,
                DifficultyId = difficulty_id,
            }
            return {
                ok = true,
                session = {
                    SessionId = "difficulty-party",
                    DungeonId = dungeon_id,
                },
            }
        end,
    },
    place_id_provider = function()
        return 456, nil
    end,
    is_studio = false,
})

local entered = ready:start(ready_players[1])
check(entered.ok == true, "Unlocked party entry must succeed.")
check(production_call ~= nil, "Production coordinator must be called.")
check(
    production_call.DifficultyId == "Depth2",
    "Selected difficulty must be forwarded to teleport authority."
)
check(
    production_call.PlaceId == 456,
    "Existing place-id argument position must remain compatible."
)

local studio_service, studio_players = build_party()
local studio = PartyEntryCoordinator.new({
    party_service = studio_service,
    player_provider = provider(studio_players),
    validate_member = function()
        return {ok = true}
    end,
    coordinator = {
        start_dungeon = function()
            error("Studio proof must not teleport.")
        end,
    },
    place_id_provider = function()
        return nil, "PublishedTeleportRequired"
    end,
    is_studio = true,
})

local proof = studio:start(studio_players[1])
check(
    proof.ok == true
        and proof.reason == "StudioPartyEntryProof",
    "Studio party entry must return proof."
)
check(
    proof.DifficultyId == "Depth2",
    "Studio proof must preserve selected difficulty."
)

print(string.format(
    "[Party Difficulty Entry Tests] PASS: %d assertions.",
    assertion_count
))
