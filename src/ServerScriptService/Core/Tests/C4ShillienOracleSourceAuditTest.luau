--!strict
-- Direct pinned Shillien Oracle class-42 source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = require(
    ReplicatedStorage.Core.Shared.C4ShillienOracleLevel30Sources
)

local checks = 0

--[[
Counts one Shillien Oracle source-audit assertion.

Args:
    valid (boolean): Expected source inventory condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the bounded assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Shillien Oracle Source Audit] " .. label)
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
Runs the exact class-42 launch inventory audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source counts pass.
]]
local function main()
    local source = Source.get()

    check(
        source.SourceClass == "Shillien Oracle",
        "source class name"
    )
    check(source.SourceClassId == 42, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    local level_20 = assert(source.Levels[20])
    local level_25 = assert(source.Levels[25])
    local level_30 = assert(source.Levels[30])

    check(count_bracket(level_20) == 26, "level 20 has 26 rank rows")
    check(count_bracket(level_25) == 32, "level 25 has 32 rank rows")
    check(count_bracket(level_30) == 34, "level 30 has 34 rank rows")
    check(source.Levels[24] == nil, "no invented level-24 bracket")
    check(source.Levels[28] == nil, "no invented level-28 bracket")

    check(
        level_20.Heal == 3
            and level_25.Heal == 3
            and level_30.Heal == 3,
        "Heal preserves three purchased ranks per bracket"
    )
    check(
        level_20.BattleHeal == 3
            and level_25.BattleHeal == 3
            and level_30.BattleHeal == 3,
        "Battle Heal preserves three purchased ranks per bracket"
    )
    check(
        level_20.GroupHeal == 3
            and level_25.GroupHeal == 3
            and level_30.GroupHeal == 3,
        "Group Heal preserves three purchased ranks per bracket"
    )
    check(
        level_20.Resurrection == 1
            and level_25.Resurrection == nil
            and level_30.Resurrection == 1,
        "Resurrection keeps exact class-42 launch brackets"
    )
    check(
        level_20.WindShackle == 1
            and level_25.WindShackle == 1
            and level_30.WindShackle == 1,
        "Wind Shackle keeps one rank per source bracket"
    )
    check(
        level_25.DryadRoot == 3
            and level_30.DryadRoot == 3
            and level_20.DryadRoot == nil,
        "Dryad Root starts only at source level 25"
    )
    check(
        level_30.VampiricRage == 1
            and level_20.VampiricRage == nil
            and level_25.VampiricRage == nil,
        "Vampiric Rage enters exactly at source level 30"
    )

    print(
        ("[Shillien Oracle Source Audit] PASS: %d assertions rows=92")
            :format(checks)
    )
end

main()
