--!strict
-- A frozen late Event is either one existing boss or one server-owned
-- non-boss ambush/surge pack, never an additional encounter or scheduler.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Dungeon = SSS.Dungeon
local Shared = RS.Core.Shared
local Core = SSS.Core
local Combat = require(Shared.DungeonOptionalEventCombatCatalog)
local Catalog = require(Shared.DungeonRuntimeContentCatalog)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Difficulty = require(Shared.DungeonDifficultyDefinitions)
local Plan = require(Dungeon.DungeonEncounterPlan)
local Sequencer = require(Dungeon.DungeonEncounterSequencer)
local count = 0
local function check(ok: boolean, label: string)
    count += 1
    assert(ok, "[Optional Combat Variations] " .. label)
end

local function selected_run(dungeon_id: string, depth_id: string, seed: number,
    enabled: boolean): any
    local state = Issuer.issue(dungeon_id, 150, seed, {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_secret_chance_basis_points = 10000,
        optional_boss_templates_enabled = true,
        optional_event_combat_enabled = enabled,
    }, true, depth_id)
    state.RunEnteredAtUnix = 150
    return state
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({"Depth2", "Depth3", "Depth4"}) do
        local difficulty = assert(Difficulty.get(dungeon_id, depth_id))
        for _, seed in ipairs({5, 7}) do
            local state = selected_run(dungeon_id, depth_id, seed, true)
            local mechanic = if seed == 5 then "Ambush" else "Surge"
            local variant = assert(Combat.get(dungeon_id, mechanic))
            check(state.OptionalBossEventActive
                and state.OptionalBossEventTemplateId == "EventAfterRoom2"
                and state.OptionalBossEventMechanicId == mechanic,
                "selected mechanic and late placement must freeze together")
            local entries = assert(Content.for_difficulty(
                dungeon_id, depth_id, state))
            local event = entries[1].Encounter
            check(event.Id == variant.Id .. "Encounter"
                and event.Kind == "EventCombat"
                and event.ExecutorId == "CombatPack"
                and event.PackId == variant.PackId
                and event.RoomSlotId == "EventArenaLate",
                "opted-in late event must use the registered non-boss executor")
            local pack = assert(Catalog.get_pack(dungeon_id, event.PackId))
            check(pack.Entries[1].BaseCount == variant.EnemyCount,
                "server-owned pack count must match selected variation")
            local after = difficulty.EncounterSequence[2].Id
            local slots = {
                EventArenaLate = {
                    SupportsCombat = true,
                    EnemySpawnGroup = "Temp.EventSpawn",
                    EnemySpawnMinCount = 8,
                    OptionalPlacementVerified = true,
                    OptionalInsertAfterId = after,
                },
                SecretArena = {SupportsBoss = true,
                    BossSpawnAnchor = "Temp.SecretBoss"},
            }
            local chosen = Policy.evaluate(
                {OptionalEncounters = entries},
                depth_id, slots, true, state)
            check(chosen.ok and #chosen.encounters == 2,
                "exactly one combat Event and one optional Secret are selected")
            local invalid_event = table.clone(entries[1])
            invalid_event.Encounter = table.clone(event)
            invalid_event.Encounter.ExecutorId = "Boss"
            invalid_event.Encounter.BossId = "TempleEventBoss"
            check(Policy.evaluate({
                OptionalEncounters = {invalid_event, entries[2]},
            }, depth_id, slots, true, state).reason
                == "OptionalBossIdentityInvalid",
                "combat-kind event cannot smuggle a boss executor")
            local materialized = Plan.materialize(
                difficulty.EncounterSequence, chosen.encounters, state)
            check(materialized.ok
                and #materialized.encounters
                    == #difficulty.EncounterSequence + 2
                and materialized.encounters[3].Id == event.Id,
                "variation must follow required Room2 without replacing it")
            local sequencer = Sequencer.new(materialized.encounters)
            check(sequencer:start(materialized.encounters[1].Id).ok
                and sequencer:clear(materialized.encounters[1].Id).ok
                and sequencer:start(materialized.encounters[2].Id).ok
                and sequencer:clear(materialized.encounters[2].Id).ok
                and sequencer:start(event.Id).ok,
                "the shared runtime must start a non-boss Event only in order")
            local snapshot = sequencer:snapshot()
            local restored = Sequencer.new(
                materialized.encounters, snapshot)
            check(restored:state_of(event.Id) == "Pending"
                and restored:next_id() == event.Id
                and restored:get(event.Id).PackId == variant.PackId,
                "restart must preserve selected pack and earlier room clears")

            slots.EventArenaLate.EnemySpawnMinCount = variant.EnemyCount - 1
            check(Policy.evaluate(
                {OptionalEncounters = entries},
                depth_id, slots, true, state
            ).reason == "OptionalBossContentUnavailable",
                "insufficient event spawn capacity must fail closed")
            slots.EventArenaLate.EnemySpawnMinCount = 8
            slots.EventArenaLate.OptionalPlacementVerified = false
            check(Policy.evaluate(
                {OptionalEncounters = entries},
                depth_id, slots, true, state
            ).reason == "OptionalBossContentUnavailable",
                "unverified physical placement must fail closed")

            local old = selected_run(dungeon_id, depth_id, seed, false)
            check(old.OptionalBossEventMechanicId == nil
                and Content.for_difficulty(
                    dungeon_id, depth_id, old)[1].Encounter.Kind
                    == "EventBoss",
                "independent switch OFF preserves the existing boss encounter")
        end
        local too_early = Issuer.issue(dungeon_id, 150, 4, {
            optional_boss_event_start = 100,
            optional_boss_event_end = 200,
            optional_boss_templates_enabled = true,
            optional_event_combat_enabled = true,
        }, true, depth_id)
        check(too_early.OptionalBossEventTemplateId == "EventAfterRoom1"
            and too_early.OptionalBossEventMechanicId == nil,
            "new mechanics cannot enter an early boss-only room")
    end
    local disabled = Issuer.issue(dungeon_id, 150, 7, {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_templates_enabled = true,
        optional_event_combat_enabled = true,
    }, false, "Depth2")
    check(disabled.OptionalBossEventMechanicId == nil
        and disabled.OptionalBossEnabled == false,
        "release lock overrides non-boss mechanic opt-in")
    local corrupt = selected_run(dungeon_id, "Depth2", 7, true)
    corrupt.OptionalBossEventMechanicId = "UnknownMechanic"
    check(Content.for_difficulty(dungeon_id, "Depth2", corrupt) == nil,
        "unknown saved mechanic must fail closed")
    corrupt = selected_run(dungeon_id, "Depth2", 7, true)
    corrupt.OptionalBossEventTemplateId = "EventAfterRoom1"
    check(Content.for_difficulty(dungeon_id, "Depth2", corrupt) == nil,
        "saved combat event cannot be moved to boss-only early room")
end
print(string.format(
    "[Optional Combat Variations] PASS: %d assertions.", count))
