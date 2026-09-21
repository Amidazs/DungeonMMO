--!strict
-- Local service-level party wipe/revive regression for Temple and Mine.
-- No Roblox cloud state, live players or released higher-depth content.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Dungeon = SSS:WaitForChild("Dungeon")
local Core = SSS:WaitForChild("Core")
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)
local DeathService = require(Dungeon.DungeonDeathService)
local Difficulty = require(RS.Core.Shared.DungeonDifficultyDefinitions)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local ReviveConfig = require(RS.Core.Shared.ReviveConfig)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Optional Depth Party Wipe] " .. message)
end

-- Exercises one fully connected party at an active higher-depth Event.
-- Args: dungeon_id (string): Existing Temple or Mine dungeon.
--       depth_id (string): Depth2 or Depth4, without release enablement.
--       party_size (number): One, two or four synthetic members.
-- Returns: nil: Checks checkpoint, free revive, all-member wipe and replay.
local function check_party(dungeon_id: string, depth_id: string,
    party_size: number)
    local now = 1000
    local function clock(): number return now end
    local map = MapAdapter.new(clock)
    local sessions = Sessions.new(map, clock)
    local members = {}
    for i = 1, party_size do
        table.insert(members, 91000 + (if dungeon_id == "TestDungeon"
            then 1000 else 2000)
            + (if depth_id == "Depth4" then 100 else 0) + i)
    end
    local session = assert(sessions:create(
        dungeon_id, members, 0, "local-party-wipe", depth_id))
    local id = session.SessionId
    for _, user_id in ipairs(members) do
        check(sessions:mark_connected(id, user_id).ok,
            "member must join the shared higher-depth run")
    end
    local opts = {
        optional_boss_event_start = 900,
        optional_boss_event_end = 1100,
        optional_boss_secret_chance_basis_points = 10000,
    }
    local entry = Issuer.issue(dungeon_id, now, 44, opts, true)
    entry.RunEnteredAtUnix = now
    check(sessions:set_instance_state(id, entry).ok,
        "frozen optional eligibility saves before Event")
    local selected = Policy.evaluate({
        OptionalEncounters = assert(Content.for_difficulty(
            dungeon_id, depth_id)),
    }, depth_id, {
        EventArena = {SupportsBoss = true,
            BossSpawnAnchor = "Fixture.EventSpawn"},
        SecretArena = {SupportsBoss = true,
            BossSpawnAnchor = "Fixture.SecretSpawn"},
    }, true, entry)
    check(selected.ok and #selected.encounters == 2,
        "both optional encounters selected for wipe fixture")
    local depth = assert(Difficulty.get(dungeon_id, depth_id))
    local controller = assert(Controller.new({
        session_service = sessions, session_id = id,
        base_sequence = depth.EncounterSequence,
        optional_encounters = selected.encounters,
    }))
    local plan = sessions:get(id).InstanceState.EncounterPlan
    local first, event = plan[1], plan[2]
    check(first.RoomSlotId == "Room1" and event.Kind == "EventBoss",
        "higher-depth Event follows first required room")
    check(controller:start(first.Id).ok and controller:clear(first.Id).ok,
        "Room1 clears once before Event")
    check(sessions:activate_checkpoint(id,
        "EncounterStart:" .. event.Id, 2).ok,
        "Event checkpoint must persist before a wipe")
    check(controller:start(event.Id).ok,
        "Event must be Active before the party is downed")

    local scheduled = {}
    local respawns = {}
    local checkpoint = {
        get_active_checkpoint = function()
            return {Id = "EncounterStart:" .. event.Id,
                CFrame = CFrame.new(7, 3, -20)}
        end,
    }
    local deaths = DeathService.new(sessions, checkpoint, id, {
        clock = clock,
        schedule = function(delay, callback)
            check(delay == ReviveConfig.FREE_REVIVE_DELAY_SECONDS,
                "free revival uses existing delay")
            table.insert(scheduled, callback)
        end,
        spawn_player = function(player, location)
            check(location == checkpoint.get_active_checkpoint().CFrame,
                "free revive spawns at the authoritative Event checkpoint")
            table.insert(respawns, player.UserId)
            return true
        end,
        paid_offer_provider = function() return nil end,
    })
    local fake_players = {}
    for _, user_id in ipairs(members) do
        local player = {UserId = user_id, Name = "FixtureMember"}
        table.insert(fake_players, player)
        local first_death = deaths:on_player_died(
            player, CFrame.new(0, 3, 0))
        check(first_death.ok and first_death.automatic_free_revive,
            "first death must use the single automatic free revive")
        check(sessions:get(id).WipeDecisionEndsAt == nil,
            "pending automatic revivals must not trigger global wipe")
    end
    check(#scheduled == party_size,
        "every member has exactly one scheduled automatic revive")
    for _, callback in ipairs(scheduled) do callback() end
    check(#respawns == party_size,
        "every member independently returns to Event checkpoint")
    for _, user_id in ipairs(members) do
        local member = sessions:get(id).Members[tostring(user_id)]
        check(member.Mode == "Active" and member.FreeReviveUsed,
            "revived member is active with free revive consumed")
    end
    check(sessions:get(id).WipeDecisionEndsAt == nil
        and controller:state_of(event.Id) == "Active",
        "party revival keeps the same Event encounter active")

    for index, player in ipairs(fake_players) do
        local second_death = deaths:on_player_died(
            player, CFrame.new(0, 3, 0))
        check(second_death.ok
            and sessions:get(id).Members[tostring(player.UserId)].Mode
                == "Spectating",
            "second death enters spectating without another free revive")
        if index < party_size then
            check(sessions:get(id).WipeDecisionEndsAt == nil,
                "one still-active party member prevents global wipe")
        end
    end
    local wiped = sessions:get(id)
    local deadline = wiped.WipeDecisionEndsAt
    check(type(deadline) == "number"
        and deadline == now + ReviveConfig.WIPE_DECISION_SECONDS,
        "wipe timer starts only after all members are inactive")
    now = deadline - 1
    check(not deaths:tick(now).failed
        and sessions:get(id).State == "Active",
        "party retains its instance until wipe decision deadline")
    now = deadline
    check(deaths:tick(now).failed
        and sessions:get(id).State == "Failed",
        "all-member wipe expires once and fails the party session")
    local failed = sessions:get(id)
    check(failed.Checkpoint.Id == "EncounterStart:" .. event.Id
        and failed.InstanceState.EncounterRuntime
            .EncounterStates[event.Id] == "Active",
        "failed run retains its saved Event/checkpoint audit state")
    check(not deaths:tick(now + 1).failed
        and sessions:get(id).State == "Failed",
        "subsequent tick must preserve failure without rebroadcasting it")
    check(not sessions:mark_connected(id, members[1]).ok,
        "terminal failed session cannot be re-entered as an active run")
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({"Depth2", "Depth4"}) do
        for _, size in ipairs({1, 2, 4}) do
            check_party(dungeon_id, depth_id, size)
        end
    end
end

print(string.format(
    "[Optional Depth Party Wipe Tests] PASS: %d assertions.", assertions
))
