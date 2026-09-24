--!strict
-- Whole-current-original-class read-only HP/MP/CP and passive vectors.
local Shared = game:GetService("ReplicatedStorage").Core.Shared
local C4 = require(Shared.C4UnifiedStatReference)

local checks = 0

--[[
Counts an exact source-only assertion rather than a live-combat pass.

Args:
    condition (boolean): One verified original class-source condition.
    label (string): Diagnostic for an unexpected source-stat result.

Returns:
    nil: Increments checks or raises an explicit failure.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Unified Stats] " .. label)
end

--[[
Checks all nine separate source templates at the level-30 launch cap.

Args:
    None.

Returns:
    nil: Confirms exact archived HP, MP and CP across all nine paths.
]]
local function check_nine_class_vitals()
    local vectors = {
        {"Human", "Fighter", 922, 319, 418},
        {"Human", "Mage", 699, 466, 366},
        {"Elf", "Fighter", 792, 324, 353},
        {"Elf", "Mage", 666, 469, 348},
        {"Human", "Ironvow", 1070, 320, 849},
        {"Human", "Oathguard", 1018, 320, 610},
        {"Human", "Ashenblade", 983, 320, 399},
        {"Elf", "GreenwardWarden", 902, 325, 453},
        {"Elf", "GreenwardScout", 874, 325, 354},
    }
    for _, vector in ipairs(vectors) do
        local result, issue = C4.get(
            vector[1], vector[2], 30, {}, {}
        )
        check(result ~= nil and issue == nil,
            vector[2] .. " source stat snapshot exists")
        check(result.Naked.MaxHP == vector[3]
            and result.Naked.MaxMP == vector[4]
            and result.Naked.MaxCP == vector[5],
            vector[2] .. " actual C4 level-30 HP/MP/CP")
        check(result.PassiveStatSnapshot.PHYSICAL_DEFENCE
                == result.Naked.NakedPDef
            and not result.ExactFinalC4StatsCertified
            and not result.LiveCombatIntegrated,
            vector[2] .. " source-only results are not live stats")
    end
end

--[[
Verifies real source passives share one loadout across weapon and body.

Args:
    None.

Returns:
    nil: Prevents weapon/body borrowing, cross-class and late-rank gain.
]]
local function check_equipment_and_class_gates()
    local knight = assert(C4.get("Human", "Oathguard", 30,
        {Weapon = "Sword", Body = "Heavy"}, {
            {SkillId = 232, Rank = 1},
        }))
    check(knight.PassiveStatSnapshot.PHYSICAL_DEFENCE
            == knight.Naked.NakedPDef + 17.7,
        "Heavy mastery adds source P.Def on correctly equipped Knight")
    local scout = assert(C4.get("Elf", "GreenwardScout", 30,
        {Weapon = "Bow", Body = "Light"}, {
            {SkillId = 208, Rank = 1},
            {SkillId = 233, Rank = 1},
        }))
    check(scout.AppliedSourceModifiers >= 2
        and scout.PassiveStatSnapshot.PHYSICAL_ATTACK
            > scout.Naked.NakedPAtk
        and scout.PassiveStatSnapshot.EVASION_RATE
            > scout.Naked.Evasion,
        "Bow and Light passive modifiers apply in one original order")
    local wrong = assert(C4.get("Elf", "GreenwardScout", 30,
        {Weapon = "Dagger", Body = "Heavy"}, {
            {SkillId = 208, Rank = 1},
            {SkillId = 233, Rank = 1},
        }))
    check(wrong.AppliedSourceModifiers == 0,
        "Borrowed Bow/Light bonuses do not apply to Dagger/Heavy")
    local _, borrowed = C4.get("Human", "Oathguard", 30,
        {Weapon = "Bow"}, {{SkillId = 208, Rank = 1}})
    check(borrowed == "OriginalPassiveNotLearnableByClassOrLevel",
        "Human Knight cannot borrow Elf Scout Bow Mastery")
    local _, early = C4.get("Elf", "GreenwardScout", 20,
        {Weapon = "Bow"}, {{SkillId = 208, Rank = 9}})
    check(early == "OriginalPassiveNotLearnableByClassOrLevel",
        "Level-20 player cannot borrow level-28 mastery ranks")
    local _, invalid = C4.get("Elf", "GreenwardScout", 30,
        {Weapon = "Bow", Bonus = "Heavy"}, {})
    check(invalid == "InvalidOriginalEquipmentLoadout",
        "Unrecognised source-equipment slots fail closed")
end

--[[
Executes complete nine-class source-only stat and loadout acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only check count upon success.
]]
local function main()
    check_nine_class_vitals()
    check_equipment_and_class_gates()
    print(("[C4 Unified Stats] SOURCE_ONLY_PASS: %d assertions "
        .. "nine_paths=9 live=false"):format(checks))
end

main()
