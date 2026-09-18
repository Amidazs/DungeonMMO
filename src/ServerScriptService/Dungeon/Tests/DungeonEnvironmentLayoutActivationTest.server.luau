--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonEnvironmentLayoutActivation"
)
if not module then
    error(
        "[Dungeon Environment Layout Activation Tests] RED: "
            .. "DungeonEnvironmentLayoutActivation is missing."
    )
end

local Activation = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Environment Layout Activation Tests] "
                .. message,
            2
        )
    end
end

local by_id = {}
local created = {}

local function add_part(id: string): BasePart
    local part = Instance.new("Part")
    part.Name = id
    part.CanTouch = false
    part.CanCollide = false
    part.Transparency = 0
    by_id[id] = part
    table.insert(created, part)
    return part
end

for index = 1, 4 do
    add_part("Synthetic.Room" .. tostring(index) .. ".Trigger")
end
for index = 1, 3 do
    add_part("Synthetic.Room" .. tostring(index) .. ".ExitBarrier")
end

local layout = {
    Id = "Depth2",
    EntranceAnchor = "Synthetic.Entry",
    Slots = {
        Room1 = {
            TriggerAnchor = "Synthetic.Room1.Trigger",
            ExitBarrierAnchor =
                "Synthetic.Room1.ExitBarrier",
        },
        Room2 = {
            TriggerAnchor = "Synthetic.Room2.Trigger",
            ExitBarrierAnchor =
                "Synthetic.Room2.ExitBarrier",
        },
        Room3 = {
            TriggerAnchor = "Synthetic.Room3.Trigger",
            ExitBarrierAnchor =
                "Synthetic.Room3.ExitBarrier",
        },
        Room4 = {
            TriggerAnchor = "Synthetic.Room4.Trigger",
        },
    },
}

local activated = Activation.apply(layout, {
    by_id = by_id,
})
check(activated.ok == true, "Four-slot layout must activate.")
check(
    activated.TriggerCount == 4,
    "Every declared trigger must activate."
)
check(
    activated.BarrierCount == 3,
    "Every declared exit barrier must activate."
)

for index = 1, 4 do
    local trigger = by_id[
        "Synthetic.Room" .. tostring(index) .. ".Trigger"
    ]
    check(
        trigger.CanTouch == true
            and trigger.CanCollide == false
            and trigger.Transparency == 1,
        "Trigger activation mismatch for slot "
            .. tostring(index)
    )
end

for index = 1, 3 do
    local barrier = by_id[
        "Synthetic.Room" .. tostring(index) .. ".ExitBarrier"
    ]
    check(
        barrier.CanTouch == false
            and barrier.CanCollide == true
            and barrier.Transparency == 1,
        "Barrier activation mismatch for slot "
            .. tostring(index)
    )
end

local missing = table.clone(layout)
missing.Slots = table.clone(layout.Slots)
missing.Slots.Room4 = {
    TriggerAnchor = "Synthetic.Missing.Trigger",
}

local missing_result = Activation.apply(missing, {
    by_id = by_id,
})
check(
    missing_result.reason == "LayoutAnchorMissing",
    "Missing declared trigger must fail closed."
)

local missing_barrier = table.clone(layout)
missing_barrier.Slots = table.clone(layout.Slots)
missing_barrier.Slots.Room3 = {
    TriggerAnchor = "Synthetic.Room3.Trigger",
    ExitBarrierAnchor = "Synthetic.Missing.ExitBarrier",
}
local missing_barrier_result = Activation.apply(
    missing_barrier,
    {
        by_id = by_id,
    }
)
check(
    missing_barrier_result.reason == "LayoutAnchorMissing",
    "Missing declared barrier must fail closed."
)

for _, part in ipairs(created) do
    part:Destroy()
end

print(string.format(
    "[Dungeon Environment Layout Activation Tests] PASS: %d assertions.",
    assertion_count
))
