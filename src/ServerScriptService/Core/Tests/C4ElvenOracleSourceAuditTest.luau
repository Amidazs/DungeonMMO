--!strict
-- Exact Elven Oracle level-30 source inventory audit.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local Sources = require(Shared.C4ElvenOracleLevel30Sources)

local checks = 0

--[[
Counts one exact Elven Oracle source-audit assertion.

Args:
    condition (boolean): Observed source inventory state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Elven Oracle Source Audit] " .. label)
end

--[[
Counts rank rows in one source bracket.

Args:
    categories (any): Historical source family counts.

Returns:
    number: Total separately purchasable source ranks in the bracket.
]]
local function count_rows(categories: any): number
    local total = 0

    for _, count in pairs(categories) do
        total += count
    end

    return total
end

--[[
Runs the exact C4 Elven Oracle level-30 source inventory audit.

Args:
    None.

Returns:
    nil: Prints bounded source-only evidence after every check passes.
]]
local function main()
    local source = Sources.get()

    check(
        source.SourceClass == "Elven Oracle"
            and source.SourceClassId == 29,
        "source inventory keeps exact historical Oracle identity"
    )
    check(
        count_rows(source.Levels[20]) == 26
            and count_rows(source.Levels[25]) == 32
            and count_rows(source.Levels[30]) == 33,
        "20/25/30 source brackets preserve exact 26/32/33 row counts"
    )
    check(
        count_rows(source.Levels[20])
            + count_rows(source.Levels[25])
            + count_rows(source.Levels[30]) == 91,
        "Elven Oracle has exactly 91 source rank rows through level 30"
    )
    check(
        source.Levels[20].KissOfEva == 1
            and source.Levels[25].Agility == 1
            and source.Levels[30].Recharge == 2
            and source.Levels[30].WindShackle == 1,
        "Oracle-specific support and wind families stay explicit"
    )

    local branch = assert(Branches.find(
        "Elf",
        "Mage",
        "ElvenOracle"
    ))
    check(
        branch.SourceSkillInventory
            == "C4ElvenOracleLevel30Sources"
            and branch.GameplayStatus == "Partial",
        "Lifebinder source inventory is registered while release is partial"
    )

    local audit = assert(Coverage.for_branch("ElvenOracle"))
    check(
        audit.SourceRankEntriesThroughCap == 91
            and audit.SourceRankEntriesByLevel[20] == 26
            and audit.SourceRankEntriesByLevel[25] == 32
            and audit.SourceRankEntriesByLevel[30] == 33,
        "launch coverage reads exact independently counted Oracle rows"
    )
    check(
        audit.CurrentCareerId == "Lifebinder"
            and audit.TrainerMappedRankEntries == 91
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped
            and audit.Status
                == "RankScheduleMappedEffectsPending",
        "all 91 rows have class-bound Lifebinder training schedules"
    )

    print((
        "[Elven Oracle Source Audit] PASS: %d assertions rows=91"
    ):format(checks))
end

main()
