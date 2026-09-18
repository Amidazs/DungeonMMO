--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("Depth1EncounterBindings")
if not module then
    error(
        "[Depth1 Encounter Bindings Tests] RED: "
            .. "Depth1EncounterBindings is missing."
    )
end

local Difficulties = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local Bindings = require(module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Depth1 Encounter Bindings Tests] " .. message, 2)
    end
end

for _, dungeon_id in ipairs({
    "TestDungeon",
    "AbandonedMine",
}) do
    local depth1 = assert(Difficulties.get(dungeon_id, "Depth1"))
    local result = Bindings.resolve(depth1.EncounterSequence)

    check(
        result.ok == true,
        dungeon_id .. " Depth1 plan must bind."
    )
    check(
        result.by_slot.Room1.PlanEncounterId == "CombatRoom1",
        dungeon_id .. " Room1 binding mismatch."
    )
    check(
        result.by_slot.Room2.PlanEncounterId == "CombatRoom2",
        dungeon_id .. " Room2 binding mismatch."
    )
    check(
        result.by_slot.Room3.PlanEncounterId == "Depth1Boss",
        dungeon_id .. " boss binding mismatch."
    )
    check(
        result.by_slot.Room1.RuntimeEncounterId == "CombatRoom1"
            and result.by_slot.Room2.RuntimeEncounterId
                == "CombatRoom2"
            and result.by_slot.Room3.RuntimeEncounterId
                == "MarauderCaptain",
        "Existing EncounterService IDs must stay backward compatible."
    )
    check(
        result.by_slot.Room1.CheckpointId
            == "EncounterStart:CombatRoom1"
            and result.by_slot.Room3.CheckpointId
                == "EncounterStart:Depth1Boss",
        "Checkpoint IDs must derive from stable plan IDs."
    )
end

local inserted_event = {
    {
        Id = "CombatRoom1",
        RoomSlotId = "Room1",
        Kind = "Combat",
    },
    {
        Id = "LimitedEventBoss",
        RoomSlotId = "EventArena",
        Kind = "EventBoss",
    },
    {
        Id = "CombatRoom2",
        RoomSlotId = "Room2",
        Kind = "Combat",
    },
    {
        Id = "Depth1Boss",
        RoomSlotId = "Room3",
        Kind = "Boss",
    },
}

local unsupported = Bindings.resolve(inserted_event)
check(
    unsupported.ok == false
        and unsupported.reason == "EncounterBindingMissing",
    "Active optional content must fail closed until physically bound."
)
check(
    unsupported.EncounterId == "LimitedEventBoss",
    "Binding failure must identify the unbound encounter."
)

print(string.format(
    "[Depth1 Encounter Bindings Tests] PASS: %d assertions.",
    assertion_count
))
