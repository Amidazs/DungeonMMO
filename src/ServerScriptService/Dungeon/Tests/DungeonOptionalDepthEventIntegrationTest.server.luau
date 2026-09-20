--!strict
-- Server-only optional encounter planning across the existing four depths.
-- No unreleased layout is registered or enabled by this contract test.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS:WaitForChild("Core"):WaitForChild("Shared")
local Dungeon = SSS:WaitForChild("Dungeon")
local Core = SSS:WaitForChild("Core")
local Definitions = require(Shared.DungeonDifficultyDefinitions)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Plan = require(Dungeon.DungeonEncounterPlan)
local Gates = require(Dungeon.DungeonOptionalEntranceGates)
local Sequencer = require(Dungeon.DungeonEncounterSequencer)

local assertions = 0

-- Checks one optional encounter contract and explains failures in Studio.
-- Args: condition (boolean): Expected gameplay invariant.
--       message (string): Specific invariant to identify when it fails.
-- Returns: nil: Raises on failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Optional Depth Event] " .. message)
end

-- Constructs an entry-time eligible, independently selected run snapshot.
-- Args: dungeon_id (string): Temple or Mine identity.
--       event_on (boolean): Whether the run entered during the event.
--       secret_on (boolean): Whether the hidden route was selected.
-- Returns: any: Frozen server-issued Event and Secret eligibility.
local function issue_state(
    dungeon_id: string, event_on: boolean, secret_on: boolean
): any
    local options = {
        optional_boss_event_start = if event_on then 100 else 200,
        optional_boss_event_end = if event_on then 200 else 300,
        optional_boss_secret_chance_basis_points =
            if secret_on then 10000 else 0,
    }
    local state = Issuer.issue(dungeon_id, 150, 42, options, true)
    state.RunEnteredAtUnix = 150
    return state
end

-- Converts a server-materialized plan to the binding order used by gates.
-- Args: encounters ({any}): Ordered authoritative run descriptors.
-- Returns: any: Detached structural slot bindings with the same order.
local function bindings_for(encounters: {any}): any
    local bindings = {by_slot = {}, ordered = {}}
    for _, encounter in ipairs(encounters) do
        local binding = {
            RoomSlotId = encounter.RoomSlotId,
            Kind = encounter.Kind,
            PlanEncounterId = encounter.Id,
        }
        bindings.by_slot[binding.RoomSlotId] = binding
        table.insert(bindings.ordered, binding)
    end
    return bindings
end

-- Checks optional prerequisites for one selected higher-depth plan.
-- Args: bindings (any): Frozen ordered room and optional bindings.
--       prerequisite (string): Required room before the optional Secret.
-- Returns: nil: Checks Event independence and fail-closed Secret access.
local function check_gates(bindings: any, prerequisite: string)
    local states = {Room1 = "Pending", Room2 = "Pending"}
    local flow = {
        state_for_slot = function(_, slot_id: string)
            return states[slot_id]
        end,
    }
    check(not Gates.status("EventArena", bindings, flow),
        "Event entrance stays closed before the first room")
    states.Room1 = "Cleared"
    check(Gates.status("EventArena", bindings, flow)
        == (bindings.by_slot.EventArena ~= nil),
        "Event gate depends only on its selected run and Room1")
    states.Room2 = "Cleared"
    if prerequisite ~= "Room2" then
        check(not Gates.status("SecretArena", bindings, flow),
            "higher-depth Secret gate cannot open at Room2")
        states[prerequisite] = "Cleared"
    end
    check(Gates.status("SecretArena", bindings, flow)
        == (bindings.by_slot.SecretArena ~= nil),
        "Secret opens only after its actual preceding required room")
end

-- Validates each independent Event/Secret combination for one difficulty.
-- Args: dungeon_id (string): Temple or Mine identity.
--       depth_id (string): Selected difficulty, Depth1 to Depth4.
--       event_on (boolean): Server-selected timed Event eligibility.
--       secret_on (boolean): Server-selected hidden route eligibility.
-- Returns: nil: Checks plan, prereqs, once-only and deferred Secret play.
local function verify_selection(
    dungeon_id: string, depth_id: string,
    event_on: boolean, secret_on: boolean
)
    local difficulty = assert(Definitions.get(dungeon_id, depth_id))
    local state = issue_state(dungeon_id, event_on, secret_on)
    local slots = {
        EventArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Synthetic.EventBossSpawn",
        },
        SecretArena = {
            SupportsBoss = true,
            BossSpawnAnchor = "Synthetic.SecretBossSpawn",
        },
    }
    local definition = {
        OptionalEncounters = assert(
            Content.for_difficulty(dungeon_id, depth_id)
        ),
    }
    local selected = Policy.evaluate(
        definition, depth_id, slots, true, state
    )
    check(selected.ok, "eligible optional policy must materialize")
    check(#selected.encounters ==
        (if event_on then 1 else 0) + (if secret_on then 1 else 0),
        "Event and Secret eligibility must be selected independently")
    local materialized = Plan.materialize(
        difficulty.EncounterSequence, selected.encounters, state
    )
    check(materialized.ok, "optional encounters must bind to this depth")
    local encounters = materialized.encounters
    check(#encounters == #difficulty.EncounterSequence
        + #selected.encounters, "optionals only extend required rooms")
    local event_index, secret_index = nil, nil
    for index, encounter in ipairs(encounters) do
        if encounter.Kind == "EventBoss" then
            event_index = index
            check(encounter.CompletionRequired == true,
                "eligible Event remains required")
        elseif encounter.Kind == "SecretBoss" then
            secret_index = index
            check(encounter.CompletionRequired == false,
                "Secret remains an optional encounter")
        end
    end
    check((event_index ~= nil) == event_on
        and (secret_index ~= nil) == secret_on,
        "only selected encounters are in the materialized plan")
    if event_on then
        check(event_index == 2 and encounters[1].RoomSlotId == "Room1",
            "Event is inserted after the first required room")
    end
    local last_required = "Room"
        .. tostring(#difficulty.EncounterSequence - 1)
    if secret_on then
        check(secret_index == #encounters - 1
            and encounters[secret_index - 1].RoomSlotId
                == last_required,
            "Secret appears after the last prerequisite, before final")
    end
    local bindings = bindings_for(encounters)
    check_gates(bindings, last_required)

    local sequencer = Sequencer.new(encounters)
    for _, encounter in ipairs(encounters) do
        if encounter.Kind == "SecretBoss" then
            check(sequencer:skip(encounter.Id).ok,
                "selected optional Secret can be bypassed")
        else
            check(sequencer:start(encounter.Id).ok
                and not sequencer:start(encounter.Id).ok,
                "required encounter starts exactly once")
            check(sequencer:clear(encounter.Id).ok,
                "required encounter clears exactly once")
        end
    end
    check(sequencer:is_complete(),
        "skipped Secret never blocks completed main progression")
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({
        "Depth1", "Depth2", "Depth3", "Depth4",
    }) do
        for _, selection in ipairs({
            {false, false}, {true, false},
            {false, true}, {true, true},
        }) do
            verify_selection(
                dungeon_id, depth_id, selection[1], selection[2]
            )
        end
    end
end

print(string.format(
    "[Optional Depth Event Tests] PASS: %d assertions.", assertions
))
