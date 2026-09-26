--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Adapters = ServerScriptService:WaitForChild("Core"):WaitForChild("Adapters")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
assert(Adapters:FindFirstChild("RobloxEntityAdapter") ~= nil, "RobloxEntityAdapter must exist.")

local adapter = InMemoryEntityAdapter.new()
local absent = adapter:load("x")
assert(absent == nil, "Unknown entity must load as nil.")

local stored = assert(adapter:update("x", function(old)
    assert(old == nil)
    return {Value = 1}
end))
assert(stored.Value == 1)
stored.Value = 99
assert(assert(adapter:load("x")).Value == 1, "Loads must be defensive copies.")

assert(adapter:update("x", function(old)
    old.Value += 1
    return old
end).Value == 2)
assert(adapter:remove("x"))
assert(adapter:load("x") == nil)

print("[Entity Adapter Contract Tests] PASS")
