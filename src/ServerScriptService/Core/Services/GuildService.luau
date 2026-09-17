--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local GuildDefinitions = require(Shared:WaitForChild("GuildDefinitions"))
local GuildProgressionConfig = require(Shared:WaitForChild("GuildProgressionConfig"))

local GuildService = {}
GuildService.__index = GuildService

local function membership_key(user_id: number, slot: number): string
    return "membership:" .. tostring(user_id) .. ":" .. tostring(slot)
end

local function guild_key(guild_id: string): string
    return "guild:" .. guild_id
end

local function invite_key(guild_id: string, user_id: number, slot: number): string
    return "invite:" .. guild_id .. ":" .. tostring(user_id) .. ":" .. tostring(slot)
end

local function member_key(user_id: number, slot: number): string
    return tostring(user_id) .. ":" .. tostring(slot)
end

local function count_members(guild: any): number
    local count = 0
    for _ in pairs(guild.Members or {}) do
        count += 1
    end
    return count
end

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

local function ensure_history(guild: any)
    if type(guild.History) ~= "table" then
        guild.History = {}
    end
end

function GuildService.new(adapter: any, clock: (() -> number)?, id_generator: (() -> string)?): any
    assert(adapter ~= nil, "GuildService requires entity adapter")
    local self = setmetatable({}, GuildService)
    self._adapter = adapter
    self._clock = clock or os.time
    self._id_generator = id_generator or function()
        return HttpService:GenerateGUID(false)
    end
    self._audit = nil
    return self
end

function GuildService:set_audit_service(audit_service: any?)
    self._audit = audit_service
end

function GuildService:_record_audit(event: any)
    if not self._audit then return end
    local ok, response = pcall(function() return self._audit:record(event) end)
    if not ok or type(response) ~= "table" or response.ok ~= true then
        warn("[Economy Audit] Guild event failed: " .. tostring(if ok then response and response.reason else response))
    end
end

function GuildService:get_guild(guild_id: string): any?
    local guild = self._adapter:load(guild_key(guild_id))
    return guild
end

function GuildService:get_membership(user_id: number, slot: number?): any?
    local selected_slot = slot or 1
    local pointer = self._adapter:load(membership_key(user_id, selected_slot))
    if not pointer or type(pointer.GuildId) ~= "string" then
        return nil
    end
    local guild = self:get_guild(pointer.GuildId)
    if not guild then
        return nil
    end
    local member = guild.Members and guild.Members[member_key(user_id, selected_slot)]
    if not member then
        return nil
    end
    return {
        GuildId = guild.GuildId,
        Name = guild.Name,
        Level = guild.Level,
        Role = member.Role,
        UserId = user_id,
        Slot = selected_slot,
    }
end

function GuildService:create_guild(user_id: number, slot: number?, raw_name: any, transaction_id: string): any
    local selected_slot = slot or 1
    if type(transaction_id) ~= "string" or transaction_id == "" then
        return result(false, "InvalidTransactionId")
    end
    local name = GuildDefinitions.normalize_name(raw_name)
    if not name then
        return result(false, "InvalidGuildName")
    end

    local existing = self:get_membership(user_id, selected_slot)
    if existing then
        local guild = self:get_guild(existing.GuildId)
        if guild and guild.History and guild.History[transaction_id] then
            return result(true, nil, {already_applied = true, guild = guild})
        end
        return result(false, "AlreadyInGuild")
    end

    local guild_id = self._id_generator()
    local now = self._clock()
    local key = member_key(user_id, selected_slot)
    local guild = {
        Version = GuildDefinitions.VERSION,
        GuildId = guild_id,
        Name = name,
        Level = 1,
        XP = 0,
        Gold = 0,
        Members = {
            [key] = {
                UserId = user_id,
                Slot = selected_slot,
                Role = "Leader",
                JoinedAt = now,
            },
        },
        History = {[transaction_id] = true},
    }

    local created, create_error = self._adapter:update(guild_key(guild_id), function(old)
        if old ~= nil then
            return nil
        end
        return guild
    end)
    if not created then
        return result(false, create_error or "GuildCreateFailed")
    end

    local pointer, pointer_error = self._adapter:update(membership_key(user_id, selected_slot), function(old)
        if old ~= nil then
            return nil
        end
        return {GuildId = guild_id}
    end)
    if not pointer then
        self._adapter:remove(guild_key(guild_id))
        return result(false, pointer_error or "MembershipCreateFailed")
    end

    return result(true, nil, {already_applied = false, guild = created})
end

function GuildService:create_invite(actor_user_id: number, target_user_id: number, transaction_id: string, actor_slot: number?, target_slot: number?): any
    local a_slot = actor_slot or 1
    local t_slot = target_slot or 1
    local membership = self:get_membership(actor_user_id, a_slot)
    if not membership then
        return result(false, "NotInGuild")
    end
    if membership.Role ~= "Leader" and membership.Role ~= "Officer" then
        return result(false, "GuildPermissionDenied")
    end
    if self:get_membership(target_user_id, t_slot) then
        return result(false, "TargetAlreadyInGuild")
    end

    local now = self._clock()
    local invite = {
        GuildId = membership.GuildId,
        TargetUserId = target_user_id,
        TargetSlot = t_slot,
        CreatedAt = now,
        ExpiresAt = now + GuildDefinitions.INVITE_SECONDS,
        TransactionId = transaction_id,
    }
    local stored, err = self._adapter:update(invite_key(membership.GuildId, target_user_id, t_slot), function(_old)
        return invite
    end)
    if not stored then
        return result(false, err or "InviteCreateFailed")
    end
    return result(true, nil, {invite = stored})
