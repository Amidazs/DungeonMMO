--!strict
-- All tracked C4 classes: every original rank needs a candidate
-- or an explicit documented gap. A mapped ID is not matching damage.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Audit = require(Shared.C4CreativeSkillLinkAudit)
local Map = require(Shared.C4CreativeSkillSourceMap)

local report = Audit.report()
assert(report.ClassPaths == 11 and report.SourceLearningRows == 657,
    "All tracked level-30 classes and source ranks must be audited")
assert(report.CandidateRows == 635
    and report.ExplicitMissingRows == 22,
    "Tracked source rows must preserve candidate and explicit-gap totals")
assert(report.CandidateRows + report.ExplicitMissingRows == 657,
    "Every historical rank requires a candidate or an explicit gap")
assert(report.UnexaminedOrBrokenRows == 0,
    "Every candidate must resolve to a real class skill and rank")
assert(report.ExplicitMissingRows > 0,
    "Do not silently pretend current skill catalogue is complete")
assert(not report.ExactC4MechanicsCertified
    and not report.LiveSkillMigrationComplete,
    "Source mapping cannot certify skill effects or finished migration")

-- These special ranks cannot be mapped by string-matching names alone.
local wind_one = assert(Map.resolve("HumanMystic", 1177, 1))
local wind_two = assert(Map.resolve("HumanMystic", 1177, 2))
local elven_heal = assert(Map.resolve("ElvenKnight", 58, 4))
local rogue_blade = assert(Map.resolve("HumanRogue", 16, 10))
local elf_aura = assert(Map.resolve("ElvenScout", 91, 2))
local elf_gap = assert(Map.resolve("ElvenScout", 58, 4))
local wizard_bolt = assert(Map.resolve("HumanWizard", 1220, 1))
local wizard_companion = assert(Map.resolve("HumanWizard", 1111, 1))
local cleric_heal = assert(Map.resolve("HumanCleric", 1011, 7))
local cleric_shield = assert(Map.resolve("HumanCleric", 1040, 2))
assert(wind_one.CreativeSkillId == "WindStrike"
    and wind_one.CreativeRank == 1
    and wind_two.CreativeSkillId == "MysticWindBolt"
    and wind_two.CreativeRank == 1,
    "Starter Wind Strike must not lose its distinct first rank")
assert(elven_heal.CreativeRank == 1
    and rogue_blade.CreativeRank == 1
    and elf_aura.CreativeRank == 1
    and elf_gap.Status == "Missing",
    "Original first-transfer offsets and missing Elf Scout heal matter")
assert(wizard_bolt.Status == "Candidate"
    and wizard_bolt.CreativeSkillId == "EmberweaverEmberBolt"
    and wizard_bolt.CreativeRank == 1
    and wizard_companion.Status == "Candidate"
    and wizard_companion.CreativeSkillId
        == "EmberweaverManaCompanion",
    "Wizard direct and companion skills both map after summon authority")

assert(cleric_heal.Status == "Candidate"
    and cleric_heal.CreativeSkillId == "DawnkeeperHealingLight"
    and cleric_heal.CreativeRank == 1
    and cleric_shield.Status == "Candidate"
    and cleric_shield.CreativeSkillId == "DawnkeeperStoneWard"
    and cleric_shield.CreativeRank == 1,
    "Cleric inherited source ranks map to exact Dawnkeeper creative ranks")

for _, class in ipairs(report.Classes) do
    local gaps = {}
    local issues = {}
    for _, row in ipairs(class.Rows) do
        if row.Status == "Missing" then
            table.insert(gaps, ("%s:%s %s"):format(
                row.SourceSkillId, row.SourceRank, row.Reason
            ))
        elseif row.Issue then
            table.insert(issues, ("%s:%s %s"):format(
                row.SourceSkillId, row.SourceRank, row.Issue
            ))
        end
    end
    print(("[C4 CREATIVE LINK] %s sourceRows=%d missing=%d "
        .. "broken=%d creativeExtra=%d")
        :format(class.ScopeId, class.SourceRows, #gaps, #issues,
            #class.CreativeSkillsOutsideThisSourceTree))
    for _, item in ipairs(gaps) do
        print("[C4 CREATIVE GAP] " .. class.ScopeId .. " " .. item)
    end
    for _, id in ipairs(class.CreativeSkillsOutsideThisSourceTree) do
        print("[C4 CREATIVE EXTRA] " .. class.ScopeId .. " " .. id)
    end
end
print(("[C4 CREATIVE LINK] AUDIT_PASS paths=%d rows=%d "
    .. "candidate=%d explicitGap=%d broken=%d differentMP=%d "
    .. "liveEffectParity=NOT_CERTIFIED")
    :format(report.ClassPaths, report.SourceLearningRows,
        report.CandidateRows, report.ExplicitMissingRows,
        report.UnexaminedOrBrokenRows,
        report.CandidateRowsWithDifferentMpNumbers))
