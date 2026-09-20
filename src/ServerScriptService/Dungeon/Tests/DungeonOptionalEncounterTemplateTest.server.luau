--!strict
-- New placements are backend templates, NOT newly authored physical rooms.
-- A late Event must be refused until a layout explicitly provides its slot.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Core = SSS.Core
local Dungeon = SSS.Dungeon
local Templates = require(Shared.DungeonOptionalEncounterTemplateCatalog)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Plan = require(Dungeon.DungeonEncounterPlan)
local Difficulty = require(Shared.DungeonDifficultyDefinitions)
local Sessions = require(Core.Services.DungeonSessionService)
local Map = require(Core.Adapters.InMemoryMapAdapter)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)

local count = 0
local function check(value: boolean, label: string)
    count += 1
    assert(value, "[Optional Encounter Templates] " .. label)
end

local function slots_for(event_anchor: string, valid: boolean): any
    return {
        EventArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Fixture.EventBoss",
        },
        EventArenaLate = {
            SupportsBoss = true,
            BossSpawnAnchor = "Fixture.LateEventBoss",
            OptionalInsertAfterId = event_anchor,
            OptionalPlacementVerified = valid,
        },
        SecretArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Fixture.SecretBoss",
        },
    }
end

-- Exercises late placement only against explicit synthetic slot metadata.
-- Args: dungeon_id (string): Registered Temple or Mine.
--       depth_id (string): Depth2/3/4 supported late-placement difficulty.
--       seed (number): Deterministic server-issued run seed.
-- Returns: nil: Checks frozen placement, fail-closed layout and recovery.
local function check_late(dungeon_id: string, depth_id: string, seed: number)
    local opts = {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_secret_chance_basis_points = 10000,
        optional_boss_templates_enabled = true,
        optional_boss_variants_enabled = true,
    }
    local state = Issuer.issue(dungeon_id, 150, seed, opts, true, depth_id)
    state.RunEnteredAtUnix = 150
    check(state.OptionalBossEventActive
        and state.OptionalBossSecretUnlocked
        and state.OptionalBossEventTemplateId == "EventAfterRoom2",
        "opted-in eligible run must freeze late Event template")
    local template = assert(Templates.get(
        dungeon_id, depth_id, "Event", "EventAfterRoom2"))
    local definition = assert(Difficulty.get(dungeon_id, depth_id))
    check(template.RoomSlotId == "EventArenaLate"
        and template.RequiresPlacementContract,
        "late Event must use a separate explicitly verified physical slot")
    check(template.InsertAfterId == definition.EncounterSequence[2].Id,
        "late template must follow this depth's second required room")
    local descriptors = assert(Content.for_difficulty(
        dungeon_id, depth_id, state))
    check(#descriptors == 2
        and descriptors[1].InsertAfterId == template.InsertAfterId
        and descriptors[1].Encounter.RoomSlotId == "EventArenaLate"
        and descriptors[1].Encounter.Id:find("LateEncounter", 1, true),
        "saved template must materialize one unique late encounter ID")
    local old_slots = slots_for(template.InsertAfterId, true)
    old_slots.EventArenaLate = nil
    check(Policy.evaluate({OptionalEncounters = descriptors},
        depth_id, old_slots, true, state).reason
        == "OptionalBossContentUnavailable",
        "existing legacy layout may not claim an unbuilt late Event")
    local invalid_slots = slots_for("WrongRequiredRoom", true)
    check(Policy.evaluate({OptionalEncounters = descriptors},
        depth_id, invalid_slots, true, state).reason
        == "OptionalBossContentUnavailable",
        "unmatched physical prerequisite must fail closed")
    invalid_slots = slots_for(template.InsertAfterId, false)
    check(Policy.evaluate({OptionalEncounters = descriptors},
        depth_id, invalid_slots, true, state).reason
        == "OptionalBossContentUnavailable",
        "unverified physical placement must fail closed")
    local synthetic_slots = slots_for(template.InsertAfterId, true)
    local chosen = Policy.evaluate({OptionalEncounters = descriptors},
        depth_id, synthetic_slots, true, state)
    check(chosen.ok and #chosen.encounters == 2,
        "explicitly verified synthetic slot admits at most one Event/Secret")
    local plan = Plan.materialize(
        definition.EncounterSequence, chosen.encounters, state)
    check(plan.ok and #plan.encounters
        == #definition.EncounterSequence + 2,
        "template may only extend, never replace, required room plan")
    local event_count, secret_count = 0, 0
    for i, encounter in ipairs(plan.encounters) do
        if encounter.Kind == "EventBoss" then
            event_count += 1
            check(i == 3 and encounter.RoomSlotId == "EventArenaLate",
                "late Event follows two required rooms at every depth")
        elseif encounter.Kind == "SecretBoss" then
            secret_count += 1
            check(i == #plan.encounters - 1,
                "Secret remains before the final required room")
        end
    end
    check(event_count == 1 and secret_count == 1,
        "at most one Event and Secret may appear in a run")

    local extra = table.clone(descriptors[1])
    extra.Encounter = table.clone(descriptors[1].Encounter)
    extra.Encounter.Id ..= "_Second"
    extra.Encounter.RoomSlotId = "EventArena"
    extra.InsertAfterId = definition.EncounterSequence[1].Id
    extra.RequiresPlacementContract = false
    local duplicated = Policy.evaluate({
        OptionalEncounters = {descriptors[1], extra, descriptors[2]},
    }, depth_id, synthetic_slots, true, state)
    check(duplicated.reason == "OptionalBossFrequencyExceeded",
        "second event boss must not exceed per-run frequency cap")
    extra = table.clone(descriptors[2])
    extra.Encounter = table.clone(descriptors[2].Encounter)
    extra.Encounter.RoomSlotId = "EventArenaLate"
    local conflict = Policy.evaluate({
        OptionalEncounters = {descriptors[1], extra},
    }, depth_id, synthetic_slots, true, state)
    check(conflict.reason == "OptionalBossRoomSlotConflict",
        "different optional kinds must never claim one physical slot")

    local now = 150
    local clock = function() return now end
    local map = Map.new(clock)
    local sessions = Sessions.new(map, clock)
    local member = 77000 + seed
    local session = assert(sessions:create(
        dungeon_id, {member}, 0, "optional-template", depth_id))
    check(sessions:mark_connected(session.SessionId, member).ok
        and sessions:set_instance_state(session.SessionId, state).ok,
        "run must save the issued template before encounter execution")
    local controller = assert(Controller.new({
        session_service = sessions, session_id = session.SessionId,
        base_sequence = definition.EncounterSequence,
        optional_encounters = chosen.encounters,
    }))
    local frozen = sessions:get(session.SessionId)
        .InstanceState.EncounterPlan
    local event = frozen[3]
    check(event.Id == descriptors[1].Encounter.Id
        and event.RoomSlotId == "EventArenaLate",
        "saved physical slot and encounter IDs must remain unchanged")
    for i = 1, 2 do
        check(controller:start(frozen[i].Id).ok
            and controller:clear(frozen[i].Id).ok,
            "both required predecessor rooms clear once")
    end
    check(controller:start(event.Id).ok
        and not controller:start(event.Id).ok,
        "late event encounter may only start once")
    now = 250
    local rebuilt = assert(Controller.new({
        session_service = Sessions.new(map, clock),
        session_id = session.SessionId,
        base_sequence = definition.EncounterSequence,
        optional_encounters = {},
    }))
    check(rebuilt:state_of(event.Id) == "Pending"
        and rebuilt:next_id() == event.Id
        and rebuilt:get(event.Id).RoomSlotId == "EventArenaLate",
        "expired Event recovers Pending with its original late slot")
    local copy = sessions:get(session.SessionId).InstanceState
    check(copy.OptionalBossEventTemplateId == "EventAfterRoom2",
        "recovery cannot reroll the issued template")
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({"Depth2", "Depth3", "Depth4"}) do
        for _, seed in ipairs({1, 7}) do
            check_late(dungeon_id, depth_id, seed)
        end
    end
    for _, depth_id in ipairs({"Depth1", "Depth2", "Depth3", "Depth4"}) do
        local state = Issuer.issue(dungeon_id, 150, 7, {
            optional_boss_event_start = 100,
            optional_boss_event_end = 200,
            optional_boss_secret_chance_basis_points = 10000,
        }, true, depth_id)
        check(state.OptionalBossEventTemplateId == nil,
            "default opt-in OFF preserves all legacy saved snapshots")
        local descriptors = assert(Content.for_difficulty(
            dungeon_id, depth_id, state))
        check(descriptors[1].Encounter.RoomSlotId == "EventArena"
            and descriptors[1].Encounter.Id:find(
                "Encounter", 1, true),
            "default Event remains at the existing first-room side arena")
        local opted = Issuer.issue(dungeon_id, 150, 7, {
            optional_boss_event_start = 100,
            optional_boss_event_end = 200,
            optional_boss_secret_chance_basis_points = 10000,
            optional_boss_templates_enabled = true,
        }, true, depth_id)
        if depth_id == "Depth1" then
            check(opted.OptionalBossEventTemplateId == "EventAfterRoom1",
                "Depth1 cannot select an unsupported later Event placement")
        end
    end
    check(Templates.get(dungeon_id, "Depth1", "Event",
        "EventAfterRoom2") == nil,
        "unsupported late Depth1 placement cannot be issued")
    local bad = Issuer.issue(dungeon_id, 150, 7, {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_secret_chance_basis_points = 10000,
    }, true, "Depth2")
    bad.OptionalBossEventTemplateId = "UnregisteredRoom"
    check(Content.for_difficulty(dungeon_id, "Depth2", bad) == nil,
        "unknown saved template must fail closed")
end

print(string.format(
    "[Optional Encounter Template Tests] PASS: %d assertions.", count
))
