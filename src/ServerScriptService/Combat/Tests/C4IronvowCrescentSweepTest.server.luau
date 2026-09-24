--!strict
-- Actual world-NPC HP proof for the independent C4 Warrior area skill.
local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local CONFIG = require(RS.Combat.Shared.CombatConfig)
local SKILLS = require(RS.Combat.Shared.SkillDefinitions)
local MELEE = require(SSS.Combat.MeleeHitService)
local DAMAGE = require(SSS.Combat.DamageService)
local ORIGIN = Vector3.new(1850, 75, 1850)
local CHECKS = 0

--[[
Counts a real combat assertion, aborting the test on its first failure.

Args:
    valid (boolean): Result of a genuine server skill/health check.
    message (string): Diagnosis retained in the Studio test log.

Returns:
    nil: Fails the fixture when any invariant is violated.
]]
local function check(valid: boolean, message: string)
    CHECKS += 1
    assert(valid, "[Warrior Crescent Sweep] " .. message)
end

--[[
Creates a physical world NPC with a queryable root and real Humanoid.

Args:
    name (string): Distinct attacker or NPC name.
    position (Vector3): World location inside the area skill's arc.
    target (boolean): Whether the NPC should be valid to hit.

Returns:
    Model: Registered real world actor.
]]
local function create_actor(
    name: string, position: Vector3, target: boolean
): Model
    local actor = Instance.new("Model")
    actor.Name = name
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(0.25, 2, 0.25)
    root.CFrame = CFrame.new(position)
    root.Anchored = true
    root.CanCollide = false
    root.Parent = actor
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = actor
    actor.PrimaryPart = root
    actor.Parent = workspace
    if target then
        CollectionService:AddTag(actor, CONFIG.TARGETS.NPC_TAG)
    end
    return actor
end

--[[
Runs the genuine registered rank and hitbox against 22 world NPCs.

Args:
    attacker (Model): Real server-owned attacking actor.
    targets ({Model}): Twenty-two independent NPCs in the front arc.
    rank (number): First or ninth separately purchased source rank.

Returns:
    nil: Proves only 20 NPCs lose exactly one hit of rank-specific HP.
]]
local function verify_rank(attacker: Model, targets: {Model}, rank: number)
    local ability = assert(SKILLS.get_for_rank(
        "IronvowCrescentSweep", rank
    ))
    for _, target in ipairs(targets) do
        target.Humanoid.Health = 100
    end
    local damage_events = 0
    MELEE.begin_active_window({
        attacker = nil,
        character = attacker,
        attack_id = ability.ID,
        attack_definition = ability,
        base_damage = ability.BASE_DAMAGE,
        on_target = function(target: Model)
            damage_events += 1
            DAMAGE.apply_damage({
                attacker = nil, attacker_character = attacker,
                target = target, source_kind = "Skill",
                source_id = ability.ID, base_damage = ability.BASE_DAMAGE,
                multiplier = 1,
            })
        end,
    })
    task.wait(ability.ACTIVE_SECONDS + 0.12)
    local hit = 0
    for _, target in ipairs(targets) do
        local hp = target.Humanoid.Health
        local expected = 100 - ability.BASE_DAMAGE
        check(math.abs(hp - expected) < 0.001
            or math.abs(hp - 100) < 0.001,
            "A target received duplicate damage or wrong rank power")
        if math.abs(hp - expected) < 0.001 then hit += 1 end
    end
    check(hit == 20 and damage_events == 20,
        "The genuine area skill must hit exactly 20 of 22 NPCs once")
end

--[[
Proves the actual rank-one and rank-nine skill hitbox and cleanup.

Args:
    None.

Returns:
    nil: Reports success only after real world HP measurements.
]]
local function main()
    local attacker = create_actor(
        "TEMP_CrescentSweepAttacker", ORIGIN, false
    )
    local targets: {Model} = {}
    for index = 1, 22 do
        local offset = (index - 11.5) * 0.38
        table.insert(targets, create_actor(
            "TEMP_CrescentSweepNPC_" .. tostring(index),
            ORIGIN + Vector3.new(offset, 0, -4), true
        ))
    end
    task.wait(0.1)
    verify_rank(attacker, targets, 1)
    verify_rank(attacker, targets, 9)
    for _, target in ipairs(targets) do target:Destroy() end
    attacker:Destroy()
    print("[Warrior Crescent Sweep] PASS: "
        .. tostring(CHECKS) .. " real NPC HP assertions")
end

main()
