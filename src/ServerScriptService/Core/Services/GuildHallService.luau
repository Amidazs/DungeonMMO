--!strict
local GuildHallService = {}
GuildHallService.__index = GuildHallService

function GuildHallService.new(guild_service: any, clock: (() -> number)?): any
    assert(guild_service ~= nil, "GuildHallService requires GuildService")
    local self = setmetatable({}, GuildHallService)
    self._guilds = guild_service
    self._clock = clock or os.time
    return self
end

function GuildHallService:create_entry(user_id: number, slot: number?): any
    local membership = self._guilds:get_membership(user_id, slot or 1)
    if not membership then
        return {ok = false, reason = "NotInGuild"}
    end
    local guild = self._guilds:get_guild(membership.GuildId)
    if not guild then
        return {ok = false, reason = "GuildNotFound"}
    end
    return {
        ok = true,
        reason = nil,
        admission = {
            Version = 1,
            GuildId = guild.GuildId,
            UserId = user_id,
            Slot = slot or 1,
            Role = membership.Role,
            HallKey = "GuildHall:" .. guild.GuildId,
            GuildLevel = guild.Level,
            IssuedAt = self._clock(),
        },
    }
end

function GuildHallService:validate_entry(user_id: number, admission: any): any
    if type(admission) ~= "table"
        or type(admission.GuildId) ~= "string"
        or admission.UserId ~= user_id
    then
        return {ok = false, reason = "InvalidGuildHallAdmission"}
    end
    local membership = self._guilds:get_membership(user_id, admission.Slot or 1)
    if not membership or membership.GuildId ~= admission.GuildId then
        return {ok = false, reason = "GuildHallMembershipChanged"}
    end
    return {ok = true, reason = nil}
end

return table.freeze(GuildHallService)
