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
    check_scope("HumanWarrior", 62)
    check_scope("HumanKnight", 54)
    check_scope("HumanRogue", 59)
    check_scope("ElvenKnight", 56)
    check_scope("ElvenScout", 77)

    local coverage = Source.coverage()
    check(coverage.PathCount == 11
        and coverage.RowCount == 657
        and coverage.UniqueSourceSkillIds == 107
        and coverage.LevelCap == 30
        and not coverage.LiveTrainerIntegrated,
        "All ten tracked original paths have exact source learning rows")

    local power_strike = Source.find_skill("HumanFighter", 3)
    check(#power_strike == 9
        and power_strike[1].SkillLevel == 1
        and power_strike[1].SP == 50
        and power_strike[1].MinLevel == 5
        and power_strike[9].SkillLevel == 9
        and power_strike[9].MinLevel == 15,
        "Human Fighter Power Strike source ranks 1-9")

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
        .. "paths=11 rows=657 uniqueSkillIds=107 live=false")
        :format(checks))
end

main()
