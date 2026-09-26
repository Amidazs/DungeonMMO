--!strict
-- Lifebinder Elven Oracle level-30 foundation regression.

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
Counts one Lifebinder foundation assertion.

Args:
    condition (boolean): Observed backend state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Lifebinder Foundation] " .. label)
end

--[[
Runs Lifebinder career, trainer and source-link foundation acceptance.

Args:
    None.

Returns:
    nil: Prints bounded foundation evidence after every check passes.
]]
local function main()
    local career = assert(Careers.for_branch("ElvenOracle"))
    check(
        career.Id == "Lifebinder"
            and career.RaceId == "Elf"
            and career.BaseClassId == "Mage"
            and career.TrainerId == "LifebinderTrainer",
        "Elven Oracle resolves only to creative Lifebinder career"
    )

    local class = assert(Classes.get("Lifebinder"))
    local trainer = assert(Trainers.get("LifebinderTrainer"))
    check(
        #class.TeachableSkills == 25
            and #trainer.Skills == 25,
        "Lifebinder class and trainer expose exactly 25 source families"
    )

    local audit = assert(Coverage.for_branch("ElvenOracle"))
    check(
        audit.SourceRankEntriesThroughCap == 91
            and audit.TrainerMappedRankEntries == 91
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "all 91 source rows have exact Lifebinder training schedules"
    )

    for _, category in ipairs({
        "Heal",
        "Recharge",
        "Resurrection",
        "GroupHeal",
        "Agility",
        "WindWalk",
        "WindShackle",
    }) do
        check(
            SkillMap.get("ElvenOracle", category) ~= nil,
            category .. " maps to a distinct Lifebinder skill"
        )
    end

    local recharge = assert(LinkMap.resolve(
        "ElvenOracle",
        1013,
        2
    ))
    check(
        recharge.CreativeSkillId == "LifebinderManaRecharge"
            and recharge.CreativeRank == 2
            and Progression.get(recharge.CreativeSkillId) ~= nil,
        "Recharge 1013:2 maps to Lifebinder Mana Recharge rank two"
    )

    local agility = assert(LinkMap.resolve(
        "ElvenOracle",
        1087,
        1
    ))
    check(
        agility.CreativeSkillId == "LifebinderAgility"
            and agility.CreativeRank == 1,
        "Agility 1087:1 maps to Lifebinder Agility"
    )

    local shackle = assert(LinkMap.resolve(
        "ElvenOracle",
        1206,
        4
    ))
    check(
        shackle.CreativeSkillId == "LifebinderWindShackle"
            and shackle.CreativeRank == 3,
        "Wind Shackle 1206:4 maps through the exact source offset"
    )

    local recharge_effect = assert(SourceEffects.get_rank(1013, 2))
    check(
        recharge_effect.Sets.skillType == "MANARECHARGE"
            and recharge_effect.Sets.power == 52
            and recharge_effect.Sets.mpInitialConsume == 11
            and recharge_effect.Sets.mpConsume == 42
            and recharge_effect.Sets.castRange == 400
            and recharge_effect.Sets.effectRange == 900,
        "Mana Recharge retains exact rank-two source contract"
    )

    local agility_effect = assert(SourceEffects.get_rank(1087, 1))
    check(
        agility_effect.Sets.skillType == "BUFF"
            and agility_effect.Effects[1].time == 1200
            and agility_effect.Effects[1].Modifiers[1].stat
                == "EVASION_RATE"
            and agility_effect.Effects[1].Modifiers[1].val == 2,
        "Agility retains exact 20-minute +2 evasion source effect"
    )

    local shackle_effect = assert(SourceEffects.get_rank(1206, 4))
    check(
        shackle_effect.Sets.effectPower == 80
            and shackle_effect.Sets.saveVs == "WIT"
            and shackle_effect.Effects[1].time == 15
            and shackle_effect.Effects[1].Modifiers[1].stat
                == "PHYSICAL_ATTACK_SPEED"
            and shackle_effect.Effects[1].Modifiers[1].val == 0.8,
        "Wind Shackle retains exact WIT-resisted 20 percent speed debuff"
    )

    print((
        "[Lifebinder Foundation] PASS: %d assertions rows=91 families=25"
    ):format(checks))
end

main()
