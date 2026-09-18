--!strict
local Base = script.Parent.Parent
local PartyService = require(Base:WaitForChild("PartyService"))

local assertion_count = 0

local function player(user_id: number, name: string): any
    return {
        UserId = user_id,
        Name = name,
        DisplayName = name,
    }
end

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Party Difficulty Tests] " .. message, 2)
    end
end

local function new_service(): any
    return PartyService.new({
        is_valid_dungeon = function(dungeon_id: string): boolean
            return dungeon_id == "TestDungeon"
                or dungeon_id == "AbandonedMine"
        end,
        default_difficulty = function(_dungeon_id: string): string
            return "Depth1"
        end,
        is_valid_difficulty = function(
            _dungeon_id: string,
            difficulty_id: string
        ): boolean
            return difficulty_id == "Depth1"
                or difficulty_id == "Depth2"
                or difficulty_id == "Depth3"
                or difficulty_id == "Depth4"
        end,
    })
end

local leader = player(401, "Leader")
local member = player(402, "Member")
local parties = new_service()

check(parties:create(leader).ok, "Party creation must succeed.")
local created = assert(parties:party_for_user(leader.UserId))
check(
    created.SelectedDifficultyId == "Depth1",
    "New parties must start on the dungeon default difficulty."
)

check(
    parties:select_difficulty(member, "Depth2").reason == "NotInParty",
    "Non-members cannot select difficulty."
)

check(parties:invite(leader, member, 100).ok, "Invite must succeed.")
check(parties:accept_invite(member, 101).ok, "Invite accept must succeed.")
check(parties:set_ready(leader, true).ok, "Leader ready must succeed.")
check(parties:set_ready(member, true).ok, "Member ready must succeed.")
check(
    parties:select_difficulty(member, "Depth2").reason == "LeaderOnly",
    "Only the leader may select difficulty."
)
check(
    parties:select_difficulty(leader, "Unknown").reason
        == "UnknownDifficulty",
    "Unknown difficulty IDs must be rejected."
)

check(
    parties:select_difficulty(leader, "Depth2").ok,
    "Leader must be able to select a valid depth."
)
local depth2 = assert(parties:party_for_user(leader.UserId))
check(
    depth2.SelectedDifficultyId == "Depth2",
    "Selected difficulty must persist in party state."
)
for _, party_member in ipairs(depth2.Members) do
    check(
        party_member.Ready == false,
        "Difficulty change must clear all readiness."
    )
end

check(parties:set_ready(leader, true).ok, "Leader re-ready must succeed.")
check(parties:set_ready(member, true).ok, "Member re-ready must succeed.")
local prepared = parties:prepare_entry(leader.UserId)
check(prepared.ok == true, "Ready party must prepare entry.")
check(
    prepared.DifficultyId == "Depth2",
    "Prepared entry must preserve selected difficulty."
)

check(
    parties:select_dungeon(leader, "AbandonedMine").ok,
    "Leader must be able to change dungeon."
)
local mine = assert(parties:party_for_user(leader.UserId))
check(
    mine.SelectedDungeonId == "AbandonedMine",
    "Dungeon selection must persist."
)
check(
    mine.SelectedDifficultyId == "Depth1",
    "Changing dungeon must reset to its default difficulty."
)
for _, party_member in ipairs(mine.Members) do
    check(
        party_member.Ready == false,
        "Dungeon change must clear readiness."
    )
end

print(string.format(
    "[Party Difficulty Tests] PASS: %d assertions.",
    assertion_count
))
