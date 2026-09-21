--!strict
-- Dedicated weekly-world-boss place runtime. Never runs inside a normal
-- Dungeon place and never trusts client-provided event/reward metadata.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Core = SSS:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")
local RuntimeServices = require(Services:WaitForChild("RuntimeServices"))
local ArrivalRules = require(
    Services:WaitForChild("WeeklyWorldBossArrivalRules")
)
local TeleportCoordinator = require(
    Services:WaitForChild("TeleportCoordinator")
)
local RobloxTeleportAdapter = require(
    Adapters:WaitForChild("RobloxTeleportAdapter")
)
local BossFactory = require(
    SSS.Dungeon:WaitForChild("DungeonWeeklyWorldBossFactory")
)

-- This place must be deliberately enabled after its independent arena
-- and combat runtime have been validated in a published TEST universe.
local enabled = SSS:GetAttribute("DungeonMMOWorldBossPlaceEnabled")
if enabled ~= true then
    warn("[World Boss] Dedicated place disabled; no admission active.")
    return
end
if not RunService:IsStudio() and game.PrivateServerId == "" then
    warn("[World Boss] Public server rejected; reservation required.")
    return
end

local runtime = RuntimeServices.new("Dungeon")
local profiles = runtime.ProfileService
local leases = runtime.LeaseService
local sessions = runtime.SessionService
local bridge = runtime.WeeklyWorldBossSessionBridge
local contribution = runtime.ContributionService
local coordinator = TeleportCoordinator.new(
    RobloxTeleportAdapter.new(), profiles, leases, sessions
)

local arena_spawn = Workspace:FindFirstChild("WorldBossArenaSpawn")
if not arena_spawn or not arena_spawn:IsA("BasePart") then
    warn("[World Boss] Authored WorldBossArenaSpawn is required.")
    return
end

local active_session_id: string? = nil
local boss_model: Model? = nil
local admitted: {[number]: boolean} = {}
local rewarded: {[number]: boolean} = {}
local return_prompt: ProximityPrompt? = nil

-- Args:
--   user_id: number; authenticated member of the loaded boss session.
-- Returns:
--   nil: grants only after a real server-recorded contribution.
local function grant_if_eligible(user_id: number)
    local session_id = active_session_id
    if not session_id or rewarded[user_id] then
        return
    end
    local snapshot = contribution:get_player_snapshot(
        session_id, user_id)
    if not snapshot.ok or type(snapshot.snapshot) ~= "table" then
        return
    end
    local totals = snapshot.snapshot
    if (totals.Damage or 0) <= 0
        and (totals.Tank or 0) <= 0
        and (totals.Support or 0) <= 0
    then
        return
    end
    local eligible = sessions:set_member_completion_eligibility(
        session_id, user_id, true)
    if not eligible.ok then
        return
    end
    local granted = bridge:grant_reward(session_id, user_id)
    if granted.ok then
        rewarded[user_id] = true
    else
        warn("[World Boss] Member reward pending: "
            .. tostring(granted.reason))
    end
end

-- Args:
--   session_id: string; authenticated, persisted boss session.
-- Returns:
--   nil: restores defeat or creates exactly one guardian.
local function prepare_encounter(session_id: string)
    if boss_model then
        return
    end
    local restored = bridge:resume(session_id)
    if not restored.ok then
        error("[World Boss] Encounter restore failed: "
            .. tostring(restored.reason))
    end
    if restored.snapshot.Defeated then
        if return_prompt then
            return_prompt.Enabled = true
        end
        for user_id in pairs(admitted) do
            grant_if_eligible(user_id)
        end
        return
    end
    local model = BossFactory.create({
        Parent = Workspace,
        SpawnCFrame = arena_spawn.CFrame * CFrame.new(0, 6, -20),
        InstanceId = session_id,
    })
    boss_model = model
    local humanoid = assert(model:FindFirstChildOfClass("Humanoid"))
    humanoid.Died:Connect(function()
        local completed = bridge:record_defeat(session_id, model)
        if not completed.ok then
            warn("[World Boss] Defeat persistence failed: "
                .. tostring(completed.reason))
            return
        end
        if return_prompt then
            return_prompt.Enabled = true
        end
        for user_id in pairs(admitted) do
            grant_if_eligible(user_id)
        end
    end)
end

