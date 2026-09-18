--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonEncounterEnvironmentRuntime"
)
if not module then
    error(
        "[Dungeon Encounter Environment Runtime Tests] RED: "
            .. "DungeonEncounterEnvironmentRuntime is missing."
    )
end

local EnvironmentRuntime = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Environment Runtime Tests] "
                .. message,
            2
        )
    end
end

local barrier = Instance.new("Part")
barrier.CanCollide = true
barrier.CanTouch = false
barrier.Transparency = 1

local environment = {}
function environment:get(anchor_id: string): BasePart?
    if anchor_id == "Synthetic.Room4.ExitBarrier" then
        return barrier
    end
    return nil
end

local binding = {
    RoomSlotId = "Room4",
    ExitBarrierAnchor = "Synthetic.Room4.ExitBarrier",
}

local opened = EnvironmentRuntime.set_exit_open(
    binding,
    environment,
    true
)
check(opened.ok == true, "Barrier opening must succeed.")
check(
    barrier.CanCollide == false,
    "Open barrier must be non-collidable."
)
check(
    barrier.CanTouch == false and barrier.Transparency == 1,
    "Barrier presentation contract must remain invisible/non-touchable."
)

local closed = EnvironmentRuntime.set_exit_open(
    binding,
    environment,
    false
)
check(closed.ok == true, "Barrier closing must succeed.")
check(
    barrier.CanCollide == true,
    "Closed barrier must be collidable."
)

local no_barrier = EnvironmentRuntime.set_exit_open(
    {
        RoomSlotId = "BossRoom",
    },
    environment,
    true
)
check(
    no_barrier.ok == true
        and no_barrier.barrier_present == false,
    "Slots without barriers must be safe no-ops."
)

local missing = EnvironmentRuntime.set_exit_open(
    {
        RoomSlotId = "Room5",
        ExitBarrierAnchor = "Synthetic.MissingBarrier",
    },
    environment,
    true
)
check(
    missing.reason == "ExitBarrierAnchorMissing",
    "Missing declared barriers must fail closed."
)

check(
    EnvironmentRuntime.set_exit_open(
        binding,
        {},
        true
    ).reason == "EncounterEnvironmentInvalid",
    "Invalid environment adapters must fail closed."
)

barrier:Destroy()

print(string.format(
    "[Dungeon Encounter Environment Runtime Tests] PASS: %d assertions.",
    assertion_count
))
