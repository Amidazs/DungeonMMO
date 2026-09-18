--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("DungeonEncounterSequencer")
if not module then
    error(
        "[Dungeon Encounter Sequencer Tests] RED: "
            .. "DungeonEncounterSequencer is missing."
    )
end

local Sequencer = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Encounter Sequencer Tests] " .. message, 2)
    end
end

local encounters = {
    {
        Id = "Combat1",
        Kind = "Combat",
        CompletionRequired = true,
    },
    {
        Id = "EventBoss",
        Kind = "EventBoss",
        CompletionRequired = true,
    },
    {
        Id = "SecretBoss",
        Kind = "SecretBoss",
        CompletionRequired = false,
    },
    {
        Id = "FinalBoss",
        Kind = "FinalBoss",
        CompletionRequired = true,
    },
}

local sequence = Sequencer.new(encounters)
check(sequence:next_id() == "Combat1", "First encounter mismatch.")
check(sequence:is_complete() == false, "Fresh sequence cannot be complete.")

local wrong = sequence:start("EventBoss")
check(
    wrong.reason == "EncounterOutOfOrder",
    "Later encounters must not start early."
)

check(sequence:start("Combat1").ok == true, "Combat1 must start.")
check(
    sequence:start("Combat1").reason == "EncounterAlreadyActive",
    "Repeated start must be rejected safely."
)
check(sequence:clear("Combat1").ok == true, "Combat1 must clear.")
check(
    sequence:clear("Combat1").already_cleared == true,
    "Repeated clear must be idempotent."
)

check(sequence:next_id() == "EventBoss", "Required EventBoss must be next.")
check(
    sequence:skip("EventBoss").reason == "EncounterRequired",
    "Required EventBoss must not be skippable."
)
check(sequence:start("EventBoss").ok == true, "EventBoss must start.")
check(sequence:clear("EventBoss").ok == true, "EventBoss must clear.")

check(sequence:next_id() == "SecretBoss", "SecretBoss must become available.")
check(
    sequence:skip("SecretBoss").ok == true,
    "Optional SecretBoss must be skippable."
)
check(sequence:next_id() == "FinalBoss", "FinalBoss must follow skipped secret.")

local snapshot = sequence:snapshot()
local restored = Sequencer.new(encounters, snapshot)
check(
    restored:next_id() == "FinalBoss",
    "Reconnect reconstruction must use stable encounter IDs."
)
check(
    restored:state_of("Combat1") == "Cleared"
        and restored:state_of("SecretBoss") == "Skipped",
    "Reconnect must preserve cleared/skipped states."
)

check(restored:start("FinalBoss").ok == true, "FinalBoss must start.")
local active_snapshot = restored:snapshot()
local active_reconnect = Sequencer.new(encounters, active_snapshot)
check(
    active_reconnect:state_of("FinalBoss") == "Pending",
    "Active encounter must restart from its start checkpoint after reconnect."
)
check(
    active_reconnect:next_id() == "FinalBoss",
    "Restarted active encounter must remain next."
)

check(active_reconnect:start("FinalBoss").ok == true, "Restarted boss must start.")
check(active_reconnect:clear("FinalBoss").ok == true, "FinalBoss must clear.")
check(
    active_reconnect:is_complete() == true,
    "All required encounters cleared must complete the run."
)

print(string.format(
    "[Dungeon Encounter Sequencer Tests] PASS: %d assertions.",
    assertion_count
))
