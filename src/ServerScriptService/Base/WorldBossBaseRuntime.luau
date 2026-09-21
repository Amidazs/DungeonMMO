--!strict
-- Optional Base-world-boss gateway. No new models and no live event
-- unless an authorized server explicitly enables and configures it.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Window = require(
    ReplicatedStorage.Core.Shared:WaitForChild("WeeklyWorldBossWindow")
)
local Identity = require(
    ReplicatedStorage.Core.Shared:WaitForChild("CharacterIdentityRules")
)

local WorldBossBaseRuntime = {}
local ENTRY_RANGE = 20

-- Args:
--   config: any; current server-owned destination and schedule settings.
-- Returns:
--   any: validated event schedule or reasoned default-off rejection.
function WorldBossBaseRuntime.validate_config(config: any): any
    if type(config) ~= "table" or config.Enabled ~= true then
        return {ok = false, reason = "WorldBossDisabled"}
    end
    if RunService:IsStudio() then
        return {ok = false, reason = "PublishedTeleportRequired"}
    end
    if type(config.PlaceId) ~= "number" or config.PlaceId <= 0
        or config.PlaceId % 1 ~= 0 or config.PlaceId == game.PlaceId
    then
        return {ok = false, reason = "WorldBossPlaceNotConfigured"}
    end
    return Window.resolve(
        os.time(), config.StartAt, config.EndAt)
end

-- Args:
--   leader: Player; player who activated the physical gateway.
--   party_service: any?; existing Base party registry.
-- Returns:
--   any: authorized group, with leader and all other members present.
function WorldBossBaseRuntime.resolve_party(
    leader: Player,
    party_service: any?
): any
    local party = party_service
        and party_service:party_for_user(leader.UserId)
    if not party or #party.Members <= 1 then
        return {ok = true, players = {leader}}
    end
    if party.LeaderUserId ~= leader.UserId then
        return {ok = false, reason = "PartyLeaderOnly"}
    end
    local players = {}
    for _, member in ipairs(party.Members) do
        local player = Players:GetPlayerByUserId(member.UserId)
        if not player or (member.UserId ~= leader.UserId
            and member.Ready ~= true)
        then
            return {ok = false, reason = "WorldBossPartyNotReady"}
        end
        table.insert(players, player)
    end
    return {ok = true, players = players}
end

-- Args:
--   player: Player; real world-boss party member.
--   anchor: BasePart; existing Base dungeon-board physical anchor.
--   profiles: any; existing authoritative profile service.
-- Returns:
--   any: server-side distance and identity validation.
function WorldBossBaseRuntime.validate_member(
    player: Player,
    anchor: BasePart,
    profiles: any
): any
    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart")
        or (root.Position - anchor.Position).Magnitude > ENTRY_RANGE
    then
        return {ok = false, reason = "WorldBossNotAtPortal"}
    end
    local profile = profiles:get_character(player.UserId, 1)
    if not profile or not Identity.is_complete(profile) then
        return {ok = false, reason = "IdentityIncomplete"}
    end
    return {ok = true}
end

-- Args: None.
-- Returns:
--   any: the current authoritative event settings on the Base server.
local function current_config(): any
    return {
        Enabled = SSS:GetAttribute("DungeonMMOWeeklyWorldBossEnabled"),
        PlaceId = SSS:GetAttribute("DungeonMMOWorldBossPlaceId"),
        StartAt = SSS:GetAttribute("DungeonMMOWorldBossStartUnix"),
        EndAt = SSS:GetAttribute("DungeonMMOWorldBossEndUnix"),
    }
end

-- Args:
--   options: any; already-initialized Base services and environment.
-- Returns:
--   any: disabled state or connected optional physical portal.
function WorldBossBaseRuntime.attach(options: any): any
    if current_config().Enabled ~= true then
        return {ok = true, enabled = false}
    end

    local anchor = options.environment:get("Base.DungeonBoard")
    if not anchor or not anchor:IsA("BasePart") then
        return {ok = false, reason = "WorldBossPortalAnchorMissing"}
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "WeeklyWorldBossEntryPrompt"
    prompt.ActionText = "Enter World Boss"
    prompt.ObjectText = "Ancient Guardian"
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor

    local busy: {[number]: boolean} = {}
    prompt.Triggered:Connect(function(leader: Player)
        if busy[leader.UserId] then
            return
        end
        -- A live server kill-switch must close an already-attached
        -- gateway immediately, not only on the next server restart.
        local config = current_config()
        local schedule = WorldBossBaseRuntime.validate_config(config)
        local party = WorldBossBaseRuntime.resolve_party(
            leader, options.party_service)
        local reason = if not schedule.ok then schedule.reason
            else if not party.ok then party.reason else nil
        local players = if party.ok then party.players else {leader}
        if not reason then
            for _, player in ipairs(players) do
                local validation = WorldBossBaseRuntime.validate_member(
                    player, anchor, options.profiles)
                if not validation.ok then
                    reason = validation.reason
                    break
                end
            end
        end

        local result = {ok = false, reason = reason}
        if not reason then
            busy[leader.UserId] = true
            result = options.coordinator:start_weekly_world_boss(
                players, config.PlaceId, options.bridge,
                config.StartAt, config.EndAt)
            busy[leader.UserId] = nil
        end
        for _, player in ipairs(players) do
            options.entry_result:FireClient(player, {
                ok = result.ok == true,
                reason = result.reason,
                WorldBoss = true,
                SessionId = result.session and result.session.SessionId,
            })
        end
    end)
    return {ok = true, enabled = true, prompt = prompt}
end

return table.freeze(WorldBossBaseRuntime)
