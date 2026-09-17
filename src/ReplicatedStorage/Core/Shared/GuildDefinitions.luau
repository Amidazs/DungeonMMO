--!strict
local GuildDefinitions = {}

GuildDefinitions.VERSION = 1
GuildDefinitions.MAX_MEMBERS = 20
GuildDefinitions.MIN_NAME_LENGTH = 3
GuildDefinitions.MAX_NAME_LENGTH = 24
GuildDefinitions.INVITE_SECONDS = 300
GuildDefinitions.ROLES = table.freeze({
    Leader = "Leader",
    Officer = "Officer",
    Member = "Member",
})

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

return table.freeze(GuildDefinitions)
