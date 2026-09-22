--!strict
-- Server-owned non-stacking short combat buffs, shared by C4 skill lines.
local Players = game:GetService("Players")

local CombatStatusService = {}

local BUFFS = table.freeze({
    PhysicalPower = table.freeze({
        Magnitude = "C4PhysicalPowerBonus",
        ExpiresAt = "C4PhysicalPowerExpiresAt",
    }),
    PhysicalGuard = table.freeze({
        Magnitude = "C4PhysicalGuardBonus",
        ExpiresAt = "C4PhysicalGuardExpiresAt",
    }),
    Evasion = table.freeze({
        Magnitude = "C4EvasionBonus",
        ExpiresAt = "C4EvasionExpiresAt",
    }),
    MagicPower = table.freeze({
        Magnitude = "C4MagicPowerBonus",
        ExpiresAt = "C4MagicPowerExpiresAt",
    }),
})

--[[
Reads a currently valid server-authored self-buff from a character.

Args:
    character (Model?): Existing Roblox character receiving the effect.
    buff_kind (string): Registered combat status identifier.

Returns:
    number: Current additive buff magnitude, or zero after expiration.
]]
function CombatStatusService.get(
    character: Model?,
    buff_kind: string
): number
    local fields = BUFFS[buff_kind]
    if not character or not fields or not character.Parent then
        return 0
    end
    local expires_at = character:GetAttribute(fields.ExpiresAt)
    if type(expires_at) ~= "number" or expires_at <= os.clock() then
        return 0
    end
    local magnitude = character:GetAttribute(fields.Magnitude)
    if type(magnitude) ~= "number" then
        return 0
    end
    return math.clamp(magnitude, 0, 0.50)
end

--[[
Applies a non-stacking, bounded self-buff only to the authenticated
living player at the moment the server executes its bought skill.

Args:
    player (Player): Genuine caster owning the character.
    definition (any): Server-authored and rank-resolved Buff skill.

Returns:
    boolean: True when a living player received a valid timed status.
]]
function CombatStatusService.apply_self(
    player: Player,
    definition: any
): boolean
    if player.Parent ~= Players or type(definition) ~= "table"
        or definition.KIND ~= "Buff"
    then
        return false
    end
    local fields = BUFFS[definition.BUFF_KIND]
    local magnitude = tonumber(definition.BUFF_MAGNITUDE)
    local seconds = tonumber(definition.BUFF_SECONDS)
    if not fields or not magnitude or magnitude ~= magnitude
        or magnitude <= 0 or magnitude > 0.50
        or not seconds or seconds ~= seconds
        or seconds <= 0 or seconds > 60
    then
        return false
    end
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or not character.Parent then
        return false
    end

    local prior = CombatStatusService.get(
        character, definition.BUFF_KIND
    )
    local previous_expiry = character:GetAttribute(fields.ExpiresAt)
    local expires_at = math.max(
        os.clock() + seconds,
        if type(previous_expiry) == "number"
            then previous_expiry else 0
    )
    character:SetAttribute(
        fields.Magnitude, math.max(prior, magnitude)
    )
    character:SetAttribute(fields.ExpiresAt, expires_at)

    task.delay(expires_at - os.clock(), function()
        if character.Parent and character:GetAttribute(
            fields.ExpiresAt
        ) == expires_at then
            character:SetAttribute(fields.Magnitude, 0)
            character:SetAttribute(fields.ExpiresAt, 0)
        end
    end)
    return true
end

return table.freeze(CombatStatusService)
