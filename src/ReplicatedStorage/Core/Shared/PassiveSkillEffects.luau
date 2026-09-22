--!strict
-- Pure, server-readable passive effect rules for learned skill ranks.
local SkillDefinitions = require(
    script.Parent:WaitForChild("SkillProgressionDefinitions")
)

local PassiveSkillEffects = {}

-- Resolves a character's purchased passive damage bonus, not proficiency.
-- Passive ranks are trained with SP and level; they are not cast or slotted.
--
-- Args:
--   character (any): Server-owned character or runtime snapshot.
--   skill_id (string): Registered class-specific passive identifier.
-- Returns:
--   number: Additive damage multiplier bonus, or zero if ineligible.
function PassiveSkillEffects.damage_bonus(
    character: any,
    skill_id: string
): number
    local definition = SkillDefinitions.get(skill_id)
    if type(character) ~= "table"
        or type(definition) ~= "table"
        or definition.Kind ~= "Passive"
    then
        return 0
    end

    local identity = character.Identity
    local allowed_classes = definition.AllowedBaseClasses
    if type(identity) ~= "table"
        or type(allowed_classes) ~= "table"
    then
        return 0
    end

    local eligible = false
    for _, class_id in ipairs(allowed_classes) do
        if identity.BaseClassId == class_id then
            eligible = true
            break
        end
    end
    if not eligible then
        return 0
    end

    local progression = character.Progression
    local skills = type(progression) == "table"
        and progression.Skills
    local state = type(skills) == "table" and skills[skill_id]
    if type(state) ~= "table" or state.Known ~= true then
        return 0
    end

    local purchased = math.floor(
        tonumber(state.PurchasedRank) or 0
    )
    local rank = math.clamp(purchased, 0, definition.MaxRank)
    return rank * (definition.DamageBonusPerRank or 0)
end

return table.freeze(PassiveSkillEffects)
