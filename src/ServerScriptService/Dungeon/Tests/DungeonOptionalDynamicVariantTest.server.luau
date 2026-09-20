--!strict
-- New encounter identities are frozen once, not rerolled on recovery.
-- Dynamic bosses reuse implemented placeholder factories and do not release art.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Core = SSS:WaitForChild("Core")
local Dungeon = SSS:WaitForChild("Dungeon")
local Shared = RS:WaitForChild("Core"):WaitForChild("Shared")
local Catalog = require(Shared.DungeonOptionalBossVariantCatalog)
local ContentCatalog = require(Shared.DungeonRuntimeContentCatalog)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local InstanceDirector = require(Core.Services.DungeonInstanceDirector)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Plan = require(Dungeon.DungeonEncounterPlan)
local Sequencer = require(Dungeon.DungeonEncounterSequencer)
local Difficulty = require(Shared.DungeonDifficultyDefinitions)
local Map = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)

local checks = 0
local function check(ok: boolean, message: string)
    checks += 1
    assert(ok, "[Optional Dynamic Variant] " .. message)
end
local allowed = {
    EventArena = {SupportsBoss = true,
        BossSpawnAnchor = "Fixture.EventBossSpawn"},
    SecretArena = {SupportsBoss = true,
        BossSpawnAnchor = "Fixture.SecretBossSpawn"},
}
local opts = {
    optional_boss_event_start = 100,
    optional_boss_event_end = 200,
    optional_boss_secret_chance_basis_points = 10000,
    optional_boss_variants_enabled = true,
}

