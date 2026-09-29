--!strict
local GuildDefinitions = {}

GuildDefinitions.VERSION = 2
GuildDefinitions.MAX_MEMBERS = 20
GuildDefinitions.MIN_NAME_LENGTH = 3
GuildDefinitions.MAX_NAME_LENGTH = 24
GuildDefinitions.INVITE_SECONDS = 300
GuildDefinitions.ROLES = table.freeze({
    Leader = "Leader",
    Officer = "Officer",
    Member = "Member",
})

GuildDefinitions.MAX_MESSAGE_LENGTH = 180

function GuildDefinitions.normalize_name(raw: any): string?
    if type(raw) ~= "string" then
        return nil
    end
    local name = string.match(raw, "^%s*(.-)%s*$") or ""
    local length = utf8.len(name)
    if not length
        or length < GuildDefinitions.MIN_NAME_LENGTH
        or length > GuildDefinitions.MAX_NAME_LENGTH
    then
        return nil
    end
    if string.find(name, "[%c]") then
        return nil
    end
    return name
end

function GuildDefinitions.is_role(role: any): boolean
    return role == "Leader" or role == "Officer" or role == "Member"
end

--[[
Creates default mutable guild settings for one stored guild.

Args:
    None.

Returns:
    any: New settings table with independent nested permissions.
]]
function GuildDefinitions.default_settings(): any
    return {
        MessageOfTheDay = "",
        ViewSettingsByRole = {
            Leader = true,
            Officer = false,
            Member = false,
        },
    }
end

--[[
Normalizes the optional guild message of the day.

Args:
    raw (any): Proposed guild message.

Returns:
    string?: Trimmed valid message, or nil when invalid.
]]
function GuildDefinitions.normalize_message(raw: any): string?
    if type(raw) ~= "string" then
        return nil
    end

    local message = string.match(raw, "^%s*(.-)%s*$") or ""
    local length = utf8.len(message)

    if not length
        or length > GuildDefinitions.MAX_MESSAGE_LENGTH
        or string.find(message, "[%c]")
    then
        return nil
    end

    return message
end

--[[
Returns whether a role may see the Guild Settings page.

Args:
    guild (any): Stored guild object.
    role (any): Member role.

Returns:
    boolean: True when settings should be visible to the role.
]]
function GuildDefinitions.can_view_settings(
    guild: any,
    role: any
): boolean
    if role == "Leader" then
        return true
    end

    if not GuildDefinitions.is_role(role)
        or type(guild) ~= "table"
        or type(guild.Settings) ~= "table"
        or type(guild.Settings.ViewSettingsByRole) ~= "table"
    then
        return false
    end

    return guild.Settings.ViewSettingsByRole[role] == true
end

return table.freeze(GuildDefinitions)
