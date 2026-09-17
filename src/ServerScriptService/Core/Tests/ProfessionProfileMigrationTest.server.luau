--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Profession Profile Migration Tests] " .. message, 2)
    end
end

check(ProfileSchema.VERSION >= 6, "Profession foundation requires schema v6 or newer.")

local fresh = ProfileMigration.migrate(nil)
local fresh_character = fresh.Characters.Slot1
check(type(fresh_character.Professions) == "table", "Fresh profile must contain Professions.")
for _, profession_id in ipairs(ProfessionDefinitions.order()) do
    local state = fresh_character.Professions[profession_id]
    check(type(state) == "table", profession_id .. " must exist on fresh profile.")
    check(state.Level == 1 and state.XP == 0, profession_id .. " must start at Level 1 / 0 XP.")
end

local legacy_v5 = ProfileSchema.create_default(3001)
legacy_v5.SchemaVersion = 5
legacy_v5.Characters.Slot1.Professions = nil
legacy_v5.Characters.Slot1.Inventory = {
    {ItemId = "captain_emblem", Quantity = 4},
}
legacy_v5.Characters.Slot1.Equipment = {
    Weapon = "marauder_sword",
}

local migrated = ProfileMigration.migrate(legacy_v5)
check(migrated.SchemaVersion == ProfileSchema.VERSION, "v5 profile must migrate to the current schema.")
check(migrated.Characters.Slot1.Inventory[1].Quantity == 4, "Migration must preserve inventory.")
check(migrated.Characters.Slot1.Equipment.Weapon == "marauder_sword", "Migration must preserve equipment.")

local malformed = ProfileSchema.create_default(3002)
malformed.Characters.Slot1.Professions = {
    Mining = {Level = 99, XP = -50},
    Blacksmithing = {Level = 99, XP = 30},
    Herbalism = "bad",
    Alchemy = {Level = 2, XP = 100000},
}

local sanitized = ProfileMigration.migrate(malformed)
local states = sanitized.Characters.Slot1.Professions
check(states.Mining.Level == 1 and states.Mining.XP == 0, "Negative Mining XP must sanitize to zero.")
check(states.Blacksmithing.Level == 2 and states.Blacksmithing.XP == 30, "Blacksmithing level must derive from XP.")
check(states.Herbalism.Level == 1 and states.Herbalism.XP == 0, "Malformed Herbalism must reset safely.")
check(states.Alchemy.Level == ProfessionDefinitions.MAX_LEVEL, "Huge XP must clamp level to foundation maximum.")

print(string.format("[Profession Profile Migration Tests] PASS: %d assertions.", assertions))
