--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))

local BankModule = Services:FindFirstChild("BankService")
if not BankModule then
    error("[Bank Service Tests] RED: BankService is missing.")
end
local BankService = require(BankModule)

local function complete_identity(profile: any, slot_key: string)
    profile.Characters[slot_key].Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "Fighter",
        CreationStage = "Complete",
    }
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(9901))
assert(profiles:mutate(9901, function(profile: any)
    complete_identity(profile, "Slot1")
end))

local inventory = InventoryService.new(profiles)
local bank = BankService.new(profiles, "Base")

assert(inventory:add_item(9901, "iron_ore", 50).ok)
local deposit = bank:deposit(9901, "iron_ore", 20)
assert(deposit.ok == true, "partial stack deposit must succeed.")

local snapshot = bank:build_snapshot(9901)
assert(snapshot.ok == true)
assert(snapshot.Capacity == 40)
assert(snapshot.UsedSlots == 1)
assert(snapshot.RemainingSlots == 39)

local iron_inventory = 0
for _, row in ipairs(snapshot.Inventory) do
    if row.ItemId == "iron_ore" then
        iron_inventory = row.Quantity
    end
end
local iron_bank = 0
for _, row in ipairs(snapshot.Items) do
    if row.ItemId == "iron_ore" then
        iron_bank = row.Quantity
    end
end
assert(iron_inventory == 30 and iron_bank == 20)

assert(bank:deposit(9901, "iron_ore", 5).ok)
snapshot = bank:build_snapshot(9901)
assert(snapshot.UsedSlots == 1, "adding to existing stack must consume no extra slot.")

local withdraw = bank:withdraw(9901, "iron_ore", 7)
assert(withdraw.ok == true)
snapshot = bank:build_snapshot(9901)
for _, row in ipairs(snapshot.Items) do
    if row.ItemId == "iron_ore" then
        assert(row.Quantity == 18)
    end
end

assert(inventory:add_item(9901, "arc_slash_book_bound", 1).ok)
local bound = bank:deposit(9901, "arc_slash_book_bound", 1)
assert(bound.ok == false and bound.reason == "ItemNotBankable")

assert(inventory:add_item(9901, "marauder_sword", 2).ok)
assert(profiles:mutate(9901, function(profile: any)
    profile.Characters.Slot1.Equipment.Weapon = "marauder_sword"
end))

local equipped_too_many = bank:deposit(9901, "marauder_sword", 2)
assert(equipped_too_many.ok == false and equipped_too_many.reason == "ItemEquipped")
assert(bank:deposit(9901, "marauder_sword", 1).ok, "spare copy must be bankable.")

local dungeon_bank = BankService.new(profiles, "Dungeon")
local dungeon_result = dungeon_bank:deposit(9901, "iron_ore", 1)
assert(dungeon_result.ok == false and dungeon_result.reason == "BaseOnlyAction")

assert(profiles:load(9902))
assert(profiles:mutate(9902, function(profile: any)
    complete_identity(profile, "Slot1")
end))
local inv2 = InventoryService.new(profiles)
local bank2 = BankService.new(profiles, "Base")
assert(inv2:add_item(9902, "marauder_sword", 41).ok)
assert(bank2:deposit(9902, "marauder_sword", 40).ok)
local before = profiles:get_character(9902, 1)
local before_count = InventoryService.count_item(before, "marauder_sword")
local full = bank2:deposit(9902, "marauder_sword", 1)
assert(full.ok == false and full.reason == "BankFull")
local after = profiles:get_character(9902, 1)
assert(InventoryService.count_item(after, "marauder_sword") == before_count, "failed BankFull mutation must not remove Inventory.")

local raw = ProfileSchema.create_default(9903)
raw.Characters.Slot2 = ProfileSchema.deep_clone(raw.Characters.Slot1)
complete_identity(raw, "Slot1")
complete_identity(raw, "Slot2")
raw.Characters.Slot1.Inventory = {{ItemId = "silverleaf", Quantity = 5}}
raw.Characters.Slot2.Inventory = {}

local raw_deposit = BankService.apply_deposit_to_profile(raw, "Slot1", "silverleaf", 5)
assert(raw_deposit.ok == true)
assert(#raw.Account.Bank.Items == 1)
local raw_withdraw = BankService.apply_withdraw_to_profile(raw, "Slot2", "silverleaf", 2)
assert(raw_withdraw.ok == true)
assert(raw.Characters.Slot2.Inventory[1].Quantity == 2)
assert(raw.Account.Bank.Items[1].Quantity == 3)

print("[Bank Service Tests] PASS")
