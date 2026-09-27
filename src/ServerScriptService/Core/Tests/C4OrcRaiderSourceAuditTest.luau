--!strict
-- Direct pinned Orc Raider class-45 source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = require(
    ReplicatedStorage.Core.Shared.C4OrcRaiderLevel30Sources
)

local checks = 0

--[[
Counts one Orc Raider source-audit assertion.

Args:
    valid (boolean): Expected source inventory condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Orc Raider Source Audit] " .. label)
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
Runs the exact class-45 launch inventory audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source counts pass.
]]
local function main()
    local source = Source.get()

    check(source.SourceClass == "Orc Raider", "source class name")
    check(source.SourceClassId == 45, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    local level_20 = assert(source.Levels[20])
    local level_24 = assert(source.Levels[24])
    local level_28 = assert(source.Levels[28])

    check(count_bracket(level_20) == 19, "level 20 has 19 rank rows")
    check(count_bracket(level_24) == 21, "level 24 has 21 rank rows")
    check(count_bracket(level_28) == 23, "level 28 has 23 rank rows")
    check(source.Levels[25] == nil, "no invented level-25 bracket")
    check(source.Levels[30] == nil, "no invented level-30 bracket")

    check(
        level_20.StunAttack == 3
            and level_24.StunAttack == 3
            and level_28.StunAttack == 3,
        "Stun Attack preserves three purchased ranks per bracket"
    )
    check(
        level_20.WildSweep == 3
            and level_24.WildSweep == 3
            and level_28.WildSweep == 3,
        "Wild Sweep preserves three purchased ranks per bracket"
    )
    check(
        level_20.PowerSmash == 3
            and level_24.PowerSmash == 3
            and level_28.PowerSmash == 3,
        "Power Smash preserves three purchased ranks per bracket"
    )
    check(
        level_20.PolearmMastery == 1
            and level_24.PolearmMastery == 1
            and level_28.PolearmMastery == 2,
        "Polearm Mastery keeps exact source rank distribution"
    )
    check(
        level_20.LightArmorMastery == 2
            and level_24.LightArmorMastery == 2
            and level_28.LightArmorMastery == 3,
        "Light Armor Mastery keeps exact source rank distribution"
    )
    check(
        level_20.HeavyArmorMastery == 2
            and level_24.HeavyArmorMastery == 2
            and level_28.HeavyArmorMastery == 3,
        "Heavy Armor Mastery keeps exact source rank distribution"
    )
    check(
        level_24.Rage == 1
            and level_20.Rage == nil
            and level_28.Rage == nil,
        "Rage enters exactly at source level 24"
    )
    check(
        level_28.BattleRoar == 1
            and level_20.BattleRoar == nil
            and level_24.BattleRoar == nil,
        "Battle Roar enters exactly at source level 28"
    )

    print(
        ("[Orc Raider Source Audit] PASS: %d assertions rows=63")
            :format(checks)
    )
end

main()
