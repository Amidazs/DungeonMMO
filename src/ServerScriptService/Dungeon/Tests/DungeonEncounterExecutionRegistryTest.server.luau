--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonEncounterExecutionRegistry"
)
if not module then
    error(
        "[Dungeon Encounter Execution Registry Tests] RED: "
            .. "DungeonEncounterExecutionRegistry is missing."
    )
end

local Registry = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Execution Registry Tests] "
                .. message,
            2
        )
    end
end

local registry = Registry.new()

local calls = {}
local combat_executor = {}

function combat_executor:validate(
    encounter: any,
    _binding: any,
    _context: any
): any
    table.insert(calls, "validate:" .. encounter.Id)
    return {ok = true}
end

function combat_executor:execute(
    encounter: any,
    binding: any,
    context: any
): any
    table.insert(calls, "execute:" .. encounter.Id)
    return {
        ok = true,
        marker = context.Marker,
        room_slot_id = binding.RoomSlotId,
    }
end

check(
    registry:register("CombatPack", combat_executor).ok == true,
    "CombatPack executor must register."
)
check(
    registry:register("CombatPack", combat_executor).reason
        == "ExecutorAlreadyRegistered",
    "Duplicate executor IDs must fail closed."
)

local explicit = {
    Id = "RoomA",
    Kind = "Combat",
    ExecutorId = "CombatPack",
}
check(
    registry:resolve_id(explicit) == "CombatPack",
    "Explicit ExecutorId must win."
)

check(
    registry:resolve_id({
        Id = "LegacyCombat",
        Kind = "Combat",
    }) == "CombatPack",
    "Legacy Combat descriptor must resolve to CombatPack."
)

for _, kind in ipairs({
    "MiniBoss",
    "Boss",
    "FinalBoss",
    "EventBoss",
    "SecretBoss",
}) do
    check(
        registry:resolve_id({
            Id = kind,
            Kind = kind,
        }) == "Boss",
        kind .. " must use the legacy Boss fallback."
    )
end

local missing = registry:validate(
    {
        Id = "BossA",
        Kind = "Boss",
        ExecutorId = "Boss",
    },
    {},
    {}
)
check(
    missing.ok == false
        and missing.reason == "EncounterExecutorMissing",
    "Unregistered executor must fail closed."
)

local invalid = registry:validate(
    {
        Id = "Unknown",
        Kind = "NotAKind",
    },
    {},
    {}
)
check(
    invalid.ok == false
        and invalid.reason == "UnknownEncounterExecutor",
    "Unknown kind without ExecutorId must fail closed."
)

local validated = registry:validate(
    explicit,
    {RoomSlotId = "Room1"},
    {Marker = "context"}
)
check(validated.ok == true, "Registered executor must validate.")
check(
    calls[#calls] == "validate:RoomA",
    "Validation must dispatch to the selected executor."
)

local executed = registry:execute(
    explicit,
    {RoomSlotId = "Room1"},
    {Marker = "context"}
)
check(executed.ok == true, "Registered executor must execute.")
check(
    executed.marker == "context"
        and executed.room_slot_id == "Room1",
    "Execution must forward context and binding."
)
check(
    calls[#calls] == "execute:RoomA",
    "Execution must dispatch to the selected executor."
)

print(string.format(
    "[Dungeon Encounter Execution Registry Tests] PASS: %d assertions.",
    assertion_count
))
