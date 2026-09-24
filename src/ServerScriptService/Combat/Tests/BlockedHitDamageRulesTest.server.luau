--!strict
-- Deterministic guard-stack and blocked-hit anti-invulnerability tests.

local SSS = game:GetService("ServerScriptService")
local Rules = require(SSS.Combat.BlockedHitDamageRules)

local assertions = 0

--[[
Checks one damage result without relying on random combat timing.

Args:
    actual (number): Actual resolved incoming damage.
    expected (number): Expected health damage before temporary wards.
    label (string): Diagnostic naming the scenario being tested.

Returns:
    nil: Raises on unexpected HP and counts a passing assertion.
]]
local function check_damage(
    actual: number,
    expected: number,
    label: string
)
    assertions += 1
    assert(math.abs(actual - expected) < 0.001,
        "[Block Damage] " .. label .. ": expected "
            .. tostring(expected) .. " got " .. tostring(actual))
end

--[[
Runs non-block, shield/block, stacked armour/buff and bypass checks.

Args:
    None.

Returns:
    nil: Prints a pass count only when all safety cases pass.
]]
local function main()
    check_damage(
        Rules.resolve(100, 100, "EnemyMelee", false),
        100, "ordinary melee remains full damage"
    )
    check_damage(
        Rules.resolve(100, 100, "EnemyMelee", nil),
        100, "missing block flag cannot apply chip"
    )
    check_damage(
        Rules.resolve(100, 100, "EnemyMelee", true),
        45, "actual block must inflict HP chip"
    )
    check_damage(
        Rules.resolve(100, 93, "EnemyMelee", true),
        41.85, "C4 Knight stance plus shield block must still hurt"
    )
    check_damage(
        Rules.resolve(100, 50, "EnemyMelee", true),
        22.5, "maximum normal passive and stance stack still hurts"
    )
    check_damage(
        Rules.resolve(100, 10, "EnemyMelee", true),
        20, "extra defence cannot breach twenty-percent damage floor"
    )
    check_damage(
        Rules.resolve(100, 0, "EnemyMelee", true),
        0, "zero actual incoming damage is not fabricated"
    )
    check_damage(
        Rules.resolve(100, 50, "EnemyMagic", true),
        50, "magic cannot be converted to shield chip"
    )
    check_damage(
        Rules.resolve(100, 50, "EnemyArea", true),
        50, "unblockable area must bypass this block helper"
    )
    check_damage(
        Rules.resolve(100, 50, "Melee", true),
        50, "PvP-like melee cannot silently inherit NPC block"
    )
    check_damage(
        Rules.resolve(100, 93, "EnemyMelee", false),
        93, "guard break must not receive ongoing block protection"
    )
    print("[Block Damage] PASS: " .. tostring(assertions)
        .. " anti-invulnerability assertions")
end

main()
