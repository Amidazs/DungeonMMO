--!strict
-- Exact C4 ordinary-player HP/MP/CP regeneration source regression.

local Shared = game:GetService("ReplicatedStorage").Core.Shared

local Regen = require(Shared.C4ResourceRegenSourceRules)
local Unified = require(Shared.C4UnifiedStatReference)

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local checks = 0

--[[
Counts one exact source regeneration assertion.

Args:
    valid (boolean): Expected C4 source formula or modifier condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Resource Regen] " .. label)
end

--[[
Compares two finite source values with a small arithmetic tolerance.

Args:
    actual (number): Calculated source value.
    expected (number): Independently derived expected value.

Returns:
    boolean: True when floating-point representation is equivalent.
]]
local function nearly_equal(
    actual: number,
    expected: number
): boolean
    return math.abs(actual - expected) < 0.000001
end

--[[
Checks level-30 Human Fighter base HP/MP/CP calculator inputs.

Args:
    None.

Returns:
    nil: Confirms exact BaseHp/BaseMp, level, CON and MEN arithmetic.
]]
local function check_level_thirty_baseline()
    local stats = assert(Regen.base_calculator_stats(
        "Human",
        "Fighter",
        30
    ))

    check(
        nearly_equal(
            stats.REG_HP_RATE,
            (1.5 + 2) * 1.19 * 1.58
        ),
        "level-30 HP regen base follows C4 arithmetic"
    )
    check(
        nearly_equal(
            stats.REG_CP_RATE,
            (1.5 + 2) * 1.19 * 1.58
        ),
        "level-30 CP regen base follows C4 arithmetic"
    )
    check(
        nearly_equal(
            stats.REG_MP_RATE,
            (0.9 + 0.6) * 1.19 * 1.28
        ),
        "level-30 MP regen base uses integer-band 0.3 additions"
    )
end

--[[
Checks exact ordinary movement multipliers on the three-second task.

Args:
    None.

Returns:
    nil: Confirms sitting, standing, walking and running source ratios.
]]
local function check_movement_bands()
    local stats = assert(Regen.base_calculator_stats(
        "Human",
        "Fighter",
        30
    ))
    local walking = assert(Regen.apply_movement(
        stats,
        "Walking"
    ))
    local sitting = assert(Regen.apply_movement(
        stats,
        "Sitting"
    ))
    local standing = assert(Regen.apply_movement(
        stats,
        "Standing"
    ))
    local running = assert(Regen.apply_movement(
        stats,
        "Running"
    ))

    check(
        nearly_equal(sitting.HP, walking.HP * 1.5)
            and nearly_equal(sitting.MP, walking.MP * 1.5)
            and nearly_equal(sitting.CP, walking.CP * 1.5),
        "sitting uses exact x1.5 resource regeneration"
    )
    check(
        nearly_equal(standing.HP, walking.HP * 1.1)
            and nearly_equal(standing.MP, walking.MP * 1.1)
            and nearly_equal(standing.CP, walking.CP * 1.1),
        "standing uses exact x1.1 resource regeneration"
    )
    check(
        nearly_equal(running.HP, walking.HP * 0.7)
            and nearly_equal(running.MP, walking.MP * 0.7)
            and nearly_equal(running.CP, walking.CP * 0.7),
        "running uses exact x0.7 resource regeneration"
    )
    check(
        walking.PeriodSeconds == 3
            and walking.MovementMultiplier == 1,
        "walking retains the three-second x1 source task"
    )
end

--[[
Checks low-level HP/CP and MP integer-band behaviour.

Args:
    None.

Returns:
    nil: Locks the distinct C4 level arithmetic around level ten.
]]
local function check_low_level_bands()
    local stats = assert(Regen.base_calculator_stats(
        "Human",
        "Fighter",
        10
    ))

    check(
        nearly_equal(
            stats.REG_HP_RATE,
            (1.5 + 0.5) * 0.99 * 1.58
        )
            and nearly_equal(
                stats.REG_CP_RATE,
                (1.5 + 0.5) * 0.99 * 1.58
            ),
        "levels one through ten use the HP/CP half-point branch"
    )
    check(
        nearly_equal(
            stats.REG_MP_RATE,
            0.9 * 0.99 * 1.28
        ),
        "level ten MP keeps zero integer-band additions"
    )

    local _, reason = Regen.apply_movement(stats, "Flying")
    check(
        reason == "InvalidOriginalResourceMovementState",
        "unknown movement state fails closed"
    )
end

--[[
Checks owned passive source functions can now modify regeneration stats.

Args:
    None.

Returns:
    nil: Confirms source REG_HP_RATE is present before passive order.
]]
local function check_owned_regen_passive()
    local baseline = assert(Regen.base_calculator_stats(
        "Human",
        "Ironvow",
        24
    ))
    local result = assert(Unified.get_with_source_items(
        "Human",
        "Ironvow",
        24,
        {},
        {
            {SkillId = 212, Rank = 1},
        }
    ))

    check(
        nearly_equal(
            result.EquippedStats.REG_HP_RATE,
            baseline.REG_HP_RATE + 1.1
        ),
        "Fast HP Recovery rank 1 adds exact source REG_HP_RATE"
    )
end

--[[
Checks an actually active source toggle uses the same regen calculator stat.

Args:
    None.

Returns:
    nil: Confirms Relax rank 1 adds five before movement multiplication.
]]
local function check_active_regen_toggle()
    local baseline = assert(Regen.base_calculator_stats(
        "Human",
        "Fighter",
        10
    ))
    local result = assert(Unified.get_with_source_effects(
        "Human",
        "Fighter",
        10,
        {},
        {},
        {
            {SkillId = 226, Rank = 1},
        }
    ))

    check(
        nearly_equal(
            result.EquippedStats.REG_HP_RATE,
            baseline.REG_HP_RATE + 5
        ),
        "Relax rank 1 adds exact active source HP regeneration"
    )
end

--[[
Checks C4 Magic armor conditions require the full reviewed chest+legs set.

Args:
    None.

Returns:
    nil: Confirms Mana Recovery does not activate from a chest alone.
]]
local function check_magic_armor_condition()
    local baseline = assert(Regen.base_calculator_stats(
        "Human",
        "Mage",
        1
    ))
    local chest_only = assert(Unified.get_with_source_items(
        "Human",
        "Mage",
        1,
        {
            Body = 425,
        },
        {
            {SkillId = 214, Rank = 1},
        }
    ))
    local full_set = assert(Unified.get_with_source_items(
        "Human",
        "Mage",
        1,
        {
            Body = 425,
            Legs = 461,
        },
        {
            {SkillId = 214, Rank = 1},
        }
    ))

    check(
        nearly_equal(
            chest_only.EquippedStats.REG_MP_RATE,
            baseline.REG_MP_RATE
        ),
        "Magic armor mastery condition rejects a chest without legs"
    )
    check(
        nearly_equal(
            full_set.EquippedStats.REG_MP_RATE,
            baseline.REG_MP_RATE * 1.2
        ),
        "Magic chest+legs set activates exact Mana Recovery multiplier"
    )
    check(
        full_set.EquippedStats.MAX_MP
            == full_set.Naked.MaxMP + 29,
        "complete apprentice magic set adds both deferred MP operations"
    )
end

--[[
Checks pinned source metadata for ordinary Dungeon resource regeneration.

Args:
    None.

Returns:
    nil: Confirms period, rate multipliers and explicit world-bonus boundary.
]]
local function check_metadata()
    local metadata = Regen.metadata()

    check(
        metadata.SourceCommit == SOURCE_COMMIT
            and metadata.RegenPeriodSeconds == 3
            and metadata.HpRegenMultiplier == 1
            and metadata.MpRegenMultiplier == 1
            and metadata.CpRegenMultiplier == 1,
        "source timing, default multipliers and provenance are pinned"
    )
    check(
        metadata.SpecialWorldBonusesIntegrated == false,
        "C4 world-zone bonuses remain explicitly outside Dungeon baseline"
    )
end

--[[
Runs ordinary C4 resource-regeneration source acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_level_thirty_baseline()
    check_movement_bands()
    check_low_level_bands()
    check_owned_regen_passive()
    check_active_regen_toggle()
    check_magic_armor_condition()
    check_metadata()

    print((
        "[C4 Resource Regen] SOURCE_ONLY_PASS: %d assertions "
        .. "period=3 movement=true passive_active=true live=false"
    ):format(checks))
end

main()
