--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Definitions = require(Shared:WaitForChild("EnvironmentAnchorDefinitions"))

local required = {}
for _, anchor_id in ipairs(Definitions.BASE.Required) do
    required[anchor_id] = true
end

for _, anchor_id in ipairs({
    "Base.Service.Travel",
    "Base.Travel.Market",
    "Base.Travel.Dwarves",
    "Base.Travel.Portals",
    "Base.Travel.Orcs",
}) do
    assert(required[anchor_id] == true, "Missing Travel semantic anchor: " .. anchor_id)
end

assert(required["Base.Service.TravelPlaceholder"] ~= true, "Travel placeholder must be removed.")

print("[Travel Environment Contract Tests] PASS")
