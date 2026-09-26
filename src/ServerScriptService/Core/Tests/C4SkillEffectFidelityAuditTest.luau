--!strict
-- A passing audit means mismatches were REPORTED, not mechanics certified.
local RS = game:GetService("ReplicatedStorage")
local report = require(
    RS.Core.Shared.C4SkillEffectFidelityAudit
).report()

assert(report.ReviewedFamilies == 3 and report.ReviewedRankRows == 24,
    "Verified C4 rank reference rows must not silently disappear")
assert(report.DifferentManaNumbers > 0,
    "Update this audit when MP numbers are actually reconciled")
assert(report.ExactC4ParityCertified == false
    and report.OtherSkillFamiliesStillNeedFullReview,
    "An incomplete audit may never report full original C4 fidelity")
for _, row in ipairs(report.Rows) do
    assert(type(row.OriginalPower) == "number"
        and type(row.OriginalMp) == "number"
        and type(row.RuntimeMagnitude) == "number"
        and type(row.RuntimeMana) == "number",
        "C4 comparison requires actual numeric source and runtime data")
    print(("[C4 FIDELITY OPEN] %s rank %d (C4 rank %d): "
        .. "C4 power=%s C4 MP=%s; Roblox %s=%s mana=%s")
        :format(row.SkillId, row.DungeonRank, row.OriginalRank,
            tostring(row.OriginalPower), tostring(row.OriginalMp),
            row.RuntimeField, tostring(row.RuntimeMagnitude),
            tostring(row.RuntimeMana)))
end
print(("[C4 FIDELITY] AUDIT_ONLY families=%d ranks=%d "
    .. "different_MP_numbers=%d exact_parity=NOT_CERTIFIED")
    :format(report.ReviewedFamilies, report.ReviewedRankRows,
        report.DifferentManaNumbers))
