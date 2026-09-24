--!strict
-- Authored C4 Warrior polearm multi-target and per-swing anti-duplication.
local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Melee = require(SSS.Combat.MeleeHitService)
local CombatConfig = require(RS.Combat.Shared.CombatConfig)

local CHECKS = 0
local ORIGIN = Vector3.new(1350, 75, 1350)

--[[
Counts an actual trusted melee or NPC health assertion.

Args:
    valid (boolean): Current verified polearm invariant.
    message (string): Failure diagnosis rather than a false PASS.

Returns:
    nil: Raises immediately on any source-owned contract failure.
]]
local function check(valid: boolean, message: string)
    CHECKS += 1
    assert(valid, "[Warrior Polearm Hit Cap] " .. message)
end

--[[
Creates an actual tagged NPC Humanoid and queryable part.

Args:
    name (string): Distinct combat actor identifier.
    position (Vector3): Position of this real world model.
    is_target (boolean): True for actual damageable NPC.

Returns:
    Model: Server-owned, tagged world combat actor.
]]
local function create_actor(
    name: string, position: Vector3, is_target: boolean
): Model
    local model = Instance.new("Model")
    model.Name = name
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(0.6, 2, 0.6)
    root.CFrame = CFrame.new(position)
    root.Anchored = true
    root.CanCollide = false
    root.Parent = model
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = model
    model.PrimaryPart = root
    model.Parent = workspace
    if is_target then
        CollectionService:AddTag(
            model, CombatConfig.TARGETS.NPC_TAG
        )
    end
    return model
end

--[[
Creates source-bounded polearm hitbox for an isolated melee swing.

Args:
    limit (number): Authentic server-assigned max targets, 5 or 10.

Returns:
    any: Real melee-service context using author-controlled geometry.
]]
local function attack_context(limit: number): any
    return {
        attacker = nil, character = assert(
            workspace:FindFirstChild("TEMP_PolearmAttacker")
        ),
        attack_id = "TEMP_PolearmSweep",
        attack_definition = {
            HITBOX = {
                SIZE = Vector3.new(10, 5, 7),
                FORWARD_OFFSET = 3.5, SAMPLE_COUNT = 3,
            },
            REACH_STUDS = 7, ARC_DEGREES = 130,
            MAX_TARGETS = limit, ACTIVE_SECONDS = 0.06,
            POWER_MULTIPLIER = 1,
        },
        base_damage = 10,
    }
end

--[[
Verifies separate NPCs each receive only one real health hit per swing.

Args:
    targets ({Model}): Twelve tagged, independently living real NPCs.
    limit (number): Five untrained or ten earned-mastery target cap.

Returns:
    nil: Checks exactly the capped number of NPC Humanoids lose HP.
]]
local function verify_swing(targets: {Model}, limit: number)
    for _, actor in ipairs(targets) do
        actor.Humanoid.Health = 100
    end
    Melee.begin_active_window(attack_context(limit))
    task.wait(0.15)
    local hit_count = 0
    for _, actor in ipairs(targets) do
        local hp = actor.Humanoid.Health
        check(hp == 100 or hp == 90,
            "One NPC cannot be damaged twice across swing samples")
        if hp == 90 then hit_count += 1 end
    end
    check(hit_count == limit,
        "Polearm hit more targets than its verified source hit limit")
end

--[[
Verifies real multi-NPC hitboxes, cap, deduplication and cleanup.

Args:
    None.

Returns:
    nil: Prints PASS only for actual world Humanoid health measurements.
]]
local function main()
    local attacker = create_actor(
        "TEMP_PolearmAttacker", ORIGIN, false
    )
    local targets = {}
    for index = 1, 12 do
        local x = (index - 6.5) * 0.7
        table.insert(targets, create_actor(
            "TEMP_PolearmTarget_" .. index,
            ORIGIN + Vector3.new(x, 0, -4), true
        ))
    end
    task.wait(0.1)
    verify_swing(targets, 5)
    verify_swing(targets, 10)
    for _, target in ipairs(targets) do target:Destroy() end
    attacker:Destroy()
    print("[Warrior Polearm Hit Cap] PASS: "
        .. tostring(CHECKS) .. " actual NPC HP assertions")
end

main()
