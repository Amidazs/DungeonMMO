--!strict
-- Original Chronicle 4 equipment-grade expertise thresholds.

local Shared = script.Parent

local C4SourceItemReference = require(
    Shared:WaitForChild("C4SourceItemReference")
)

local C4EquipmentExpertiseRules = {}

local SOURCE_SKILL_ID = 239
local GRADE_LEVELS = table.freeze({
    D = 20,
    C = 40,
    B = 52,
    A = 61,
    S = 76,
})

--[[
Returns the original minimum level for one source equipment grade.

Gradeless items require no expertise level. Unknown grades fail closed.

Args:
    grade (any): Original item grade, or nil for gradeless equipment.

Returns:
    (number?, string?): Minimum character level or strict rejection reason.
]]
function C4EquipmentExpertiseRules.required_level(
    grade: any
): (number?, string?)
    if grade == nil then
        return 1, nil
    end

    if type(grade) ~= "string" then
        return nil, "UnknownOriginalEquipmentGrade"
    end

    local required_level = GRADE_LEVELS[grade]
    if not required_level then
        return nil, "UnknownOriginalEquipmentGrade"
    end

    return required_level, nil
end

--[[
Checks a reviewed original equipment loadout against C4 Expertise levels.

The pinned C4 runtime awards Expertise skill 239 from character level:
D=20, C=40, B=52, A=61 and S=76. The launch cap currently reaches D only,
but the complete thresholds are kept so later level-cap expansion does not
need a second balance rule.

Args:
    level (number): Authoritative current character level.
    source_item_ids (any): Reviewed source item IDs by source paperdoll slot.

Returns:
    (any?, string?): Source expertise result or strict rejection reason.
]]
function C4EquipmentExpertiseRules.validate(
    level: number,
    source_item_ids: any
): (any?, string?)
    if type(level) ~= "number"
        or level ~= level
        or level % 1 ~= 0
        or level < 1
    then
        return nil, "InvalidOriginalEquipmentLevel"
    end

    local resolved, reason = C4SourceItemReference.resolve(
        source_item_ids
    )
    if not resolved then
        return nil, reason
    end

    local highest_required_level = 1
    local highest_grade = nil

    for _, item in pairs(resolved.Items) do
        local required_level, grade_reason =
            C4EquipmentExpertiseRules.required_level(item.Grade)

        if not required_level then
            return nil, grade_reason
        end

        if required_level > level then
            return nil, "OriginalEquipmentGradeExpertiseRequired"
        end

        if required_level > highest_required_level then
            highest_required_level = required_level
            highest_grade = item.Grade
        end
    end

    return {
        Level = level,
        SourceExpertiseSkillId = SOURCE_SKILL_ID,
        HighestRequiredLevel = highest_required_level,
        HighestRequiredGrade = highest_grade,
        Eligible = true,
        SourceOnly = true,
        LiveIntegrated = false,
    }, nil
end

return table.freeze(C4EquipmentExpertiseRules)
