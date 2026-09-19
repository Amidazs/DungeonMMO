--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local Content = require(Dungeon:WaitForChild(
    "DungeonOptionalBossContent"
))
local Policy = require(Dungeon:WaitForChild(
    "DungeonOptionalBossPolicy"
))
local Triggers = require(Dungeon:WaitForChild(
    "DungeonOptionalBossTriggers"
))
local Plan = require(Dungeon:WaitForChild("DungeonEncounterPlan"))

local assertion_count = 0

-- Verifies one condition and records the precise failure message.
-- Args: condition (boolean): Expected test condition.
--       message (string): Explanation on failure.
-- Returns: nil: Raises if the expectation is false.
local function check(condition: boolean, message: string)
    assertion_count += 1
    assert(condition, "[Optional Boss Policy Tests] " .. message)
end

local slots = {
    EventArena = {
        SupportsBoss = true,
        BossSpawnAnchor = "Synthetic.Event.Spawn",
    },
    SecretArena = {
        SupportsBoss = true,
        BossSpawnAnchor = "Synthetic.Secret.Spawn",
    },
}

-- Returns a server-owned test run with an active, bounded event.
-- Args: None.
-- Returns: any: Synthetic authoritative instance-state snapshot.
local function active_state(): any
    return {
        OptionalBossEnabled = true,
        OptionalBossEventActive = true,
        OptionalBossEventId = "TempleEclipse",
        RunEnteredAtUnix = 150,
        OptionalBossEventWindows = {
            TempleEclipse = {StartUnix = 100, EndUnix = 200},
        },
        OptionalBossSecretUnlocked = true,
        OptionalBossSecretUnlocks = {TempleHiddenSanctum = true},
    }
end

-- Returns the real dormant content for the requested dungeon and depth.
-- Args: dungeon_id (string): Registered authored dungeon.
--       difficulty_id (string): Depth in the progression ladder.
-- Returns: any: Optional encounter definition container.
local function definitions(
    dungeon_id: string,
    difficulty_id: string
): any
    return {
        OptionalEncounters = Content.for_difficulty(
            dungeon_id, difficulty_id
        ),
    }
end

local definition = definitions("TestDungeon", "Depth1")
local state = active_state()
local disabled = Policy.evaluate(
    definition, "Depth1", nil, false, state
)
check(disabled.ok and #disabled.encounters == 0,
    "Disabled rollout must ignore absent physical slots")

local ready = Policy.evaluate(
    definition, "Depth1", slots, true, state
)
check(ready.ok and #ready.encounters == 2,
    "Both explicitly triggered optional bosses must be admitted")
check(ready.encounters[1].Encounter.Kind == "EventBoss",
    "Event boss must retain EventBoss role")
check(ready.encounters[2].Encounter.Kind == "SecretBoss",
    "Secret boss must retain SecretBoss role")
check(ready.encounters[1].CompletionRequired == true,
    "Triggered event must be completion-required")
check(ready.encounters[2].CompletionRequired == false,
    "Secret boss must remain optional")

local base = {
    {Id = "CombatRoom1", Kind = "Combat", RoomSlotId = "Room1"},
    {Id = "CombatRoom2", Kind = "Combat", RoomSlotId = "Room2"},
    {Id = "Depth1Boss", Kind = "Boss", RoomSlotId = "Room3"},
}
local plan = Plan.materialize(base, ready.encounters, state)
check(plan.ok and #plan.encounters == 5,
    "Selected encounters must materialize into the generic plan")
check(plan.encounters[2].Kind == "EventBoss",
    "Event must be inserted after the first combat room")
check(plan.encounters[4].Kind == "SecretBoss",
    "Secret must be inserted before the final boss")

state.RunEnteredAtUnix = 200
local late = Policy.evaluate(definition, "Depth1", slots, true, state)
check(late.ok and #late.encounters == 1,
    "Entering at event window end must not activate the event")
