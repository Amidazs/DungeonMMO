--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local BankConfigModule = Shared:FindFirstChild("BankConfig")
local TransferModule = Shared:FindFirstChild("ItemTransferRules")

if not BankConfigModule then
    error("[Bank Config/Transfer Tests] RED: BankConfig is missing.")
end
if not TransferModule then
    error("[Bank Config/Transfer Tests] RED: ItemTransferRules is missing.")
end

local BankConfig = require(BankConfigModule)
local ItemTransferRules = require(TransferModule)

assert(BankConfig.VERSION == 1, "Bank config version must be 1.")
assert(BankConfig.CAPACITY == 40, "Initial Bank capacity must be exactly 40.")
assert(BankConfig.ACCESS_DISTANCE == 18, "Bank access distance must be exactly 18 studs.")

local iron_ok, iron_reason = ItemTransferRules.can_bank("iron_ore")
assert(iron_ok == true and iron_reason == nil, "Ordinary materials must be bankable.")

local bound_ok, bound_reason = ItemTransferRules.can_bank("arc_slash_book_bound")
assert(bound_ok == false and bound_reason == "ItemNotBankable", "Bound Skill Book must be rejected.")

local unknown_ok, unknown_reason = ItemTransferRules.can_bank("__unknown_bank_item__")
assert(unknown_ok == false and unknown_reason == "UnknownItem", "Unknown item must be rejected.")

print("[Bank Config/Transfer Tests] PASS")
