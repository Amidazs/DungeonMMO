--!strict
-- Historic C4 bracket-to-DungeonMMO launch audit contract.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Coverage = require(Shared.C4Level30LaunchCoverage)
local Branches = require(Shared.C4FirstTransferBranches)
local BaseInventory = require(Shared.C4BaseSkillInventory)

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
    local human_paths = assert(Branches.get("Human", "Fighter"))
    local elven_paths = assert(Branches.get("Elf", "Fighter"))
    check(#human_paths == 3
        and human_paths[1].Id == "HumanWarrior"
        and human_paths[2].Id == "HumanKnight"
        and human_paths[3].Id == "HumanRogue",
        "Human Fighter must keep its three separate first transfers")
    check(#elven_paths == 2
        and elven_paths[1].Id == "ElvenKnight"
        and elven_paths[2].Id == "ElvenScout",
        "Elven Fighter must keep both its Knight and Scout branches")
    check(BaseInventory.get("Human", "Fighter") ~= nil
        and BaseInventory.get("Elf", "Fighter") ~= nil,
        "Human and Elven starter skill inventories must stay separate")
    local elven_knight = assert(Coverage.for_branch("ElvenKnight"))
    check(elven_knight.SourceClass == "Elven Knight"
        and elven_knight.CurrentCareerId == "GreenwardWarden"
        and elven_knight.SourceInventoryAuditedThroughCap == true
        and elven_knight.SourceRankEntriesThroughCap == 56
        and elven_knight.SourceRankEntriesByLevel[20] == 18
        and elven_knight.SourceRankEntriesByLevel[24] == 18
        and elven_knight.SourceRankEntriesByLevel[28] == 20,
        "Elven Knight must keep its independently sourced 56 ranks")
    check(elven_knight.TrainerMappedRankEntries == 56
        and elven_knight.MissingRankScheduleEntries == 0
        and elven_knight.SourceRankScheduleMapped
        and not elven_knight.ExactSourceRankCoverageCertified
        and not elven_knight.LaunchSkillCatalogueReady
        and elven_knight.Status == "RankScheduleMappedEffectsPending",
        "All Warden ranks map independently, without release certification")
    local wizard = assert(Coverage.for_branch("HumanWizard"))
    check(wizard.SourceClass == "Human Wizard"
        and wizard.SourceInventoryAuditedThroughCap == true
        and wizard.SourceRankEntriesThroughCap == 93
        and wizard.SourceRankEntriesByLevel[20] == 29
        and wizard.SourceRankEntriesByLevel[25] == 32
        and wizard.SourceRankEntriesByLevel[28] == 1
        and wizard.SourceRankEntriesByLevel[30] == 31
        and #wizard.SourceBrackets == 4
        and wizard.SourceBrackets[1] == 20
        and wizard.SourceBrackets[2] == 25
        and wizard.SourceBrackets[3] == 28
        and wizard.SourceBrackets[4] == 30,
        "Human Wizard C4 source ranks must retain exact launch brackets")
    check(wizard.CurrentCareerId == "Emberweaver"
        and wizard.TrainerMappedRankEntries == 93
        and wizard.MissingRankScheduleEntries == 0
        and wizard.SourceRankScheduleMapped
        and wizard.Status == "RankScheduleMappedEffectsPending",
        "Human Wizard level-30 rank schedule is fully mapped")

    local cleric = assert(Coverage.for_branch("HumanCleric"))
    check(
        cleric.SourceClass == "Cleric"
            and cleric.SourceInventoryAuditedThroughCap
            and cleric.SourceRankEntriesThroughCap == 88
            and cleric.SourceRankEntriesByLevel[20] == 26
            and cleric.SourceRankEntriesByLevel[25] == 31
            and cleric.SourceRankEntriesByLevel[30] == 31
            and #cleric.SourceBrackets == 3,
        "Human Cleric retains exact 20/25/30 source-rank inventory"
    )
    check(
        cleric.CurrentCareerId == "Dawnkeeper"
            and cleric.TrainerMappedRankEntries == 88
            and cleric.MissingRankScheduleEntries == 0
            and cleric.SourceRankScheduleMapped
            and cleric.Status == "RankScheduleMappedEffectsPending",
        "Human Cleric rank schedule maps only through earned Dawnkeeper"
    )

    local elven_wizard = assert(Coverage.for_branch("ElvenWizard"))
    check(
        elven_wizard.SourceClass == "Elven Wizard"
            and elven_wizard.SourceInventoryAuditedThroughCap
            and elven_wizard.SourceRankEntriesThroughCap == 82
            and elven_wizard.SourceRankEntriesByLevel[20] == 24
            and elven_wizard.SourceRankEntriesByLevel[25] == 29
            and elven_wizard.SourceRankEntriesByLevel[30] == 29
            and #elven_wizard.SourceBrackets == 3,
        "Elven Wizard retains exact 20/25/30 source-rank inventory"
    )
    check(
        elven_wizard.CurrentCareerId == nil
            and elven_wizard.TrainerMappedRankEntries == 0
            and elven_wizard.MissingRankScheduleEntries == 82
            and not elven_wizard.SourceRankScheduleMapped
            and elven_wizard.Status
                == "SourceRanksAuditedClassUnimplemented",
        "Elven Wizard source audit stays distinct from implementation"
    )

    local warrior = assert(Coverage.for_branch("HumanWarrior"))
    check(warrior.Status == "RankScheduleMappedEffectsPending"
        and warrior.SourceRankEntriesThroughCap == 62
        and warrior.SourceRankEntriesByLevel[20] == 20
        and warrior.SourceRankEntriesByLevel[24] == 19
        and warrior.SourceRankEntriesByLevel[28] == 23,
        "Historical Warrior 20/24/28 rank inventory is now complete")
    check(warrior.TrainerMappedRankEntries == 62
        and warrior.MissingRankScheduleEntries == 0
        and warrior.SourceRankScheduleMapped
        and not warrior.ExactSourceRankCoverageCertified
        and not warrior.LaunchSkillCatalogueReady,
        "Warrior maps all 62 source training rows; its original C4 "
            .. "gameplay mechanics and class release remain uncertified")
    local knight = assert(Coverage.for_branch("HumanKnight"))
    check(knight.Status == "RankScheduleMappedEffectsPending"
        and knight.SourceRankEntriesThroughCap == 54
        and knight.SourceRankEntriesByLevel[20] == 16
        and knight.SourceRankEntriesByLevel[24] == 16
        and knight.SourceRankEntriesByLevel[28] == 22,
        "Historical Knight 20/24/28 inventory does not grant a class")
    check(knight.TrainerMappedRankEntries == 54
        and knight.MissingRankScheduleEntries == 0
        and knight.SourceRankScheduleMapped
        and not knight.ExactSourceRankCoverageCertified
        and not knight.LaunchSkillCatalogueReady,
        "Knight has all 54 source rank schedules, but live mechanic "
            .. "parity and launch certification are still outstanding")
    local report = Coverage.report()
    check(report.FirstTransferBranches == 18,
        "All original first-transfer branches belong in launch audit")
    check(
        report.SourceAuditedBranches == 8,
        "Exactly eight first-transfer branches have source inventories"
    )
    check(
        report.RankSchedulesMappedBranches == 7,
        "Seven implemented first-transfer branches map trainer ranks"
    )
    check(
        report.VerifiedCompleteBranches == 0,
        "Source inventories and rank schedules do not certify a class"
    )
    check(
        not report.ReleaseSkillGatePassed,
        "Incomplete first-transfer trees must keep the release gate closed"
    )
    check(Coverage.for_branch("UnknownCareer") == nil,
        "Invented classes must not count toward release coverage")
    print(("[Level 30 Launch] PASS: %d assertions")
        :format(checks))
end

main()
