--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local module = Services:FindFirstChild("ReputationService")
if not module then
    error("[Reputation Service Tests] RED: ReputationService is missing.")
end

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local ReputationService = require(module)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Reputation Service Tests] " .. message, 2)
    end
end

local character = ProfileSchema.create_default(9201).Characters.Slot1

local first = ReputationService.apply_points_to_character(character, "Scholars", 5)
check(first.ok == true and first.new_points == 5, "First Scholars award must reach 5.")

local second = ReputationService.apply_points_to_character(character, "Scholars", 10)
check(second.ok == true and second.new_points == 15, "Second Scholars award must reach 15.")

local before = character.Reputation.Factions.Scholars.Points
for _, invalid in ipairs({0, -1, 1.5, 0 / 0, math.huge}) do
    local rejected = ReputationService.apply_points_to_character(
        character,
        "Scholars",
        invalid
    )
    check(
        rejected.ok == false and rejected.reason == "InvalidPoints",
        "Invalid point amount must reject."
    )
end
check(
    character.Reputation.Factions.Scholars.Points == before,
    "Rejected awards must not mutate reputation."
)

local unknown = ReputationService.apply_points_to_character(
    character,
    "UnknownFaction",
    5
)
check(
    unknown.ok == false and unknown.reason == "UnknownFaction",
    "Unknown faction must reject."
)

local adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(adapter)
assert(profiles:load(9202))
local service = ReputationService.new(profiles)
local snapshot = service:get_snapshot(9202)
check(snapshot.ok == true, "Loaded profile snapshot must succeed.")
snapshot.reputation.Factions.Scholars.Points = 99
check(
    assert(profiles:get_character(9202, 1)).Reputation.Factions.Scholars.Points == 0,
    "Snapshot must be a deep clone."
)

local missing = service:get_snapshot(999999)
check(
    missing.ok == false and missing.reason == "ProfileNotLoaded",
    "Missing profile snapshot must reject."
)

print(string.format("[Reputation Service Tests] PASS: %d assertions.", assertions))