--!strict
local Workspace = game:GetService("Workspace")

local GuildRuntime = {}

local HALL_Y = -900
local HALL_SPACING = 180
local hall_slots: {[string]: number} = {}
local next_hall_slot = 0

local function root_part(player: Player): BasePart?
    local character = player.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    return if root and root:IsA("BasePart") then root else nil
end

local function safe_request_id(value: any): string?
    if type(value) ~= "string" or value == "" or #value > 96 then
        return nil
    end
    return value
end

local function valid_user_id(value: any): number?
    if type(value) ~= "number" or value ~= value or value < 1 or value >= math.huge or value % 1 ~= 0 then
        return nil
    end
    return value
end

local function valid_short_id(value: any): string?
    if type(value) ~= "string" or value == "" or #value > 128 then return nil end
    return value
end

local function transaction_id(player: Player, action: string, request_id: string): string
    return string.format("Guild:%d:%s:%s", player.UserId, action, request_id)
end
local function make_part(parent: Instance, name: string, size: Vector3, cframe: CFrame): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = true
    part.Parent = parent
    return part
end

local function ensure_hall_root(): Folder
    local existing = Workspace:FindFirstChild("GuildHallProofRuntime")
    if existing and existing:IsA("Folder") then return existing end
    if existing then existing:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "GuildHallProofRuntime"
    folder.Parent = Workspace
    return folder
end

local function hall_cframe(guild_id: string): CFrame
    local slot = hall_slots[guild_id]
    if not slot then
        next_hall_slot += 1
        slot = next_hall_slot
        hall_slots[guild_id] = slot
    end
    return CFrame.new(slot * HALL_SPACING, HALL_Y, 0)
end
local function ensure_hall(guild_id: string): BasePart
    local root = ensure_hall_root()
    local existing = root:FindFirstChild(guild_id)
    if existing and existing:IsA("Model") then
        local spawn = existing:FindFirstChild("Spawn")
        if spawn and spawn:IsA("BasePart") then return spawn end
        existing:Destroy()
    elseif existing then
        existing:Destroy()
    end

    local model = Instance.new("Model")
    model.Name = guild_id
    model.Parent = root
    local origin = hall_cframe(guild_id)
    make_part(model, "Floor", Vector3.new(60, 2, 60), origin)
    make_part(model, "NorthWall", Vector3.new(60, 18, 2), origin * CFrame.new(0, 9, -30))
    make_part(model, "SouthWall", Vector3.new(60, 18, 2), origin * CFrame.new(0, 9, 30))
    make_part(model, "WestWall", Vector3.new(2, 18, 60), origin * CFrame.new(-30, 9, 0))
    make_part(model, "EastWall", Vector3.new(2, 18, 60), origin * CFrame.new(30, 9, 0))
    local spawn = make_part(model, "Spawn", Vector3.new(4, 1, 4), origin * CFrame.new(0, 2, 0))
    spawn.CanCollide = false
    spawn.Transparency = 1
    return spawn
end

local function pivot_player(player: Player, target: CFrame): boolean
    local character = player.Character
    if not character or not root_part(player) then return false end
    return pcall(function()
        character:PivotTo(target + Vector3.new(0, 4, 0))
    end)
