--!strict
-- Whole tracked C4 learning-tree source regression through level 30.
local RS = game:GetService("ReplicatedStorage")
local Source = require(
    RS.Core.Shared.C4Level30SkillTreeSource
)

local checks = 0

--[[
Counts one C4 learning-tree source assertion.

Args:
    valid (boolean): Expected exact row/source contract.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Skill Tree] " .. label)
end

--[[
Checks one exact source scope count and row validity.

Args:
    scope_id (string): One supported original path.
    expected_rows (number): Independently counted level<=30 rows.

Returns:
    nil: Ensures every source row is bounded and complete.
]]
local function check_scope(
    scope_id: string, expected_rows: number
)
    local source = assert(Source.get(scope_id))
    check(#source.Rows == expected_rows,
        scope_id .. " exact source learning-row count")
    for _, row in ipairs(source.Rows) do
        check(type(row.SkillId) == "number"
            and row.SkillId > 0
            and type(row.SkillLevel) == "number"
            and row.SkillLevel > 0
            and type(row.SkillName) == "string"
            and row.SkillName ~= ""
            and row.SP >= 0
            and row.MinLevel >= 1
            and row.MinLevel <= 30,
            scope_id .. " valid source row " .. row.SkillName)
    end
end

--[[
Runs all starter and first-transfer learning-tree source checks.

Args:
    None.

Returns:
    nil: Prints exact tracked-path source totals, not live trainer parity.
]]
local function main()
    check_scope("HumanFighter", 39)
    check_scope("HumanMystic", 44)
    check_scope("HumanWizard", 93)
    check_scope("HumanCleric", 88)
    check_scope("ElvenFighter", 43)
    check_scope("ElvenMystic", 42)
    check_scope("OrcFighter", 31)
    check_scope("OrcMystic", 35)
    check_scope("OrcRaider", 63)
    check_scope("OrcMonk", 41)
    check_scope("OrcShaman", 77)
    check_scope("ElvenWizard", 82)
    check_scope("ElvenOracle", 91)
    check_scope("PalusKnight", 50)
    check_scope("DarkWizard", 86)
    check_scope("ShillienOracle", 92)
    check_scope("HumanWarrior", 62)
    check_scope("HumanKnight", 54)
    check_scope("HumanRogue", 59)
    check_scope("ElvenKnight", 56)
    check_scope("ElvenScout", 77)

    local coverage = Source.coverage()
    check(coverage.PathCount == 23
        and coverage.RowCount == 1370
        and coverage.UniqueSourceSkillIds == 170
        and coverage.LevelCap == 30
        and not coverage.LiveTrainerIntegrated,
        "All twenty-one tracked original paths have exact source learning rows")

    local power_strike = Source.find_skill("HumanFighter", 3)
    check(#power_strike == 9
        and power_strike[1].SkillLevel == 1
        and power_strike[1].SP == 50
        and power_strike[1].MinLevel == 5
        and power_strike[9].SkillLevel == 9
        and power_strike[9].MinLevel == 15,
        "Human Fighter Power Strike source ranks 1-9")

    local orc_punch = Source.find_skill("OrcFighter", 29)
    check(
        #orc_punch == 9
            and orc_punch[1].SkillLevel == 1
            and orc_punch[1].SP == 60
            and orc_punch[1].MinLevel == 5
            and orc_punch[9].SkillLevel == 9
            and orc_punch[9].SP == 1300
            and orc_punch[9].MinLevel == 15,
        "Orc Fighter Iron Punch source ranks 1-9"
    )

    local orc_toughness = Source.find_skill("OrcFighter", 134)
    local orc_iron_body = Source.find_skill("OrcFighter", 295)
    check(
        #orc_toughness == 1
            and orc_toughness[1].SkillLevel == 1
            and orc_toughness[1].MinLevel == 1
            and #orc_iron_body == 1
            and orc_iron_body[1].SkillLevel == 1
            and orc_iron_body[1].MinLevel == 15,
        "Orc Fighter passive source entry levels remain exact"
    )

    local raider_stun = Source.find_skill("OrcRaider", 100)
    check(
        #raider_stun == 9
            and raider_stun[1].SkillLevel == 1
            and raider_stun[1].MinLevel == 20
            and raider_stun[9].SkillLevel == 9
            and raider_stun[9].MinLevel == 28,
        "Orc Raider Stun Attack source ranks 1-9 preserve brackets"
    )

    local raider_rage = Source.find_skill("OrcRaider", 94)
    local raider_great = Source.find_skill("OrcRaider", 293)
    check(
        #raider_rage == 1
            and raider_rage[1].SkillLevel == 1
            and raider_rage[1].MinLevel == 24
            and #raider_great == 3
            and raider_great[1].MinLevel == 20
            and raider_great[2].MinLevel == 24
            and raider_great[3].MinLevel == 28,
        "Orc Raider unique Rage and great-weapon brackets stay exact"
    )

    local monk_punch = Source.find_skill("OrcMonk", 29)
    check(
        #monk_punch == 9
            and monk_punch[1].SkillLevel == 10
            and monk_punch[1].SP == 2600
            and monk_punch[1].MinLevel == 20
            and monk_punch[9].SkillLevel == 18
            and monk_punch[9].SP == 5700
            and monk_punch[9].MinLevel == 28,
        "Orc Monk inherited Iron Punch ranks 10-18 preserve brackets"
    )

    local monk_force = Source.find_skill("OrcMonk", 54)
    check(
        #monk_force == 6
            and monk_force[1].SkillLevel == 1
            and monk_force[1].SP == 3300
            and monk_force[1].MinLevel == 24
            and monk_force[6].SkillLevel == 6
            and monk_force[6].SP == 5700
            and monk_force[6].MinLevel == 28,
        "Orc Monk Force Blaster ranks 1-6 preserve source SP/levels"
    )

    local orc_mystic_drain =
        Source.find_skill("OrcMystic", 1090)
    check(
        #orc_mystic_drain == 2
            and orc_mystic_drain[1].SkillLevel == 1
            and orc_mystic_drain[1].MinLevel == 7
            and orc_mystic_drain[2].SkillLevel == 2
            and orc_mystic_drain[2].MinLevel == 14,
        "Orc Mystic Life Drain inheritance preserves exact ranks"
    )

    local shaman_stun = Source.find_skill("OrcShaman", 100)
    check(
        #shaman_stun == 9
            and shaman_stun[1].SkillLevel == 1
            and shaman_stun[1].MinLevel == 20
            and shaman_stun[9].SkillLevel == 9
            and shaman_stun[9].MinLevel == 30,
        "Orc Shaman Stun Attack ranks preserve 20/25/30 brackets"
    )

    local shaman_life = Source.find_skill("OrcShaman", 1229)
    check(
        #shaman_life == 3
            and shaman_life[1].MinLevel == 20
            and shaman_life[2].MinLevel == 25
            and shaman_life[3].MinLevel == 30,
        "Orc Shaman Chant of Life preserves one rank per bracket"
    )

    local wizard_blaze = Source.find_skill("HumanWizard", 1220)
    check(#wizard_blaze == 6
        and wizard_blaze[1].SkillLevel == 1
        and wizard_blaze[1].SP == 1400
        and wizard_blaze[1].MinLevel == 20
        and wizard_blaze[6].SkillLevel == 6
        and wizard_blaze[6].SP == 5300
        and wizard_blaze[6].MinLevel == 30,
        "Human Wizard Blaze ranks 1-6 preserve source SP/levels")

    local wizard_servitor = Source.find_skill("HumanWizard", 1127)
    check(#wizard_servitor == 9
        and wizard_servitor[1].SP == 960
        and wizard_servitor[9].SP == 3500,
        "Human Wizard Servitor Heal ranks stay source-only metadata")

    local cleric_heal = Source.find_skill("HumanCleric", 1011)
    check(#cleric_heal == 9
        and cleric_heal[1].SkillLevel == 7
        and cleric_heal[1].MinLevel == 20
        and cleric_heal[9].SkillLevel == 15
        and cleric_heal[9].SP == 4400
        and cleric_heal[9].MinLevel == 30,
        "Human Cleric Heal ranks 7-15 preserve source SP/levels")

    local oracle_recharge = Source.find_skill(
        "ElvenOracle",
        1013
    )
    check(
        #oracle_recharge == 2
            and oracle_recharge[1].SkillLevel == 1
            and oracle_recharge[1].SP == 6200
            and oracle_recharge[1].MinLevel == 30
            and oracle_recharge[2].SkillLevel == 2
            and oracle_recharge[2].SP == 6200,
        "Elven Oracle Recharge ranks 1-2 preserve source SP/level"
    )

    local oracle_shackle = Source.find_skill(
        "ElvenOracle",
        1206
    )
    check(
        #oracle_shackle == 3
            and oracle_shackle[1].SkillLevel == 2
            and oracle_shackle[1].MinLevel == 20
            and oracle_shackle[3].SkillLevel == 4
            and oracle_shackle[3].MinLevel == 30,
        "Elven Oracle Wind Shackle ranks 2-4 preserve source levels"
    )

    local dark_twister = Source.find_skill("DarkWizard", 1178)
    check(
        #dark_twister == 6
            and dark_twister[1].SkillLevel == 1
            and dark_twister[1].SP == 1600
            and dark_twister[1].MinLevel == 20
            and dark_twister[6].SkillLevel == 6
            and dark_twister[6].SP == 5500
            and dark_twister[6].MinLevel == 30,
        "Dark Wizard Twister ranks 1-6 preserve source SP/levels"
    )

    local dark_shadow = Source.find_skill("DarkWizard", 1128)
    check(
        #dark_shadow == 3
            and dark_shadow[1].SkillLevel == 1
            and dark_shadow[1].SP == 3300
            and dark_shadow[1].MinLevel == 20
            and dark_shadow[3].SkillLevel == 3
            and dark_shadow[3].SP == 11000
            and dark_shadow[3].MinLevel == 30,
        "Dark Wizard Shadow summon ranks preserve source SP/levels"
    )

    local dusk_empower = Source.find_skill(
        "ShillienOracle",
        1059
    )
    check(
        #dusk_empower == 1
            and dusk_empower[1].SkillLevel == 1
            and dusk_empower[1].SP == 6500
            and dusk_empower[1].MinLevel == 25,
        "Shillien Oracle Empower rank one preserves source SP/level"
    )

    local dusk_blood = Source.find_skill(
        "ShillienOracle",
        1268
    )
    check(
        #dusk_blood == 1
            and dusk_blood[1].SkillLevel == 1
            and dusk_blood[1].SP == 12000
            and dusk_blood[1].MinLevel == 30,
        "Shillien Oracle Vampiric Rage enters exactly at level 30"
    )

    local dusk_shackle = Source.find_skill(
        "ShillienOracle",
        1206
    )
    check(
        #dusk_shackle == 3
            and dusk_shackle[1].SkillLevel == 2
            and dusk_shackle[1].MinLevel == 20
            and dusk_shackle[2].SkillLevel == 3
            and dusk_shackle[2].MinLevel == 25
            and dusk_shackle[3].SkillLevel == 4
            and dusk_shackle[3].MinLevel == 30,
        "Shillien Oracle Wind Shackle ranks 2-4 preserve brackets"
    )

    local common = Source.find_skill("ElvenKnight", 1320)
    check(#common == 2
        and common[1].SkillLevel == 2
        and common[1].MinLevel == 20
        and common[2].SkillLevel == 3
        and common[2].MinLevel == 28,
        "Elven Knight automatic common-item ranks 2/3")

    local expertise = Source.find_skill("HumanWarrior", 239)
    check(#expertise == 1
        and expertise[1].SkillLevel == 1
        and expertise[1].MinLevel == 20,
        "Human Warrior Expertise D automatic source row")

    local aggression = Source.find_skill("ElvenKnight", 28)
    check(#aggression == 6
        and aggression[1].SkillLevel == 1
        and aggression[6].SkillLevel == 6,
        "Elven Knight Aggression ranks through level30")

    print(("[C4 Skill Tree] EXACT_SOURCE_PASS: %d assertions, "
        .. "paths=23 rows=1370 uniqueSkillIds=170 live=false")
        :format(checks))
end

main()
