--!strict
-- Exact Elven Wizard level-30 source inventory audit.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local Sources = require(Shared.C4ElvenWizardLevel30Sources)

local checks = 0

--[[
Counts one exact Elven Wizard source-audit assertion.

Args:
    condition (boolean): Observed source inventory state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Elven Wizard Source Audit] " .. label)
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
Runs the exact C4 Elven Wizard level-30 source inventory audit.

Args:
    None.

Returns:
    nil: Prints bounded source-only evidence after every check passes.
]]
local function main()
    local source = Sources.get()

    check(
        source.SourceClass == "Elven Wizard",
        "source inventory keeps the exact historical class identity"
    )
    check(
        count_rows(source.Levels[20]) == 24
            and count_rows(source.Levels[25]) == 29
            and count_rows(source.Levels[30]) == 29,
        "20/25/30 source brackets preserve exact 24/29/29 row counts"
    )
    check(
        count_rows(source.Levels[20])
            + count_rows(source.Levels[25])
            + count_rows(source.Levels[30]) == 82,
        "Elven Wizard has exactly 82 source rank rows through level 30"
    )
    check(
        source.Levels[20].WaterBolt == 2
            and source.Levels[25].ResistWater == 1
            and source.Levels[25].HolyBolt == 1
            and source.Levels[30].HolyBolt == 1,
        "class-specific water, resistance and holy families stay distinct"
    )
    check(
        source.Levels[20].ManaServitorSummon == 1
            and source.Levels[20].CombatServitorSummon == 1
            and source.Levels[25].ServitorRecharge == 2
            and source.Levels[30].ServitorHeal == 3,
        "companion-dependent source rows remain explicitly counted"
    )

    local branches = assert(Branches.get("Elf", "Mage"))
    local branch = assert(Branches.find(
        "Elf",
        "Mage",
        "ElvenWizard"
    ))
    check(
        #branches == 2
            and branch.SourceSkillInventory
                == "C4ElvenWizardLevel30Sources"
            and branch.GameplayStatus == "Partial",
        "Moonweaver foundation is explicit while release remains partial"
    )

    local audit = assert(Coverage.for_branch("ElvenWizard"))
    check(
        audit.SourceRankEntriesThroughCap == 82
            and audit.SourceRankEntriesByLevel[20] == 24
            and audit.SourceRankEntriesByLevel[25] == 29
            and audit.SourceRankEntriesByLevel[30] == 29,
        "launch coverage reads the exact independently counted inventory"
    )
    check(
        audit.CurrentCareerId == "Moonweaver"
            and audit.TrainerMappedRankEntries == 82
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped
            and audit.Status
                == "RankScheduleMappedEffectsPending",
        "all 82 rows now have class-bound Moonweaver training schedules"
    )

    print((
        "[Elven Wizard Source Audit] PASS: %d assertions rows=82"
    ):format(checks))
end

main()
