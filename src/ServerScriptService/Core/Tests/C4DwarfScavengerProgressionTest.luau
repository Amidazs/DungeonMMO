--!strict
-- Deepclaimer source mapping, exact stats and rank schedule regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Coverage = require(Shared.C4Level30LaunchCoverage)
local CreativeMap = require(Shared.C4CreativeSkillSourceMap)
local SkillTree = require(Shared.C4Level30SkillTreeSource)
local Stats = require(Shared.C4PrimaryStatReference)

local checks = 0

--[[
Counts one Deepclaimer progression assertion.

Args:
    valid (boolean): Expected exact source/progression condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Deepclaimer Progression] " .. label)
end

--[[
Checks that every Scavenger source row resolves to a creative candidate.

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
Runs the exact Deepclaimer launch progression audit.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all source checks pass.
]]
local function main()
    local coverage = assert(Coverage.for_branch("DwarfScavenger"))

    check(
        coverage.SourceRankEntriesThroughCap == 49,
        "Scavenger has 49 source rank rows"
    )
    check(
        coverage.SourceRankEntriesByLevel[20] == 14
            and coverage.SourceRankEntriesByLevel[24] == 12
            and coverage.SourceRankEntriesByLevel[28] == 23,
        "Scavenger keeps exact 14/12/23 source brackets"
    )
    check(
        coverage.TrainerMappedRankEntries == 49,
        "all 49 rows map to the Deepclaimer trainer"
    )
    check(
        coverage.MissingRankScheduleEntries == 0
            and coverage.SourceRankScheduleMapped,
        "Deepclaimer source schedule has zero rank gaps"
    )

    check_scope("DwarfScavenger")

    local spoil2 = assert(
        CreativeMap.resolve("DwarfScavenger", 254, 2)
    )
    local spoil3 = assert(
        CreativeMap.resolve("DwarfScavenger", 254, 3)
    )
    check(
        spoil2.CreativeSkillId == "DeepclaimerSalvageMark"
            and spoil2.CreativeRank == 1
            and spoil3.CreativeRank == 2,
        "Spoil ranks 2/3 continue after inherited starter Spoil rank 1"
    )

    local festival = assert(
        CreativeMap.resolve("DwarfScavenger", 302, 1)
    )
    check(
        festival.CreativeSkillId == "DeepclaimerSalvageFestival"
            and festival.CreativeRank == 1,
        "Spoil Festival rank 1 maps independently at level 28"
    )

    local vitals, reason = Stats.get_level_vitals(
        "Dwarf",
        "Deepclaimer",
        30
    )
    check(reason == nil and vitals ~= nil, "level-30 vitals resolve")
    check(vitals.MaxHP == 1197, "exact level-30 HP is 1197")
    check(vitals.MaxMP == 327, "exact level-30 MP is 327")
    check(vitals.MaxCP == 834, "exact level-30 CP is 834")

    local reference = assert(Stats.get("Dwarf", "Deepclaimer"))
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
        ("[Deepclaimer Progression] PASS: %d assertions")
            :format(checks)
    )
end

main()
