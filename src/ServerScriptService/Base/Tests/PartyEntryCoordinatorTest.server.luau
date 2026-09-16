local Base = script.Parent.Parent
local PartyService = require(Base:WaitForChild("PartyService"))
local PartyEntryCoordinator = require(Base:WaitForChild("PartyEntryCoordinator"))

local function player(id, name)
    return {UserId = id, Name = name, DisplayName = name}
end

local function expect(value, message)
    assert(value, message)
end

local function build_party(count, dungeon_id)
    local service = PartyService.new({
        is_valid_dungeon = function(id)
            return id == "TestDungeon" or id == "AbandonedMine"
        end,
    })
    local players = {
        player(201, "Leader"),
        player(202, "Two"),
        player(203, "Three"),
        player(204, "Four"),
    }
    expect(service:create(players[1]).ok, "create party")
    expect(service:select_dungeon(players[1], dungeon_id).ok, "select dungeon")
    for index = 2, count do
        expect(service:invite(players[1], players[index], 100 + index).ok, "invite member")
        expect(service:accept_invite(players[index], 110 + index).ok, "accept member")
    end
    if count > 1 then
        for index = 1, count do
            expect(service:set_ready(players[index], true).ok, "ready member")
        end
    end
    return service, players
end

local function provider(players)
    local by_id = {}
    for _, p in ipairs(players) do by_id[p.UserId] = p end
    return function(user_id) return by_id[user_id] end, by_id
end

local service2, players2 = build_party(2, "TestDungeon")
local get2 = provider(players2)
local calls = {}
local fake_coordinator = {
    start_dungeon = function(_, players, dungeon_id, place_id)
        table.insert(calls, {players = players, dungeon_id = dungeon_id, place_id = place_id})
        return {ok = true, session = {SessionId = "S1", DungeonId = dungeon_id, MemberUserIds = {201, 202}}}
    end,
}
local entry2 = PartyEntryCoordinator.new({
    party_service = service2,
    player_provider = get2,
    validate_member = function(_) return {ok = true} end,
    coordinator = fake_coordinator,
    place_id_provider = function() return 999, nil end,
    is_studio = false,
})
local r2 = entry2:start(players2[1])
expect(r2.ok, "two-player production entry should succeed")
expect(#calls == 1, "coordinator should be called once")
expect(#calls[1].players == 2, "exact two-player list must be forwarded")
expect(calls[1].players[1].UserId == 201 and calls[1].players[2].UserId == 202, "member order must be preserved")
expect(calls[1].dungeon_id == "TestDungeon", "Temple ID must be forwarded")
expect(calls[1].place_id == 999, "place id must be forwarded")

local service4, players4 = build_party(4, "AbandonedMine")
local get4 = provider(players4)
local four_calls = {}
local entry4 = PartyEntryCoordinator.new({
    party_service = service4,
    player_provider = get4,
    validate_member = function(_) return {ok = true} end,
    coordinator = {
        start_dungeon = function(_, players, dungeon_id, _)
            table.insert(four_calls, {players = players, dungeon_id = dungeon_id})
            return {ok = true, session = {SessionId = "S4", DungeonId = dungeon_id, MemberUserIds = {201,202,203,204}}}
        end,
    },
    place_id_provider = function() return 777, nil end,
    is_studio = false,
})
local r4 = entry4:start(players4[1])
expect(r4.ok, "four-player Mine entry should succeed")
expect(#four_calls[1].players == 4, "exact four-player list must be forwarded")
expect(four_calls[1].dungeon_id == "AbandonedMine", "Mine ID must be forwarded")

local missing_service, missing_players = build_party(3, "TestDungeon")
local missing_provider, missing_by_id = provider(missing_players)
missing_by_id[203] = nil
local missing_calls = 0
local missing_entry = PartyEntryCoordinator.new({
    party_service = missing_service,
    player_provider = missing_provider,
    validate_member = function(_) return {ok = true} end,
    coordinator = {start_dungeon = function() missing_calls += 1; return {ok = true} end},
    place_id_provider = function() return 1, nil end,
    is_studio = false,
})
local missing = missing_entry:start(missing_players[1])
expect(missing.reason == "PartyMemberMissing" and missing.MemberUserId == 203, "missing member must block whole party")
expect(missing_calls == 0, "missing member must not call coordinator")

local invalid_service, invalid_players = build_party(2, "TestDungeon")
local invalid_provider = provider(invalid_players)
local invalid_calls = 0
local invalid_entry = PartyEntryCoordinator.new({
    party_service = invalid_service,
    player_provider = invalid_provider,
    validate_member = function(p)
        if p.UserId == 202 then return {ok = false, reason = "IdentityIncomplete"} end
        return {ok = true}
    end,
    coordinator = {start_dungeon = function() invalid_calls += 1; return {ok = true} end},
    place_id_provider = function() return 1, nil end,
    is_studio = false,
})
local invalid = invalid_entry:start(invalid_players[1])
expect(invalid.reason == "IdentityIncomplete" and invalid.MemberUserId == 202, "invalid member reason should identify member")
expect(invalid_calls == 0, "invalid member must not call coordinator")

local studio_service, studio_players = build_party(4, "AbandonedMine")
local studio_provider = provider(studio_players)
local studio_calls = 0
local studio_entry = PartyEntryCoordinator.new({
    party_service = studio_service,
    player_provider = studio_provider,
    validate_member = function(_) return {ok = true} end,
    coordinator = {start_dungeon = function() studio_calls += 1; return {ok = true} end},
    place_id_provider = function() return nil, "PublishedTeleportRequired" end,
    is_studio = true,
})
local studio = studio_entry:start(studio_players[1])
expect(studio.ok and studio.reason == "StudioPartyEntryProof", "Studio multi-party entry should return validated proof")
expect(#studio.Players == 4 and studio.DungeonId == "AbandonedMine", "Studio proof must preserve exact party and dungeon")
expect(studio_calls == 0, "Studio proof must not attempt external teleport")

local fail_service, fail_players = build_party(2, "TestDungeon")
local fail_provider = provider(fail_players)
local fail_entry = PartyEntryCoordinator.new({
    party_service = fail_service,
    player_provider = fail_provider,
    validate_member = function(_) return {ok = true} end,
    coordinator = {start_dungeon = function() return {ok = false, reason = "ReserveFailed"} end},
    place_id_provider = function() return 123, nil end,
    is_studio = false,
})
expect(fail_entry:start(fail_players[1]).reason == "ReserveFailed", "coordinator failure should propagate unchanged")

print("[Party Entry Coordinator Tests] PASS")
