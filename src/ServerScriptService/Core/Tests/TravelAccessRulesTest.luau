--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local Module = Shared:FindFirstChild("TravelAccessRules")
if not Module then
    error("[Travel Access Rules Tests] RED: TravelAccessRules is missing.")
end

local TravelAccessRules = require(Module)

assert(TravelAccessRules.within_service_distance(
    Vector3.zero,
    Vector3.new(18, 0, 0)
) == true)

assert(TravelAccessRules.within_service_distance(
    Vector3.zero,
    Vector3.new(18.01, 0, 0)
) == false)

assert(TravelAccessRules.already_at_destination(
    Vector3.zero,
    Vector3.new(10, 0, 0)
) == true)

assert(TravelAccessRules.already_at_destination(
    Vector3.zero,
    Vector3.new(10.01, 0, 0)
) == false)

print("[Travel Access Rules Tests] PASS")