state.RunEnteredAtUnix = 100
check(Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Entering at event window start must activate the event")
state.RunEnteredAtUnix = 99
check(not Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Entering before the event window must fail closed")
state.RunEnteredAtUnix = nil
state.CreatedAt = 150
check(Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Server-authoritative instance creation time is valid entry time")
state.CreatedAt = nil
state.RunEnteredAtUnix = 150

state.OptionalBossEventId = "DifferentEvent"
check(not Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Unrelated event ID must not activate the boss")
state.OptionalBossEventId = "TempleEclipse"
state.OptionalBossEventWindows = {}
check(not Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Missing event schedule must fail closed")
state.OptionalBossEventWindows.TempleEclipse = {
    StartUnix = 200, EndUnix = 100,
}
check(not Triggers.evaluate(
    definition.OptionalEncounters[1], state
).active, "Invalid event schedule must fail closed")
state.OptionalBossEventWindows.TempleEclipse = {
    StartUnix = 100, EndUnix = 200,
}
state.OptionalBossEventActive = false
local event_off = Policy.evaluate(
    definition, "Depth1", slots, true, state
)
check(event_off.ok and #event_off.encounters == 1,
    "Inactive event must not block an independently unlocked secret")
state.OptionalBossEventActive = true

state.OptionalBossSecretUnlocks = {}
local secret_locked = Policy.evaluate(
    definition, "Depth1", slots, true, state
)
check(secret_locked.ok and #secret_locked.encounters == 1,
    "Locked secret must not join the authoritative plan")
state.OptionalBossSecretUnlocks.TempleHiddenSanctum = true

local missing_slot = Policy.evaluate(
    definition, "Depth1", {}, true, state
)
check(not missing_slot.ok
    and missing_slot.reason == "OptionalBossContentUnavailable",
    "Triggered optional boss must reject unregistered physical rooms")
local bad_slot = {
    EventArena = {SupportsBoss = false},
    SecretArena = slots.SecretArena,
}
check(not Policy.evaluate(
    definition, "Depth1", bad_slot, true, state
).ok, "Combat-only physical slot must reject an optional boss")
bad_slot.EventArena = {SupportsBoss = true}
check(not Policy.evaluate(
    definition, "Depth1", bad_slot, true, state
).ok, "Missing boss-spawn anchor must fail closed")
check(Policy.evaluate(
    definition, "Depth1", slots, true, {}
).ok, "An entirely inactive event must not require physical content")

local missing_content = {
    OptionalEncounters = {{
        Encounter = {
            Id = "UnknownBossEncounter",
            Kind = "EventBoss",
            ExecutorId = "Boss",
            BossId = "NotRegisteredBoss",
            RoomSlotId = "EventArena",
        },
        InsertAfterId = "CombatRoom1",
        AllowedDifficulties = {Depth1 = true},
        CompletionRequired = true,
        Activation = definition.OptionalEncounters[1].Activation,
        Trigger = definition.OptionalEncounters[1].Trigger,
    }},
}
check(not Policy.evaluate(
    missing_content, "Depth1", slots, true, state
).ok, "Unregistered boss content must never enter the plan")

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, difficulty_id in ipairs({
        "Depth1", "Depth2", "Depth3", "Depth4",
    }) do
        local optional = Content.for_difficulty(
            dungeon_id, difficulty_id
        )
        check(optional ~= nil and #optional == 2,
            dungeon_id .. " " .. difficulty_id .. " content missing")
        check(optional[1].Encounter.Kind == "EventBoss"
            and optional[2].Encounter.Kind == "SecretBoss",
            dungeon_id .. " " .. difficulty_id .. " kind mismatch")
    end
end
local mine_definition = definitions("AbandonedMine", "Depth1")
local mine_state = active_state()
mine_state.OptionalBossEventId = "MineEchoSurge"
mine_state.OptionalBossEventWindows = {
    MineEchoSurge = {StartUnix = 100, EndUnix = 200},
}
mine_state.OptionalBossSecretUnlocks = {MineSealedGallery = true}
local mine_ready = Policy.evaluate(
    mine_definition, "Depth1", slots, true, mine_state
)
check(mine_ready.ok and #mine_ready.encounters == 2,
    "Mine event window and secret unlock must select both bosses")
check(mine_ready.encounters[1].Encounter.BossId
    == "AbandonedMineEventBoss",
    "Mine event must select its own boss content")
check(mine_ready.encounters[2].Encounter.BossId
    == "AbandonedMineSecretBoss",
    "Mine secret must select its own boss content")
mine_state.OptionalBossEventId = "DeepEchoes"
check(#Policy.evaluate(
    mine_definition, "Depth1", slots, true, mine_state
).encounters == 1,
    "Existing Deep Echoes modifier must not activate the event boss")

local anchors = {
    Depth1 = {"CombatRoom1", "Depth1Boss"},
    Depth2 = {"Depth2Combat1", "Depth2Boss"},
    Depth3 = {"Depth3Combat1", "Depth3Boss"},
    Depth4 = {"Depth4Combat1", "Depth4FinalBoss"},
}
for depth_id, expected in pairs(anchors) do
    local optional = Content.for_difficulty("TestDungeon", depth_id)
    check(optional[1].InsertAfterId == expected[1]
        and optional[2].InsertBeforeId == expected[2],
        depth_id .. " insertion must follow existing progression")
end

check(Content.for_difficulty("Unknown", "Depth1") == nil,
    "Unknown dungeon must not expose optional boss content")
check(Content.for_difficulty("TestDungeon", "Depth5") == nil,
    "Unregistered depth must not expose optional boss content")

print(string.format(
    "[Optional Boss Policy Tests] PASS: %d assertions.",
    assertion_count
))
