--!strict
-- Event eligibility is frozen on entry, independently of dungeon modifiers.
-- The test uses disposable sessions; no release switch is enabled.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Core = SSS:WaitForChild("Core")
local Dungeon = SSS:WaitForChild("Dungeon")
local Shared = RS:WaitForChild("Core"):WaitForChild("Shared")

local Difficulties = require(Shared.DungeonDifficultyDefinitions)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local Map = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)

local checks = 0

-- Verifies an immutable run requirement and records the assertion count.
-- Args: value (boolean): Whether the required invariant is satisfied.
--       description (string): Failure context for the Studio test runner.
-- Returns: nil: Raises if the invariant is false.
local function check(value: boolean, description: string)
    checks += 1
    assert(value, "[Timed Event Recovery] " .. description)
end

-- Locates a kind within a saved encounter plan.
-- Args: plan ({any}): Materialized server encounter descriptors.
--       kind (string): EventBoss or SecretBoss.
-- Returns: any?: Encounter with the requested kind, when present.
local function find_kind(plan: {any}, kind: string): any?
    for _, encounter in ipairs(plan) do
        if encounter.Kind == kind then
            return encounter
        end
    end
    return nil
end

-- Supplies registered boss-only room capabilities to generic policy tests.
-- Args: None.
-- Returns: any: Synthetic optional slots, never a released physical map.
local function optional_slots(): any
    return {
        EventArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Synthetic.EventSpawn",
        },
        SecretArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Synthetic.SecretSpawn",
        },
    }
end

-- Reconstructs one run after its entry window closes and checks no reroll.
-- Args: dungeon_id (string): Existing Temple or Mine dungeon.
--       depth_id (string): Current depth in the released sequence schema.
--       user_id (number): Disposable, unique in-memory session member.
-- Returns: nil: Confirms event and secret persistence across recreation.
local function check_recovery(
    dungeon_id: string, depth_id: string, user_id: number
)
    local now = 150
    local function clock(): number
        return now
    end
    local map = Map.new(clock)
    local sessions = Sessions.new(map, clock)
    local session = assert(sessions:create(
        dungeon_id, {user_id}, 0, "event-recovery", depth_id
    ))
    check(sessions:mark_connected(session.SessionId, user_id).ok,
        "new run must be active before optional event issuance")
    local options = {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
        optional_boss_secret_chance_basis_points = 10000,
    }
    local state = Issuer.issue(dungeon_id, now, 42, options, true)
    state.RunEnteredAtUnix = now
    -- Mine's standard DeepEchoes event modifier must remain independent
    -- from its timed optional boss event.
    if dungeon_id == "AbandonedMine" then
        state.EventId = "DeepEchoes"
        state.EventActive = true
    end
    local definition = assert(Difficulties.get(dungeon_id, depth_id))
    local optional = assert(Content.for_difficulty(dungeon_id, depth_id))
    check(sessions:set_instance_state(
        session.SessionId, state
    ).ok, "event and secret eligibility must persist at dungeon entry")
    local selected = Policy.evaluate(
        {OptionalEncounters = optional}, depth_id,
        optional_slots(), true, state
    )
    check(selected.ok and #selected.encounters == 2,
        "eligible run must independently select Event and Secret")
    local controller = assert(Controller.new({
        session_service = sessions,
        session_id = session.SessionId,
        base_sequence = definition.EncounterSequence,
        optional_encounters = selected.encounters,
    }))
    local frozen = assert(sessions:get(session.SessionId))
    local saved_plan = frozen.InstanceState.EncounterPlan
    local event = assert(find_kind(saved_plan, "EventBoss"))
    local secret = assert(find_kind(saved_plan, "SecretBoss"))
    check(event.CompletionRequired and not secret.CompletionRequired,
        "frozen optional encounter roles must remain distinct")

    now = 250
    local new_entrant = Issuer.issue(
        dungeon_id, now, 42, options, true
    )
    check(not new_entrant.OptionalBossEventActive
        and new_entrant.OptionalBossSecretUnlocked,
        "new runs after the window cannot inherit expired Event access")
    local restored_sessions = Sessions.new(map, clock)
    local restored = assert(Controller.new({
        session_service = restored_sessions,
        session_id = session.SessionId,
        base_sequence = definition.EncounterSequence,
        optional_encounters = {},
    }))
    local recovered = assert(restored_sessions:get(session.SessionId))
    check(#restored:encounters() == #saved_plan,
        "recovered run keeps the original materialized encounter plan")
    check(recovered.InstanceState.OptionalBossEventActive
        and recovered.InstanceState.OptionalBossSecretUnlocked
        and recovered.InstanceState.OptionalBossEventId
            == state.OptionalBossEventId,
        "event expiry must not reroll eligibility during reconnect")
    check(recovered.InstanceState.OptionalBossEventWindows[
        state.OptionalBossEventId
    ].EndUnix == 200, "original event window remains in persisted state")
    if dungeon_id == "AbandonedMine" then
        check(recovered.InstanceState.EventId == "DeepEchoes"
            and recovered.InstanceState.OptionalBossEventId
                == "MineEchoSurge",
            "Mine modifier and optional timed boss keep separate IDs")
    end

    local reopened = Policy.evaluate(
        {OptionalEncounters = optional}, depth_id,
        optional_slots(), true, recovered.InstanceState
    )
    check(reopened.ok and #reopened.encounters == 2,
        "saved entry-time window remains eligible after global expiry")
    local room1 = assert(definition.EncounterSequence[1])
    check(restored:start(room1.Id).ok
        and restored:clear(room1.Id).ok,
        "required first room remains ordered after recovery")
    check(restored:next_id() == event.Id
        and restored:start(event.Id).ok,
        "expired global event still plays once for the eligible run")
    check(not restored:start(event.Id).ok
        and restored:clear(event.Id).ok,
        "repeated event startup cannot duplicate the selected boss")
    check(restored:state_of(secret.Id) == "Pending",
        "Event clear must not implicitly unlock or clear Secret")
    check(controller:state_of(event.Id) == "Pending",
        "previous detached controller cannot mutate recovered copy")
end

local member = 99800
for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({
        "Depth1", "Depth2", "Depth3", "Depth4",
    }) do
        member += 1
        check_recovery(dungeon_id, depth_id, member)
    end
end

print(string.format(
    "[Timed Event Recovery Tests] PASS: %d assertions.", checks
))
