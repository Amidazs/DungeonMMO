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
Checks the tracked source templates at the level-30 launch cap.

Args:
    None.

Returns:
    nil: Confirms exact archived HP, MP and CP across all tracked paths.
]]
local function check_all_class_vitals()
    local vectors = {
        {"Human", "Fighter", 922, 319, 418},
        {"Human", "Mage", 699, 466, 366},
        {"Elf", "Fighter", 792, 324, 353},
        {"Elf", "Mage", 666, 469, 348},
        {"Human", "Ironvow", 1070, 320, 849},
        {"Human", "Oathguard", 1018, 320, 610},
        {"Human", "Ashenblade", 983, 320, 399},
        {"Human", "Emberweaver", 705, 492, 355},
        {"Human", "Dawnkeeper", 770, 492, 387},
        {"Elf", "Moonweaver", 682, 495, 343},
        {"Elf", "Lifebinder", 744, 495, 374},
        {"Elf", "GreenwardWarden", 902, 325, 453},
        {"Elf", "GreenwardScout", 874, 325, 354},
        {"DarkElf", "Duskguard", 856, 325, 430},
        {"DarkElf", "Veilblade", 831, 325, 337},
        {"DarkElf", "Nightweaver", 672, 482, 338},
        {"DarkElf", "Duskseer", 732, 482, 368},
        {"Orc", "Fighter", 1075, 322, 562},
        {"Orc", "Warhowl", 1269, 327, 884},
        {"Orc", "Spiritclaw", 1230, 327, 617},
        {"Dwarf", "Fighter", 1014, 322, 680},
        {"Dwarf", "Gearwright", 1161, 327, 921},
        {"Dwarf", "Deepclaimer", 1197, 327, 834},
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
        {Weapon = "Sword", Body = "Heavy", Legs = "Heavy"}, {
            {SkillId = 232, Rank = 1},
        }))
    local heavy_expected = knight.Naked.NakedPDef + 17.7
    local heavy_actual =
        knight.PassiveStatSnapshot.PHYSICAL_DEFENCE
    check(
        math.abs(heavy_actual - heavy_expected) < 0.000001,
        (
            "Heavy mastery source P.Def expected %.6f, got %.6f"
        ):format(heavy_expected, heavy_actual)
    )
    local scout = assert(C4.get("Elf", "GreenwardScout", 30,
        {Weapon = "Bow", Body = "Light", Legs = "Light"}, {
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
    local _, false_body = C4.get("Human", "Oathguard", 30,
        {Weapon = "Heavy"}, {{SkillId = 232, Rank = 1}})
    check(false_body == "InvalidOriginalEquipmentLoadout",
        "Weapon slot cannot impersonate source heavy armour")
    local _, false_weapon = C4.get("Elf", "GreenwardScout", 30,
        {Body = "Bow"}, {{SkillId = 208, Rank = 1}})
    check(false_weapon == "InvalidOriginalEquipmentLoadout",
        "Armour slot cannot impersonate a C4 bow")
end

--[[
Checks the C4 class-fist fallback keeps naked stats while retaining Fist kind.

Args:
    None.

Returns:
    nil: Confirms source item 248 is identity-only for stat staging.
]]
local function check_orc_virtual_fist()
    local result = assert(C4.get_with_source_items(
        "Orc",
        "Fighter",
        30,
        {Weapon = 248},
        {}
    ))

    check(
        result.ScopeId == "OrcFighter"
            and result.SourceItemIds.Weapon == 248
            and result.SourceKinds.Weapon == "Fist"
            and result.Naked.WeaponCriticalFormulaApplied == false,
        "Orc class fist stays a virtual Fist source identity"
    )
    check(
        result.EquippedStats.PHYSICAL_ATTACK == 5
            and result.EquippedStats.MAGICAL_ATTACK == 5
            and result.EquippedStats.PHYSICAL_ATTACK_SPEED == 318
            and result.EquippedStats.CRITICAL_RATE == 40
            and result.EquippedStats.ACCURACY_COMBAT == 61,
        "virtual Orc fist preserves exact naked C4 combat stats"
    )
end

--[[
Checks exact Human Wizard Quick Recovery reuse multipliers.

Args:
    None.

Returns:
    nil: Confirms neutral reuse 1 receives source rank-one/two multipliers.
]]
local function check_human_wizard_reuse()
    local neutral = assert(C4.get(
        "Human",
        "Emberweaver",
        30,
        {},
        {}
    ))
    check(
        neutral.PassiveStatSnapshot.MAGICAL_SKILL_REUSE == 1
            and neutral.PassiveStatSnapshot.SKILL_MASTERY == 0,
        "Human Wizard source reuse and mastery start at exact neutral values"
    )

    local first = assert(C4.get(
        "Human",
        "Emberweaver",
        20,
        {},
        {{SkillId = 164, Rank = 1}}
    ))
    check(
        first.PassiveStatSnapshot.MAGICAL_SKILL_REUSE == 0.8,
        "Quick Recovery rank one multiplies magical reuse by 0.8"
    )

    local second = assert(C4.get(
        "Human",
        "Emberweaver",
        30,
        {},
        {{SkillId = 164, Rank = 2}}
    ))
    check(
        second.PassiveStatSnapshot.MAGICAL_SKILL_REUSE == 0.75,
        "Quick Recovery rank two multiplies magical reuse by 0.75"
    )

    local _, early = C4.get(
        "Human",
        "Emberweaver",
        20,
        {},
        {{SkillId = 164, Rank = 2}}
    )
    check(
        early == "OriginalPassiveNotLearnableByClassOrLevel",
        "level twenty cannot borrow level-thirty Quick Recovery rank two"
    )
end

--[[
Checks all eight true Nightweaver passive families in calculator order.

Args:
    None.

Returns:
    nil: Confirms exact level-30 Dark Wizard passive stat output.
]]
local function check_nightweaver_passives()
    local result = assert(C4.get(
        "DarkElf",
        "Nightweaver",
        30,
        {},
        {
            {SkillId = 146, Rank = 10},
            {SkillId = 164, Rank = 2},
            {SkillId = 213, Rank = 2},
            {SkillId = 234, Rank = 6},
            {SkillId = 249, Rank = 7},
            {SkillId = 285, Rank = 6},
            {SkillId = 228, Rank = 1},
            {SkillId = 229, Rank = 1},
        }
    ))

    local stats = result.PassiveStatSnapshot
    check(
        result.ScopeId == "DarkWizard"
            and result.AppliedSourceModifiers == 10
            and stats.MAGICAL_DEFENCE == 100
            and stats.MAGICAL_SKILL_REUSE == 0.75
            and stats.MAX_MP == 532
            and stats.RECHARGE_MP_RATE == 33,
        "Nightweaver passives preserve exact defence, reuse and mana effects"
    )
    check(
        math.abs(stats.MAGICAL_ATTACK_SPEED - 331.8) < 0.000001
            and math.abs(stats.REG_MP_RATE - 3.68825) < 0.000001
            and stats.MAGICAL_ATTACK == 27.11
            and stats.PHYSICAL_ATTACK == 12.4,
        "Nightweaver casting, recovery and focus modifiers stay source exact"
    )
end

--[[
Checks all eight true Duskseer passive families in calculator order.

Args:
    None.

Returns:
    nil: Confirms exact level-30 Shillien Oracle passive stat output.
]]
local function check_duskseer_passives()
    local result = assert(C4.get(
        "DarkElf",
        "Duskseer",
        30,
        {},
        {
            {SkillId = 146, Rank = 10},
            {SkillId = 164, Rank = 2},
            {SkillId = 213, Rank = 2},
            {SkillId = 228, Rank = 1},
            {SkillId = 229, Rank = 1},
            {SkillId = 235, Rank = 6},
            {SkillId = 236, Rank = 6},
            {SkillId = 249, Rank = 7},
        }
    ))

    local stats = result.PassiveStatSnapshot
    check(
        result.ScopeId == "ShillienOracle"
            and result.AppliedSourceModifiers == 9
            and stats.MAGICAL_DEFENCE == 100
            and stats.MAGICAL_SKILL_REUSE == 0.75
            and stats.MAX_MP == 532
            and stats.RECHARGE_MP_RATE == 1,
        "Duskseer passives preserve exact defence, reuse and mana effects"
    )
    check(
        math.abs(stats.MAGICAL_ATTACK_SPEED - 331.8) < 0.000001
            and math.abs(stats.REG_MP_RATE - 3.68825) < 0.000001
            and stats.MAGICAL_ATTACK == 27.11
            and stats.PHYSICAL_ATTACK == 12.4,
        "Duskseer casting, recovery and weapon modifiers stay source exact"
    )
end

--[[
Checks Duskseer Empower and Blood Rite share active calculator ordering.

Args:
    None.

Returns:
    nil: Confirms exact class-42 magic power and melee absorption modifiers.
]]
local function check_duskseer_unique_active_buffs()
    local result = assert(C4.get_with_source_effects(
        "DarkElf",
        "Duskseer",
        30,
        {},
        {
            {SkillId = 146, Rank = 10},
            {SkillId = 164, Rank = 2},
            {SkillId = 213, Rank = 2},
            {SkillId = 228, Rank = 1},
            {SkillId = 229, Rank = 1},
            {SkillId = 235, Rank = 6},
            {SkillId = 236, Rank = 6},
            {SkillId = 249, Rank = 7},
        },
        {
            {SkillId = 1059, Rank = 1},
            {SkillId = 1268, Rank = 1},
        }
    ))

    local first = assert(result.SelectedActiveEffects[1])
    local second = assert(result.SelectedActiveEffects[2])
    check(
        result.ScopeId == "ShillienOracle"
            and result.AppliedSourceModifiers == 11
            and math.abs(
                result.EquippedStats.MAGICAL_ATTACK - 35.4755
            ) < 0.000001
            and result.EquippedStats.ABSORB_DAMAGE_PERCENT == 6,
        "Duskseer unique active buffs preserve exact combined stats"
    )
    check(
        first.SkillId == 1059
            and first.Rank == 1
            and first.StackType == "mAtk"
            and first.StackOrder == 1.55
            and second.SkillId == 1268
            and second.Rank == 1
            and second.StackType == "vampRage"
            and second.StackOrder == 6,
        "Duskseer Empower and Blood Rite preserve source stack identities"
    )
end

--[[
Checks Warhowl inherits Orc Fighter passives before Raider passives.

Args:
    None.

Returns:
    nil: Confirms exact class-44/class-45 source passive composition.
]]
local function check_warhowl_inherited_passives()
    local result = assert(C4.get(
        "Orc",
        "Warhowl",
        30,
        {Weapon = "Blunt"},
        {
            {SkillId = 134, Rank = 1},
            {SkillId = 141, Rank = 3},
            {SkillId = 142, Rank = 5},
            {SkillId = 148, Rank = 1},
            {SkillId = 211, Rank = 2},
            {SkillId = 212, Rank = 1},
            {SkillId = 216, Rank = 4},
            {SkillId = 227, Rank = 7},
            {SkillId = 231, Rank = 7},
            {SkillId = 257, Rank = 4},
            {SkillId = 293, Rank = 3},
            {SkillId = 295, Rank = 1},
        }
    ))

    local stats = result.PassiveStatSnapshot
    check(
        result.ScopeId == "OrcRaider"
            and result.AppliedSourceModifiers == 12
            and stats.MAX_HP == 1369
            and stats.PHYSICAL_DEFENCE == 109
            and math.abs(stats.PHYSICAL_ATTACK - 20.125) < 0.000001,
        "Warhowl composes inherited Orc Fighter and Raider passives"
    )
    check(
        stats.ROOT_VULN == 0.8
            and stats.SLEEP_VULN == 0.8
            and stats.POISON_VULN == 0.8
            and stats.FALL == 0.6,
        "Toughness and Iron Body preserve exact source multipliers"
    )
end

--[[
Checks Spiritclaw inherits Orc Fighter passives before Monk passives.

Args:
    None.

Returns:
    nil: Confirms exact class-44/class-47 passive stat composition.
]]
local function check_spiritclaw_inherited_passives()
    local result = assert(C4.get(
        "Orc",
        "Spiritclaw",
        30,
        {Weapon = "Fist", Body = "Light", Legs = "Light"},
        {
            {SkillId = 134, Rank = 1},
            {SkillId = 141, Rank = 3},
            {SkillId = 142, Rank = 5},
            {SkillId = 295, Rank = 1},
            {SkillId = 210, Rank = 4},
            {SkillId = 233, Rank = 6},
            {SkillId = 319, Rank = 1},
        }
    ))

    local stats = result.PassiveStatSnapshot
    check(
        result.ScopeId == "OrcMonk"
            and result.AppliedSourceModifiers == 13
            and math.abs(stats.PHYSICAL_ATTACK - 20.125) < 0.000001
            and math.abs(stats.PHYSICAL_DEFENCE - 115.8) < 0.000001
            and stats.ACCURACY_COMBAT == 63
            and stats.EVASION_RATE == 71
            and stats.RUN_SPEED == 129,
        "Spiritclaw composes inherited Orc Fighter and Monk passives"
    )
    check(
        stats.ROOT_VULN == 0.8
            and stats.SLEEP_VULN == 0.8
            and stats.POISON_VULN == 0.8
            and stats.FALL == 0.6,
        "Spiritclaw retains exact Toughness and Iron Body multipliers"
    )
end


--[[
Checks both Dwarf careers inherit Dwarven Fighter weapon mastery.

Args:
    None.

Returns:
    nil: Confirms starter and first-transfer source passives compose together.
]]
local function check_dwarf_inherited_passives()
    for _, class_id in ipairs({"Gearwright", "Deepclaimer"}) do
        local result = assert(C4.get(
            "Dwarf",
            class_id,
            30,
            {Weapon = "Blunt"},
            {
                {SkillId = 141, Rank = 3},
                {SkillId = 205, Rank = 4},
            }
        ))

        check(
            result.AppliedSourceModifiers == 2
                and result.PassiveStatSnapshot.PHYSICAL_ATTACK
                    > result.Naked.NakedPAtk,
            class_id
                .. " composes Dwarven Fighter and branch Blunt mastery"
        )
    end
end

--[[
Checks Concentration contributes its dynamic attack-cancel offset.

Args:
    None.

Returns:
    nil: Confirms active source rank 1078:2 produces a signed -25 offset.
]]
local function check_concentration_attack_cancel_offset()
    local result = assert(C4.get_with_source_effects(
        "DarkElf",
        "Nightweaver",
        30,
        {},
        {
            {SkillId = 146, Rank = 10},
            {SkillId = 164, Rank = 2},
            {SkillId = 213, Rank = 2},
            {SkillId = 234, Rank = 6},
            {SkillId = 249, Rank = 7},
            {SkillId = 285, Rank = 6},
            {SkillId = 228, Rank = 1},
            {SkillId = 229, Rank = 1},
        },
        {
            {SkillId = 1078, Rank = 2},
        }
    ))

    local selected = assert(result.SelectedActiveEffects[1])
    check(
        result.EquippedStats.ATTACK_CANCEL_RATE == -25
            and result.AppliedSourceModifiers == 11
            and selected.SkillId == 1078
            and selected.Rank == 2
            and selected.StackType == "Concentration"
            and selected.StackOrder == 25,
        "Concentration rank two contributes exact -25 attack-cancel offset"
    )
end

--[[
Executes tracked source-only stat and loadout acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only check count upon success.
]]
local function main()
    check_all_class_vitals()
    check_equipment_and_class_gates()
    check_orc_virtual_fist()
    check_human_wizard_reuse()
    check_nightweaver_passives()
    check_duskseer_passives()
    check_duskseer_unique_active_buffs()
    check_warhowl_inherited_passives()
    check_spiritclaw_inherited_passives()
    check_dwarf_inherited_passives()
    check_concentration_attack_cancel_offset()
    print(("[C4 Unified Stats] SOURCE_ONLY_PASS: %d assertions "
        .. "paths=23 live=false"):format(checks))
end

main()
