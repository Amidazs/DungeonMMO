--!strict
-- Reusable, character-owned C4 recipe literacy and common creation gates.
local ProfessionSelectionRules = require(
    script.Parent:WaitForChild("ProfessionSelectionRules")
)

local FirstTransfers = require(
    script.Parent:WaitForChild("OriginalFirstTransferDefinitions")
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

--[[
Authorizes one of the three genuinely purchased first-transfer crafting ranks.

Args:
    character (any): Current authoritative Rogue/Ranger character.
    profession_id (string): Its one selected creation profession.
    required_rank (number): Authored recipe tier, from one to three.

Returns:
    boolean: True only when literacy, source class/level and purchased
        creation rank all authorize this specific career and tier.
]]
function C4ProfessionSkillRules.can_make_scout_common(
    character: any, profession_id: string, required_rank: number
): boolean
    if type(character) ~= "table"
        or type(required_rank) ~= "number"
        or required_rank % 1 ~= 0
        or required_rank < 1 or required_rank > 3
        or not C4ProfessionSkillRules.can_read(
            character, profession_id
        )
    then
        return false
    end

    local identity = character.Identity or {}
    if identity.BaseClassId ~= "Ranger"
        and identity.BaseClassId ~= "Rogue"
    then
        return false
    end
    if identity.RaceId ~= "Human" and identity.RaceId ~= "Elf" then
        return false
    end

    local source_levels = {20, 28, 36}
    local level = tonumber(character.Level) or 0
    if level < source_levels[required_rank] then
        return false
    end

    local state = character.Progression
        and character.Progression.Skills
        and character.Progression.Skills.ScoutCommonItemCreation
    return type(state) == "table"
        and state.Known == true
        and type(state.PurchasedRank) == "number"
        and state.PurchasedRank >= required_rank
        and state.PurchasedRank <= 3
end

--[[
Authorizes only real personally earned Knight common-item creation tiers.

The original source tiers 2 and 3 are represented by purchased ranks
one and two, at owner levels 20 and 28. Crafting never grants a second
profession; it still requires starter recipe literacy and common creation.

Args:
    character (any): Authoritative server-owned character profile.
    profession_id (string): This character's one selected craft career.
    required_rank (number): Authored Knight recipe tier, one or two.

Returns:
    boolean: True only for verified class, skills, level and career.
]]
function C4ProfessionSkillRules.can_make_knight_common(
    character: any,
    profession_id: string,
    required_rank: number
): boolean
    if type(character) ~= "table"
        or type(required_rank) ~= "number"
        or required_rank % 1 ~= 0
        or required_rank < 1 or required_rank > 2
        or not C4ProfessionSkillRules.can_make_common(
            character, profession_id
        )
    then
        return false
    end
    local awarded = FirstTransfers.awarded(character)
    if not awarded or awarded.Id ~= "Oathguard" then
        return false
    end
    local levels = {20, 28}
    if (tonumber(character.Level) or 0)
        < levels[required_rank]
    then
        return false
    end
    local skills = character.Progression
        and character.Progression.Skills
    local state = skills and skills.OathguardCommonItemCreation
    return type(state) == "table"
        and state.Known == true
        and type(state.PurchasedRank) == "number"
        and state.PurchasedRank >= required_rank
        and state.PurchasedRank <= 2
end

return table.freeze(C4ProfessionSkillRules)
