--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))

assert(ProfileSchema.VERSION == 7, "Bank gate must use profile schema v7.")

local legacy_v6 = ProfileSchema.create_default(100)
legacy_v6.SchemaVersion = 6
legacy_v6.Account.Bank = nil
legacy_v6.Characters.Slot1.Gold = 321
legacy_v6.Characters.Slot1.Inventory = {
    {ItemId = "iron_ore", Quantity = 7},
}

local migrated = ProfileMigration.migrate(legacy_v6)
assert(migrated.SchemaVersion == 7)
assert(type(migrated.Account.Bank) == "table")
assert(migrated.Account.Bank.Version == 1)
assert(type(migrated.Account.Bank.Items) == "table")
assert(#migrated.Account.Bank.Items == 0, "v6 profile must receive empty Bank.")
assert(migrated.Characters.Slot1.Gold == 321, "migration must preserve existing Gold.")
assert(migrated.Characters.Slot1.Inventory[1].Quantity == 7, "migration must preserve character Inventory.")

local malformed = ProfileSchema.create_default(101)
malformed.Account.Bank = {
    Version = 999,
    Items = {
        {ItemId = "iron_ore", Quantity = 3},
        {ItemId = "iron_ore", Quantity = 4},
        {ItemId = "arc_slash_book_bound", Quantity = 1},
        {ItemId = "__missing__", Quantity = 5},
        {ItemId = "marauder_sword", Quantity = 45},
        {ItemId = "silverleaf", Quantity = -2},
    },
}

local cleaned = ProfileMigration.migrate(malformed)
assert(cleaned.Account.Bank.Version == 1)

local iron = 0
local swords = 0
local bound = 0
local total_slots = 0
for _, entry in ipairs(cleaned.Account.Bank.Items) do
    if entry.ItemId == "iron_ore" then
        iron += entry.Quantity
        total_slots += 1
    elseif entry.ItemId == "marauder_sword" then
        swords += entry.Quantity
        total_slots += entry.Quantity
    elseif entry.ItemId == "arc_slash_book_bound" then
        bound += entry.Quantity
    end
end

assert(iron == 7, "duplicate stackable Bank rows must merge.")
assert(bound == 0, "non-bankable entries must be removed.")
assert(total_slots <= 40, "migration must cap Bank to 40 slots.")
assert(swords == 39, "after one Iron stack, only 39 non-stackable sword slots remain.")

print("[Profile Migration Bank v7 Tests] PASS")
