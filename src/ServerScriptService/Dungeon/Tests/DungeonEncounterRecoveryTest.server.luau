--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local Recovery = require(
    Dungeon:WaitForChild("DungeonEncounterRecovery")
)

local assertion_count = 0
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Encounter Recovery Tests] " .. message, 2)
    end
end

local bindings = {
    ok = true,
    by_slot = {},
    ordered = {},
}
for index = 1, 6 do
    local binding = {
        PlanEncounterId = "Encounter" .. tostring(index),
        RoomSlotId = "Room" .. tostring(index),
        CheckpointId =
            "EncounterStart:Encounter" .. tostring(index),
        CheckpointSequence = index,
    }
    bindings.by_slot[binding.RoomSlotId] = binding
    table.insert(bindings.ordered, binding)
end

local entrance = assert(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "Entrance"
    )
)
check(
    entrance.NextEncounterId == "Encounter1",
    "Entrance must target the first arbitrary slot."
)

local room5 = assert(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "EncounterStart:Encounter5"
    )
)
for index = 1, 4 do
    check(
        room5.EncounterStates[
            "Encounter" .. tostring(index)
        ] == "Cleared",
        "Earlier arbitrary encounter must stay cleared."
    )
end
check(
    room5.EncounterStates.Encounter5 == "Pending"
        and room5.EncounterStates.Encounter6 == "Pending",
    "Target and later encounters must remain pending."
)
check(
    room5.NextEncounterId == "Encounter5",
    "Stable fifth-slot checkpoint must recover generically."
)

local legacy = assert(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "OldBossRoom",
        {OldBossRoom = "Room6"}
    )
)
check(
    legacy.NextEncounterId == "Encounter6",
    "Legacy alias map must remain supported."
)
check(
    legacy.EncounterStates.Encounter5 == "Cleared",
    "Legacy late-room recovery must preserve earlier clears."
)

check(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "MissingCheckpoint"
    ) == nil,
    "Unknown checkpoint must fail closed."
)

print(string.format(
    "[Dungeon Encounter Recovery Tests] PASS: %d assertions.",
    assertion_count
))
