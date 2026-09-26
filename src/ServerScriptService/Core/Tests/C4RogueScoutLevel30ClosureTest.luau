--!strict
-- Human Rogue / Elven Scout final level-30 source-gap closure regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Classes = require(Shared.ClassProgressionDefinitions)
local CreativeMap = require(Shared.C4CreativeSkillSourceMap)
local PassiveStats = require(Shared.C4PassiveStatReference)
local ScoutHeal = require(Shared.C4ScoutHealMigrationPlan)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local SkillMap = require(Shared.C4Level30ClassSkillMap)
local Trainers = require(Shared.TrainerCatalogues)

local checks = 0

--[[
Counts one Rogue/Scout closure assertion.

Args:
    condition (boolean): Observed exact source state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and counts the assertion.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Rogue Scout Closure] " .. label)
end

--[[
Returns whether one trainer catalogue contains a creative skill.

Args:
    trainer_id (string): Exact trainer catalogue ID.
    skill_id (string): Creative skill being searched.

Returns:
    boolean: True when the skill is genuinely trainable there.
]]
local function trainer_contains(
    trainer_id: string,
    skill_id: string
): boolean
    local trainer = assert(Trainers.get(trainer_id))

    for _, entry in ipairs(trainer.Skills) do
        if entry.SkillId == skill_id then
            return true
        end
    end

    return false
end

--[[
Checks Human Rogue Vital Force exact passive source semantics.

Args:
    None.

Returns:
    nil: Confirms source mapping and exact regeneration modifiers.
]]
local function check_rogue_vital_force()
    local link = assert(CreativeMap.resolve(
        "HumanRogue",
        148,
        1
    ))

    check(
        link.Status == "Candidate"
            and link.CreativeSkillId == "AshenbladeVitalForce"
            and link.CreativeRank == 1,
        "Vital Force maps to its own exact Ashenblade passive"
    )

    local definition = assert(
        SkillDefinitions.get("AshenbladeVitalForce")
    )
    check(
        definition.Kind == "Passive"
            and definition.MaxRank == 1
            and definition.RankLevels[1] == 24
            and Classes.can_teach(
                "Ashenblade",
                "AshenbladeVitalForce"
            )
            and trainer_contains(
                "AshenbladeTrainer",
                "AshenbladeVitalForce"
            ),
        "Vital Force is purchased only through the earned Ashenblade path"
    )

    local applied = assert(PassiveStats.apply(
        {
            REG_HP_RATE = 10,
            REG_MP_RATE = 5,
        },
        {},
        {
            {
                SkillId = 148,
                Rank = 1,
            },
        }
    ))
    check(
        applied.Stats.REG_HP_RATE == 11.9
            and applied.Stats.REG_MP_RATE == 5.9
            and applied.AppliedModifiers == 2,
        "Vital Force applies exact +1.9 HP and +0.9 MP regen source stats"
    )

    check(
        SkillMap.get("HumanRogue", "VitalForce")
            == "AshenbladeVitalForce",
        "level-30 family map exposes exact Vital Force"
    )
end

--[[
Checks Elven Scout Elemental Heal exact nine-rank source semantics.

Args:
    None.

Returns:
    nil: Confirms source mapping, ranks, levels and live family ownership.
]]
local function check_scout_elemental_heal()
    local first = assert(CreativeMap.resolve(
        "ElvenScout",
        58,
        4
    ))
    local last = assert(CreativeMap.resolve(
        "ElvenScout",
        58,
        12
    ))

    check(
        first.Status == "Candidate"
            and first.CreativeSkillId
                == "GreenwardScoutElementalHeal"
            and first.CreativeRank == 1
            and last.Status == "Candidate"
            and last.CreativeSkillId
                == "GreenwardScoutElementalHeal"
            and last.CreativeRank == 9,
        "Elemental Heal source ranks 4-12 map to creative ranks 1-9"
    )

    local definition = assert(
        SkillDefinitions.get("GreenwardScoutElementalHeal")
    )
    check(
        definition.Kind == "Support"
            and definition.MaxRank == 9
            and definition.RankLevels[1] == 20
            and definition.RankLevels[3] == 20
            and definition.RankLevels[4] == 24
            and definition.RankLevels[6] == 24
            and definition.RankLevels[7] == 28
            and definition.RankLevels[9] == 28,
        "Scout heal preserves exact 20/24/28 learning brackets"
    )

    local first_plan = assert(ScoutHeal.get_rank(4))
    local last_plan = assert(ScoutHeal.get_rank(12))
    check(
        first_plan.SourcePower == 95
            and first_plan.SourceTotalMP == 53
            and first_plan.SourceCastMs == 5000
            and first_plan.SourceReuseMs == 10000
            and last_plan.SourcePower == 157
            and last_plan.SourceTotalMP == 83
            and first_plan.LiveLearnable
            and first_plan.LiveCastable
            and last_plan.LiveLearnable
            and last_plan.LiveCastable,
        "Scout heal keeps exact source power, MP and timing endpoints"
    )

    check(
        Classes.can_teach(
            "GreenwardScout",
            "GreenwardScoutElementalHeal"
        )
            and trainer_contains(
                "GreenwardScoutTrainer",
                "GreenwardScoutElementalHeal"
            )
            and SkillMap.get(
                "ElvenScout",
                "ElementalHeal"
            ) == "GreenwardScoutElementalHeal",
        "Scout heal is owned only by the Greenward Scout trainer path"
    )
end

--[[
Checks both first-transfer source scopes now have no explicit gaps.

Args:
    None.

Returns:
    nil: Confirms the two historical level-30 catalogues are closed.
]]
local function check_gap_closure()
    local rogue = assert(CreativeMap.get_scope("HumanRogue"))
    local scout = assert(CreativeMap.get_scope("ElvenScout"))

    check(
        next(rogue.Gaps) == nil,
        "Human Rogue has zero explicit level-30 source gaps"
    )
    check(
        next(scout.Gaps) == nil,
        "Elven Scout has zero explicit level-30 source gaps"
    )
end

--[[
Runs final Human Rogue / Elven Scout source-gap closure acceptance.

Args:
    None.

Returns:
    nil: Prints bounded green evidence.
]]
local function main()
    check_rogue_vital_force()
    check_scout_elemental_heal()
    check_gap_closure()

    print((
        "[C4 Rogue Scout Closure] PASS: %d assertions "
            .. "rogue_gaps=0 scout_gaps=0"
    ):format(checks))
end

main()
