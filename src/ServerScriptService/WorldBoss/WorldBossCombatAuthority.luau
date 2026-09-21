--!strict
-- Only the isolated world-boss runtime may bind this adapter. It
-- prevents unrelated combat and pre-event support from earning rewards.
local Players = game:GetService("Players")

local WorldBossCombatAuthority = {}
WorldBossCombatAuthority.__index = WorldBossCombatAuthority

-- Args:
--   contributions: any; existing authoritative contribution service.
--   get_encounter: () -> any; current boss, session and admitted users.
-- Returns:
--   any: scoped adapter for the existing combat contribution bridge.
function WorldBossCombatAuthority.new(
    contributions: any,
    get_encounter: () -> any
): any
    assert(contributions ~= nil and type(get_encounter) == "function",
        "Boss combat authority requires contribution and encounter")
    return setmetatable({
        _contributions = contributions,
        _get_encounter = get_encounter,
    }, WorldBossCombatAuthority)
end

-- Args:
--   user_id: number; real authenticated attacking player.
--   event: any; server-created combat contribution event.
-- Returns:
--   any: persisted contribution or an explicit rejection.
function WorldBossCombatAuthority:record_for_user(
    user_id: number,
    event: any
): any
    local context = self._get_encounter()
    local boss = context and context.Boss
    local humanoid = boss and boss:FindFirstChildOfClass("Humanoid")
    local player = Players:GetPlayerByUserId(user_id)
    if not context or not context.Admitted[user_id]
        or not player or not player.Character
        or player.Character:GetAttribute("DungeonRunParticipant") ~= true
        or player.Character:GetAttribute("DungeonEncounterId")
            ~= "WeeklyBoss:" .. tostring(context.SessionId)
        or not humanoid or humanoid.Health <= 0
    then
        return {ok = false, reason = "WorldBossCombatNotActive"}
    end

    local session = context.Sessions:get(context.SessionId)
    local member = session and session.Members[tostring(user_id)]
    local event = session and session.InstanceState
        and session.InstanceState.WeeklyWorldBoss
    if not member or member.Abandoned == true
        or not member.Connected
        or type(event) ~= "table" or event.Defeated == true
    then
        return {ok = false, reason = "WorldBossMemberNotActive"}
    end

    if type(event) ~= "table"
        or type(event.Type) ~= "string"
        or type(event.Metadata) ~= "table"
    then
        return {ok = false, reason = "InvalidWorldBossContribution"}
    end

    if event.Type == "DamageDealt" then
        if event.Metadata.TargetName ~= boss.Name then
            return {ok = false, reason = "InvalidWorldBossTarget"}
        end
    elseif event.Type == "EffectiveHealing"
        or event.Type == "EffectiveWard"
    then
        if context.Admitted[event.Metadata.TargetUserId] ~= true then
            return {ok = false, reason = "InvalidWorldBossSupportTarget"}
        end
    elseif event.Type ~= "DamageMitigated" then
        return {ok = false, reason = "InvalidWorldBossContributionType"}
    end

    return self._contributions:record_for_user(user_id, event)
end

return table.freeze(WorldBossCombatAuthority)
