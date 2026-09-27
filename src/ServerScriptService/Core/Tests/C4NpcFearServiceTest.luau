--!strict
-- Exact server-owned C4 NPC Fear movement regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Fear = require(
    ServerScriptService.Combat.C4NpcFearService
)

local checks = 0

--[[
Counts one Fear authority assertion.

Args:
    condition (boolean): Required runtime condition.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 NPC Fear] " .. label)
end

--[[
Builds one disposable living combat model at a fixed position.

Args:
    name (string): Diagnostic model name.
    position (Vector3): HumanoidRootPart position.

Returns:
    Model: Living disposable combat model.
]]
local function actor(name: string, position: Vector3): Model
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = workspace

    local humanoid = Instance.new("Humanoid")
    humanoid.Health = 100
    humanoid.MaxHealth = 100
    humanoid.Parent = model

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.Position = position
    root.Parent = model

    return model
end

--[[
Runs timing, source-distance and cleanup acceptance for Fear.

Args:
    None.

Returns:
    nil: Prints bounded Fear authority evidence.
]]
local function main()
    local caster = actor(
        "TEMP_FearCaster",
        Vector3.new(0, 0, 0)
    )
    local target = actor(
        "TEMP_FearTarget",
        Vector3.new(10, 0, -5)
    )

    local applied, reason = Fear.apply(
        target,
        caster,
        5,
        4,
        500,
        25,
        100
    )
    check(
        applied and reason == nil,
        "exact five-by-four-second Fear applies"
    )
    check(
        target:GetAttribute("C4Feared") == true
            and target:GetAttribute("C4FearEndsAt") == 120,
        "Fear exposes bounded diagnostic state"
    )

    local first = assert(Fear.flee_destination(target, 100))
    check(
        first == Vector3.new(30, 0, -25)
            and target:GetAttribute(
                "C4FearActionsIssued"
            ) == 1,
        "first source Fear action moves 500 units on both axes"
    )

    local same = assert(Fear.flee_destination(target, 103.9))
    check(
        same == first
            and target:GetAttribute(
                "C4FearActionsIssued"
            ) == 1,
        "Fear does not invent movement actions between source ticks"
    )

    local second = assert(Fear.flee_destination(target, 104))
    check(
        second == first
            and target:GetAttribute(
                "C4FearActionsIssued"
            ) == 2,
        "second source action keeps the current forced destination"
    )

    local expired = Fear.flee_destination(target, 120)
    check(
        expired == nil
            and target:GetAttribute("C4Feared") == false,
        "Fear clears exactly at the source duration"
    )

    target:Destroy()
    caster:Destroy()

    print((
        "[C4 NPC Fear] PASS: %d assertions "
            .. "actions=5 interval=4 flee=500"
    ):format(checks))
end

main()
