--!strict
-- Direct pinned Orc Monk class-47 source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = require(
    ReplicatedStorage.Core.Shared.C4OrcMonkLevel30Sources
)

local checks = 0

--[[
Counts one Orc Monk source-audit assertion.

Args:
    valid (boolean): Expected source inventory condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Orc Monk Source Audit] " .. label)
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
Runs the exact class-47 launch inventory audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source counts pass.
]]
local function main()
    local source = Source.get()

    check(source.SourceClass == "Orc Monk", "source class name")
    check(source.SourceClassId == 47, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    local level_20 = assert(source.Levels[20])
    local level_24 = assert(source.Levels[24])
    local level_28 = assert(source.Levels[28])

    check(count_bracket(level_20) == 12, "level 20 has 12 rank rows")
    check(count_bracket(level_24) == 14, "level 24 has 14 rank rows")
    check(count_bracket(level_28) == 15, "level 28 has 15 rank rows")
    check(source.Levels[25] == nil, "no invented level-25 bracket")
    check(source.Levels[30] == nil, "no invented level-30 bracket")

    check(
        level_20.IronPunch == 3
            and level_24.IronPunch == 3
            and level_28.IronPunch == 3,
        "Iron Punch preserves three ranks per source bracket"
    )
    check(
        level_20.StunningFist == 3
            and level_24.StunningFist == 3
            and level_28.StunningFist == 3,
        "Stunning Fist preserves three ranks per source bracket"
    )
    check(
        level_20.LightArmorMastery == 2
            and level_24.LightArmorMastery == 2
            and level_28.LightArmorMastery == 2,
        "Light Armor Mastery preserves exact two-rank brackets"
    )
    check(
        level_20.WolfTotem == 1
            and level_24.WolfTotem == nil
            and level_28.WolfTotem == nil,
        "Wolf Totem enters exactly at source level 20"
    )
    check(
        level_24.FocusForce == 1
            and level_20.FocusForce == nil
            and level_28.FocusForce == nil,
        "Focus Force enters exactly at source level 24"
    )
    check(
        level_28.BearTotem == 1
            and level_20.BearTotem == nil
            and level_24.BearTotem == nil,
        "Bear Totem enters exactly at source level 28"
    )
    check(
        level_20.AgileMovement == 1
            and level_24.AgileMovement == nil
            and level_28.AgileMovement == nil,
        "Agile Movement enters exactly at source level 20"
    )

    print(
        ("[Orc Monk Source Audit] PASS: %d assertions rows=41")
            :format(checks)
    )
end

main()
