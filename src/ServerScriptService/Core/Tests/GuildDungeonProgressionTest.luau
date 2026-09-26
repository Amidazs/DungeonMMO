--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local GuildService = require(Services:WaitForChild("GuildService"))

local ids = 0
local adapter = InMemoryEntityAdapter.new()
local service = GuildService.new(
    adapter,
    function() return 2000 end,
    function()
        ids += 1
        return "guild-" .. tostring(ids)
    end
)

local created = assert(service:create_guild(10, 1, "Raiders", "create").guild)
for user_id = 11, 13 do
    assert(service:create_invite(10, user_id, "invite:" .. tostring(user_id)).ok)
    assert(service:accept_invite(user_id, created.GuildId, "join:" .. tostring(user_id)).ok)
end

local solo = service:award_dungeon_clear({10}, "clear:solo")
assert(solo.ok and next(solo.awards) == nil, "Solo clear must not award guild progression.")

local pair = service:award_dungeon_clear({10, 11}, "clear:pair")
assert(pair.ok and pair.awards[created.GuildId].XP == 100)
local after_pair = assert(service:get_guild(created.GuildId))
assert(after_pair.XP == 100 and after_pair.Gold == 40)

assert(service:award_dungeon_clear({10, 11}, "clear:pair").ok)
local replay = assert(service:get_guild(created.GuildId))
assert(replay.XP == 100 and replay.Gold == 40, "Duplicate clear must not award twice.")

assert(service:award_dungeon_clear({10, 11, 12, 13}, "clear:four").ok)
local after_four = assert(service:get_guild(created.GuildId))
assert(after_four.XP == 350 and after_four.Gold == 140)

assert(adapter:update("guild:" .. created.GuildId, function(guild)
    guild.XP = 1000
    guild.Gold = 2500
    return guild
end))
assert(service:upgrade_guild(11, "upgrade:bad").reason == "GuildPermissionDenied")
local upgraded = service:upgrade_guild(10, "upgrade:2")
assert(upgraded.ok and upgraded.guild.Level == 2)
assert(upgraded.guild.XP == 1000, "Guild XP must not be spent by an upgrade.")
assert(upgraded.guild.Gold == 0, "Guild Gold must be spent by an upgrade.")

print("[Guild Dungeon Progression Tests] PASS")
