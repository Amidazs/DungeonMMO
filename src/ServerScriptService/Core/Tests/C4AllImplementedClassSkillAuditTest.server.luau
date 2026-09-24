--!strict
-- Passing means EVERY authored rank has been enumerated, not C4 matched.
local RS = game:GetService("ReplicatedStorage")
local audit = require(
    RS.Core.Shared.C4AllImplementedClassSkillAudit
).report()

assert(audit.ClassScopes == 13
    and audit.ExactC4MechanicalParityCertified == false,
    "All four starters, five original careers and four legacy races")
local found = {}
for _, entry in ipairs(audit.Classes) do
    assert(entry.SkillFamilies > 0 and entry.RankRows > 0,
        "Empty current class scope cannot count as inspected")
    assert(entry.ExactC4MechanicsCertified == false,
        "Unverified current class cannot be marked C4-equivalent")
    assert(entry.RankRowsWithoutExactSource
            + entry.SourceRowsReviewed == entry.RankRows,
        "Every current rank must have an explicit evidence status")
    if not entry.Legacy then
        assert(entry.SourceRowsReviewed > 0,
            "Each original class requires a sourced numerical example")
    end
    found[entry.Id] = true
    print(("[C4 ALL-CLASS AUDIT] %s families=%d ranks=%d "
        .. "source_rows=%d unverified=%d legacy=%s")
        :format(entry.Id, entry.SkillFamilies, entry.RankRows,
            entry.SourceRowsReviewed, entry.RankRowsWithoutExactSource,
            tostring(entry.Legacy)))
end
for _, class_id in ipairs({
    "HumanFighter", "ElvenFighter", "HumanMystic", "ElvenMystic",
    "HumanRogue", "ElvenScout", "HumanWarrior", "HumanKnight",
    "ElvenKnight", "LegacyHumanRanger", "LegacyElvenRanger",
    "LegacyHumanRogue", "LegacyElvenRogue",
}) do
    assert(found[class_id], "Current class omitted: " .. class_id)
end
print(("[C4 ALL-CLASS AUDIT] AUDIT_ONLY scopes=%d "
    .. "rank_rows=%d sourced=%d missing_source=%d parity=OPEN")
    :format(audit.ClassScopes, audit.RanksExamined,
        audit.SourceRowsReviewed,
        audit.OtherRankRowsNotSourceVerified))
