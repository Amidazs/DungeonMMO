--!strict
-- Reusable, character-owned C4 recipe literacy and common creation gates.
local ProfessionSelectionRules = require(
    script.Parent:WaitForChild("ProfessionSelectionRules")
)

local C4ProfessionSkillRules = {}

--[[
Checks an earned passive skill on the authoritative character profile.

Args:
    character (any): Server-owned or detached test character.
    skill_id (string): Authored C4 passive identifier.

Returns:
    boolean: True only for a bought or earned rank on this character.
]]
local function owns_rank(character: any, skill_id: string): boolean
    local progression = type(character) == "table"
        and character.Progression
    local skills = type(progression) == "table" and progression.Skills
    local state = type(skills) == "table" and skills[skill_id]
    return type(state) == "table" and state.Known == true
        and (tonumber(state.PurchasedRank) or 0) >= 1
end

--[[
Checks whether the character may study its selected career's blueprint.

Args:
    character (any): Server-owned character with purchased skills.
    profession_id (string): Registered creation profession.

Returns:
    boolean: True only with that crafting career and Recipe Reading.
]]
function C4ProfessionSkillRules.can_read(
    character: any, profession_id: string
): boolean
    return ProfessionSelectionRules.can_use(
        character and character.ProfessionSlots, profession_id
    ) and owns_rank(character, "C4RecipeReading")
end

--[[
Checks whether a skill-based common recipe may run server-side.

Args:
    character (any): Server-owned character with purchased skills.
    profession_id (string): Required selected crafting profession.

Returns:
    boolean: True only when both C4 ranks and career are owned.
]]
function C4ProfessionSkillRules.can_make_common(
    character: any, profession_id: string
): boolean
    return C4ProfessionSkillRules.can_read(character, profession_id)
        and owns_rank(character, "C4CommonItemCreation")
end

return table.freeze(C4ProfessionSkillRules)
