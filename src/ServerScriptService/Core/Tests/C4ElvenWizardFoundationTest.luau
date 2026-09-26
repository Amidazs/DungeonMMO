--!strict
-- Moonweaver Elven Wizard level-30 foundation regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local LinkMap = require(Shared.C4CreativeSkillSourceMap)
local Progression = require(Shared.SkillProgressionDefinitions)
local SkillMap = require(Shared.C4Level30ClassSkillMap)
local SourceEffects = require(Shared.C4SkillEffectSource)
local Trainers = require(Shared.TrainerCatalogues)

local checks = 0

--[[
Counts one Moonweaver foundation assertion.

Args:
    condition (boolean): Observed backend state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Moonweaver Foundation] " .. label)
end

--[[
Runs the Moonweaver career, trainer and source-link foundation audit.

Args:
    None.

Returns:
    nil: Prints bounded foundation evidence after every check passes.
]]
local function main()
    local career = assert(Careers.for_branch("ElvenWizard"))
    check(
        career.Id == "Moonweaver"
            and career.RaceId == "Elf"
            and career.BaseClassId == "Mage"
            and career.TrainerId == "MoonweaverTrainer",
        "Elven Wizard resolves only to the creative Moonweaver career"
    )

    local class = assert(Classes.get("Moonweaver"))
    local trainer = assert(Trainers.get("MoonweaverTrainer"))
    check(
        #class.TeachableSkills == 22
            and #trainer.Skills == 22,
        "Moonweaver class and trainer expose exactly 22 source families"
    )

    local audit = assert(Coverage.for_branch("ElvenWizard"))
    check(
        audit.SourceRankEntriesThroughCap == 82
            and audit.TrainerMappedRankEntries == 82
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "all 82 level-30 source rows have exact training schedules"
    )

    for _, category in ipairs({
        "WaterBolt",
        "ResistWater",
        "HolyBolt",
        "ManaServitorSummon",
        "CombatServitorSummon",
        "ServitorHeal",
        "ServitorRecharge",
    }) do
        check(
            SkillMap.get("ElvenWizard", category) ~= nil,
            category .. " maps to a distinct Moonweaver skill"
        )
    end

    local tidal = assert(LinkMap.resolve(
        "ElvenWizard",
        1175,
        6
    ))
    check(
        tidal.CreativeSkillId == "MoonweaverTidalBolt"
            and tidal.CreativeRank == 6
            and Progression.get(tidal.CreativeSkillId) ~= nil,
        "Aqua Swirl 1175:6 maps to Moonweaver Tidal Bolt rank six"
    )

    local solar = assert(LinkMap.resolve(
        "ElvenWizard",
        1264,
        2
    ))
    check(
        solar.CreativeSkillId == "MoonweaverSolarSpark"
            and solar.CreativeRank == 2,
        "Solar Spark 1264:2 maps to Moonweaver Solar Spark rank two"
    )

    local aqua = assert(SourceEffects.get_rank(1175, 6))
    check(
        aqua.Sets.power == 38
            and aqua.Sets.magicLvl == 30
            and aqua.Sets.element == "WATER"
            and aqua.Sets.mpInitialConsume == 6
            and aqua.Sets.mpConsume == 21,
        "Tidal Bolt rank six retains exact Aqua Swirl source values"
    )

    local ward = assert(SourceEffects.get_rank(1182, 1))
    check(
        ward.Sets.skillType == "BUFF"
            and ward.Sets.mpInitialConsume == 5
            and ward.Sets.mpConsume == 18
            and ward.Effects[1].time == 1200
            and ward.Effects[1].Modifiers[1].val == 0.85,
        "Tidal Ward retains exact 20-minute water-resistance source effect"
    )

    local mana_summon = assert(SourceEffects.get_rank(1226, 3))
    check(
        mana_summon.Sets.npcId == 12065
            and mana_summon.Sets.itemConsumeId == 1458
            and mana_summon.Sets.itemConsumeCount == 1
            and mana_summon.Sets.itemConsumeCountOT == 1
            and mana_summon.Sets.expPenalty == 0.3,
        "rank-three mana companion keeps exact source summon contract"
    )

    local combat_summon = assert(SourceEffects.get_rank(1227, 3))
    check(
        combat_summon.Sets.npcId == 12358
            and combat_summon.Sets.itemConsumeCount == 1
            and combat_summon.Sets.itemConsumeSteps == 0
            and combat_summon.Sets.expPenalty == 0.9,
        "rank-three combat companion keeps exact source summon contract"
    )

    print((
        "[Moonweaver Foundation] PASS: %d assertions rows=82 families=22"
    ):format(checks))
end

main()
