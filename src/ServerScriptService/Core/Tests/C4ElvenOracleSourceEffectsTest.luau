--!strict
-- Exact Lifebinder / Elven Oracle source-effect regression through level 30.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Effects = require(Shared.C4SkillEffectSource)
local SourceMap = require(Shared.C4CreativeSkillSourceMap)
local SourceRanks = require(Shared.C4ElvenOracleLevel30Sources)
local Skills = require(Shared.C4ElvenOracleSkillDefinitions)
local Status = require(Shared.C4StatusEffectReference)

local checks = 0

local ACTIVE_FAMILIES = table.freeze({
    Heal = 1011,
    Recharge = 1013,
    BattleHeal = 1015,
    Resurrection = 1016,
    GroupHeal = 1027,
    DisruptUndead = 1031,
    MentalShield = 1035,
    Shield = 1040,
    HolyWeapon = 1043,
    Might = 1068,
    Sleep = 1069,
    KissOfEva = 1073,
    Concentration = 1078,
    Agility = 1087,
    DryadRoot = 1201,
    WindWalk = 1204,
    WindShackle = 1206,
})

--[[
Counts one Lifebinder source-effect assertion.

Args:
    condition (boolean): Observed source contract.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Lifebinder Source Effects] " .. label
    )
end

--[[
Returns the highest source rank represented by one creative family.

Args:
    source_skill_id (number): Historical C4 source skill.

Returns:
    number: Highest mapped source rank through level 30.
]]
local function highest_rank(source_skill_id: number): number
    local scope = assert(SourceMap.get_scope("ElvenOracle"))
    local candidate = assert(scope.Candidates[source_skill_id])
    local creative = assert(Skills.get(candidate.SkillId))
    return creative.MaxRank + (candidate.Offset or 0)
end

--[[
Checks one active family keeps its exact C4 target contract.

Args:
    source_skill_id (number): Historical source skill.
    expected_target (string): Exact C4 target type.

Returns:
    nil: Adds one source-target assertion.
]]
local function check_target(
    source_skill_id: number,
    expected_target: string
)
    local effect = assert(Effects.get_rank(
        source_skill_id,
        highest_rank(source_skill_id)
    ))
    check(
        effect.Sets.target == expected_target,
        tostring(source_skill_id)
            .. " preserves exact target "
            .. expected_target
    )
end

--[[
Runs Elven Oracle source-effect acceptance.

Args:
    None.

Returns:
    nil: Prints exact active-family evidence.
]]
local function main()
    local source = SourceRanks.get()
    check(
        source.SourceClass == "Elven Oracle"
            and source.SourceClassId == 29,
        "source inventory remains pinned to Elven Oracle class 29"
    )

    local scope = assert(SourceMap.get_scope("ElvenOracle"))
    for category, source_skill_id in pairs(ACTIVE_FAMILIES) do
        local candidate = assert(scope.Candidates[source_skill_id])
        check(
            type(candidate.SkillId) == "string"
                and candidate.SkillId ~= "",
            category .. " has a creative source mapping"
        )
    end

    for _, source_skill_id in ipairs({
        1011,
        1013,
        1015,
        1035,
        1040,
        1043,
        1068,
        1069,
        1073,
        1078,
        1087,
        1201,
        1204,
        1206,
    }) do
        check_target(source_skill_id, "TARGET_ONE")
    end
    check_target(1016, "TARGET_CORPSE_PLAYER")
    check_target(1027, "TARGET_PARTY")
    check_target(1031, "TARGET_UNDEAD")

    local recharge = assert(Effects.get_rank(1013, 2))
    check(
        recharge.Sets.skillType == "MANARECHARGE"
            and recharge.Sets.power == 52
            and recharge.Sets.mpInitialConsume == 11
            and recharge.Sets.mpConsume == 42
            and recharge.Sets.castRange == 400
            and recharge.Sets.effectRange == 900,
        "Recharge rank two keeps exact power, MP and range fields"
    )

    local agility = assert(Effects.get_rank(1087, 1))
    check(
        agility.Sets.skillType == "BUFF"
            and agility.Effects[1].time == 1200
            and agility.Effects[1].Modifiers[1].stat
                == "EVASION_RATE"
            and agility.Effects[1].Modifiers[1].val == 2,
        "Agility keeps exact 20-minute +2 evasion source effect"
    )

    local shackle = assert(
        Status.physical_attack_rate_weakening_plan(1206, 4)
    )
    check(
        shackle.PhysicalAttackSpeedMultiplier == 0.8
            and shackle.RateReductionFraction == 0.2
            and shackle.DurationSeconds == 15
            and shackle.SaveVs == "WIT"
            and shackle.EffectPower == 80
            and shackle.MagicLevel == 30,
        "Wind Shackle keeps exact 20 percent cadence reduction"
    )

    local sleep = assert(Status.sleep_plan(1069, 6))
    check(
        sleep.DurationSeconds == 30
            and sleep.StopsMovement
            and sleep.StopsAttacks
            and sleep.BreaksOnDamage,
        "Slumber retains exact shared C4 Sleep behavior"
    )

    local root = assert(Status.root_plan(1201, 6))
    check(
        root.DurationSeconds == 30
            and root.StopsMovement
            and not root.BreaksOnDamage,
        "Rootbind retains exact shared C4 Root behavior"
    )

    print((
        "[Lifebinder Source Effects] PASS: %d assertions "
            .. "activeFamilies=17"
    ):format(checks))
end

main()
