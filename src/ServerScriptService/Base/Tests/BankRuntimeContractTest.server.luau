--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
for _, name in ipairs({
    "BankSnapshotRequest",
    "BankSnapshot",
    "BankDepositRequest",
    "BankWithdrawRequest",
    "BankActionResult",
}) do
    assert(remotes:FindFirstChild(name) ~= nil, "Missing Bank remote: " .. name)
end

local Base = ServerScriptService:WaitForChild("Base")
assert(Base:FindFirstChild("BankRuntime") ~= nil, "BankRuntime module must exist.")

print("[Bank Runtime Contract Tests] PASS")
