--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")

local required = {
    "MarketSnapshotRequest",
    "MarketSnapshot",
    "MarketCreateRequest",
    "MarketBuyRequest",
    "MarketCancelRequest",
    "MarketActionResult",
}

local assertions = 0
for _, name in ipairs(required) do
    assertions += 1
    local remote = remotes:FindFirstChild(name)
    if not remote or not remote:IsA("RemoteEvent") then
        error("[Market Remote Contract Tests] Missing RemoteEvent: " .. name, 2)
    end
end

print(string.format(
    "[Market Remote Contract Tests] PASS: %d assertions.",
    assertions
))
