--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("DungeonEncounterRuntimeState")
if not module then
    error(
        "[Dungeon Encounter Runtime State Tests] RED: "
            .. "DungeonEncounterRuntimeState is missing."
    )
end

local RuntimeState = require(module)
local InMemoryMapAdapter = require(
    Adapters:WaitForChild("InMemoryMapAdapter")
)
local DungeonSessionService = require(
    Services:WaitForChild("DungeonSessionService")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Runtime State Tests] " .. message,
            2
        )
    end
end

local now = 5000

local function clock(): number
    return now
end

local sessions = DungeonSessionService.new(
    InMemoryMapAdapter.new(clock),
    clock
)

local session = assert(
    sessions:create(
        "TestDungeon",
        {9101},
        100,
        "runtime-state",
        "Depth1"
    )
)
assert(sessions:set_instance_state(session.SessionId, {
    DifficultyId = "Depth1",
    RareStateId = "HiddenCrypt",
    EventActive = true,
}).ok)
check(
    RuntimeState.checkpoint_id("CombatRoom1")
        == "EncounterStart:CombatRoom1",
    "Checkpoint IDs must derive from stable encounter IDs."
)

local snapshot = {
    Version = 1,
    EncounterStates = {
        CombatRoom1 = "Cleared",
        SecretGuardian = "Active",
        FinalBoss = "Pending",
    },
    ActiveEncounterId = "SecretGuardian",
    NextEncounterId = "SecretGuardian",
}

local persisted = RuntimeState.persist(
    sessions,
    session.SessionId,
    snapshot
)
check(persisted.ok == true, "Runtime snapshot must persist.")

local reloaded = assert(sessions:get(session.SessionId))
check(
    reloaded.InstanceState.RareStateId == "HiddenCrypt"
        and reloaded.InstanceState.EventActive == true,
    "Encounter persistence must preserve authored instance state."
)

local restored = RuntimeState.from_session(reloaded)
check(
    restored.EncounterStates.CombatRoom1 == "Cleared",
    "Cleared encounter state must restore."
)
check(
    restored.ActiveEncounterId == "SecretGuardian",
    "Active encounter identity must restore."
)

restored.EncounterStates.CombatRoom1 = "Pending"
local fresh = RuntimeState.from_session(
    assert(sessions:get(session.SessionId))
)
check(
    fresh.EncounterStates.CombatRoom1 == "Cleared",
    "Returned snapshots must be detached copies."
)

local plan = {
    {Id = "CombatRoom1"},
    {Id = "EventBoss"},
    {Id = "SecretGuardian"},
    {Id = "FinalBoss"},
}

check(
    RuntimeState.checkpoint_sequence(
        plan,
        "EventBoss"
    ) == 2,
    "Event boss checkpoint must follow materialized order."
)
check(
    RuntimeState.checkpoint_sequence(
        plan,
        "SecretGuardian"
    ) == 3,
    "Secret boss insertion must get its own stable sequence."
)
check(
    RuntimeState.checkpoint_sequence(
        {{Id = "CombatRoom1"}},
        "Missing"
    ) == nil,
    "Unknown encounter checkpoint sequence must fail closed."
)

print(string.format(
    "[Dungeon Encounter Runtime State Tests] PASS: %d assertions.",
    assertion_count
))
