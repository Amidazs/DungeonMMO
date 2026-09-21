--!strict
-- Shared per-member death/respawn state for the isolated world boss.
-- It deliberately reuses DungeonSessionService member modes.
local Players = game:GetService("Players")

local WorldBossMemberLifecycle = {}
WorldBossMemberLifecycle.__index = WorldBossMemberLifecycle

type PlayerBinding = {
    player: Player,
    session_id: string,
    spawn_cframe: CFrame,
    respawn_delay: number,
}

-- Args:
--   sessions: any; authoritative DungeonSessionService.
-- Returns:
--   any: lifecycle helper for one isolated world-boss runtime.
function WorldBossMemberLifecycle.new(sessions: any): any
    assert(sessions ~= nil,
        "World boss lifecycle requires DungeonSessionService")
    return setmetatable({
        _sessions = sessions,
    }, WorldBossMemberLifecycle)
end

-- Args:
--   session_id: string; active server-issued world-boss session.
--   user_id: number; authenticated member who has a live character.
-- Returns:
--   any: session mutation result.
function WorldBossMemberLifecycle:mark_active(
    session_id: string,
    user_id: number
): any
    return self._sessions:set_member_mode(
        session_id, user_id, "Active")
end

-- Args:
--   session_id: string; active world-boss session.
--   user_id: number; authenticated member whose Humanoid died.
-- Returns:
--   any: persisted dead-state mutation result.
function WorldBossMemberLifecycle:mark_dead(
    session_id: string,
    user_id: number
): any
    return self._sessions:set_member_mode(
        session_id, user_id, "Dead")
end

-- Args:
--   session_id: string; stored world-boss session.
--   user_id: number; member considered for a server respawn.
-- Returns:
--   boolean: true only for a connected, non-abandoned dead member.
function WorldBossMemberLifecycle:can_respawn(
    session_id: string,
    user_id: number
): boolean
    local session = self._sessions:get(session_id)
    if not session or session.State ~= "Active" then
        return false
    end
    local member = session.Members
        and session.Members[tostring(user_id)]
    if not member or member.Connected ~= true
        or member.Abandoned == true
        or member.Mode ~= "Dead"
    then
        return false
    end
    return type(session.InstanceState) == "table"
        and type(session.InstanceState.WeeklyWorldBoss) == "table"
end

-- Args:
--   binding: PlayerBinding; immutable per-player encounter routing.
-- Returns:
--   nil: persists death and schedules one server-authorized respawn.
function WorldBossMemberLifecycle:_handle_death(
    binding: PlayerBinding
)
    local user_id = binding.player.UserId
    local dead = self:mark_dead(binding.session_id, user_id)
    if not dead.ok then
        warn("[World Boss] Member death persistence failed: "
            .. tostring(dead.reason))
        return
    end

    task.delay(binding.respawn_delay, function()
        local same_player = Players:GetPlayerByUserId(user_id)
            == binding.player
        if same_player
            and self:can_respawn(binding.session_id, user_id)
        then
            binding.player:LoadCharacter()
        end
    end)
end

-- Args:
--   binding: PlayerBinding; server-owned encounter routing.
--   character: Model; freshly spawned Roblox character.
-- Returns:
--   nil: marks encounter identity, positions, and binds one death event.
function WorldBossMemberLifecycle:_activate_character(
    binding: PlayerBinding,
    character: Model
)
    character:SetAttribute("DungeonRunParticipant", true)
    character:SetAttribute(
        "DungeonEncounterId", "WeeklyBoss:" .. binding.session_id)
    character:SetAttribute("WorldBossSessionId", binding.session_id)
    character:PivotTo(binding.spawn_cframe)

    local active = self:mark_active(
        binding.session_id, binding.player.UserId)
    if not active.ok then
        warn("[World Boss] Member activation failed: "
            .. tostring(active.reason))
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 5)
    if humanoid and humanoid:IsA("Humanoid") then
        humanoid.Died:Connect(function()
            self:_handle_death(binding)
        end)
    else
        warn("[World Boss] Character missing Humanoid death signal.")
    end
end

-- Args:
--   player: Player; authenticated admitted world-boss member.
--   session_id: string; frozen encounter session.
--   spawn_cframe: CFrame; trusted arena spawn for this member.
--   respawn_delay: number; server delay before same-session respawn.
-- Returns:
--   RBXScriptConnection: CharacterAdded connection for runtime lifetime.
function WorldBossMemberLifecycle:bind_player(
    player: Player,
    session_id: string,
    spawn_cframe: CFrame,
    respawn_delay: number
): RBXScriptConnection
    assert(type(session_id) == "string" and session_id ~= "",
        "World boss member binding requires session ID")
    assert(typeof(spawn_cframe) == "CFrame",
        "World boss member binding requires spawn CFrame")
    assert(type(respawn_delay) == "number" and respawn_delay >= 0,
        "World boss member binding requires nonnegative respawn delay")

    local binding: PlayerBinding = {
        player = player,
        session_id = session_id,
        spawn_cframe = spawn_cframe,
        respawn_delay = respawn_delay,
    }
    local connection = player.CharacterAdded:Connect(function(character)
        self:_activate_character(binding, character)
    end)
    player:LoadCharacter()
    return connection
end

return table.freeze(WorldBossMemberLifecycle)
