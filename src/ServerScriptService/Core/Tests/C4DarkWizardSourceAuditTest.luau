--!strict
-- Direct pinned Dark Wizard class-39 source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = require(
    ReplicatedStorage.Core.Shared.C4DarkWizardLevel30Sources
)

local checks = 0

--[[
Counts one Dark Wizard source-audit assertion.

Args:
    valid (boolean): Expected source inventory condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the bounded assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dark Wizard Source Audit] " .. label)
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
Runs the exact class-39 launch inventory audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source counts pass.
]]
local function main()
    local source = Source.get()

    check(source.SourceClass == "Dark Wizard", "source class name")
    check(source.SourceClassId == 39, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    local level_20 = assert(source.Levels[20])
    local level_25 = assert(source.Levels[25])
    local level_30 = assert(source.Levels[30])

    check(count_bracket(level_20) == 25, "level 20 has 25 rank rows")
    check(count_bracket(level_25) == 31, "level 25 has 31 rank rows")
    check(count_bracket(level_30) == 30, "level 30 has 30 rank rows")
    check(source.Levels[24] == nil, "no invented level-24 bracket")
    check(source.Levels[28] == nil, "no invented level-28 bracket")

    check(
        level_20.VampiricTouch == 2
            and level_25.VampiricTouch == 2
            and level_30.VampiricTouch == nil,
        "Vampiric Touch launch ranks stop after source rank six"
    )
    check(
        level_20.IceBolt == 2
            and level_25.IceBolt == nil
            and level_30.IceBolt == nil,
        "Ice Bolt class-39 launch rows are only source ranks five and six"
    )
    check(
        level_20.ServitorHeal == 3
            and level_25.ServitorHeal == 3
            and level_30.ServitorHeal == 3,
        "Servitor Heal preserves three purchased ranks per bracket"
    )
    check(
        level_20.SummonShadow == 1
            and level_25.SummonShadow == 1
            and level_30.SummonShadow == 1
            and level_20.SummonSilhouette == 1
            and level_25.SummonSilhouette == 1
            and level_30.SummonSilhouette == 1,
        "both source summon families retain one rank per bracket"
    )
    check(
        level_25.PoisonCloud == 1
            and level_30.PoisonCloud == nil
            and level_25.ShadowSpark == 1
            and level_30.ShadowSpark == 1,
        "Dark Wizard poison-cloud and shadow-spark brackets stay exact"
    )

    print(
        ("[Dark Wizard Source Audit] PASS: %d assertions rows=86")
            :format(checks)
    )
end

main()
