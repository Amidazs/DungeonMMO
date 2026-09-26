--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Profile Migration Market V11 Tests] " .. message, 2) end
end

local legacy = ProfileSchema.create_default(7001)
legacy.SchemaVersion = 10
legacy.Characters.Slot1.Market = nil
legacy.Characters.Slot1.Gold = 321
legacy.Characters.Slot1.Bestiary.Entries.marauder = {Kills = 7, Milestones = {first_defeat = true}}

local migrated = ProfileMigration.migrate(legacy)
check(migrated.SchemaVersion == ProfileSchema.VERSION, "v10 profile must migrate to current schema.")
check(migrated.Characters.Slot1.Gold == 321, "Market migration must preserve Gold.")
check(migrated.Characters.Slot1.Bestiary.Entries.marauder.Kills == 7,
    "Market migration must preserve prior Phase 3 state.")
check(migrated.Characters.Slot1.Market.Version == 1, "Market state must be created.")
check(#migrated.Characters.Slot1.Market.ActiveListingIds == 0, "New Market active list must be empty.")
local malformed = ProfileSchema.create_default(7002)
malformed.SchemaVersion = 10
malformed.Characters.Slot1.Market = {
    Version = 999,
    ActiveListingIds = {"a", "", "a", 5, "b"},
    History = {good = {Kind = "Create"}, bad = "nope"},
    Recovery = {listing = {State = "Listed"}, broken = 12},
}
local cleaned = ProfileMigration.migrate(malformed)
check(cleaned.Characters.Slot1.Market.Version == 1, "Market version must sanitize.")
check(#cleaned.Characters.Slot1.Market.ActiveListingIds == 2,
    "Market active listing IDs must be unique valid strings.")
check(cleaned.Characters.Slot1.Market.History.good.Kind == "Create",
    "Valid Market history receipt must survive sanitization.")
check(cleaned.Characters.Slot1.Market.History.bad == nil,
    "Malformed Market history receipt must be removed.")
check(cleaned.Characters.Slot1.Market.Recovery.listing.State == "Listed",
    "Valid Market recovery receipt must survive sanitization.")
check(cleaned.Characters.Slot1.Market.Recovery.broken == nil,
    "Malformed Market recovery receipt must be removed.")

local repeated = ProfileMigration.migrate(cleaned)
check(repeated.SchemaVersion == ProfileSchema.VERSION, "Repeated migration must remain current schema.")
check(#repeated.Characters.Slot1.Market.ActiveListingIds == 2,
    "Repeated migration must be idempotent for active listings.")
print(string.format("[Profile Migration Market V11 Tests] PASS: %d assertions.", assertions))
