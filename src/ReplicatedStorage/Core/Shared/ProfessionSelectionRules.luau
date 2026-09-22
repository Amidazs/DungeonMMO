--!strict
-- Exactly one gathering and one crafting profession per character.
-- The pairing is unrestricted: choosing Mining never grants Blacksmithing.
local ProfessionDefinitions = require(script.Parent.ProfessionDefinitions)

local ProfessionSelectionRules = {}

--[[
Normalizes persisted slots without guessing from historical XP.

Args:
    value (any): Persisted or untrusted selection payload.

Returns:
    any: Two validated profession IDs or empty slot strings.
]]
function ProfessionSelectionRules.normalize(value: any): any
    local source = if type(value) == "table" then value else {}
    local result = {Gathering = "", Creation = ""}
    for _, kind in {"Gathering", "Creation"} do
        local id = source[kind]
        local definition = if type(id) == "string"
            then ProfessionDefinitions.get(id) else nil
        if definition and definition.Kind == kind then
            result[kind] = id
        end
    end
    return result
end

--[[
Checks authority to use a profession without inspecting its XP.

Args:
    slots (any): Current character's server-side profession slots.
    profession_id (string): Profession being used for a skill or craft.

Returns:
    boolean: True only when this exact profession was selected.
]]
function ProfessionSelectionRules.can_use(
    slots: any,
    profession_id: string
): boolean
    local definition = ProfessionDefinitions.get(profession_id)
    if not definition then
        return false
    end
    local normalized = ProfessionSelectionRules.normalize(slots)
    return normalized[definition.Kind] == profession_id
end

--[[
Chooses a single profession for an unfilled category.

Existing selections cannot be replaced through this path. A future
unlearning system must have separately approved migration and XP rules.

Args:
    slots (any): Server-owned character profession selection.
    profession_id (any): Requested profession ID, never trusted directly.

Returns:
    any?: Validated next slot map, or nil when selection was refused.
    string?: Machine-readable rejection, or nil on success.
]]
function ProfessionSelectionRules.choose(
    slots: any,
    profession_id: any
): (any?, string?)
    local definition = if type(profession_id) == "string"
        then ProfessionDefinitions.get(profession_id) else nil
    if not definition then
        return nil, "UnknownProfession"
    end
    local normalized = ProfessionSelectionRules.normalize(slots)
    if normalized[definition.Kind] ~= "" then
        return nil, "ProfessionSlotAlreadyFilled"
    end
    normalized[definition.Kind] = profession_id
    return normalized, nil
end

return table.freeze(ProfessionSelectionRules)
