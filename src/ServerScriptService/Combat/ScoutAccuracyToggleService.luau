--!strict
-- Authenticated, resource-draining C4 Rogue/Scout accuracy stance.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ScoutAccuracyToggleService = {}

local active: {[Player]: any} = {}
local last_activation: {[Player]: number} = {}
local authorizer: ((Player, any) -> boolean)? = nil
local spend_stamina: ((Player, number) -> boolean)? = nil

--[[
Disables a toggle and immediately clears replicated character status.

Args:
    player (Player): Owner of the active or previously active stance.

Returns:
    nil: No active record or visible bonus remains on the character.
]]
function ScoutAccuracyToggleService.stop(player: Player)
    local record = active[player]
    active[player] = nil
    if record and record.Character and record.Character.Parent then
        record.Character:SetAttribute("C4ScoutAccuracyActive", false)
        record.Character:SetAttribute("C4ScoutAccuracyBonus", 0)
    end
end

--[[
Installs server-owned skill authority used at activation and upkeep.

Args:
    callback ((Player, any) -> boolean): Verifies purchased rank,
        loadout, race, class, character level, and live session state.

Returns:
    nil: The callback is applied on every active status inspection.
]]
function ScoutAccuracyToggleService.set_authorizer(callback: any)
    assert(type(callback) == "function", "A server authorizer is required")
    authorizer = callback
end

--[[
Registers the ordinary authoritative combat stamina spender.

Args:
    callback ((Player, number) -> boolean): Existing server stamina
        deduction. Injected to avoid a combat/progression require cycle.

Returns:
    nil: Toggles now use actual player stamina, never client values.
]]
function ScoutAccuracyToggleService.set_stamina_spender(callback: any)
    assert(type(callback) == "function", "Stamina spender is required")
    spend_stamina = callback
end

--[[
Returns whether an active stance is still bound to its living owner.

Args:
    player (Player): Original authenticated player.
    record (any): Stored rank and exact character instance.

Returns:
    boolean: True only for a living, connected authorized original.
]]
local function is_valid(player: Player, record: any): boolean
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    if player.Parent ~= Players or not character
        or character ~= record.Character
        or not character.Parent or not humanoid
        or humanoid.Health <= 0
        or not authorizer or not authorizer(player, record)
    then
        return false
    end
    return true
end

--[[
Returns the real accuracy bonus from an active cast.

Args:
    player (Player?): Real current combatant; nil is always neutral.

Returns:
    number: Server-owned source-rank bonus, or zero when unavailable.
]]
function ScoutAccuracyToggleService.get_bonus(player: Player?): number
    local record = player and active[player]
    if not player or not record then
        return 0
    end
    if not is_valid(player, record) then
        ScoutAccuracyToggleService.stop(player)
        return 0
    end
    return record.Bonus
end

--[[
Toggles one owned source-ranked stance for a real living player.

Args:
    player (Player): Owner whose genuine SkillRequest passed combat checks.
    definition (any): Authoritative rank-resolved ScoutAccuracyToggle definition.

Returns:
    boolean: True if the request activated or deactivated the stance.
    boolean: True if the stance is now on.
    string: Stable result reason for combat diagnostics.
]]
function ScoutAccuracyToggleService.toggle(
    player: Player, definition: any, rank: number
): (boolean, boolean, string)
    if active[player] then
        ScoutAccuracyToggleService.stop(player)
        return true, false, "Deactivated"
    end
    if type(definition) ~= "table"
        or definition.KIND ~= "ScoutAccuracyToggle"
        or definition.ID ~= "ScoutAccuracyToggle"
    then
        return false, false, "InvalidToggle"
    end
    local now = os.clock()
    if now - (last_activation[player] or -math.huge) < 0.30 then
        return false, false, "ToggleRateLimited"
    end
    local record = {
        Character = player.Character,
        Bonus = definition.ACCURACY_BONUS,
        Upkeep = definition.UPKEEP_STAMINA_PER_SECOND,
        Definition = definition,
        Rank = rank,
        Elapsed = 0,
    }
    if not is_valid(player, record) then
        return false, false, "ToggleUnavailable"
    end
    if not spend_stamina
        or not spend_stamina(player, definition.STAMINA_COST)
    then
        return false, false, "Stamina"
    end
    last_activation[player] = now
    active[player] = record
    record.Character:SetAttribute("C4ScoutAccuracyActive", true)
    record.Character:SetAttribute(
        "C4ScoutAccuracyBonus", record.Bonus
    )
    return true, true, "Activated"
end

--[[
Drains stamina in whole one-second intervals and drops invalid stances.

Args:
    delta_time (number): Actual Heartbeat time since the last update.

Returns:
    nil: Exhaustion, death, respawn and revoked skills remove the bonus.
]]
local function update_active(delta_time: number)
    for player, record in active do
        if not is_valid(player, record) then
            ScoutAccuracyToggleService.stop(player)
            continue
        end
        record.Elapsed += math.clamp(delta_time, 0, 1)
        while record.Elapsed >= 1 do
            record.Elapsed -= 1
            if not spend_stamina
                or not spend_stamina(player, record.Upkeep)
            then
                ScoutAccuracyToggleService.stop(player)
                break
            end
        end
    end
end

RunService.Heartbeat:Connect(update_active)
Players.PlayerRemoving:Connect(function(player)
    ScoutAccuracyToggleService.stop(player)
    last_activation[player] = nil
end)

return table.freeze(ScoutAccuracyToggleService)
