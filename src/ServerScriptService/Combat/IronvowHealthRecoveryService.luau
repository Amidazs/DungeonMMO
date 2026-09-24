--!strict
-- Genuine C4 Warrior passive HP recovery, including outside combat.
-- Server-owned and never available to dead or unawarded characters.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Progression = require(
    game.ServerScriptService.Core.Services.ProgressionRuntimeState
)

local IronvowHealthRecoveryService = {}
local elapsed_by_player: {[Player]: number} = {}

--[[
Heals one living owner's real server Humanoid by paid passive HP regen.

Args:
    player (Player): Genuine currently connected session owner.
    seconds (number): Bounded elapsed simulation interval.

Returns:
    number: Actual HP gained, never beyond the real current max HP.
]]
function IronvowHealthRecoveryService.apply_tick(
    player: Player, seconds: number
): number
    if player.Parent ~= Players
        or type(seconds) ~= "number"
        or seconds ~= seconds
        or seconds <= 0 or seconds > 1.25
    then
        return 0
    end
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    -- A stored or detached avatar is not a living world-owned player.
    if not character or not character:IsDescendantOf(workspace)
        or not humanoid or humanoid.Health <= 0
        or humanoid.Health >= humanoid.MaxHealth
    then
        return 0
    end
    local rate = Progression.get_health_recovery_per_second(
        player.UserId
    )
    if rate <= 0 then return 0 end
    local previous = humanoid.Health
    humanoid.Health = math.min(
        humanoid.MaxHealth, previous + rate * seconds
    )
    return humanoid.Health - previous
end

--[[
Accumulates one-second server-only regen ticks per real connected owner.

Args:
    delta_time (number): Server Heartbeat elapsed seconds.

Returns:
    nil: Adds only authenticated, bounded healing at one-second intervals.
]]
local function on_heartbeat(delta_time: number)
    for _, player in Players:GetPlayers() do
        elapsed_by_player[player] = math.min(
            (elapsed_by_player[player] or 0)
                + math.clamp(delta_time, 0, 0.25),
            1.25
        )
        if elapsed_by_player[player] >= 1 then
            elapsed_by_player[player] -= 1
            IronvowHealthRecoveryService.apply_tick(player, 1)
        end
    end
end

RunService.Heartbeat:Connect(on_heartbeat)
Players.PlayerRemoving:Connect(function(player)
    elapsed_by_player[player] = nil
end)

return table.freeze(IronvowHealthRecoveryService)
