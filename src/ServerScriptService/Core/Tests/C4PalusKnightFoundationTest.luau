--!strict
-- Palus Knight / Duskguard level-30 source schedule regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Coverage = require(Shared.C4Level30LaunchCoverage)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Mapping = require(Shared.C4Level30ClassSkillMap)
local Sources = require(Shared.C4PalusKnightLevel30Sources)
local SourceMap = require(Shared.C4CreativeSkillSourceMap)
local Skills = require(Shared.C4PalusKnightSkillDefinitions)
local Trainer = require(Shared.TrainerCatalogues)

local checks = 0

local EXPECTED = {
    HealthDrain = "DuskguardUmbralSiphon",
    DefenseAura = "DuskguardDefenseAura",
    UltimateDefense = "DuskguardLastStand",
    Poison = "DuskguardVenomHex",
    MagicResistance = "DuskguardRunicResistance",
    ShieldMastery = "DuskguardShieldMastery",
    SwordBluntMastery = "DuskguardSteelTraining",
    HeavyArmorMastery = "DuskguardHeavyArmorTraining",
    Confusion = "DuskguardMindRend",
    Aggression = "DuskguardChallenge",
    BowDefense = "DuskguardArrowWard",
    BleedAttack = "DuskguardCrimsonSting",
    AttackAura = "DuskguardAttackAura",
}

--[[
Counts one Duskguard foundation assertion.

Args:
    condition (boolean): Observed source/progression state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Palus Knight] " .. label)
end

--[[
Counts all exact Palus Knight source-rank rows through level 30.

Args:
    source (any): Palus Knight source inventory.

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
Runs Palus Knight career, source-map and trainer parity checks.

Args:
    None.

Returns:
    nil: Prints green source-schedule evidence.
]]
local function main()
    local source = Sources.get()
    check(
        source.SourceClassId == 32
            and source_rank_count(source) == 50,
        "class 32 preserves all 50 level-20/24/28 source rank rows"
    )

    local career = assert(Careers.for_branch("PalusKnight"))
    local class = assert(Classes.get("Duskguard"))
    local trainer = assert(Trainer.get("DuskguardTrainer"))

    check(
        career.Id == "Duskguard"
            and career.RaceId == "DarkElf"
            and career.BaseClassId == "Fighter"
            and class.Id == "Duskguard"
            and trainer.AllowedClasses[1] == "Duskguard",
        "Dark Elf Fighter career and trainer identity are independent"
    )

    local taught = {}
    for _, row in ipairs(trainer.Skills) do
        taught[row.SkillId] = true
    end

    for category, skill_id in pairs(EXPECTED) do
        local definition = assert(Skills.get(skill_id))
        check(
            Mapping.get("PalusKnight", category) == skill_id
                and taught[skill_id] == true
                and definition.AllowedRaces[1] == "DarkElf"
                and definition.AllowedFirstTransferClasses[1]
                    == "Duskguard",
            category .. " maps to one trainable Duskguard family"
        )
    end

    local source_links = assert(SourceMap.get_scope("PalusKnight"))
    local gap_count = 0
    for _ in pairs(source_links.Gaps or {}) do
        gap_count += 1
    end
    check(
        gap_count == 0,
        "Palus Knight has no creative source-map gaps"
    )

    local coverage = assert(Coverage.for_branch("PalusKnight"))
    check(
        coverage.SourceRankEntriesThroughCap == 50
            and coverage.TrainerMappedRankEntries == 50
            and coverage.MissingRankScheduleEntries == 0
            and coverage.SourceRankScheduleMapped,
        "all 50 source ranks are represented by the Duskguard schedule"
    )

    check(
        #class.TeachableSkills == 13,
        "Duskguard exposes all thirteen level-30 skill families"
    )

    print((
        "[C4 Palus Knight] PASS: %d assertions source_ranks=50 "
            .. "families=13 gaps=0"
    ):format(checks))
end

main()
