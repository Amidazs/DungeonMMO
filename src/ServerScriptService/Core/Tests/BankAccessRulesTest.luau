--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local Module = Shared:FindFirstChild("BankAccessRules")
if not Module then
    error("[Bank Access Rules Tests] RED: BankAccessRules is missing.")
end

local BankAccessRules = require(Module)

assert(BankAccessRules.within_distance(Vector3.new(0, 0, 0), Vector3.new(18, 0, 0)) == true)
assert(BankAccessRules.within_distance(Vector3.new(0, 0, 0), Vector3.new(18.01, 0, 0)) == false)

print("[Bank Access Rules Tests] PASS")