end
function GuildRuntime.attach(config: any): any
    local guilds = assert(config.guilds, "GuildRuntime requires GuildService")
    local hall = assert(config.hall, "GuildRuntime requires GuildHallService")
    local travel = assert(config.travel, "GuildRuntime requires TravelService")
    local environment = assert(config.environment, "GuildRuntime requires Base environment")
    local remotes = assert(config.remotes, "GuildRuntime requires Remotes")
    local rate_limits = config.rate_limits

    local snapshot_request = remotes:WaitForChild("GuildSnapshotRequest") :: RemoteEvent
    local snapshot_remote = remotes:WaitForChild("GuildSnapshot") :: RemoteEvent
    local action_request = remotes:WaitForChild("GuildActionRequest") :: RemoteEvent
    local action_result = remotes:WaitForChild("GuildActionResult") :: RemoteEvent

    local function send_snapshot(player: Player)
        snapshot_remote:FireClient(player, guilds:build_snapshot(player.UserId, 1))
    end

    local function finish(player: Player, action: string, response: any)
        action_result:FireClient(player, {
            action = action,
            ok = response and response.ok == true,
            reason = response and response.reason or nil,
            admission = response and response.admission or nil,
        })
        if response and response.ok == true then send_snapshot(player) end
    end

    snapshot_request.OnServerEvent:Connect(function(player: Player)
        send_snapshot(player)
    end)
    action_request.OnServerEvent:Connect(function(
        player: Player,
        action: any,
        payload: any,
        request_id: any
    )
        if type(action) ~= "string" or #action > 32 then
            finish(player, "Invalid", {ok = false, reason = "InvalidGuildAction"})
            return
        end
        local request = safe_request_id(request_id)
        if not request then
            finish(player, action, {ok = false, reason = "InvalidRequestId"})
            return
        end
        if rate_limits and not rate_limits:allow(player.UserId, "GuildManagement", 12, 10) then
            finish(player, action, {ok = false, reason = "RateLimited"})
            return
        end
        local body = if type(payload) == "table" then payload else {}
        local tx = transaction_id(player, action, request)
        local response: any

        if action == "Create" then
            response = guilds:create_guild(player.UserId, 1, body.Name, tx)
        elseif action == "Invite" then
            local target = valid_user_id(body.TargetUserId)
            response = if target then guilds:create_invite(player.UserId, target, tx) else {ok=false, reason="InvalidGuildRequest"}
        elseif action == "Accept" then
            local guild_id = valid_short_id(body.GuildId)
            response = if guild_id then guilds:accept_invite(player.UserId, guild_id, tx) else {ok=false, reason="InvalidGuildRequest"}
        elseif action == "SetRole" then
            local target = valid_user_id(body.TargetUserId)
            local role = valid_short_id(body.Role)
            response = if target and role then guilds:set_role(player.UserId, target, role, tx) else {ok=false, reason="InvalidGuildRequest"}
        elseif action == "TransferLeader" then
            local target = valid_user_id(body.TargetUserId)
            response = if target then guilds:transfer_leadership(player.UserId, target, tx) else {ok=false, reason="InvalidGuildRequest"}
        elseif action == "Kick" then
            local target = valid_user_id(body.TargetUserId)
            response = if target then guilds:kick(player.UserId, target, tx) else {ok=false, reason="InvalidGuildRequest"}
        elseif action == "Leave" then
            response = guilds:leave(player.UserId, tx)
        elseif action == "Upgrade" then
            response = guilds:upgrade_guild(player.UserId, tx)
        elseif action == "HallEntry" then
            local travel_check = travel:validate_special_request(player.UserId)
            if travel_check.ok ~= true then
                finish(player, action, travel_check)
                return
            end
            response = hall:create_entry(player.UserId, 1)
            if response.ok == true then
                local admission_check = hall:validate_entry(player.UserId, response.admission)
                if admission_check.ok ~= true then
                    finish(player, action, admission_check)
                    return
                end
                local spawn = ensure_hall(response.admission.GuildId)
                if not pivot_player(player, spawn.CFrame) then
                    finish(player, action, {ok = false, reason = "GuildHallTravelFailed"})
                    return
                end
                travel:record_success(player.UserId)
            end
        elseif action == "HallExit" then
            local destination = environment:get("Base.PlayerSpawn")
            if not destination then
                finish(player, action, {ok = false, reason = "BaseSpawnUnavailable"})
                return
            end
            if not pivot_player(player, destination.CFrame) then
                finish(player, action, {ok = false, reason = "GuildHallTravelFailed"})
                return
            end
            response = {ok = true}
        else
            response = {ok = false, reason = "UnknownGuildAction"}
        end

        finish(player, action, response)
    end)

    return {
        send_snapshot = send_snapshot,
    }
end

return table.freeze(GuildRuntime)
