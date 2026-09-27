--!strict
-- Exact C4 XML effect catalogue coverage; no live skill values are changed.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Tree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)

local checks = 0

--[[
Counts one source-effect catalogue assertion.

Args:
    valid (boolean): Expected rank-resolved C4 source condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Skill Effects] " .. label)
end

--[[
Finds a passive modifier by source stat name.

Args:
    rank (any): Rank-resolved C4 source definition.
    stat_name (string): Original source stat identifier.

Returns:
    any?: First matching source modifier.
]]
local function find_modifier(rank: any, stat_name: string): any?
    for _, modifier in ipairs(rank.Modifiers) do
        if modifier.stat == stat_name then
            return modifier
        end
    end
    return nil
end

--[[
Checks every learning-tree skill/rank resolves to pinned XML facts.

Args:
    None.

Returns:
    nil: Every tracked path's exact source ranks are present.
]]
local function check_all_tree_rows()
    for _, scope in ipairs(Tree.coverage().Scopes) do
        local class = assert(Tree.get(scope.ScopeId))
        for _, row in ipairs(class.Rows) do
            local rank = Effects.get_rank(
                row.SkillId, row.SkillLevel
            )
            check(rank ~= nil,
                scope.ScopeId .. " source effect "
                    .. tostring(row.SkillId) .. ":"
                    .. tostring(row.SkillLevel))
        end
    end
end

--[[
Checks representative active, passive, control and utility source fields.

Args:
    None.

Returns:
    nil: Verifies parser resolved source tables at exact skill ranks.
]]
local function check_known_vectors()
    local strike = assert(Effects.get_rank(3, 1))
    check(strike.Sets.mpConsume == 10
        and strike.Sets.power == 25
        and strike.Sets.hitTime == 1080
        and strike.Sets.reuseDelay == 13000
        and strike.Sets.skillType == "PDAM",
        "Power Strike rank1 exact active source fields")

    local stun = assert(Effects.get_rank(100, 3))
    check(stun.Sets.mpConsume == 22
        and stun.Sets.power == 35
        and stun.Sets.effectType == "STUN"
        and stun.Sets.effectPower == 50
        and stun.Sets.saveVs == "CON",
        "Warrior Stun Attack rank3 exact status fields")

    local bow = assert(Effects.get_rank(208, 9))
    local bow_attack = find_modifier(bow, "PHYSICAL_ATTACK")
    check(bow_attack ~= nil
        and bow_attack.Operation == "add"
        and bow_attack.UsingKind == "Bow",
        "Scout Bow Mastery source passive keeps Bow condition")

    local common = assert(Effects.get_rank(1320, 3))
    check(common.Sets.target == "TARGET_SELF"
        and common.Sets.skillType == "DUMMY"
        and common.Sets.operateType == "PASSIVE",
        "Create Common Item rank3 exact passive identity")

    local expertise = assert(Effects.get_rank(239, 1))
    check(expertise.Sets.target == "TARGET_SELF"
        and expertise.Sets.operateType == "PASSIVE",
        "Expertise D rank1 exact passive identity")

    local wizard_blaze = assert(Effects.get_rank(1220, 6))
    check(wizard_blaze.Sets.mpInitialConsume == 6
        and wizard_blaze.Sets.mpConsume == 21
        and wizard_blaze.Sets.power == 38
        and wizard_blaze.Sets.magicLvl == 30
        and wizard_blaze.Sets.element == "FIRE"
        and wizard_blaze.Sets.skillType == "MDAM",
        "Human Wizard Blaze rank6 exact source fields")

    local wizard_sleep = assert(Effects.get_rank(1069, 6))
    check(wizard_sleep.Sets.mpInitialConsume == 6
        and wizard_sleep.Sets.mpConsume == 21
        and wizard_sleep.Sets.magicLvl == 30
        and wizard_sleep.Sets.effectType == "SLEEP"
        and wizard_sleep.Effects[1].abnormal == "SLEEP"
        and wizard_sleep.Effects[1].time == 30,
        "Human Wizard Sleep rank6 exact source control fields")

    local wizard_servitor = assert(Effects.get_rank(1127, 9))
    check(wizard_servitor.Sets.target == "TARGET_PET"
        and wizard_servitor.Sets.mpInitialConsume == 9
        and wizard_servitor.Sets.mpConsume == 35
        and wizard_servitor.Effects[1].power == 294,
        "Human Wizard Servitor Heal rank9 exact source fields")

    local cleric_heal = assert(Effects.get_rank(1011, 15))
    check(cleric_heal.Sets.mpInitialConsume == 9
        and cleric_heal.Sets.mpConsume == 35
        and cleric_heal.Effects[1].power == 245
        and cleric_heal.Sets.target == "TARGET_ONE",
        "Human Cleric Heal rank15 exact source fields")

    local cleric_root = assert(Effects.get_rank(1201, 6))
    check(cleric_root.Sets.mpInitialConsume == 6
        and cleric_root.Sets.mpConsume == 21
        and cleric_root.Sets.magicLvl == 30
        and cleric_root.Sets.effectPower == 80
        and cleric_root.Effects[1].name == "Root"
        and cleric_root.Effects[1].time == 30
        and cleric_root.Effects[1].abnormal == "ROOT",
        "Human Cleric Dryad Root rank6 exact source fields")

    local cleric_robe = assert(Effects.get_rank(235, 6))
    local cleric_robe_defence =
        find_modifier(cleric_robe, "PHYSICAL_DEFENCE")
    check(cleric_robe_defence ~= nil
        and cleric_robe_defence.val == 17.4
        and cleric_robe_defence.UsingKind == "Magic",
        "Human Cleric Robe Mastery rank6 keeps Magic gear condition")

    local dark_twister = assert(Effects.get_rank(1178, 6))
    check(dark_twister.Sets.mpInitialConsume == 6
        and dark_twister.Sets.mpConsume == 21
        and dark_twister.Sets.magicLvl == 30
        and dark_twister.Sets.power == 38
        and dark_twister.Sets.element == "WIND"
        and dark_twister.Sets.skillType == "MDAM",
        "Dark Wizard Twister rank6 exact source fields")

    local dark_shadow = assert(Effects.get_rank(1128, 3))
    check(dark_shadow.Sets.target == "TARGET_SELF"
        and dark_shadow.Sets.npcId == 12071
        and dark_shadow.Sets.itemConsumeCount == 1
        and dark_shadow.Sets.itemConsumeCountOT == 1
        and dark_shadow.Sets.reuseDelay == 21600000
        and dark_shadow.Sets.skillType == "SUMMON",
        "Dark Wizard Shadow summon rank3 exact source fields")

    local poison_surrender = assert(Effects.get_rank(1224, 2))
    check(poison_surrender.Sets.magicLvl == 30
        and poison_surrender.Sets.effectPower == 80
        and poison_surrender.Sets.saveVs == "MEN"
        and poison_surrender.Effects[1].Modifiers[1].stat
            == "POISON_VULN"
        and poison_surrender.Effects[1].Modifiers[1].val == 1.25,
        "Dark Wizard poison surrender rank2 exact source debuff")

    local dusk_empower = assert(Effects.get_rank(1059, 1))
    check(
        dusk_empower.Sets.mpInitialConsume == 5
            and dusk_empower.Sets.mpConsume == 18
            and dusk_empower.Sets.skillType == "BUFF"
            and dusk_empower.Sets.target == "TARGET_ONE"
            and dusk_empower.Effects[1].time == 1200
            and dusk_empower.Effects[1].Modifiers[1].Operation
                == "mul"
            and dusk_empower.Effects[1].Modifiers[1].stat
                == "MAGICAL_ATTACK"
            and dusk_empower.Effects[1].Modifiers[1].val == 1.55,
        "Shillien Oracle Empower rank one preserves exact source buff"
    )

    local dusk_blood = assert(Effects.get_rank(1268, 1))
    check(
        dusk_blood.Sets.mpInitialConsume == 6
            and dusk_blood.Sets.mpConsume == 21
            and dusk_blood.Sets.skillType == "BUFF"
            and dusk_blood.Effects[1].time == 1200
            and dusk_blood.Effects[1].Modifiers[1].Operation
                == "add"
            and dusk_blood.Effects[1].Modifiers[1].stat
                == "ABSORB_DAMAGE_PERCENT"
            and dusk_blood.Effects[1].Modifiers[1].val == 6,
        "Shillien Oracle Vampiric Rage rank one preserves six percent"
    )

    local orc_punch = assert(Effects.get_rank(29, 9))
    check(
        orc_punch.Sets.mpConsume == 22
            and orc_punch.Sets.magicLvl == 14
            and orc_punch.Sets.power == 82
            and orc_punch.Sets.hitTime == 1604
            and orc_punch.Sets.coolTime == 296
            and orc_punch.Sets.reuseDelay == 15000
            and orc_punch.Sets.skillType == "PDAM"
            and orc_punch.Conditions[1].kind == "Fist, Dual Fist",
        "Orc Fighter Iron Punch rank nine preserves exact source fields"
    )

    local orc_toughness = assert(Effects.get_rank(134, 1))
    check(
        #orc_toughness.Modifiers == 3
            and orc_toughness.Modifiers[1].stat == "ROOT_VULN"
            and orc_toughness.Modifiers[1].val == 0.8
            and orc_toughness.Modifiers[2].stat == "SLEEP_VULN"
            and orc_toughness.Modifiers[2].val == 0.8
            and orc_toughness.Modifiers[3].stat == "POISON_VULN"
            and orc_toughness.Modifiers[3].val == 0.8,
        "Orc Fighter Toughness preserves three exact vulnerability modifiers"
    )

    local orc_body = assert(Effects.get_rank(295, 1))
    check(
        #orc_body.Modifiers == 1
            and orc_body.Modifiers[1].stat == "FALL"
            and orc_body.Modifiers[1].val == 0.6,
        "Orc Fighter Iron Body preserves exact fall modifier"
    )

    local raider_bandage = assert(Effects.get_rank(34, 1))
    check(
        raider_bandage.Sets.mpConsume == 20
            and raider_bandage.Sets.magicLvl == 20
            and raider_bandage.Sets.effectPower == 30
            and raider_bandage.Sets.negateStats == "BLEED"
            and raider_bandage.Sets.reuseDelay == 3000
            and raider_bandage.Effects[1].name == "NegateEffect",
        "Orc Raider Bandage rank one preserves exact bleed cure fields"
    )

    local raider_rage = assert(Effects.get_rank(94, 1))
    check(
        raider_rage.Sets.mpConsume == 11
            and raider_rage.Sets.reuseDelay == 300000
            and raider_rage.Effects[1].time == 60
            and raider_rage.Effects[1].stackType == "pAtks"
            and raider_rage.Effects[1].Modifiers[1].val == 1.45
            and raider_rage.Effects[1].Modifiers[2].val == 0.8
            and raider_rage.Effects[1].Modifiers[3].val == 3,
        "Orc Raider Rage rank one preserves exact source tradeoffs"
    )

    local raider_two_hand = assert(Effects.get_rank(293, 3))
    check(
        #raider_two_hand.Modifiers == 2
            and raider_two_hand.Modifiers[1].stat == "PHYSICAL_ATTACK"
            and raider_two_hand.Modifiers[1].val == 10.7
            and raider_two_hand.Modifiers[1].UsingKind
                == "Big Sword,Big Blunt"
            and raider_two_hand.Modifiers[2].stat == "ACCURACY_COMBAT"
            and raider_two_hand.Modifiers[2].val == 3,
        "Orc Raider two-handed mastery rank three is source exact"
    )

    local monk_force = assert(Effects.get_rank(54, 6))
    check(
        monk_force.Sets.mpConsume == 24
            and monk_force.Sets.magicLvl == 28
            and monk_force.Sets.power == 222
            and monk_force.Sets.num_charges == 1
            and monk_force.Sets.skillType == "CHARGEDAM"
            and monk_force.Conditions[1].kind == "Fist, Dual Fist",
        "Orc Monk Force Blaster rank six preserves exact source fields"
    )

    local monk_cripple = assert(Effects.get_rank(95, 3))
    check(
        monk_cripple.Sets.mpConsume == 25
            and monk_cripple.Sets.magicLvl == 28
            and monk_cripple.Sets.effectPower == 80
            and monk_cripple.Sets.saveVs == "WIT"
            and monk_cripple.Effects[1].time == 120
            and monk_cripple.Effects[1].Modifiers[1].stat == "RUN_SPEED"
            and monk_cripple.Effects[1].Modifiers[1].val == 0.7,
        "Orc Monk Cripple rank three preserves exact slow contract"
    )

    local monk_stun = assert(Effects.get_rank(120, 9))
    check(
        monk_stun.Sets.mpConsume == 30
            and monk_stun.Sets.magicLvl == 28
            and monk_stun.Sets.power == 80
            and monk_stun.Sets.effectPower == 50
            and monk_stun.Sets.saveVs == "CON"
            and monk_stun.Effects[1].abnormal == "STUN"
            and monk_stun.Effects[1].time == 9,
        "Orc Monk Stunning Fist rank nine preserves exact stun contract"
    )

    local shaman_weapon = assert(Effects.get_rank(250, 7))
    check(
        shaman_weapon.Modifiers[1].val == 9.5
            and shaman_weapon.Modifiers[2].val == 11.9
            and shaman_weapon.Modifiers[3].val == 1.45
            and shaman_weapon.Modifiers[4].val == 1.17,
        "Orc Shaman Weapon Mastery rank seven is source exact"
    )

    local shaman_sleep = assert(Effects.get_rank(1097, 5))
    check(
        shaman_sleep.Sets.magicLvl == 30
            and shaman_sleep.Sets.mpInitialConsume == 6
            and shaman_sleep.Sets.mpConsume == 21
            and shaman_sleep.Effects[1].abnormal == "SLEEP"
            and shaman_sleep.Effects[1].time == 30,
        "Orc Shaman Dreaming Spirit rank five is source exact"
    )

    local shaman_life = assert(Effects.get_rank(1229, 3))
    check(
        shaman_life.Sets.magicLvl == 30
            and shaman_life.Sets.mpInitialConsume == 18
            and shaman_life.Sets.mpConsume == 70
            and shaman_life.Effects[1].name == "HealOverTime"
            and shaman_life.Effects[1].val == 18,
        "Orc Shaman Chant of Life rank three is source exact"
    )

    local heal = assert(Effects.get_rank(58, 4))
    check(heal.Sets.mpInitialConsume == 11
        and heal.Sets.mpConsume == 42
        and heal.Sets.mpInitialConsume + heal.Sets.mpConsume == 53
        and heal.Effects[1].power == 95,
        "Elemental Heal rank4 exact split MP and heal power")
end

--[[
Runs source XML coverage for the whole current original class catalogue.

Args:
    None.

Returns:
    nil: Prints effect-source coverage, never live effect parity.
]]
local function main()
    check_all_tree_rows()
    check_known_vectors()
    local coverage = Effects.coverage()
    check(coverage.SkillCount == 170
        and coverage.RequiredSkillRankPairs == 648
        and not coverage.LiveCombatIntegrated,
        "All twenty-three-path source skill/rank definitions are catalogued")
    print(("[C4 Skill Effects] EXACT_SOURCE_PASS: %d assertions, "
        .. "skills=170 uniqueRankPairs=648 live=false")
        :format(checks))
end

main()
