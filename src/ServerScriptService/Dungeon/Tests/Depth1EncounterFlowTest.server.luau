--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("Depth1EncounterFlow")
if not module then
    error(
        "[Depth1 Encounter Flow Tests] RED: "
            .. "Depth1EncounterFlow is missing."
    )
end

local Difficulties = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local Bindings = require(
    Dungeon:WaitForChild("Depth1EncounterBindings")
)
local Flow = require(module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Depth1 Encounter Flow Tests] " .. message, 2)
    end
end

local calls = {}
local fake_controller: any = {}

function fake_controller:start(encounter_id: string): any
    table.insert(calls, "start:" .. encounter_id)
    return {
        ok = true,
        encounter_id = encounter_id,
    }
end

function fake_controller:clear(encounter_id: string): any
    table.insert(calls, "clear:" .. encounter_id)
    local next_id = nil
    if encounter_id == "CombatRoom1" then
        next_id = "CombatRoom2"
    elseif encounter_id == "CombatRoom2" then
        next_id = "Depth1Boss"
    end
    return {
        ok = true,
        next_encounter_id = next_id,
        complete = encounter_id == "Depth1Boss",
    }
end

function fake_controller:state_of(encounter_id: string): string
    if encounter_id == "CombatRoom1" then
        return "Cleared"
    end
    return "Pending"
end

function fake_controller:is_complete(): boolean
    return false
end

local depth1 = assert(Difficulties.get("TestDungeon", "Depth1"))
local binding_result = Bindings.resolve(depth1.EncounterSequence)
assert(binding_result.ok)

local flow = Flow.new(fake_controller, binding_result)

local room1 = flow:start_slot("Room1")
check(room1.ok == true, "Room1 start must route.")
check(
    calls[#calls] == "start:CombatRoom1",
    "Room1 must use its logical plan ID."
)
check(
    room1.binding.RuntimeEncounterId == "CombatRoom1",
    "Room1 must preserve legacy runtime ID."
)

local cleared_room1 = flow:clear_runtime("CombatRoom1")
check(cleared_room1.ok == true, "Room1 clear must route.")
check(
    calls[#calls] == "clear:CombatRoom1",
    "Room1 clear must use logical plan ID."
)
check(
    cleared_room1.next_binding.PlanEncounterId
        == "CombatRoom2",
    "Room1 clear must expose Room2 as next binding."
)

local boss = flow:start_slot("Room3")
check(boss.ok == true, "Boss start must route.")
check(
    calls[#calls] == "start:Depth1Boss",
    "Physical MarauderCaptain must map to logical Depth1Boss."
)
check(
    boss.binding.RuntimeEncounterId == "MarauderCaptain",
    "Boss must retain existing EncounterService ID."
)

local boss_clear = flow:clear_runtime("MarauderCaptain")
check(boss_clear.ok == true, "Boss clear must route.")
check(
    calls[#calls] == "clear:Depth1Boss",
    "Boss clear must use logical plan ID."
)

check(
    flow:state_for_slot("Room1") == "Cleared",
    "Flow state lookup must use logical plan ID."
)

local cancel_controller: any = {}
function cancel_controller:cancel_active(encounter_id: string): any
    return {
        ok = encounter_id == "Depth1Boss",
        reason = if encounter_id == "Depth1Boss"
            then nil
            else "EncounterNotActive",
    }
end
local cancel_flow = Flow.new(cancel_controller, binding_result)
check(
    cancel_flow:cancel_slot("Room3").ok == true,
    "Flow cancel must translate room slot to logical encounter ID."
)
check(
    cancel_flow:cancel_slot("Unknown").reason == "UnknownRoomSlot",
    "Flow cancel must fail closed for unknown slots."
)
check(
    flow:binding_for_runtime("MarauderCaptain")
        .PlanEncounterId == "Depth1Boss",
    "Runtime boss ID must resolve back to its physical binding."
)
check(
    flow:binding_for_runtime("Unknown") == nil,
    "Unknown runtime encounter IDs must not resolve a binding."
)
check(
    flow:start_slot("Unknown").reason == "UnknownRoomSlot",
    "Unknown physical room slots must fail closed."
)
check(
    flow:clear_runtime("Unknown").reason
        == "UnknownRuntimeEncounter",
    "Unknown runtime encounter IDs must fail closed."
)

print(string.format(
    "[Depth1 Encounter Flow Tests] PASS: %d assertions.",
    assertion_count
))
