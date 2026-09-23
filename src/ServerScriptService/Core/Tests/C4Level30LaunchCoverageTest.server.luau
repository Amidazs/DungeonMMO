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
    check(#audit.AuthoredClassSkillsThroughCap > 20,
        "Earned first-transfer career offers original shared and class skills")
    check(audit.TrainerMappedRankEntries == expected.total
        and audit.MissingRankScheduleEntries == 0
        and audit.SourceRankScheduleMapped,
        "Every recorded source rank must have a correctly gated real "
            .. "trainer entry at its exact reference level")
    check(audit.SourceInventoryAuditedThroughCap
        and not audit.ExactSourceRankCoverageCertified
        and not audit.LaunchSkillCatalogueReady,
        "Matching training rows cannot certify every live combat effect")
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
    check(report.SourceAuditedBranches == 4
        and report.RankSchedulesMappedBranches == 2
        and report.VerifiedCompleteBranches == 0
        and not report.ReleaseSkillGatePassed,
        "Do not certify unreviewed source branches or incomplete trees")
    local warrior = assert(Coverage.for_branch("HumanWarrior"))
    check(warrior.Status == "SkillRankParityOutstanding"
        and warrior.SourceRankEntriesThroughCap == 62
        and warrior.SourceRankEntriesByLevel[20] == 20
        and warrior.SourceRankEntriesByLevel[24] == 19
        and warrior.SourceRankEntriesByLevel[28] == 23,
        "Historical Warrior 20/24/28 rank inventory is now complete")
    check(warrior.TrainerMappedRankEntries == 24
        and warrior.MissingRankScheduleEntries == 38
        and not warrior.SourceRankScheduleMapped
        and not warrior.LaunchSkillCatalogueReady,
        "Ironvow has only four fully scheduled real trainer families; "
            .. "blunt, polearm, HP and utility rows must remain outstanding")
    local knight = assert(Coverage.for_branch("HumanKnight"))
    check(knight.Status == "SkillRankParityOutstanding"
        and knight.SourceRankEntriesThroughCap == 54
        and knight.SourceRankEntriesByLevel[20] == 16
        and knight.SourceRankEntriesByLevel[24] == 16
        and knight.SourceRankEntriesByLevel[28] == 22,
        "Historical Knight 20/24/28 inventory does not grant a class")
    check(Coverage.for_branch("UnknownCareer") == nil,
        "Invented classes must not count toward release coverage")
    print(("[Level 30 Launch] PASS: %d assertions")
        :format(checks))
end

main()
