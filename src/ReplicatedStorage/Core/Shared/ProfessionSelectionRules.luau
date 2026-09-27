--!strict
-- Normal characters own one gathering and one crafting profession.
-- Earned Dwarf first transfers may expand only their approved category.

local ProfessionDefinitions = require(script.Parent.ProfessionDefinitions)
local FirstTransfers = require(script.Parent.OriginalFirstTransferDefinitions)

local ProfessionSelectionRules = {}

local BASE_CAPACITY = table.freeze({
    Gathering = 1,
    Creation = 1,
})

--[[
Returns the server-authoritative profession capacity for one character.

Args:
    character (any): Server-owned character state, when available.

Returns:
    any: Gathering and Creation slot counts for the earned identity.
]]
function ProfessionSelectionRules.capacity(character: any?): any
    local gathering = BASE_CAPACITY.Gathering
    local creation = BASE_CAPACITY.Creation
    local awarded = if type(character) == "table"
        then FirstTransfers.awarded(character) else nil

    if awarded and awarded.Id == "Gearwright" then
        creation = 2
    end

    return {
        Gathering = gathering,
        Creation = creation,
    }
end

--[[
Returns stable persisted slot keys for one profession category.

Args:
    kind (string): Profession kind, Gathering or Creation.
    capacity (number): Number of authorized slots in the category.

Returns:
    {string}: Ordered persisted keys, such as Creation and Creation2.
]]
local function slot_keys(kind: string, capacity: number): {string}
    local keys = {kind}

    for index = 2, capacity do
        table.insert(keys, kind .. tostring(index))
    end

    return keys
end

--[[
Copies one valid selected profession into its normalized slot.

Args:
    source (any): Persisted profession slot payload.
    result (any): Mutable normalized slot payload.
    key (string): Persisted slot key.
    kind (string): Expected profession category.

Returns:
    nil: Mutates result only when the persisted value is valid.
]]
local function copy_valid_slot(
    source: any,
    result: any,
    key: string,
    kind: string
)
    local profession_id = source[key]
    local definition = if type(profession_id) == "string"
        then ProfessionDefinitions.get(profession_id) else nil

    if definition and definition.Kind == kind then
        result[key] = profession_id
    end
end

--[[
Normalizes persisted slots without guessing from historical XP.

Ordinary characters retain the legacy two-key shape. Extra keys are exposed
only when the authenticated character capacity permits them.

Args:
    value (any): Persisted or untrusted selection payload.
    character (any): Optional server-owned character identity.

Returns:
    any: Validated profession slot map for the current capacity.
]]
function ProfessionSelectionRules.normalize(
    value: any,
    character: any?
): any
    local source = if type(value) == "table" then value else {}
    local capacity = ProfessionSelectionRules.capacity(character)
    local result = {
        Gathering = "",
        Creation = "",
    }

    for _, kind in {"Gathering", "Creation"} do
        local keys = slot_keys(kind, capacity[kind])
        for _, key in ipairs(keys) do
            if key ~= kind then
                result[key] = ""
            end
            copy_valid_slot(source, result, key, kind)
        end
    end

    return result
end

--[[
Checks authority to use a profession without inspecting its XP.

Args:
    slots (any): Current character's server-side profession slots.
    profession_id (string): Profession being used for a skill or craft.
    character (any): Optional server-owned character identity.

Returns:
    boolean: True only when this exact profession was selected.
]]
function ProfessionSelectionRules.can_use(
    slots: any,
    profession_id: string,
    character: any?
): boolean
    local definition = ProfessionDefinitions.get(profession_id)
    if not definition then
        return false
    end

    local capacity = ProfessionSelectionRules.capacity(character)
    local normalized = ProfessionSelectionRules.normalize(slots, character)
    for _, key in ipairs(slot_keys(
        definition.Kind,
        capacity[definition.Kind]
    )) do
        if normalized[key] == profession_id then
            return true
        end
    end

    return false
end

--[[
Chooses a profession for the first unfilled authorized category slot.

Existing selections cannot be replaced through this path. A future
unlearning system must have separately approved migration and XP rules.

Args:
    slots (any): Server-owned character profession selection.
    profession_id (any): Requested profession ID, never trusted directly.
    character (any): Optional server-owned character identity.

Returns:
    any?: Validated next slot map, or nil when selection was refused.
    string?: Machine-readable rejection, or nil on success.
]]
function ProfessionSelectionRules.choose(
    slots: any,
    profession_id: any,
    character: any?
): (any?, string?)
    local definition = if type(profession_id) == "string"
        then ProfessionDefinitions.get(profession_id) else nil
    if not definition then
        return nil, "UnknownProfession"
    end

    local capacity = ProfessionSelectionRules.capacity(character)
    local normalized = ProfessionSelectionRules.normalize(slots, character)
    for _, key in ipairs(slot_keys(
        definition.Kind,
        capacity[definition.Kind]
    )) do
        if normalized[key] == profession_id then
            return nil, "ProfessionAlreadySelected"
        end
        if normalized[key] == "" then
            normalized[key] = profession_id
            return normalized, nil
        end
    end

    return nil, "ProfessionSlotAlreadyFilled"
end

return table.freeze(ProfessionSelectionRules)