-- Args:
--   player: Player; actual arriving party member.
-- Returns:
--   nil: admits only via stored reserved session and lease handoff.
local function admit_player(player: Player)
    if active_session_id and not sessions:get(active_session_id) then
        player:Kick("World boss session has expired.")
        return
    end
    if not RunService:IsStudio()
        and game.PrivateServerId == ""
    then
        player:Kick("A reserved world-boss server is required.")
        return
    end
    local join_data = player:GetJoinData()
    local teleport_data = join_data.TeleportData
    if type(teleport_data) ~= "table"
        or type(teleport_data.SessionId) ~= "string"
    then
        player:Kick("Missing world-boss session.")
        return
    end
    local session_id = teleport_data.SessionId
    if active_session_id and session_id ~= active_session_id then
        player:Kick("Another party owns this reserved encounter.")
        return
    end
    local session = sessions:get(session_id)
    local checked = ArrivalRules.validate(
        session, teleport_data, player.UserId, game.PlaceId)
    if not checked.ok then
        player:Kick("World-boss admission rejected: "
            .. tostring(checked.reason))
        return
    end
    local restored = bridge:resume(session_id)
    if not restored.ok then
        player:Kick("World-boss event unavailable: "
            .. tostring(restored.reason))
        return
    end
    local nonce = sessions:get_handoff_nonce(
        session_id, player.UserId)
    local claim = nonce and leases:claim_handoff(
        player.UserId, nonce)
    if not claim or not claim.ok then
        player:Kick("World-boss profile handoff rejected.")
        return
    end
    local cleared = sessions:clear_handoff_nonce(
        session_id, player.UserId)
    if not cleared.ok then
        player:Kick("World-boss handoff could not be finalized.")
        return
    end
    local profile, load_error = profiles:load(player.UserId)
    if not profile then
        player:Kick("World-boss profile failed to load: "
            .. tostring(load_error))
        return
    end
    local connected = sessions:mark_connected(
        session_id, player.UserId)
    if not connected.ok then
        profiles:release(player.UserId, "WorldBossAdmissionFailed")
        player:Kick("World-boss session could not connect.")
        return
    end

    active_session_id = session_id
    admitted[player.UserId] = true
    player.CharacterAdded:Connect(function(character: Model)
        character:PivotTo(
            arena_spawn.CFrame * CFrame.new(0, 4, 12))
    end)
    player:LoadCharacter()
    prepare_encounter(session_id)
    grant_if_eligible(player.UserId)
    print("[World Boss] Admitted " .. tostring(player.UserId)
        .. " to " .. session_id)
end

-- Args:
--   player: Player; authenticated member activating the return prompt.
-- Returns:
--   nil: reuses existing Base lease-handoff and return coordinator.
local function return_to_base(player: Player)
    local session = active_session_id
        and sessions:get(active_session_id)
    if not session or not admitted[player.UserId] then
        return
    end
    local defeated = session.InstanceState
        and session.InstanceState.WeeklyWorldBoss
        and session.InstanceState.WeeklyWorldBoss.Defeated
    if defeated ~= true then
        return
    end
    grant_if_eligible(player.UserId)
    local prepared = sessions:set_world_boss_return_pending(
        session.SessionId, player.UserId, true)
    if not prepared.ok then
        warn("[World Boss] Return authorization failed: "
            .. tostring(prepared.reason))
        return
    end
    local result = coordinator:return_to_base({player}, session)
    if not result.ok then
        sessions:set_world_boss_return_pending(
            session.SessionId, player.UserId, false)
        warn("[World Boss] Return failed: " .. tostring(result.reason))
    end
end

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "WorldBossReturnPrompt"
prompt.ActionText = "Return to Base"
prompt.ObjectText = "World Boss"
prompt.MaxActivationDistance = 12
prompt.HoldDuration = 0.25
prompt.RequiresLineOfSight = false
prompt.Enabled = false
prompt.Parent = arena_spawn
return_prompt = prompt
prompt.Triggered:Connect(return_to_base)

Players.PlayerAdded:Connect(admit_player)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(admit_player, player)
end

Players.PlayerRemoving:Connect(function(player: Player)
    admitted[player.UserId] = nil
    rewarded[player.UserId] = nil
    if coordinator:is_pending(player.UserId) then
        profiles:forget_for_handoff(player.UserId)
        coordinator:acknowledge_departure(player.UserId)
    else
        profiles:release(player.UserId, "WorldBossPlayerRemoving")
        if active_session_id then
            sessions:mark_disconnected(
                active_session_id, player.UserId)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(15)
        for user_id in pairs(admitted) do
            if not coordinator:is_pending(user_id) then
                leases:renew(user_id)
                profiles:save(user_id, "WorldBossAutosave")
            end
        end
        if active_session_id then
            sessions:refresh(active_session_id)
        end
    end
end)

game:BindToClose(function()
    for user_id in pairs(admitted) do
        if coordinator:is_pending(user_id) then
            profiles:forget_for_handoff(user_id)
        else
            profiles:release(user_id, "WorldBossClose")
        end
    end
end)
