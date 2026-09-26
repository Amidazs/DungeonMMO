--!strict
-- Pure C4 derived-stat reference vectors; no live player is modified.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Derived = require(Shared.C4DerivedStatReference)

local checks = 0
local EPSILON = 0.00001

--[[
Counts one exact C4 source-formula assertion.

Args:
    valid (boolean): Expected source result.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Derived Stats] " .. label)
end

--[[
Checks one two-decimal C4 primary-stat source bonus.

Args:
    name (string): C4 stat name.
    value (number): Integer stat value.
    expected (number): Exact statBonus.xml result.

Returns:
    nil: Verifies the source table-equivalent value.
]]
local function check_bonus(
    name: string, value: number, expected: number
)
    local actual = assert(Derived.stat_bonus(name, value))
    check(math.abs(actual - expected) <= EPSILON,
        name .. tostring(value) .. " bonus")
end

--[[
Checks a complete naked level-30 source vector.

Args:
    race_id (string): Historical Human or Elf.
    class_id (string): Exact DungeonMMO source-mapped identity.
    expected (any): Independently calculated C4 source values.

Returns:
    nil: Verifies derived combat stats before equipment or skills.
]]
local function check_vector(
    race_id: string, class_id: string, expected: any
)
    local actual, reason = Derived.get_naked_combat(
        race_id, class_id, 30, true
    )
    check(actual ~= nil and reason == nil,
        race_id .. "/" .. class_id .. " source vector exists")
    for key, value in pairs(expected) do
        check(actual[key] == value,
            race_id .. "/" .. class_id .. " " .. key)
    end
    local unarmed = assert(Derived.get_naked_combat(
        race_id, class_id, 30, false
    ))
    check(unarmed.PhysicalCriticalRate == 40,
        "Unarmed player preserves C4 fixed critical source rate")
    check(not actual.EquipmentModifiersApplied
        and not actual.SkillModifiersApplied,
        "Base vector cannot masquerade as fully equipped combat stats")
end

--[[
Runs primary bonuses and four racial starter combat formula vectors.

First-transfer classes share those racial primary/base-combat templates,
while their distinct HP/MP/CP growth was tested separately in v2.44.

Args:
    None.

Returns:
    nil: Prints exact source-only formula validation count.
]]
local function main()
    check_bonus("STR", 40, 1.20)
    check_bonus("STR", 36, 1.04)
    check_bonus("INT", 41, 1.21)
    check_bonus("INT", 37, 1.12)
    check_bonus("CON", 43, 1.58)
    check_bonus("CON", 36, 1.28)
    check_bonus("MEN", 39, 1.48)
    check_bonus("MEN", 40, 1.49)
    check_bonus("DEX", 30, 1.10)
    check_bonus("DEX", 35, 1.15)
    check_bonus("WIT", 20, 1.00)
    check_bonus("WIT", 23, 1.16)
    check(Derived.level_modifier(30) == 1.19,
        "C4 level30 modifier is exactly 1.19")

    check_vector("Human", "Fighter", {
        MaxHP = 922, MaxMP = 319, MaxCP = 418,
        NakedPAtk = 5, NakedPDef = 95,
        NakedMAtk = 5, NakedMDef = 62,
        PhysicalAttackSpeed = 330,
        MagicalAttackSpeed = 213,
        RunSpeed = 126, Accuracy = 63, Evasion = 63,
        PhysicalCriticalRate = 484,
    })
    check_vector("Human", "Mage", {
        MaxHP = 699, MaxMP = 466, MaxCP = 366,
        NakedPAtk = 2, NakedPDef = 64,
        NakedMAtk = 12, NakedMDef = 72,
        PhysicalAttackSpeed = 303,
        MagicalAttackSpeed = 333,
        RunSpeed = 121, Accuracy = 57, Evasion = 57,
        PhysicalCriticalRate = 404,
    })
    check_vector("Elf", "Fighter", {
        MaxHP = 792, MaxMP = 324, MaxCP = 353,
        NakedPAtk = 4, NakedPDef = 95,
        NakedMAtk = 6, NakedMDef = 63,
        PhysicalAttackSpeed = 345,
        MagicalAttackSpeed = 249,
        RunSpeed = 143, Accuracy = 65, Evasion = 65,
        PhysicalCriticalRate = 529,
    })
    check_vector("Elf", "Mage", {
        MaxHP = 666, MaxMP = 469, MaxCP = 348,
        NakedPAtk = 2, NakedPDef = 64,
        NakedMAtk = 10, NakedMDef = 72,
        PhysicalAttackSpeed = 312,
        MagicalAttackSpeed = 386,
        RunSpeed = 126, Accuracy = 59, Evasion = 59,
        PhysicalCriticalRate = 426,
    })

    check(Derived.stat_bonus("Vitality", 5) == nil
        and Derived.level_modifier(0) == nil,
        "Custom Roblox stat names and invalid levels fail closed")

    print(("[C4 Derived Stats] SOURCE_FORMULA_PASS: %d assertions, "
        .. "live=false"):format(checks))
end

main()
