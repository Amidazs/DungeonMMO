--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Race Change Remote Contract Tests] " .. message, 2) end
end

for _, name in ipairs({
    "RaceChangePreviewRequest",
    "RaceChangePreview",
    "RaceChangeApplyRequest",
    "RaceChangeActionResult",
}) do
    local remote = remotes:FindFirstChild(name)
    check(remote ~= nil and remote:IsA("RemoteEvent"),
        name .. " must exist as a RemoteEvent.")
end

check(remotes:FindFirstChild("RaceChangePurchaseRequest") == nil,
    "Phase 3 must not expose a Race Change purchase/Robux remote.")

print(string.format("[Race Change Remote Contract Tests] PASS: %d assertions.", assertions))