end

function GuildService:accept_invite(target_user_id: number, guild_id: string, transaction_id: string, target_slot: number?): any
    local slot = target_slot or 1
    if self:get_membership(target_user_id, slot) then
        return result(false, "AlreadyInGuild")
    end
    local invite = self._adapter:load(invite_key(guild_id, target_user_id, slot))
    if not invite then
        return result(false, "InviteNotFound")
    end
    if (tonumber(invite.ExpiresAt) or 0) <= self._clock() then
        return result(false, "InviteExpired")
    end

    local m_key = member_key(target_user_id, slot)
    local updated, update_error = self._adapter:update(guild_key(guild_id), function(guild)
        if type(guild) ~= "table" then
            return nil
        end
        ensure_history(guild)
        if guild.History[transaction_id] then
            return guild
        end
        if count_members(guild) >= GuildDefinitions.MAX_MEMBERS then
            return nil
        end
        guild.Members[m_key] = {
            UserId = target_user_id,
            Slot = slot,
            Role = "Member",
            JoinedAt = self._clock(),
        }
        guild.History[transaction_id] = true
        return guild
    end)
    if not updated then
        return result(false, update_error or "GuildFull")
    end

    local pointer, pointer_error = self._adapter:update(membership_key(target_user_id, slot), function(old)
        if old ~= nil then
            return nil
        end
        return {GuildId = guild_id}
    end)
    if not pointer then
        return result(false, pointer_error or "MembershipCreateFailed")
    end
    self._adapter:remove(invite_key(guild_id, target_user_id, slot))
    return result(true, nil, {guild = updated})
end

function GuildService:set_role(actor_user_id: number, target_user_id: number, role: string, transaction_id: string, actor_slot: number?, target_slot: number?): any
    if role ~= "Officer" and role ~= "Member" then
        return result(false, "InvalidGuildRole")
    end
    local actor = self:get_membership(actor_user_id, actor_slot or 1)
    if not actor or actor.Role ~= "Leader" then
        return result(false, "GuildPermissionDenied")
    end
    local target_key = member_key(target_user_id, target_slot or 1)
    local updated, err = self._adapter:update(guild_key(actor.GuildId), function(guild)
        if type(guild) ~= "table" or not guild.Members[target_key] then
            return nil
        end
        ensure_history(guild)
        if guild.History[transaction_id] then
            return guild
        end
        if guild.Members[target_key].Role == "Leader" then
            return nil
        end
        guild.Members[target_key].Role = role
        guild.History[transaction_id] = true
        return guild
    end)
    if not updated then
        return result(false, err or "GuildMemberNotFound")
    end
    return result(true, nil, {guild = updated})
end

function GuildService:transfer_leadership(actor_user_id: number, target_user_id: number, transaction_id: string, actor_slot: number?, target_slot: number?): any
    local a_slot = actor_slot or 1
    local t_slot = target_slot or 1
    local actor = self:get_membership(actor_user_id, a_slot)
    if not actor or actor.Role ~= "Leader" then
        return result(false, "GuildPermissionDenied")
    end
    local actor_key = member_key(actor_user_id, a_slot)
    local target_key = member_key(target_user_id, t_slot)
    local updated, err = self._adapter:update(guild_key(actor.GuildId), function(guild)
        if type(guild) ~= "table" or not guild.Members[target_key] then
            return nil
        end
        ensure_history(guild)
        if guild.History[transaction_id] then
            return guild
        end
        guild.Members[actor_key].Role = "Officer"
        guild.Members[target_key].Role = "Leader"
        guild.History[transaction_id] = true
        return guild
    end)
    if not updated then
        return result(false, err or "GuildMemberNotFound")
    end
    return result(true, nil, {guild = updated})
end

function GuildService:kick(actor_user_id: number, target_user_id: number, transaction_id: string, actor_slot: number?, target_slot: number?): any
    local target_slot_value = target_slot or 1
    local actor = self:get_membership(actor_user_id, actor_slot or 1)
    if not actor or actor.Role ~= "Leader" then
        return result(false, "GuildPermissionDenied")
    end
    local target_key = member_key(target_user_id, target_slot_value)
    local updated, err = self._adapter:update(guild_key(actor.GuildId), function(guild)
        if type(guild) ~= "table" or not guild.Members[target_key] then
            return nil
        end
        if guild.Members[target_key].Role == "Leader" then
            return nil
        end
        ensure_history(guild)
        if guild.History[transaction_id] then
            return guild
        end
        guild.Members[target_key] = nil
        guild.History[transaction_id] = true
        return guild
    end)
    if not updated then
        return result(false, err or "GuildMemberNotFound")
    end
    self._adapter:remove(membership_key(target_user_id, target_slot_value))
    return result(true, nil, {guild = updated})
