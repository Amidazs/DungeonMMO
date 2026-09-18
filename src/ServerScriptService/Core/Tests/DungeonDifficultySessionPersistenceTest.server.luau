--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryMapAdapter = require(
    Adapters:WaitForChild("InMemoryMapAdapter")
)
local DungeonSessionService = require(
    Services:WaitForChild("DungeonSessionService")
)

local now = 3000
local function clock(): number
    return now
end

local sessions = DungeonSessionService.new(
    InMemoryMapAdapter.new(clock),
    clock
)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Session Tests] " .. message,
            2
        )
    end
end
local legacy = assert(
    sessions:create(
        "TestDungeon",
        {601},
        100,
        "reserved-legacy"
    )
)
check(
    legacy.Difficulty.Id == "Depth1",
    "Omitted difficulty must default to Depth1."
)
check(
    legacy.Difficulty.Order == 1,
    "Default difficulty order must be 1."
)

local explicit = assert(
    sessions:create(
        "TestDungeon",
        {602},
        100,
        "reserved-depth3",
        "Depth3"
    )
)
check(
    explicit.Difficulty.Id == "Depth3",
    "Explicit difficulty must persist in the session."
)
check(
    explicit.Difficulty.Order == 3,
    "Explicit difficulty order must persist."
)
local reloaded = assert(sessions:get(explicit.SessionId))
check(
    reloaded.Difficulty.Id == "Depth3",
    "Session reload must preserve difficulty."
)
local indexed = assert(sessions:get_for_user(602))
check(
    indexed.Difficulty.Id == "Depth3",
    "Reconnect lookup must preserve the same difficulty."
)

local unknown, unknown_error = sessions:create(
    "TestDungeon",
    {603},
    100,
    "reserved-unknown",
    "Unknown"
)
check(
    unknown == nil and unknown_error == "UnknownDifficulty",
    "Unknown difficulty IDs must be rejected."
)

print(string.format(
    "[Dungeon Difficulty Session Tests] PASS: %d assertions.",
    assertion_count
))
