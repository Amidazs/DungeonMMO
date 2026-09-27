--!strict
-- Direct pinned Dwarven Fighter / Artisan source inventory regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local ArtisanSource = require(Shared.C4DwarfArtisanLevel30Sources)
local SkillTree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)

local checks = 0

--[[
Counts one Dwarf source-audit assertion.

Args:
    valid (boolean): Expected pinned-source condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Artisan Source Audit] " .. label)
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
Runs the exact class-53/class-56 launch source audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after exact source checks pass.
]]
local function main()
    local source = ArtisanSource.get()

    check(source.SourceClass == "Artisan", "source class name")
    check(source.SourceClassId == 56, "source class id")
    check(
        source.SourceCommit
            == "07f8536384e799f128d44198dd7ab23519660eea",
        "pinned C4 source commit"
    )

    check(count_bracket(assert(source.Levels[20])) == 16,
        "level 20 has 16 rank rows")
    check(count_bracket(assert(source.Levels[24])) == 15,
        "level 24 has 15 rank rows")
    check(count_bracket(assert(source.Levels[28])) == 19,
        "level 28 has 19 rank rows")
    check(source.Levels[25] == nil and source.Levels[30] == nil,
        "no invented 25/30 brackets")

    local starter = SkillTree.get("DwarvenFighter")
    local artisan = SkillTree.get("DwarfArtisan")
    check(starter ~= nil and #starter.Rows == 15,
        "Dwarven Fighter has exact 15 rows")
    check(artisan ~= nil and #artisan.Rows == 50,
        "Artisan has exact 50 rows")

    for _, skill_id in ipairs({
        25, 42, 150, 172, 205, 248, 254, 1321,
    }) do
        check(Effects.get(skill_id) ~= nil,
            "source effect exists for " .. tostring(skill_id))
    end

    local coverage = SkillTree.coverage()
    check(coverage.PathCount == 23, "coverage expands to 23 paths")
    check(coverage.RowCount == 1370, "coverage expands to 1370 rows")
    check(coverage.UniqueSourceSkillIds == 170,
        "coverage expands to 170 unique source skill ids")

    print(
        ("[Dwarf Artisan Source Audit] PASS: %d assertions rows=65")
            :format(checks)
    )
end

main()
