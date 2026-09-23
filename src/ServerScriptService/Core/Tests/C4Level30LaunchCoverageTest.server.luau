--!strict
-- Historic C4 bracket-to-DungeonMMO launch audit contract.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Coverage = require(Shared.C4Level30LaunchCoverage)

local checks = 0

--[[
Verifies one launch skill-audit claim without marking gameplay as complete.

Args:
    valid (boolean): Actual inventory and authored-career contract.
    label (string): Expected branch/bracket coverage condition.

Returns:
    nil: Fails the focused test or increments successful checks.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Level 30 Launch] " .. label)
end

--[[
Checks the complete counted source rank inventory of a first class.

Args:
    branch_id (string): Registered first-transfer source branch.
    expected (any): Audited historical bracket counts and current class.

Returns:
    nil: Exposes remaining skill work without equating legacy analogues.
]]
local function check_branch(branch_id: string, expected: any)
    local audit = assert(Coverage.for_branch(branch_id))
    check(audit.LevelCap == 30, "First-transfer launch cap is level 30")
    check(audit.CurrentCareerId == expected.career,
        "Audit must select the genuine separately earned class")
    check(audit.SourceRankEntriesThroughCap == expected.total,
        "Reference rank opportunities must count each original rank")
    for level, count in pairs(expected.brackets) do
        check(audit.SourceRankEntriesByLevel[level] == count,
            "Incorrect original reference count at level "
                .. tostring(level))
    end
    check(audit.SourceRankEntriesByLevel[32] == nil,
        "Level-32 reference ranks belong in postlaunch updates")
    check(#audit.AuthoredClassSkillsThroughCap == 2,
        "Both earned careers still have only two own-class skills")
    check(audit.SourceInventoryAuditedThroughCap
        and not audit.ExactSourceRankCoverageCertified
        and not audit.LaunchSkillCatalogueReady,
        "A legacy analogue or incomplete class must not pass parity")
end

--[[
Checks the launch contract for all 18 original first-transfer paths.

Args:
    None.

Returns:
    nil: Prints only verified numeric and readiness assertions.
]]
local function main()
    check_branch("HumanRogue", {
        career = "Ashenblade",
        total = 59,
        brackets = {[20] = 20, [24] = 19, [28] = 20},
    })
    check_branch("ElvenScout", {
        career = "GreenwardScout",
        total = 77,
        brackets = {[20] = 26, [24] = 25, [28] = 26},
    })
    local report = Coverage.report()
    check(report.FirstTransferBranches == 18,
        "All original first-transfer branches belong in launch audit")
    check(report.SourceAuditedBranches == 2
        and report.VerifiedCompleteBranches == 0
        and not report.ReleaseSkillGatePassed,
        "Do not certify unreviewed source branches or incomplete trees")
    local warrior = assert(Coverage.for_branch("HumanWarrior"))
    check(warrior.Status == "HistoricalSourceAuditOutstanding"
        and warrior.SourceRankEntriesThroughCap == nil,
        "Level-20-only historical Warrior notes are not full cap parity")
    check(Coverage.for_branch("UnknownCareer") == nil,
        "Invented classes must not count toward release coverage")
    print(("[Level 30 Launch] PASS: %d assertions")
        :format(checks))
end

main()
