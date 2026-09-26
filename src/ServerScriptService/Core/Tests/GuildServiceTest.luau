--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local GuildService = require(Services:WaitForChild("GuildService"))

local now = 1000
local next_id = 0
local service = GuildService.new(
    InMemoryEntityAdapter.new(),
    function() return now end,
    function()
        next_id += 1
        return "guild-" .. tostring(next_id)
    end
)

local created = service:create_guild(1, 1, "  Night Watch  ", "create:1")
assert(created.ok and created.guild.Name == "Night Watch")
assert(created.guild.Level == 1 and created.guild.XP == 0 and created.guild.Gold == 0)
assert(service:get_membership(1, 1).Role == "Leader")
assert(service:create_guild(1, 1, "Other", "create:2").reason == "AlreadyInGuild")

local invite = service:create_invite(1, 2, "invite:2")
assert(invite.ok)
local joined = service:accept_invite(2, created.guild.GuildId, "join:2")
assert(joined.ok)
assert(service:get_membership(2, 1).Role == "Member")

local denied = service:set_role(2, 1, "Officer", "role:bad")
assert(not denied.ok and denied.reason == "GuildPermissionDenied")
assert(service:set_role(1, 2, "Officer", "role:2").ok)
assert(service:get_membership(2, 1).Role == "Officer")

local invite3 = service:create_invite(2, 3, "invite:3")
assert(invite3.ok, "Officer must be allowed to invite.")
assert(service:accept_invite(3, created.guild.GuildId, "join:3").ok)
assert(service:kick(2, 3, "kick:bad").reason == "GuildPermissionDenied")
assert(service:kick(1, 3, "kick:3").ok)
assert(service:get_membership(3, 1) == nil)

assert(service:transfer_leadership(1, 2, "leader:2").ok)
assert(service:get_membership(2, 1).Role == "Leader")
assert(service:get_membership(1, 1).Role == "Officer")
assert(service:leave(2, "leave:leader").reason == "LeaderTransferRequired")
assert(service:transfer_leadership(2, 1, "leader:1").ok)
assert(service:leave(2, "leave:2").ok)

print("[Guild Service Tests] PASS")