end

function GuildService:leave(user_id: number, transaction_id: string, slot: number?): any
    local selected_slot = slot or 1
    local membership = self:get_membership(user_id, selected_slot)
    if not membership then
        return result(false, "NotInGuild")
    end
    local guild = self:get_guild(membership.GuildId)
    if not guild then
        return result(false, "GuildNotFound")
    end
    local key = member_key(user_id, selected_slot)
    local member = guild.Members[key]
    if member.Role == "Leader" and count_members(guild) > 1 then
        return result(false, "LeaderTransferRequired")
    end

    if member.Role == "Leader" then
        self._adapter:remove(guild_key(guild.GuildId))
    else
        local updated, err = self._adapter:update(guild_key(guild.GuildId), function(current)
            if type(current) ~= "table" then
                return nil
            end
            ensure_history(current)
            if current.History[transaction_id] then
                return current
            end
            current.Members[key] = nil
            current.History[transaction_id] = true
            return current
        end)
        if not updated then
            return result(false, err or "GuildLeaveFailed")
        end
    end
    self._adapter:remove(membership_key(user_id, selected_slot))
    return result(true, nil)
end

function GuildService:award_dungeon_clear(user_ids: {number}, transaction_id: string): any
    local groups: {[string]: {number}} = {}
    for _, user_id in ipairs(user_ids) do
        local membership = self:get_membership(user_id, 1)
        if membership then
            local group = groups[membership.GuildId]
            if not group then
                group = {}
                groups[membership.GuildId] = group
            end
            table.insert(group, user_id)
        end
    end

    local awards = {}
    for guild_id, members in pairs(groups) do
        local count = #members
        if count >= 2 then
            local reward = GuildProgressionConfig.clear_reward(count)
            local applied_new = false
            local updated, err = self._adapter:update(guild_key(guild_id), function(guild)
                if type(guild) ~= "table" then
                    return nil
                end
                ensure_history(guild)
                if guild.History[transaction_id] then
                    return guild
                end
                guild.XP = math.max(0, math.floor(tonumber(guild.XP) or 0)) + reward.XP
                guild.Gold = math.max(0, math.floor(tonumber(guild.Gold) or 0)) + reward.Gold
                guild.History[transaction_id] = true
                applied_new = true
                return guild
            end)
            if not updated then
                return result(false, err or "GuildProgressionFailed")
            end
            awards[guild_id] = {
                MemberCount = count,
                XP = reward.XP,
                Gold = reward.Gold,
                Level = updated.Level,
            }
            if applied_new and reward.Gold > 0 then
                self:_record_audit({
                    TransactionId = transaction_id .. ":Guild:" .. guild_id,
                    Kind = "GuildDungeonReward",
                    GuildId = guild_id,
                    GuildGoldDelta = reward.Gold,
                    Reason = "DungeonClear",
                    Timestamp = self._clock(),
                })
            end
        end
    end
    return result(true, nil, {awards = awards})
end

function GuildService:upgrade_guild(actor_user_id: number, transaction_id: string, slot: number?): any
    local membership = self:get_membership(actor_user_id, slot or 1)
    if not membership or membership.Role ~= "Leader" then
        return result(false, "GuildPermissionDenied")
    end

    local spent_gold = 0
    local updated, err = self._adapter:update(guild_key(membership.GuildId), function(guild)
        if type(guild) ~= "table" then
            return nil
        end
        ensure_history(guild)
        if guild.History[transaction_id] then
            return guild
        end
        local level = math.max(1, math.floor(tonumber(guild.Level) or 1))
        local required = GuildProgressionConfig.upgrade_requirement(level)
        if not required then
            return nil
        end
        if (tonumber(guild.XP) or 0) < required.XP then
            return nil
        end
        if (tonumber(guild.Gold) or 0) < required.Gold then
            return nil
        end
        guild.Gold -= required.Gold
        guild.Level = level + 1
        guild.History[transaction_id] = true
        spent_gold = required.Gold
        return guild
    end)
    if not updated then
        return result(false, err or "GuildUpgradeRequirementsNotMet")
    end
    if spent_gold > 0 then
        self:_record_audit({
            TransactionId = transaction_id .. ":Guild:" .. membership.GuildId,
            Kind = "GuildUpgradeSpend",
            UserId = actor_user_id,
            GuildId = membership.GuildId,
            GuildGoldDelta = -spent_gold,
            Reason = "GuildLevelUpgrade",
            Timestamp = self._clock(),
        })
    end
    return result(true, nil, {guild = updated})
end

function GuildService:build_snapshot(user_id: number, slot: number?): any
    local membership = self:get_membership(user_id, slot or 1)
    if not membership then
        return result(true, nil, {membership = nil, guild = nil})
    end
    return result(true, nil, {
        membership = membership,
        guild = self:get_guild(membership.GuildId),
    })
end

return table.freeze(GuildService)
