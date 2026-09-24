--!strict
-- Source-inspired earned Warrior HP surge; no damage immunity is granted.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local IronvowEnduranceSurgeService = {}
local active: {[Player]: any} = {}
local authorizer: ((Player, any) -> boolean)? = nil
local recalculate: ((Player) -> ())? = nil

--[[
Installs the genuine class/rank and current-combat authorization callback.

Args:
    callback ((Player, any) -> boolean): Server-owned skill permission.

Returns:
    nil: The permission is checked on activation and throughout the buff.
]]
function IronvowEnduranceSurgeService.set_authorizer(callback: any)
    assert(type(callback) == "function", "Authorizer required")
    authorizer = callback
end

--[[
Installs the owner-health recalculator without a progression require cycle.

Args:
    callback ((Player) -> ()): Reapplies actual Humanoid MaxHealth.

Returns:
    nil: Later start/end operations adjust only this owner's health.
]]
function IronvowEnduranceSurgeService.set_recalculator(callback: any)
    assert(type(callback) == "function", "Health callback required")
    recalculate = callback
end

--[[
Ends one owner's temporary maximum HP without refreshing its heal.

Args:
    player (Player): Genuine owner of the prior active status.

Returns:
    nil: Removes the multiplier before recalculating health and expiry.
]]
function IronvowEnduranceSurgeService.stop(player: Player)
    local record = active[player]
    active[player] = nil
    if not record then return end
    if record.Character and record.Character.Parent then
        record.Character:SetAttribute("IronvowEnduranceActive", false)
        record.Character:SetAttribute("IronvowEnduranceExpiresAt", nil)
    end
    if recalculate and player.Parent == Players
        and player.Character == record.Character
    then
        recalculate(player)
    end
end

--[[
Confirms a purchased surge still belongs to one living active character.

Args:
    player (Player): Original connected player.
    record (any): Server-created owner, rank and deadline record.

Returns:
    boolean: True only for living, authorized and unexpired owner.
]]
local function valid(player: Player, record: any): boolean
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    return player.Parent == Players
        and character == record.Character
        and character ~= nil and character:IsDescendantOf(workspace)
        and humanoid ~= nil and humanoid.Health > 0
        and os.clock() < record.ExpiresAt
        and authorizer ~= nil and authorizer(player, record)
end

--[[
Returns server-owned max-HP increase; an active copy cannot be stacked.

Args:
    player (Player?): Authenticated live owner, if currently connected.

Returns:
    number: Ten-percent bonus or zero when inactive or invalid.
]]
function IronvowEnduranceSurgeService.get_bonus(
    player: Player?
): number
    local record = player and active[player]
    if not player or not record then return 0 end
    if not valid(player, record) then
        IronvowEnduranceSurgeService.stop(player)
        return 0
    end
    return record.Bonus
end

--[[
Checks a new cast without charging MP or triggering another free heal.

Args:
    player (Player): Authenticated living user attempting a cast.

Returns:
    boolean: True only when no current surge already exists.
]]
function IronvowEnduranceSurgeService.can_activate(
    player: Player
): boolean
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    return player.Parent == Players and not active[player]
        and character ~= nil and character:IsDescendantOf(workspace)
        and humanoid ~= nil
        and humanoid.Health > 0
end

--[[
Activates actual bonus MaxHealth and one bounded health restoration.

MP is charged by the authenticated CombatService before this operation.

Args:
    player (Player): Real purchased-class owner and live character.
    definition (any): Server-resolved source ability, not client input.
    rank (number): Currently bought rank (only rank one exists).

Returns:
    boolean: True only after real owner max HP and HP have changed.
]]
function IronvowEnduranceSurgeService.activate(
    player: Player, definition: any, rank: number
): boolean
    if not IronvowEnduranceSurgeService.can_activate(player)
        or type(definition) ~= "table"
        or definition.KIND ~= "HealthSurge"
        or definition.ID ~= "IronvowEnduranceSurge"
        or rank ~= 1 or definition.MAX_HP_BONUS ~= 0.10
        or definition.RESTORE_FRACTION ~= 0.10
        or definition.DURATION_SECONDS ~= 600
        or not recalculate or not authorizer
    then
        return false
    end
    local character = assert(player.Character)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    local record = {
        Character = character,
        Definition = definition,
        Rank = rank,
        Bonus = definition.MAX_HP_BONUS,
        ExpiresAt = os.clock() + definition.DURATION_SECONDS,
    }
    if not valid(player, record) then return false end
    active[player] = record
    character:SetAttribute("IronvowEnduranceActive", true)
    character:SetAttribute("IronvowEnduranceExpiresAt", record.ExpiresAt)
    recalculate(player)
    if humanoid.Health > 0 then
        humanoid.Health = math.min(
            humanoid.MaxHealth,
            humanoid.Health + humanoid.MaxHealth
                * definition.RESTORE_FRACTION
        )
    end
    return true
end

RunService.Heartbeat:Connect(function()
    for player, record in active do
        if not valid(player, record) then
            IronvowEnduranceSurgeService.stop(player)
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    IronvowEnduranceSurgeService.stop(player)
end)

return table.freeze(IronvowEnduranceSurgeService)
