--!strict
-- Gearwright source mapping, exact stats and rank schedule regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Coverage = require(Shared.C4Level30LaunchCoverage)
local CreativeMap = require(Shared.C4CreativeSkillSourceMap)
local SkillTree = require(Shared.C4Level30SkillTreeSource)
local Stats = require(Shared.C4PrimaryStatReference)

local checks = 0

--[[
Counts one Gearwright progression assertion.

Args:
    valid (boolean): Expected exact source/progression condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Gearwright Progression] " .. label)
end

--[[
Checks that every source row resolves to one creative rank candidate.

Args:
    scope_id (string): Original source learning-tree scope.

Returns:
    nil: Verifies every row is mapped without a source gap.
]]
local function check_scope(scope_id: string)
    local source = assert(SkillTree.get(scope_id))

    for _, row in ipairs(source.Rows) do
        local resolved = CreativeMap.resolve(
            scope_id,
            row.SkillId,
            row.SkillLevel
        )
        check(
            resolved ~= nil and resolved.Status == "Candidate",
            scope_id .. " source row maps "
                .. tostring(row.SkillId)
                .. ":"
                .. tostring(row.SkillLevel)
        )
    end
end

--[[
Runs the exact Gearwright launch progression audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all source checks pass.
]]
local function main()
    local coverage = assert(Coverage.for_branch("DwarfArtisan"))

    check(
        coverage.SourceRankEntriesThroughCap == 50,
        "Artisan has 50 source rank rows"
    )
    check(
        coverage.TrainerMappedRankEntries == 50,
        "all 50 rows map to the Gearwright trainer"
    )
    check(
        coverage.MissingRankScheduleEntries == 0,
        "Gearwright rank schedule has zero gaps"
    )
    check(
        coverage.SourceRankScheduleMapped == true,
        "Gearwright source schedule is fully mapped"
    )

    check_scope("DwarvenFighter")
    check_scope("DwarfArtisan")

    local create_rank = assert(
        CreativeMap.resolve("DwarfArtisan", 172, 2)
    )
    check(
        create_rank.CreativeSkillId == "GearwrightBlueprintTraining"
            and create_rank.CreativeRank == 1,
        "Create Item rank 2 becomes blueprint training rank 1"
    )

    local load_rank = assert(
        CreativeMap.resolve("DwarfArtisan", 150, 2)
    )
    check(
        load_rank.CreativeSkillId == "GearwrightPackTraining"
            and load_rank.CreativeRank == 1,
        "Weight Limit rank 2 continues after starter rank 1"
    )

    local vitals, reason = Stats.get_level_vitals(
        "Dwarf",
        "Gearwright",
        30
    )
    check(reason == nil and vitals ~= nil, "level-30 vitals resolve")
    check(vitals.MaxHP == 1161, "exact level-30 HP is 1161")
    check(vitals.MaxMP == 327, "exact level-30 MP is 327")
    check(vitals.MaxCP == 921, "exact level-30 CP is 921")

    local reference = assert(Stats.get("Dwarf", "Gearwright"))
    check(
        reference.Stats.STR == 39
            and reference.Stats.DEX == 29
            and reference.Stats.CON == 45,
        "exact physical primary stats"
    )
    check(
        reference.Stats.INT == 20
            and reference.Stats.WIT == 10
            and reference.Stats.MEN == 27,
        "exact mental primary stats"
    )

    print(
        ("[Gearwright Progression] PASS: %d assertions")
            :format(checks)
    )
end

main()
