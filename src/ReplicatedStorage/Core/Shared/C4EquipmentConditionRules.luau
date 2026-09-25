--!strict
-- Exact C4 equipment-kind condition semantics for source skill functions.

local C4EquipmentConditionRules = {}

local ARMOR_KINDS = table.freeze({
    Heavy = true,
    Light = true,
    Magic = true,
})

--[[
Checks one C4 armor type against chest/legs paperdoll semantics.

ConditionUsingItemType requires a matching chest plus either a matching legs
item or a matching FullArmor chest. A chest alone is not enough to activate an
armor-type mastery condition.

Args:
    kind (string): Heavy, Light or Magic source armor type.
    equipment (any): Reviewed source-kind paperdoll metadata.

Returns:
    boolean: True only when the original armor condition is satisfied.
]]
local function matches_armor(
    kind: string,
    equipment: any
): boolean
    if type(equipment) ~= "table"
        or equipment.Body ~= kind
    then
        return false
    end

    if equipment.BodyPart == "FullArmor" then
        return true
    end

    return equipment.Legs == kind
end

--[[
Checks one non-armor C4 item kind against the worn source item mask.

DungeonMMO's reviewed source paperdoll currently exposes Weapon and OffHand
weapon-type masks. These are sufficient for launch skill conditions such as
Sword, Blunt, Dagger, Bow, Pole and Shield.

Args:
    kind (string): One original non-armor item kind.
    equipment (any): Reviewed source-kind paperdoll metadata.

Returns:
    boolean: True when the source kind is currently worn.
]]
local function matches_worn_kind(
    kind: string,
    equipment: any
): boolean
    if type(equipment) ~= "table" then
        return false
    end

    return equipment.Weapon == kind
        or equipment.OffHand == kind
end

--[[
Checks a comma-separated C4 using-kind condition.

Armor kinds reproduce ConditionUsingItemType chest/legs semantics. Non-armor
kinds reproduce the worn-mask behaviour for reviewed Weapon/OffHand source
items. Any listed source kind may satisfy the condition.

Args:
    allowed (string?): Comma-separated source equipment kinds, or nil.
    equipment (any): Reviewed source-kind paperdoll metadata.

Returns:
    boolean: True when no condition exists or one listed kind matches.
]]
function C4EquipmentConditionRules.matches(
    allowed: string?,
    equipment: any
): boolean
    if allowed == nil then
        return true
    end

    if type(allowed) ~= "string"
        or allowed == ""
    then
        return false
    end

    for kind in string.gmatch(allowed, "[^,]+") do
        local trimmed = kind:match("^%s*(.-)%s*$")

        if ARMOR_KINDS[trimmed] then
            if matches_armor(trimmed, equipment) then
                return true
            end
        elseif matches_worn_kind(trimmed, equipment) then
            return true
        end
    end

    return false
end

--[[
Returns whether a source kind is one of C4's three armor families.

Args:
    kind (any): Source item-kind value.

Returns:
    boolean: True for Heavy, Light or Magic.
]]
function C4EquipmentConditionRules.is_armor_kind(
    kind: any
): boolean
    return type(kind) == "string"
        and ARMOR_KINDS[kind] == true
end

return table.freeze(C4EquipmentConditionRules)
