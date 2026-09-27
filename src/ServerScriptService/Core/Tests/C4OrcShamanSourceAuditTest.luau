--!strict
-- Direct pinned Orc Shaman class-50 source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = require(
    ReplicatedStorage.Core.Shared.C4OrcShamanLevel30Sources
)

local checks = 0

--[[
Counts one Orc Shaman source-audit assertion.

Args:
    valid (boolean): Expected source inventory condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Orc Shaman Source Audit] " .. label)
end

--[[
Counts every separately purchasable source rank in one level bracket.

Args:
    categories (any): Frozen category-to-rank-count dictionary.

Returns:
    number: Total source rank rows in the bracket.
]]
local function count_bracket(categories: any): number
    local total = 0

    for _, count in pairs(categories) do
        total += count
    end

    return total
end

--[[
Runs the exact class-50 launch inventory audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source counts pass.
]]
local function main()
    local source = Source.get()

    check(source.SourceClass == "Orc Shaman", "source class name")
    check(source.SourceClassId == 50, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    local level_20 = assert(source.Levels[20])
    local level_25 = assert(source.Levels[25])
    local level_30 = assert(source.Levels[30])

    check(count_bracket(level_20) == 24, "level 20 has 24 rank rows")
    check(count_bracket(level_25) == 26, "level 25 has 26 rank rows")
    check(count_bracket(level_30) == 27, "level 30 has 27 rank rows")
    check(source.Levels[24] == nil, "no invented level-24 bracket")
    check(source.Levels[28] == nil, "no invented level-28 bracket")

    check(
        level_20.StunAttack == 3
            and level_25.StunAttack == 3
            and level_30.StunAttack == 3,
        "Stun Attack preserves three purchased ranks per bracket"
    )
    check(
        level_20.AntiMagic == 2
            and level_25.AntiMagic == 2
            and level_30.AntiMagic == 2,
        "Anti Magic preserves two purchased ranks per bracket"
    )
    check(
        level_20.LifeDrain == 1
            and level_25.LifeDrain == 1
            and level_30.LifeDrain == 1,
        "Life Drain preserves one purchased rank per bracket"
    )
    check(
        level_25.BlazeQuake == 1
            and level_20.BlazeQuake == nil
            and level_30.BlazeQuake == nil,
        "Blaze Quake enters exactly at source level 25"
    )
    check(
        level_30.PowerOfPaagrio == 1
            and level_20.PowerOfPaagrio == nil
            and level_25.PowerOfPaagrio == nil,
        "Power of Paagrio enters exactly at source level 30"
    )
    check(
        level_20.SealOfPoison == 1
            and level_25.SealOfPoison == nil
            and level_30.SealOfPoison == 1,
        "Seal of Poison keeps exact source brackets"
    )
    check(
        level_20.ChantOfLife == 1
            and level_25.ChantOfLife == 1
            and level_30.ChantOfLife == 1,
        "Chant of Life preserves one rank per source bracket"
    )

    print(
        ("[Orc Shaman Source Audit] PASS: %d assertions rows=77")
            :format(checks)
    )
end

main()
