--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local Flow = require(
    Dungeon:WaitForChild("DungeonEncounterFlow")
)

local assertion_count = 0
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Encounter Flow Tests] " .. message, 2)
    end
end

local bindings = {
    ok = true,
    by_slot = {},
    by_encounter = {},
    by_runtime = {},
    ordered = {},
}

for index = 1, 6 do
    local encounter_id = if index == 6
        then "FinalBoss"
        else "Encounter" .. tostring(index)
    local runtime_id = "Runtime" .. tostring(index)
    local binding = {
        PlanEncounterId = encounter_id,
        RoomSlotId = "Room" .. tostring(index),
        RuntimeEncounterId = runtime_id,
        CheckpointSequence = index,
    }
    bindings.by_slot[binding.RoomSlotId] = binding
    bindings.by_encounter[encounter_id] = binding
    bindings.by_runtime[runtime_id] = binding
    table.insert(bindings.ordered, binding)
end

local states = {}
for _, binding in ipairs(bindings.ordered) do
    states[binding.PlanEncounterId] = "Pending"
end

local active_id: string? = nil
local controller: any = {}

function controller:start(encounter_id: string): any
    if active_id ~= nil then
        return {ok = false, reason = "AnotherEncounterActive"}
    end
    if states[encounter_id] ~= "Pending" then
        return {ok = false, reason = "EncounterNotPending"}
    end
    local expected = self:next_id()
    if encounter_id ~= expected then
        return {ok = false, reason = "EncounterOutOfOrder"}
    end
    states[encounter_id] = "Active"
    active_id = encounter_id
    return {ok = true}
end

function controller:clear(encounter_id: string): any
    if active_id ~= encounter_id then
        return {ok = false, reason = "EncounterNotActive"}
    end
    states[encounter_id] = "Cleared"
    active_id = nil
    return {
        ok = true,
        next_encounter_id = self:next_id(),
        complete = self:next_id() == nil,
    }
end

function controller:cancel_active(encounter_id: string): any
    if active_id ~= encounter_id then
        return {ok = false, reason = "EncounterNotActive"}
    end
    states[encounter_id] = "Pending"
    active_id = nil
    return {ok = true}
end

function controller:state_of(encounter_id: string): string?
    return states[encounter_id]
end

function controller:next_id(): string?
    for _, binding in ipairs(bindings.ordered) do
        if states[binding.PlanEncounterId] ~= "Cleared" then
            return binding.PlanEncounterId
        end
    end
    return nil
end

function controller:is_complete(): boolean
    return self:next_id() == nil
end

local flow = Flow.new(controller, bindings)

check(
    flow:first_binding().RoomSlotId == "Room1",
    "First binding must be generic."
)
check(
    flow:binding_for_slot("Room6").PlanEncounterId
        == "FinalBoss",
    "Sixth room slot must be addressable."
)
check(
    flow:binding_for_runtime("Runtime4").RoomSlotId
        == "Room4",
    "Runtime lookup must be generic."
)
check(
    flow:binding_for_encounter("FinalBoss").RoomSlotId
        == "Room6",
    "Logical encounter lookup must be generic."
)

for index = 1, 6 do
    local slot_id = "Room" .. tostring(index)
    local runtime_id = "Runtime" .. tostring(index)
    local started = flow:start_slot(slot_id)
    check(started.ok == true, slot_id .. " must start.")
    local cleared = flow:clear_runtime(runtime_id)
    check(cleared.ok == true, slot_id .. " must clear.")
    if index < 6 then
        check(
            cleared.next_binding.RoomSlotId
                == "Room" .. tostring(index + 1),
            "Clear must expose the next arbitrary slot."
        )
    else
        check(
            cleared.next_binding == nil
                and cleared.complete == true,
            "Final arbitrary slot must complete the run."
        )
    end
end

check(flow:is_complete() == true, "Six-slot flow must complete.")
check(
    flow:start_slot("Missing").reason == "UnknownRoomSlot",
    "Unknown arbitrary slot must fail closed."
)

print(string.format(
    "[Dungeon Encounter Flow Tests] PASS: %d assertions.",
    assertion_count
))
