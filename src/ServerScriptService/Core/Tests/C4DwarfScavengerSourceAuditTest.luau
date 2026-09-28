--!strict
-- Direct pinned Scavenger source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Sources = require(Shared.C4DwarfScavengerLevel30Sources)
local SkillTree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)

local checks = 0

--[[
Counts one Scavenger source-audit assertion.

Args:
    valid (boolean): Expected pinned-source condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Scavenger Source Audit] " .. label)
end

--[[
Counts every separately purchasable source rank in one bracket.

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
Runs the exact class-54 launch source audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source checks pass.
]]
local function main()
    local source = Sources.get()

    check(source.SourceClass == "Scavenger", "source class name")
    check(source.SourceClassId == 54, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    check(count_bracket(assert(source.Levels[20])) == 15,
        "level 20 has 15 rank rows")
    check(count_bracket(assert(source.Levels[24])) == 15,
        "level 24 has 15 rank rows")
    check(count_bracket(assert(source.Levels[28])) == 19,
        "level 28 has 19 rank rows")
    check(source.Levels[25] == nil and source.Levels[30] == nil,
        "no invented 25/30 brackets")

    local scavenger = SkillTree.get("DwarfScavenger")
    check(scavenger ~= nil and #scavenger.Rows == 49,
        "Scavenger has exact 49 rows")

    local spoil2 = assert(Effects.get_rank(254, 2))
    local spoil3 = assert(Effects.get_rank(254, 3))
    local festival = assert(Effects.get_rank(302, 1))
    check(
        spoil2.Sets.mpConsume == 19
            and spoil2.Sets.magicLvl == 20,
        "Spoil rank 2 exact source cost and magic level"
    )
    check(
        spoil3.Sets.mpConsume == 25
            and spoil3.Sets.magicLvl == 28,
        "Spoil rank 3 exact source cost and magic level"
    )
    check(
        festival.Sets.mpConsume == 73
            and festival.Sets.magicLvl == 28
            and festival.Sets.target == "TARGET_AREA"
            and festival.Sets.skillRadius == 200,
        "Spoil Festival rank 1 exact source fields"
    )

    local coverage = SkillTree.coverage()
    check(coverage.PathCount == 24, "coverage expands to 24 paths")
    check(coverage.RowCount == 1419, "coverage expands to 1419 rows")
    check(coverage.UniqueSourceSkillIds == 171,
        "coverage expands to 171 unique source skill ids")

    print(
        ("[Dwarf Scavenger Source Audit] PASS: %d assertions rows=49")
            :format(checks)
    )
end

main()
