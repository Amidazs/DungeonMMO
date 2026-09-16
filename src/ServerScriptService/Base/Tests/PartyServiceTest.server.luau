local Base = script.Parent.Parent
local PartyService = require(Base:WaitForChild("PartyService"))

local function player(id, name)
    return {UserId = id, Name = name, DisplayName = name}
end

local function expect(value, message)
    assert(value, message)
end

local function service()
    return PartyService.new({
        invite_seconds = 30,
        is_valid_dungeon = function(id)
            return id == "TestDungeon" or id == "AbandonedMine"
        end,
    })
end

local A = player(101, "Alpha")
local B = player(102, "Bravo")
local C = player(103, "Charlie")
local D = player(104, "Delta")
local E = player(105, "Echo")

local parties = service()
local created = parties:create(A)
expect(created.ok, "leader should create party")
expect(parties:party_size(A.UserId) == 1, "party should start solo")
expect(not parties:create(A).ok, "player cannot create second party")

local invited = parties:invite(A, B, 100)
expect(invited.ok, "leader invite should succeed")
expect(parties:invite(A, B, 101).reason == "InviteAlreadyPending", "one actionable invite per target")
expect(parties:accept_invite(B, 102).ok, "invite accept should succeed")
expect(parties:party_size(A.UserId) == 2, "party should contain two members")

expect(parties:set_ready(A, true).ok, "leader ready should succeed")
local not_ready = parties:prepare_entry(A.UserId)
expect(not_ready.reason == "PartyNotReady", "entry must block until all members ready")
expect(parties:set_ready(B, true).ok, "member ready should succeed")
expect(parties:prepare_entry(A.UserId).ok, "two ready members should be entry-ready")

expect(parties:invite(A, C, 103).ok, "third invite should succeed")
expect(parties:accept_invite(C, 104).ok, "third member accept should succeed")
local after_join = parties:party_for_user(A.UserId)
for _, member in ipairs(after_join.Members) do
    expect(member.Ready == false, "membership change must clear readiness")
end

expect(parties:select_dungeon(B, "AbandonedMine").reason == "LeaderOnly", "member cannot select dungeon")
expect(parties:set_ready(A, true).ok, "leader may ready before dungeon switch")
expect(parties:set_ready(B, true).ok, "member may ready before dungeon switch")
expect(parties:set_ready(C, true).ok, "third member may ready before dungeon switch")
expect(parties:select_dungeon(A, "AbandonedMine").ok, "leader can select Mine")
local after_selection = parties:party_for_user(A.UserId)
expect(after_selection.SelectedDungeonId == "AbandonedMine", "selection must persist in server party state")
for _, member in ipairs(after_selection.Members) do
    expect(member.Ready == false, "dungeon selection change must clear readiness")
end

expect(parties:invite(A, D, 105).ok, "fourth invite should succeed")
expect(parties:accept_invite(D, 106).ok, "fourth member accept should succeed")
expect(parties:party_size(A.UserId) == 4, "party max should be four")
expect(parties:invite(A, E, 107).reason == "PartyFull", "fifth member must be rejected")
expect(parties:kick(B, C.UserId).reason == "LeaderOnly", "ordinary member cannot kick")
expect(parties:kick(A, C.UserId).ok, "leader can kick ordinary member")
expect(parties:party_size(A.UserId) == 3, "kick should remove member")

local before_leave = parties:party_for_user(A.UserId)
local expected_new_leader = before_leave.Members[2].UserId
expect(parties:leave(A).ok, "leader leave should succeed")
local transferred = parties:party_for_user(B.UserId)
expect(transferred.LeaderUserId == expected_new_leader, "leadership should transfer to longest-standing remaining member")
for _, member in ipairs(transferred.Members) do
    expect(member.Ready == false, "leader departure must clear readiness")
end

local expiring = service()
expect(expiring:create(A).ok, "expiry fixture create")
expect(expiring:invite(A, B, 200).ok, "expiry fixture invite")
local expired = expiring:expire_invites(231)
expect(#expired == 1 and expired[1] == B.UserId, "invite should expire after thirty seconds")
expect(expiring:accept_invite(B, 231).reason == "InviteMissing", "expired invite must not be actionable")

local competing = service()
expect(competing:create(A).ok, "competing party A")
expect(competing:create(C).ok, "competing party C")
expect(competing:invite(A, B, 300).ok, "first invite should be active")
expect(competing:invite(C, B, 301).reason == "InviteAlreadyPending", "target should hold one actionable invite")
expect(competing:decline_invite(B).ok, "invite decline should clear pending invite")
expect(competing:invite(C, B, 302).ok, "new invite allowed after decline")

local solo = service()
expect(solo:create(E).ok, "solo create")
expect(solo:set_ready(E, true).reason == "SoloReadyNotRequired", "solo party should not need ready")
expect(solo:prepare_entry(E.UserId).ok, "solo party should prepare without ready")
expect(solo:leave(E).ok, "solo leave")
expect(solo:party_size(E.UserId) == 0, "empty party should be destroyed")

print("[Party Service Tests] PASS")