-- Checks one uniquely frozen combination at each difficulty.
-- Args: dungeon_id (string): Temple or AbandonedMine.
--       depth_id (string): Existing difficulty identity.
--       seed (number): Server hash with independently selected variants.
--       event_on/secret_on (boolean): Issued independent eligibility.
local function check_variant(dungeon_id: string, depth_id: string,
    seed: number, event_on: boolean, secret_on: boolean)
    local options = {
        optional_boss_event_start = if event_on then 100 else 200,
        optional_boss_event_end = if event_on then 200 else 300,
        optional_boss_secret_chance_basis_points =
            if secret_on then 10000 else 0,
        optional_boss_variants_enabled = true,
    }
    local state = Issuer.issue(dungeon_id, 150, seed, options, true)
    state.RunEnteredAtUnix = 150
    local event_variant = assert(Catalog.get(
        dungeon_id, "Event", (seed % 2) + 1))
    local secret_variant = assert(Catalog.get(
        dungeon_id, "Secret", (math.floor(seed / 7) % 2) + 1))
    check(state.OptionalBossEventActive == event_on
        and state.OptionalBossSecretUnlocked == secret_on,
        "independent eligibility must not be changed by variety")
    check(state.OptionalBossEventId ==
        (if event_on then event_variant.Id else nil),
        "only selected Event ID can be saved")
    if secret_on then
        check(state.OptionalBossSecretUnlocks[secret_variant.Id] == true,
            "exact server-selected Secret identity must be persisted")
    else
        check(next(state.OptionalBossSecretUnlocks) == nil,
            "ineligible Secret cannot issue an unlock")
    end
    local descriptors = assert(Content.for_difficulty(
        dungeon_id, depth_id, state))
    check(#descriptors == 2
        and descriptors[1].Encounter.BossId == event_variant.BossId
        and descriptors[2].Encounter.BossId == secret_variant.BossId,
        "one Event/Secret descriptor must resolve from saved identities")
    check(descriptors[1].Trigger.EventId == event_variant.Id
        and descriptors[2].Trigger.UnlockId == secret_variant.Id,
        "saved trigger identity must match selected placeholder boss")
    local selected = Policy.evaluate(
        {OptionalEncounters = descriptors},
        depth_id, allowed, true, state)
    check(selected.ok and #selected.encounters
        == (if event_on then 1 else 0) + (if secret_on then 1 else 0),
        "optional policy admits only one eligible encounter per kind")
    local required = assert(Difficulty.get(dungeon_id, depth_id))
    local materialized = Plan.materialize(
        required.EncounterSequence, selected.encounters, state)
    check(materialized.ok and #materialized.encounters
        == #required.EncounterSequence + #selected.encounters,
        "variant must not replace or duplicate a required encounter")
    local ordered = materialized.encounters
    local event_count, secret_count = 0, 0
    for i, encounter in ipairs(ordered) do
        if encounter.Kind == "EventBoss" then
            event_count += 1
            check(i == 2 and encounter.RoomSlotId == "EventArena"
                and encounter.CompletionRequired == true,
                "Event remains required immediately after Room1")
        elseif encounter.Kind == "SecretBoss" then
            secret_count += 1
            check(i == #ordered - 1
                and encounter.RoomSlotId == "SecretArena"
                and encounter.CompletionRequired == false,
                "Secret remains skippable before the final room")
        end
    end
    check(event_count == (if event_on then 1 else 0)
        and secret_count == (if secret_on then 1 else 0),
        "no variant combination may spawn two of either kind")
    local sequencer = Sequencer.new(ordered)
    for _, encounter in ipairs(ordered) do
        if encounter.Kind == "SecretBoss" then
            check(sequencer:skip(encounter.Id).ok,
                "variant Secret remains skippable")
        else
            check(sequencer:start(encounter.Id).ok
                and not sequencer:start(encounter.Id).ok
                and sequencer:clear(encounter.Id).ok,
                "variant encounter starts and clears once")
        end
    end
    check(sequencer:is_complete(),
        "optional variant selection cannot block required completion")

    -- Controller reconstruction reads the already frozen plan, never
    -- chooses a different optional boss when a window later expires.
    if event_on and secret_on then
        local now = 150
        local map = Map.new(function() return now end)
        local sessions = Sessions.new(map, function() return now end)
        local session = assert(sessions:create(
            dungeon_id, {80000 + seed}, 0, "variant-fixture", depth_id))
        check(sessions:mark_connected(
            session.SessionId, 80000 + seed).ok,
            "disposable variant session admitted")
        check(sessions:set_instance_state(
            session.SessionId, state).ok,
            "frozen variant identities persisted")
        local controller = assert(Controller.new({
            session_service = sessions, session_id = session.SessionId,
            base_sequence = required.EncounterSequence,
            optional_encounters = selected.encounters,
        }))
        local frozen = sessions:get(session.SessionId)
            .InstanceState.EncounterPlan
        check(frozen[2].BossId == event_variant.BossId
            and frozen[#frozen - 1].BossId == secret_variant.BossId,
            "materialized plan freezes both selected variant bosses")
        check(controller:start(frozen[1].Id).ok
            and controller:clear(frozen[1].Id).ok
            and controller:start(frozen[2].Id).ok,
            "a selected Event can start in the persisted run")
        now = 250
        local reconstructed = assert(Controller.new({
            session_service = Sessions.new(map, function() return now end),
            session_id = session.SessionId,
            base_sequence = required.EncounterSequence,
            optional_encounters = {},
        }))
        check(reconstructed:state_of(frozen[2].Id) == "Pending"
            and reconstructed:state_of(frozen[1].Id) == "Cleared"
            and reconstructed:get(frozen[2].Id).BossId
                == event_variant.BossId,
            "interrupted Event recovers Pending as the same variant")
        check(reconstructed:get(frozen[#frozen - 1].Id).BossId
                == secret_variant.BossId,
            "deferred Secret identity survives window expiry/recovery")
    end
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    check(Catalog.count(dungeon_id, "Event") == 2
        and Catalog.count(dungeon_id, "Secret") == 2,
        "dungeon must have two registered choices per optional kind")
    for _, kind in ipairs({"Event", "Secret"}) do
        for index = 1, 2 do
            local variant = assert(Catalog.get(dungeon_id, kind, index))
            local boss = ContentCatalog.get_boss(variant.BossId)
            check(boss ~= nil
                and ContentCatalog.is_boss_factory_implemented(
                    boss.FactoryId),
                "variants must reuse genuinely implemented boss factories")
            check(Catalog.find(
                dungeon_id, kind, variant.Id) == variant,
                "variant identity resolution must be exact")
        end
    end
    for _, depth in ipairs({"Depth1", "Depth2", "Depth3", "Depth4"}) do
        for _, seed in ipairs({0, 1, 7, 8}) do
            for _, selection in ipairs({
                {false, false}, {true, false},
                {false, true}, {true, true},
            }) do
                check_variant(dungeon_id, depth, seed,
                    selection[1], selection[2])
            end
        end
    end
    local legacy = Issuer.issue(dungeon_id, 150, 1, {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_secret_chance_basis_points = 10000,
    }, true)
    check(legacy.OptionalBossEventId ==
        Catalog.get(dungeon_id, "Event", 1).Id
        and legacy.OptionalBossSecretUnlocks[
            Catalog.get(dungeon_id, "Secret", 1).Id],
        "disabled variant opt-in preserves both old boss identities")
    local locked = Issuer.issue(dungeon_id, 150, 1, opts, false)
    check(not locked.OptionalBossEnabled
        and locked.OptionalBossEventId == nil
        and next(locked.OptionalBossSecretUnlocks) == nil,
        "release lock dominates newly introduced variant selection")
    local corrupt = Issuer.issue(dungeon_id, 150, 1, opts, true)
    corrupt.OptionalBossEventId = "UnregisteredOptionalBoss"
    check(Content.for_difficulty(dungeon_id, "Depth2", corrupt) == nil,
        "unknown saved event identity must fail closed")
    corrupt = Issuer.issue(dungeon_id, 150, 1, opts, true)
    corrupt.OptionalBossSecretUnlocks = {UnknownSecret = true}
    check(Content.for_difficulty(dungeon_id, "Depth2", corrupt) == nil,
        "unknown saved Secret identity must fail closed")
    corrupt = Issuer.issue(dungeon_id, 150, 1, opts, true)
    corrupt.OptionalBossSecretUnlocks.UnknownSecret = true
    check(Content.for_difficulty(dungeon_id, "Depth2", corrupt) == nil,
        "multiple saved Secret identities must fail closed")
end
check(Catalog.count("Unknown", "Event") == 0
    and Catalog.get("Unknown", "Secret", 1) == nil,
    "unregistered dungeon cannot get a variant")
print(string.format(
    "[Optional Dynamic Variant Tests] PASS: %d assertions.", checks
))
