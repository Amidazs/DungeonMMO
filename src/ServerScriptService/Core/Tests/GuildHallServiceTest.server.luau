--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local GuildService = require(Services:WaitForChild("GuildService"))
local GuildHallService = require(Services:WaitForChild("GuildHallService"))

local guilds = GuildService.new(
    InMemoryEntityAdapter.new(),
    function() return 3000 end,
    function() return "hall-guild" end
)
local hall = GuildHallService.new(guilds, function() return 3001 end)

assert(hall:create_entry(90).reason == "NotInGuild")
assert(guilds:create_guild(90, 1, "Hall Test", "create:hall").ok)

local entry = hall:create_entry(90)
assert(entry.ok and entry.admission.GuildId == "hall-guild")
assert(entry.admission.HallKey == "GuildHall:hall-guild")
assert(hall:validate_entry(90, entry.admission).ok)
assert(not hall:validate_entry(91, entry.admission).ok)

print("[Guild Hall Service Tests] PASS")
