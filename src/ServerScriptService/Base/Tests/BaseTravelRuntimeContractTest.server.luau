--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
for _, name in ipairs({
    "TravelSnapshotRequest",
    "TravelSnapshot",
    "TravelRequest",
    "TravelActionResult",
}) do
    assert(remotes:FindFirstChild(name) ~= nil, "Missing Travel remote: " .. name)
end

local Base = ServerScriptService:WaitForChild("Base")
assert(Base:FindFirstChild("BaseTravelRuntime") ~= nil, "BaseTravelRuntime module must exist.")

print("[Base Travel Runtime Contract Tests] PASS")
