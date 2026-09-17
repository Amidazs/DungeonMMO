--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local ConfigModule = Shared:FindFirstChild("TravelConfig")
local DefinitionsModule = Shared:FindFirstChild("TravelDestinationDefinitions")

if not ConfigModule then
    error("[Travel Config/Definitions Tests] RED: TravelConfig is missing.")
end
if not DefinitionsModule then
    error("[Travel Config/Definitions Tests] RED: TravelDestinationDefinitions is missing.")
end

local TravelConfig = require(ConfigModule)
local TravelDestinationDefinitions = require(DefinitionsModule)
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))

assert(TravelConfig.HOLD_DURATION == 1, "Travel hold duration must be exactly 1 second.")
assert(TravelConfig.ACCESS_DISTANCE == 18, "Travel access distance must be exactly 18 studs.")
assert(TravelConfig.COOLDOWN_SECONDS == 5, "Travel cooldown must be exactly 5 seconds.")
assert(TravelConfig.ARRIVAL_HEIGHT_OFFSET == 3, "Travel arrival height offset must be 3 studs.")
assert(TravelConfig.ALREADY_THERE_DISTANCE == 10, "Already-there distance must be 10 studs.")
assert(ProfileSchema.VERSION >= 7, "Travel v1 requires Bank-era schema v7 or newer.")

local expected = {
    {"Market", "Market", "Base.Travel.Market"},
    {"Dwarves", "Dwarven Area", "Base.Travel.Dwarves"},
    {"Portals", "Dungeon Portals", "Base.Travel.Portals"},
    {"Orcs", "Orc Area", "Base.Travel.Orcs"},
}

assert(#TravelDestinationDefinitions.ORDER == 4, "Travel v1 must expose exactly four destinations.")

for index, row in ipairs(expected) do
    local id = TravelDestinationDefinitions.ORDER[index]
    assert(id == row[1], "Travel destination order mismatch.")
    local definition = TravelDestinationDefinitions.get(id)
    assert(definition ~= nil, "Travel destination missing: " .. row[1])
    assert(definition.Id == row[1])
    assert(definition.Name == row[2])
    assert(definition.AnchorId == row[3])
    assert(definition.SortOrder == index)
end

print("[Travel Config/Definitions Tests] PASS")
