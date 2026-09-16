local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")

for _, name in ipairs({"PartyActionRequest", "PartySnapshot", "PartyActionResult"}) do
    local remote = remotes:FindFirstChild(name)
    assert(remote ~= nil, name .. " remote missing")
    assert(remote:IsA("RemoteEvent"), name .. " must be RemoteEvent")
end

print("[Party Remote Contract Tests] PASS")
