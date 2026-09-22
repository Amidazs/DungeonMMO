--!strict
-- A leader cannot start a depth unless every selected character
-- has independently earned the previous depth in this dungeon.
local SSS = game:GetService("ServerScriptService")
local Base = SSS:WaitForChild("Base")
local Services = SSS.Core:WaitForChild("Services")
local PartyService = require(Base:WaitForChild("PartyService"))
local Entry = require(Base:WaitForChild("PartyEntryCoordinator"))
local Progression = require(
    Services:WaitForChild("DungeonDifficultyProgressionService")
)

local assertions = 0

-- Args:
--   condition: boolean; expected progression or party invariant.
--   message: string; useful failure explanation.
-- Returns:
--   nil: increments assertion count or raises on failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Party Difficulty Unlock Tests] " .. message)
end

-- Args:
--   user_id: number; unique fixture party member.
-- Returns:
--   any: server-authorized player-shaped entry object.
local function player(user_id: number): any
    return {
        UserId = user_id,
        Name = "Member" .. tostring(user_id),
        DisplayName = "Member" .. tostring(user_id),
    }
end

local players = {
    player(401), player(402), player(403), player(404),
}
local by_id = {}
local profiles = {}
for _, member in ipairs(players) do
    by_id[member.UserId] = member
    profiles[member.UserId] = {
        DungeonDifficultyProgress = {
            Dungeons = {
                TestDungeon = {Completed = {Depth1 = true}},
                AbandonedMine = {Completed = {}},
            },
        },
    }
end

local profile_service = {}
function profile_service:get_character(
    user_id: number,
    _slot: number
): any?
    return profiles[user_id]
end

local progression = Progression.new(profile_service, {
    analyze = function(
        _dungeon_id: string,
        _difficulty_id: string
    ): any
        return {ok = true, Ready = true}
    end,
})
local party = PartyService.new({
    is_valid_dungeon = function(dungeon_id: string): boolean
        return dungeon_id == "TestDungeon"
            or dungeon_id == "AbandonedMine"
    end,
    is_valid_difficulty = function(
        _dungeon_id: string,
        difficulty_id: string
    ): boolean
        return difficulty_id == "Depth1"
            or difficulty_id == "Depth2"
            or difficulty_id == "Depth3"
    end,
})

check(party:create(players[1]).ok, "Leader must create a party.")
for index = 2, #players do
    check(
        party:invite(players[1], players[index], 100 + index).ok,
        "Each participant must receive a real party invitation."
    )
    check(
        party:accept_invite(players[index], 110 + index).ok,
        "Each participant must accept the party invitation."
    )
end

-- Args: None.
-- Returns:
--   nil: updates every participant's consent after a leader selection.
local function ready_everyone()
    for _, member in ipairs(players) do
        check(
            party:set_ready(member, true).ok,
            "Every member must individually confirm readiness."
        )
    end
end

check(
    party:select_dungeon(players[1], "TestDungeon").ok,
    "Leader must choose Temple."
)
check(
    party:select_difficulty(players[1], "Depth2").ok,
    "Leader must choose the requested depth."
)
ready_everyone()

local reservations = 0
local coordinator = {}
function coordinator:start_dungeon(
    members: {any},
    _dungeon_id: string,
    _place_id: number,
    difficulty_id: string
): any
    reservations += 1
    return {
        ok = true,
        DifficultyId = difficulty_id,
        Members = members,
    }
end

local entry = Entry.new({
    party_service = party,
    player_provider = function(user_id: number): any?
        return by_id[user_id]
    end,
    validate_member = function(
        member: any,
        dungeon_id: string,
        difficulty_id: string
    ): any
        return progression:validate_entry(
            member.UserId, dungeon_id, difficulty_id
        )
    end,
    coordinator = coordinator,
    place_id_provider = function(): (number, string?)
        return 123, nil
    end,
    is_studio = false,
})

profiles[404].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth1 = false
local locked_member = entry:start(players[1])
check(
    locked_member.ok == false
        and locked_member.reason == "DifficultyLocked"
        and locked_member.MemberUserId == 404
        and reservations == 0,
    "One locked fourth member must prevent the entire party starting."
)

profiles[404].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth1 = true
local permitted = entry:start(players[1])
check(
    permitted.ok == true
        and permitted.DifficultyId == "Depth2"
        and #permitted.Members == 4
        and reservations == 1,
    "All four individually unlocked members may start the selected depth."
)

profiles[401].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth1 = false
local locked_leader = entry:start(players[1])
check(
    locked_leader.reason == "DifficultyLocked"
        and locked_leader.MemberUserId == 401
        and reservations == 1,
    "Even the leader must independently unlock the requested depth."
)
profiles[401].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth1 = true

check(
    party:select_difficulty(players[1], "Depth3").ok,
    "Party must be able to select the next known depth."
)
ready_everyone()
for _, character in pairs(profiles) do
    character.DungeonDifficultyProgress.Dungeons
        .TestDungeon.Completed.Depth2 = true
end
profiles[403].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth2 = false
local skipped_depth = entry:start(players[1])
check(
    skipped_depth.reason == "DifficultyLocked"
        and skipped_depth.MemberUserId == 403
        and reservations == 1,
    "Finishing Depth1 does not let one member skip Depth2 for Depth3."
)
profiles[403].DungeonDifficultyProgress.Dungeons
    .TestDungeon.Completed.Depth2 = true
check(
    entry:start(players[1]).ok and reservations == 2,
    "All four Depth2 clears must permit a Depth3 party."
)

check(
    party:select_dungeon(players[1], "AbandonedMine").ok,
    "Leader can select a different dungeon."
)
check(
    party:select_difficulty(players[1], "Depth2").ok,
    "Mine has an independent difficulty selection."
)
ready_everyone()
local other_dungeon = entry:start(players[1])
check(
    other_dungeon.reason == "DifficultyLocked"
        and reservations == 2,
    "Temple unlocks must not unlock higher difficulties in the Mine."
)

print(string.format(
    "[Party Difficulty Unlock Tests] PASS: %d assertions.",
    assertions
))
