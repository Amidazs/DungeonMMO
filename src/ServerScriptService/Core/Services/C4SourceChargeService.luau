--!strict
-- Server-owned C4 force-charge state for reviewed source skills.

local C4SourceChargeService = {}
C4SourceChargeService.__index = C4SourceChargeService

--[[
Validates one charge owner.

Args:
    player (any): Player instance or disposable server-owned test actor.

Returns:
    boolean: True when an integral numeric UserId is available.
]]
local function valid_owner(player: any): boolean
    return (
        type(player) == "table"
        or typeof(player) == "Instance"
    )
        and type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Creates an empty source charge authority.

Args:
    None.

Returns:
    any: Isolated server-owned charge state.
]]
function C4SourceChargeService.new(): any
    return setmetatable({
        _charges_by_user_id = {},
    }, C4SourceChargeService)
end

--[[
Returns the current reviewed charge count.

Args:
    player (any): Server-owned charge owner.

Returns:
    (number?, string?): Current charge count or strict denial reason.
]]
function C4SourceChargeService:get(
    player: any
): (number?, string?)
    if not valid_owner(player) then
        return nil, "C4SourceChargeOwnerInvalid"
    end

    return self._charges_by_user_id[player.UserId] or 0, nil
end

--[[
Adds one C4 force charge without exceeding the source maximum.

Args:
    player (any): Server-owned charge owner.
    maximum (number): Exact source maxCharges value.

Returns:
    (any?, string?): Detached before/after charge evidence.
]]
function C4SourceChargeService:add_one(
    player: any,
    maximum: number
): (any?, string?)
    if not valid_owner(player) then
        return nil, "C4SourceChargeOwnerInvalid"
    end
    if type(maximum) ~= "number"
        or maximum % 1 ~= 0
        or maximum < 1
    then
        return nil, "C4SourceChargeMaximumInvalid"
    end

    local before = self._charges_by_user_id[player.UserId] or 0
    local after = math.min(maximum, before + 1)
    self._charges_by_user_id[player.UserId] = after

    return {
        ChargeBefore = before,
        ChargeAfter = after,
        MaximumCharges = maximum,
        Added = after > before,
        SourceOnly = true,
        ClientAuthority = false,
    }, nil
end

--[[
Consumes the exact number of source charges required by a skill.

Args:
    player (any): Server-owned charge owner.
    required (number): Exact source num_charges value.

Returns:
    (any?, string?): Detached before/after evidence or insufficient-charge denial.
]]
function C4SourceChargeService:consume(
    player: any,
    required: number
): (any?, string?)
    if not valid_owner(player) then
        return nil, "C4SourceChargeOwnerInvalid"
    end
    if type(required) ~= "number"
        or required % 1 ~= 0
        or required < 1
    then
        return nil, "C4SourceChargeRequirementInvalid"
    end

    local before = self._charges_by_user_id[player.UserId] or 0
    if before < required then
        return nil, "C4SourceChargeInsufficient"
    end

    local after = before - required
    self._charges_by_user_id[player.UserId] = after

    return {
        ChargeBefore = before,
        ChargeAfter = after,
        ChargesConsumed = required,
        SourceOnly = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears one owner's ephemeral source charges.

Args:
    player (any): Departing server-owned charge owner.

Returns:
    nil: Removes only the selected owner's charge state.
]]
function C4SourceChargeService:clear_owner(player: any)
    if valid_owner(player) then
        self._charges_by_user_id[player.UserId] = nil
    end
end

--[[
Reports source charge authority capabilities.

Args:
    None.

Returns:
    any: Immutable capability evidence.
]]
function C4SourceChargeService:capability(): any
    return {
        Available = true,
        ServerOwned = true,
        OneChargeIncrement = true,
        SourceMaximumEnforced = true,
        ExactConsumption = true,
        ClientAuthority = false,
    }
end

return C4SourceChargeService
