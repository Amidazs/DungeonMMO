--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("ReputationDefinitions")
if not module then
    error("[Reputation Definitions Tests] RED: ReputationDefinitions is missing.")
end

local ReputationDefinitions = require(module)
local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Reputation Definitions Tests] " .. message, 2)
    end
end

local valid, reason = ReputationDefinitions.validate()
check(valid == true, reason or "Definitions must validate.")

local scholars = assert(ReputationDefinitions.get("Scholars"))
check(scholars.DisplayName == "Scholars", "Scholars display name mismatch.")
check(ReputationDefinitions.get("UnknownFaction") == nil, "Unknown faction must not resolve.")

print(string.format("[Reputation Definitions Tests] PASS: %d assertions.", assertions))