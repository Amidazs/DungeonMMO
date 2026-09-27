--!strict
-- Dark Elf Assassin / Veilblade level-30 source schedule regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Coverage = require(Shared.C4Level30LaunchCoverage)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Mapping = require(Shared.C4Level30ClassSkillMap)
local Sources = require(Shared.C4DarkElfAssassinLevel30Sources)
local SourceMap = require(Shared.C4CreativeSkillSourceMap)
local Skills = require(Shared.SkillProgressionDefinitions)
local Trainer = require(Shared.TrainerCatalogues)

local checks = 0

local EXPECTED = {
    MortalBlow = "WayfinderCut",
    Unlock = "ScoutLockpicking",
    PowerShot = "WayfinderArrow",
    HealthDrain = "VeilbladeUmbralSiphon",
    DefenseAura = "VeilbladeDefenseAura",
    BowRange = "RangerLongRange",
    Poison = "VeilbladeVenomHex",
    FallResistance = "ScoutFallResistance",
    LungCapacity = "ScoutLungCapacity",
    BowMastery = "WayfinderBowMastery",
    DaggerMastery = "WayfinderDaggerMastery",
    LightArmorMastery = "ScoutLightArmorMastery",
    CriticalPowerToggle = "ScoutCriticalPowerToggle",
    Confusion = "VeilbladeMindRend",
    Bleed = "WayfinderWound",
    CriticalPower = "VeilbladeCriticalPower",
    Evasion = "ScoutEvasion",
    Sting = "VeilbladeCrimsonSting",
    AccuracyToggle = "ScoutAccuracyToggle",
    AttackAura = "VeilbladeAttackAura",
    UltimateEvasion = "ScoutEvasiveFocus",
    QuickStep = "ScoutFleetFoot",
    AcrobaticMove = "ScoutRunningEvasion",
}

--[[
Counts one Veilblade foundation assertion.

Args:
    condition (boolean): Observed source/progression state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Dark Elf Assassin] " .. label)
end

--[[
Counts all exact Dark Elf Assassin source-rank rows through level 30.

Args:
    source (any): Dark Elf Assassin source inventory.

Returns:
    number: Total separately learnable ranks.
]]
local function source_rank_count(source: any): number
    local total = 0

    for _, families in pairs(source.Levels) do
        for _, count in pairs(families) do
            total += count
        end
    end

    return total
end

--[[
Runs Assassin career, source-map and trainer parity checks.

Args:
    None.

Returns:
    nil: Prints green source-schedule evidence.
]]
local function main()
    local source = Sources.get()
    check(
        source.SourceClassId == 35
            and source_rank_count(source) == 70,
        "class 35 preserves all 70 level-20/24/28 source rank rows"
    )

    local career = assert(Careers.for_branch("DarkElfAssassin"))
    local class = assert(Classes.get("Veilblade"))
    local trainer = assert(Trainer.get("VeilbladeTrainer"))

    check(
        career.Id == "Veilblade"
            and career.RaceId == "DarkElf"
            and career.BaseClassId == "Fighter"
            and class.Id == "Veilblade"
            and trainer.AllowedClasses[1] == "Veilblade",
        "Dark Elf Fighter Assassin career and trainer are independent"
    )

    local taught = {}
    for _, row in ipairs(trainer.Skills) do
        taught[row.SkillId] = true
    end

    for category, skill_id in pairs(EXPECTED) do
        local definition = assert(Skills.get(skill_id))
        check(
            Mapping.get("DarkElfAssassin", category) == skill_id
                and taught[skill_id] == true
                and definition.Id == skill_id,
            category .. " maps to one trainable Veilblade family"
        )
    end

    local source_links =
        assert(SourceMap.get_scope("DarkElfAssassin"))
    local gap_count = 0
    for _ in pairs(source_links.Gaps or {}) do
        gap_count += 1
    end
    check(
        gap_count == 0,
        "Dark Elf Assassin has no creative source-map gaps"
    )

    local coverage =
        assert(Coverage.for_branch("DarkElfAssassin"))
    check(
        coverage.SourceRankEntriesThroughCap == 70
            and coverage.TrainerMappedRankEntries == 70
            and coverage.MissingRankScheduleEntries == 0
            and coverage.SourceRankScheduleMapped,
        "all 70 source ranks are represented by the Veilblade schedule"
    )

    check(
        #class.TeachableSkills == 23,
        "Veilblade exposes all twenty-three level-30 skill families"
    )

    print((
        "[C4 Dark Elf Assassin] PASS: %d assertions "
            .. "source_ranks=70 families=23 gaps=0"
    ):format(checks))
end

main()
