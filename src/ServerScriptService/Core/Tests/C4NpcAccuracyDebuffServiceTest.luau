--!strict
-- Isolated server-owned C4 NPC accuracy-debuff state regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local AccuracyDebuff = require(
    ServerScriptService.Combat.C4NpcAccuracyDebuffService
)

local checks = 0

--[[
Counts one accuracy-state assertion.

Args:
    valid (boolean): Expected runtime state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and increments the assertion count.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 NPC Accuracy Debuff] " .. label)
end

--[[
Builds one disposable living Workspace NPC.

Args:
    None.

Returns:
    Model: Living model accepted by the accuracy authority.
]]
local function fixture_npc(): Model
    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_C4AccuracyNpc"

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = enemy

    enemy.Parent = Workspace
    return enemy
end

--[[
Runs non-stacking, decoration and cleanup acceptance.

Args:
    None.

Returns:
    nil: Prints bounded server-state evidence.
]]
local function main()
    local enemy = fixture_npc()
    local boundary = table.freeze({
        SourceStatCandidate = table.freeze({
            ACCURACY_COMBAT = 30,
            EVASION_RATE = 20,
        }),
    })

    check(
        AccuracyDebuff.apply(enemy, 12, 15),
        "valid source accuracy penalty applies"
    )
    check(
        AccuracyDebuff.get_penalty(enemy) == 12
            and enemy:GetAttribute("C4AccuracyPenalty") == 12,
        "live source penalty is server-owned and observable"
    )

    local decorated =
        AccuracyDebuff.decorate_boundary(enemy, boundary)
    check(
        decorated ~= boundary
            and decorated.SourceStatCandidate.ACCURACY_COMBAT == 18
            and boundary.SourceStatCandidate.ACCURACY_COMBAT == 30,
        "runtime penalty decorates without mutating source reference"
    )

    check(
        AccuracyDebuff.apply(enemy, 6, 15)
            and AccuracyDebuff.get_penalty(enemy) == 12,
        "weaker reapplication cannot reduce current penalty"
    )
    check(
        AccuracyDebuff.apply(enemy, 15, 15)
            and AccuracyDebuff.get_penalty(enemy) == 15,
        "stronger reapplication replaces penalty magnitude"
    )

    AccuracyDebuff.clear(enemy)
    check(
        AccuracyDebuff.get_penalty(enemy) == 0
            and enemy:GetAttribute("C4AccuracyPenalty") == 0,
        "explicit lifecycle cleanup removes current accuracy state"
    )

    enemy:Destroy()

    print((
        "[C4 NPC Accuracy Debuff] PASS: %d assertions"
    ):format(checks))
end

main()
