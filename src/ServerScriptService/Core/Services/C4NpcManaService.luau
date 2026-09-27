--!strict
-- Server-owned current/max mana authority for reviewed C4 NPCs.

local CURRENT_ATTRIBUTE = "C4NpcCurrentMana"
local MAX_ATTRIBUTE = "C4NpcMaxMana"

local C4NpcManaService = {}

--[[
Checks whether one number is finite and non-negative.

Args:
    value (any): Candidate numeric value.

Returns:
    boolean: True only for finite non-negative numbers.
]]
local function valid_amount(value: any): boolean
    return type(value) == "number"
        and value == value
        and value >= 0
        and value < math.huge
end

--[[
Requires a server-owned NPC Model.

Args:
    target (any): Candidate NPC instance.

Returns:
    Model: Validated NPC model.

Raises:
    error: When the target is not a Model.
]]
local function require_model(target: any): Model
    assert(
        typeof(target) == "Instance" and target:IsA("Model"),
        "C4 NPC mana target must be a Model"
    )
    return target
end

--[[
Initializes or validates one NPC's authoritative mana state.

Existing current mana is preserved when the reviewed maximum is unchanged.
A missing or stale maximum resets the NPC to its reviewed source maximum.

Args:
    target (Model): Server-owned NPC model.
    maximum (number): Reviewed source MAX_MP.

Returns:
    number: Current authoritative mana after initialization.
]]
function C4NpcManaService.ensure(
    target: Model,
    maximum: number
): number
    local model = require_model(target)
    assert(
        valid_amount(maximum),
        "C4 NPC maximum mana must be finite and non-negative"
    )

    local stored_max = model:GetAttribute(MAX_ATTRIBUTE)
    local current = model:GetAttribute(CURRENT_ATTRIBUTE)

    if stored_max ~= maximum
        or not valid_amount(current)
        or current > maximum
    then
        model:SetAttribute(MAX_ATTRIBUTE, maximum)
        model:SetAttribute(CURRENT_ATTRIBUTE, maximum)
        return maximum
    end

    return current
end

--[[
Returns one NPC's current authoritative mana.

Args:
    target (Model): Server-owned NPC model.

Returns:
    number: Current mana, or zero before initialization.
]]
function C4NpcManaService.get(target: Model): number
    local model = require_model(target)
    local value = model:GetAttribute(CURRENT_ATTRIBUTE)

    if not valid_amount(value) then
        return 0
    end
    return value
end

--[[
Returns one NPC's reviewed maximum mana.

Args:
    target (Model): Server-owned NPC model.

Returns:
    number: Maximum mana, or zero before initialization.
]]
function C4NpcManaService.get_max(target: Model): number
    local model = require_model(target)
    local value = model:GetAttribute(MAX_ATTRIBUTE)

    if not valid_amount(value) then
        return 0
    end
    return value
end

--[[
Drains one exact amount from an initialized NPC mana pool.

The result clamps at zero, matching C4 current-MP reduction semantics.

Args:
    target (Model): Server-owned initialized NPC model.
    amount (number): Non-negative requested MP drain.

Returns:
    number: Effective MP removed.
]]
function C4NpcManaService.drain(
    target: Model,
    amount: number
): number
    local model = require_model(target)
    assert(
        valid_amount(amount),
        "C4 NPC mana drain must be finite and non-negative"
    )

    local maximum = C4NpcManaService.get_max(model)
    if maximum <= 0 then
        return 0
    end

    local before = C4NpcManaService.get(model)
    local after = math.max(0, before - amount)
    model:SetAttribute(CURRENT_ATTRIBUTE, after)
    return before - after
end

--[[
Clears transient C4 mana state from one NPC model.

Args:
    target (Model): Server-owned NPC model.

Returns:
    nil: Removes only C4 NPC mana attributes.
]]
function C4NpcManaService.clear(target: Model)
    local model = require_model(target)
    model:SetAttribute(CURRENT_ATTRIBUTE, nil)
    model:SetAttribute(MAX_ATTRIBUTE, nil)
end

return table.freeze(C4NpcManaService)
