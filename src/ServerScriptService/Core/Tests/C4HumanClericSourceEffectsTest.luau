--!strict
-- Exact Human Cleric source-effect regression through the level-30 cap.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Effects = require(Shared.C4SkillEffectSource)
local SourceMap = require(Shared.C4CreativeSkillSourceMap)
local SourceRanks = require(Shared.C4HumanClericLevel30Sources)
local Skills = require(Shared.C4HumanClericSkillDefinitions)
local Status = require(Shared.C4StatusEffectReference)

local checks = 0

local EXPECTED = table.freeze({
    Heal = 1011,
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
    Focus = 1077,
    Concentration = 1078,
    Acumen = 1085,
    ResistFire = 1191,
    DryadRoot = 1201,
    WindWalk = 1204,
})

--[[
Counts one Human Cleric source-effect assertion.

Args:
    condition (boolean): Observed source contract.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Human Cleric Source Effects] " .. label)
end

--[[
Returns the highest source rank scheduled through level 30.

Args:
    source_skill_id (number): Historical C4 source skill.

Returns:
    number: Highest source rank represented by the Cleric schedule.
]]
local function highest_rank(source_skill_id: number): number
    local scope = assert(SourceMap.get_scope("HumanCleric"))
    local candidate = assert(scope.Candidates[source_skill_id])
    local creative = assert(Skills.get(candidate.SkillId))
    return creative.MaxRank + (candidate.Offset or 0)
end

--[[
Checks one source family is present with its expected target contract.

Args:
    source_skill_id (number): Historical source skill.
    expected_target (string): Exact C4 target type.

Returns:
    nil: Adds one assertion.
]]
local function check_target(
    source_skill_id: number,
    expected_target: string
)
    local rank = highest_rank(source_skill_id)
    local effect = assert(Effects.get_rank(source_skill_id, rank))
    check(
        effect.Sets.target == expected_target,
        tostring(source_skill_id)
            .. " preserves exact source target "
            .. expected_target
    )
end

--[[
Runs Human Cleric source-effect acceptance.

Args:
    None.

Returns:
    nil: Prints exact source coverage evidence.
]]
local function main()
    local source = SourceRanks.get()
    check(
        source.SourceClass == "Cleric",
        "source inventory remains pinned to original Cleric"
    )

    local scope = assert(SourceMap.get_scope("HumanCleric"))
    for category, source_skill_id in pairs(EXPECTED) do
        local candidate = assert(scope.Candidates[source_skill_id])
        check(
            type(candidate.SkillId) == "string"
                and candidate.SkillId ~= "",
            category .. " has a creative source mapping"
        )
    end

    check_target(1011, "TARGET_ONE")
    check_target(1015, "TARGET_ONE")
    check_target(1016, "TARGET_CORPSE_PLAYER")
    check_target(1027, "TARGET_PARTY")
    check_target(1035, "TARGET_ONE")
    check_target(1040, "TARGET_ONE")
    check_target(1043, "TARGET_ONE")
    check_target(1068, "TARGET_ONE")
    check_target(1069, "TARGET_ONE")
    check_target(1073, "TARGET_ONE")
    check_target(1077, "TARGET_ONE")
    check_target(1078, "TARGET_ONE")
    check_target(1085, "TARGET_ONE")
    check_target(1191, "TARGET_ONE")
    check_target(1201, "TARGET_ONE")
    check_target(1204, "TARGET_ONE")

    local sleep = assert(Status.sleep_plan(1069, highest_rank(1069)))
    check(
        sleep.DurationSeconds == 30
            and sleep.SaveVs == "WIT"
            and sleep.StopsMovement
            and sleep.StopsAttacks,
        "Cleric Sleep retains exact C4 control contract"
    )

    local root = assert(
        Status.root_plan(1201, highest_rank(1201))
    )
    check(
        root.DurationSeconds == 30
            and root.SaveVs == "WIT"
            and root.StopsMovement
            and not root.BreaksOnDamage,
        "Dryad Root retains exact C4 movement-control contract"
    )

    print((
        "[Human Cleric Source Effects] PASS: %d assertions"
    ):format(checks))
end

main()
