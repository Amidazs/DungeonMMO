--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))

local TravelModule = Services:FindFirstChild("TravelService")
if not TravelModule then
    error("[Travel Service Tests] RED: TravelService is missing.")
end
local TravelService = require(TravelModule)

local function complete_identity(profile: any)
    profile.Characters.Slot1.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "Fighter",
        CreationStage = "Complete",
    }
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(8801))

local travel = TravelService.new(profiles, "Base", {
    is_teleport_pending = function(_user_id: number): boolean
        return false
    end,
    has_recoverable_session = function(_user_id: number): boolean
        return false
    end,
})

local incomplete = travel:validate_request(8801, "Market", 100)
assert(incomplete.ok == false and incomplete.reason == "IdentityIncomplete")

assert(profiles:mutate(8801, function(profile: any)
    complete_identity(profile)
end))

local unknown = travel:validate_request(8801, "__missing__", 100)
assert(unknown.ok == false and unknown.reason == "UnknownDestination")
assert(travel:remaining_cooldown(8801, 100) == 0, "Rejected requests must not start cooldown.")

local valid = travel:validate_request(8801, "Market", 100)
assert(valid.ok == true)
assert(valid.destination.Id == "Market")

travel:record_success(8801, 100)
assert(travel:remaining_cooldown(8801, 100) == 5)

local cooling = travel:validate_request(8801, "Dwarves", 104.99)
assert(cooling.ok == false and cooling.reason == "TravelCooldown")

local expired = travel:validate_request(8801, "Dwarves", 105)
assert(expired.ok == true)

travel:clear_user(8801)
assert(travel:remaining_cooldown(8801, 100) == 0)

local pending = TravelService.new(profiles, "Base", {
    is_teleport_pending = function(_user_id: number): boolean
        return true
    end,
    has_recoverable_session = function(_user_id: number): boolean
        return false
    end,
})
local pending_result = pending:validate_request(8801, "Market", 100)
assert(pending_result.ok == false and pending_result.reason == "TeleportPending")

local active = TravelService.new(profiles, "Base", {
    is_teleport_pending = function(_user_id: number): boolean
        return false
    end,
    has_recoverable_session = function(_user_id: number): boolean
        return true
    end,
})
local active_result = active:validate_request(8801, "Market", 100)
assert(active_result.ok == false and active_result.reason == "ActiveDungeonSession")

local dungeon = TravelService.new(profiles, "Dungeon", {})
local dungeon_result = dungeon:validate_request(8801, "Market", 100)
assert(dungeon_result.ok == false and dungeon_result.reason == "BaseOnlyAction")

local snapshot = travel:build_snapshot(8801, 200)
assert(snapshot.ok == true)
assert(#snapshot.Destinations == 4)
assert(snapshot.Destinations[1].Id == "Market")
assert(snapshot.Destinations[4].Id == "Orcs")
assert(snapshot.Destinations[1].Position == nil)
assert(snapshot.Destinations[1].CFrame == nil)

print("[Travel Service Tests] PASS")
