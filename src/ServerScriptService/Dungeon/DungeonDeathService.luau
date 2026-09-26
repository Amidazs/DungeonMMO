--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ReviveConfig = require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("ReviveConfig"))
local CombatConfig = require(ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Shared"):WaitForChild("CombatConfig"))
local StaminaService = require(ServerScriptService:WaitForChild("Combat"):WaitForChild("StaminaService"))

local DungeonDeathService = {}
DungeonDeathService.__index = DungeonDeathService

local function operation(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}; out.ok = ok; out.reason = reason; return out
end

local function all_members_inactive(session: any): boolean
    local has_member = false
    for _, member in pairs(session.Members or {}) do
        has_member = true
        if member.Connected == true and (member.Mode == "Active" or member.Mode == "Reviving") then return false end
    end
    return has_member
end

local function default_safe_paid_cframe(death_cframe: CFrame, player: Player): CFrame?
    local character = player.Character
    local exclusions = {}
    if character then table.insert(exclusions, character) end
    local ray_params = RaycastParams.new(); ray_params.FilterType = Enum.RaycastFilterType.Exclude; ray_params.FilterDescendantsInstances = exclusions; ray_params.RespectCanCollide = true
    local overlap_params = OverlapParams.new(); overlap_params.FilterType = Enum.RaycastFilterType.Exclude; overlap_params.FilterDescendantsInstances = exclusions; overlap_params.RespectCanCollide = true
    local offsets = {Vector3.new(0,0,0),Vector3.new(4,0,0),Vector3.new(-4,0,0),Vector3.new(0,0,4),Vector3.new(0,0,-4)}
    for _, offset in ipairs(offsets) do
        local origin = death_cframe.Position + offset + Vector3.new(0,6,0)
        local hit = Workspace:Raycast(origin, Vector3.new(0,-14,0), ray_params)
        if hit then
            local candidate = CFrame.new(hit.Position + Vector3.new(0,3,0))
            local blockers = Workspace:GetPartBoundsInBox(candidate, Vector3.new(2.5,4,2.5), overlap_params)
            local blocked=false
            for _, part in ipairs(blockers) do if part.CanCollide and part ~= hit.Instance then blocked=true break end end
            if not blocked then return candidate end
        end
    end
    return nil
end

local function default_spawn_player(player: Player, cframe: CFrame): boolean
    local old_character = player.Character
    player:LoadCharacter()
    local character = player.Character
    if not character or character == old_character then character = player.CharacterAdded:Wait() end
    character:PivotTo(cframe)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.Health = humanoid.MaxHealth end
    StaminaService.reset_player(player)
    character:SetAttribute("CombatStamina", CombatConfig.STAMINA.MAX)
    return true
end

function DungeonDeathService.new(session_service:any, checkpoint_service:any, session_id:string, options:any?):any
    assert(session_service ~= nil and checkpoint_service ~= nil, "DungeonDeathService dependencies are required")
    local config=options or {}; local self=setmetatable({},DungeonDeathService)
    self._sessions=session_service; self._checkpoints=checkpoint_service; self._session_id=session_id
    self._clock=config.clock or os.time; self._schedule=config.schedule or task.delay
    self._spawn_player=config.spawn_player or default_spawn_player
    self._safe_paid_cframe=config.safe_paid_cframe or default_safe_paid_cframe
    self._emit_state=config.emit_state or function(_user_id:number,_payload:any) end
    self._paid_offer_provider=config.paid_offer_provider or function(_user_id:number) return nil end
    self._on_member_mode=config.on_member_mode or function(_user_id:number,_mode:string) end
    self._death_cframes={}; self._revive_ends_at={}
    self._skill_resurrection_requests = {}
    self._completed_paid_revive_counts = {}
    self._on_recoverable_wipe = config.on_recoverable_wipe
    self._wipe_reset_requested = false
    return self
end

function DungeonDeathService:_emit(user_id:number)
    local session=self._sessions:get(self._session_id); if not session then return end
    local member=session.Members[tostring(user_id)]; if not member then return end
    self._emit_state(user_id,{
        session_state=session.State,
        member_mode=member.Mode,
        free_available=member.FreeReviveUsed ~= true and session.State == "Active",
        paid_offer=self._paid_offer_provider(user_id),
        wipe_ends_at=session.WipeDecisionEndsAt,
        revive_at=self._revive_ends_at[user_id],
        skill_resurrection_offer =
            self._skill_resurrection_requests[user_id],
    })
end

-- Sends authoritative revive UI state after initial admission or
-- reconnection. The client must not infer its previous death mode
-- from a newly loaded character or an earlier RemoteEvent.
--
-- Args:
--   player: Player; currently connected run member.
-- Returns:
--   any: operation result indicating whether state was sent.
function DungeonDeathService:send_member_state(player: any): any
    local session = self._sessions:get(self._session_id)
    if not session then
        return operation(false, "SessionNotFound")
    end
    local member = session.Members[tostring(player.UserId)]
    if not member or member.Connected ~= true then
        return operation(false, "MemberNotConnected")
    end
    self:_emit(player.UserId)
    return operation(true, nil)
end

-- Args:
--   session: any; authoritative session membership snapshot.
-- Returns:
--   boolean: true when no connected living member remains and
--       at least one automatic free revive is already in progress.
local function can_retry_wiped_room(session: any): boolean
    local reviving = false
    for _, member in pairs(session.Members or {}) do
        if member.Connected == true then
            if member.Mode == "Active" then
                return false
            end
            if member.Mode == "Reviving" then
                reviving = true
            end
        end
    end
    return reviving
end

function DungeonDeathService:_refresh_wipe_state():any
    local session=self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then return operation(false,"SessionNotActive") end

    if can_retry_wiped_room(session)
        and not self._wipe_reset_requested
        and self._on_recoverable_wipe
    then
        local reset = self._on_recoverable_wipe(session)
        if type(reset) == "table" and reset.ok == true then
            self._wipe_reset_requested = true
        end
    elseif not can_retry_wiped_room(session) then
        self._wipe_reset_requested = false
    end

    if all_members_inactive(session) then
        if type(session.WipeDecisionEndsAt) ~= "number" then
            local deadline=self._clock()+ReviveConfig.WIPE_DECISION_SECONDS
            local set_result=self._sessions:set_wipe_deadline(self._session_id,deadline); if not set_result.ok then return set_result end
        end
    elseif session.WipeDecisionEndsAt ~= nil then self._sessions:set_wipe_deadline(self._session_id,nil) end
    return operation(true,nil)
end

function DungeonDeathService:_finish_automatic_revive(player:any)
    local session=self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then return end
    local member=session.Members[tostring(player.UserId)]
    if not member or member.Mode ~= "Reviving" then return end
    self._revive_ends_at[player.UserId]=nil
    self._skill_resurrection_requests[player.UserId] = nil
    if member.Connected ~= true then
        self._sessions:set_member_mode(self._session_id,player.UserId,"Active")
        self._sessions:set_wipe_deadline(self._session_id,nil)
        self._on_member_mode(player.UserId,"Active")
        return
    end
    local checkpoint=self._checkpoints:get_active_checkpoint()
    local spawned=self._spawn_player(player,checkpoint.CFrame)
    if not spawned then
        self._sessions:set_member_mode(self._session_id,player.UserId,"Spectating")
        if self._sessions.set_member_completion_eligibility then self._sessions:set_member_completion_eligibility(self._session_id,player.UserId,false) end
        self._on_member_mode(player.UserId,"Spectating")
        self:_refresh_wipe_state(); self:_emit(player.UserId); return
    end
    self._sessions:set_member_mode(self._session_id,player.UserId,"Active")
    self._on_member_mode(player.UserId,"Active")
    self:_refresh_wipe_state(); self:_emit(player.UserId)
end

--[[
Checks whether one living party member may offer skill resurrection.

Args:
    caster (any): Living server-owned party caster.
    target (any): Dead server-owned party target.

Returns:
    (boolean, string?): Readiness or strict session-state reason.
]]
function DungeonDeathService:can_skill_resurrect(
    caster: any,
    target: any
): (boolean, string?)
    local session = self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then
        return false, "SessionNotActive"
    end
    if not caster or not target
        or type(caster.UserId) ~= "number"
        or type(target.UserId) ~= "number"
        or caster.UserId == target.UserId
    then
        return false, "InvalidSkillResurrectionParticipants"
    end

    local caster_member =
        session.Members[tostring(caster.UserId)]
    local target_member =
        session.Members[tostring(target.UserId)]
    if not caster_member or not target_member then
        return false, "NotPartyMember"
    end
    if caster_member.Connected ~= true
        or caster_member.Mode ~= "Active"
    then
        return false, "SkillResurrectionCasterNotActive"
    end
    if target_member.Connected ~= true then
        return false, "SkillResurrectionTargetDisconnected"
    end
    if target_member.Mode ~= "Dead"
        and target_member.Mode ~= "Spectating"
        and target_member.Mode ~= "Reviving"
    then
        return false, "SkillResurrectionTargetNotDead"
    end

    return true, nil
end

--[[
Creates one C4-style resurrection proposal for the dead player.

The source implementation asks the dead player to accept. This method only
records that server-owned proposal; it never revives on cast completion.

Args:
    caster (any): Living party caster.
    target (any): Dead party target.
    restore_experience_power (number): Exact source Resurrection power.

Returns:
    any: Operation result containing the accepted proposal metadata.
]]
function DungeonDeathService:request_skill_resurrection(
    caster: any,
    target: any,
    restore_experience_power: number
): any
    local ready, reason = self:can_skill_resurrect(
        caster,
        target
    )
    if not ready then
        return operation(false, reason)
    end
    if type(restore_experience_power) ~= "number"
        or restore_experience_power < 0
        or restore_experience_power ~= restore_experience_power
    then
        return operation(false, "InvalidSkillResurrectionPower")
    end

    local user_id = target.UserId
    if self._skill_resurrection_requests[user_id] then
        return operation(false, "SkillResurrectionAlreadyOffered")
    end

    local offer = {
        caster_user_id = caster.UserId,
        restore_experience_power = restore_experience_power,
    }
    self._skill_resurrection_requests[user_id] = offer
    self:_emit(user_id)

    return operation(true, nil, {
        offer = offer,
    })
end

--[[
Declines and clears one pending skill-resurrection proposal.

Args:
    target (any): Dead player declining the current proposal.

Returns:
    any: Operation result indicating whether an offer existed.
]]
function DungeonDeathService:decline_skill_resurrection(
    target: any
): any
    if not target or type(target.UserId) ~= "number" then
        return operation(false, "InvalidSkillResurrectionTarget")
    end

    local user_id = target.UserId
    if not self._skill_resurrection_requests[user_id] then
        return operation(false, "SkillResurrectionOfferMissing")
    end

    self._skill_resurrection_requests[user_id] = nil
    self:_emit(user_id)
    return operation(true, nil)
end

--[[
Accepts one pending skill resurrection at the recorded death location.

The game has no C4 death-XP penalty yet, so source Resurrection power is
retained as evidence rather than fabricating an XP refund. The normal Dungeon
spawn authority restores the character and combat resources.

Args:
    target (any): Dead player accepting their current proposal.

Returns:
    any: Operation result with source-power and spawn evidence.
]]
function DungeonDeathService:accept_skill_resurrection(
    target: any
): any
    if not target or type(target.UserId) ~= "number" then
        return operation(false, "InvalidSkillResurrectionTarget")
    end

    local user_id = target.UserId
    local offer = self._skill_resurrection_requests[user_id]
    if not offer then
        return operation(false, "SkillResurrectionOfferMissing")
    end

    local session = self._sessions:get(self._session_id)
    local member = session
        and session.Members[tostring(user_id)]
    if not session or session.State ~= "Active"
        or not member
        or member.Connected ~= true
        or member.Mode == "Active"
    then
        self._skill_resurrection_requests[user_id] = nil
        return operation(false, "SkillResurrectionTargetUnavailable")
    end

    local target_cframe = self._death_cframes[user_id]
    if not target_cframe then
        local checkpoint = self._checkpoints:get_active_checkpoint()
        target_cframe = checkpoint.CFrame
    end

    self._skill_resurrection_requests[user_id] = nil
    self._revive_ends_at[user_id] = nil

    local spawned = self._spawn_player(target, target_cframe)
    if not spawned then
        self:_emit(user_id)
        return operation(false, "RespawnFailed")
    end

    local changed = self._sessions:set_member_mode(
        self._session_id,
        user_id,
        "Active"
    )
    if not changed.ok then
        return changed
    end

    self._sessions:set_wipe_deadline(self._session_id, nil)
    self._on_member_mode(user_id, "Active")
    self:_refresh_wipe_state()
    self:_emit(user_id)

    return operation(true, nil, {
        cframe = target_cframe,
        restore_experience_power =
            offer.restore_experience_power,
        caster_user_id = offer.caster_user_id,
    })
end

function DungeonDeathService:on_player_died(player:any, death_cframe:CFrame):any
    self._skill_resurrection_requests[player.UserId] = nil
    local session=self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then return operation(false,"SessionNotActive") end
    local member=session.Members[tostring(player.UserId)]; if not member then return operation(false,"NotMember") end
    self._death_cframes[player.UserId]=death_cframe
    if self._sessions.set_member_completion_eligibility then self._sessions:set_member_completion_eligibility(self._session_id,player.UserId,member.Connected==true and member.Mode=="Active") end
    if member.FreeReviveUsed ~= true then
        local dead=self._sessions:set_member_mode(self._session_id,player.UserId,"Dead"); if not dead.ok then return dead end
        local consumed=self._sessions:consume_free_revive(self._session_id,player.UserId); if not consumed.ok then return consumed end
        self._revive_ends_at[player.UserId]=self._clock()+ReviveConfig.FREE_REVIVE_DELAY_SECONDS
        self._on_member_mode(player.UserId,"Reviving")
        self:_refresh_wipe_state(); self:_emit(player.UserId)
        self._schedule(ReviveConfig.FREE_REVIVE_DELAY_SECONDS,function() self:_finish_automatic_revive(player) end)
        return operation(true,nil,{session=self._sessions:get(self._session_id),automatic_free_revive=true})
    end
    local changed=self._sessions:set_member_mode(self._session_id,player.UserId,"Spectating"); if not changed.ok then return changed end
    self._on_member_mode(player.UserId,"Spectating")
    self:_refresh_wipe_state(); self:_emit(player.UserId)
    return operation(true,nil,{session=self._sessions:get(self._session_id)})
end

function DungeonDeathService:request_free_revive(player:any):any
    self:_emit(player.UserId)
    return operation(false,"AutomaticFreeRevive")
end

function DungeonDeathService:request_paid_revive(player:any):any
    local session=self._sessions:get(self._session_id); if not session or session.State ~= "Active" then return operation(false,"SessionNotActive") end
    local member=session.Members[tostring(player.UserId)]; if not member then return operation(false,"NotMember") end
    if member.FreeReviveUsed ~= true then return operation(false,"FreeReviveStillAvailable") end
    if member.Mode ~= "Dead" and member.Mode ~= "Spectating" then return operation(false,"MemberNotDead") end
    local offer=self._paid_offer_provider(player.UserId); if not offer then return operation(false,"PaidOfferUnavailable") end
    return operation(false,"PaidPurchaseRequired",{paid_offer=offer})
end

-- Args:
--   player: Player; member whose paid revive was already granted.
-- Returns:
--   any: respawn result, or an explicit fail-closed rejection.
function DungeonDeathService:complete_paid_revive(player: any): any
    local session = self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then
        return operation(false, "SessionNotActive")
    end

    self._skill_resurrection_requests[player.UserId] = nil
    local member = session.Members[tostring(player.UserId)]
    if not member then
        return operation(false, "NotMember")
    end
    if member.Connected ~= true then
        return operation(false, "MemberDisconnected")
    end
    if member.FreeReviveUsed ~= true then
        return operation(false, "FreeReviveStillAvailable")
    end

    -- DungeonSessionService atomically records the purchase and sets
    -- Mode to Active BEFORE the authorized on_granted callback fires.
    local paid_count = member.PaidReviveCount
    local completed = self._completed_paid_revive_counts[player.UserId] or 0
    if member.Mode ~= "Active"
        or type(paid_count) ~= "number"
        or paid_count <= completed
    then
        return operation(false, "PaidReviveAlreadyProcessed")
    end

    -- Reserve the grant before the potentially yielding LoadCharacter.
    self._completed_paid_revive_counts[player.UserId] = paid_count
    local checkpoint = self._checkpoints:get_active_checkpoint()
    local target = checkpoint.CFrame
    local spawned = self._spawn_player(player, target)
    if not spawned then
        self._sessions:set_member_mode(
            self._session_id, player.UserId, "Spectating"
        )
        self._on_member_mode(player.UserId, "Spectating")
        self:_refresh_wipe_state()
        self:_emit(player.UserId)
        return operation(false, "RespawnFailed")
    end

    local changed = self._sessions:set_member_mode(
        self._session_id, player.UserId, "Active"
    )
    if not changed.ok then
        return changed
    end
    self._on_member_mode(player.UserId, "Active")
    self:_refresh_wipe_state()
    self:_emit(player.UserId)
    return operation(true, nil, {
        cframe = target,
        checkpoint = checkpoint,
    })
end

function DungeonDeathService:tick(now:number?):any
    local tick_now=now or self._clock(); local session=self._sessions:get(self._session_id)
    if not session or session.State ~= "Active" then
        -- A terminal failure is announced once, at the transition.
        -- Repeated announcements hide replay voting and error screens.
        return {failed = false}
    end
    local deadline=session.WipeDecisionEndsAt
    if type(deadline)=="number" and tick_now>=deadline and all_members_inactive(session) then
        local failed=self._sessions:mark_failed(self._session_id,"WipeReviveTimeout")
        for _,member in pairs(session.Members) do self:_emit(member.UserId) end
        return {failed=failed.ok==true,reason=failed.reason}
    end
    return {failed=false}
end

return table.freeze(DungeonDeathService)
