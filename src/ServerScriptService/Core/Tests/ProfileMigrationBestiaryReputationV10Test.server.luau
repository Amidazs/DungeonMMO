--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Bestiary Reputation Migration Tests] " .. message, 2)
    end
end

local raw = ProfileSchema.create_default(9101)
raw.SchemaVersion = 9
raw.Bestiary = nil
raw.Reputation = nil
raw.Characters.Slot1.CraftingKnowledge.LearnedRecipes["blacksmith_iron_guard_blueprint"] = true
raw.Characters.Slot1.Quests.Completed["migration_sentinel"] = true
raw.Characters.Slot1.ClassAdvancement.CompletedByRace.Elf = "Ranger"

local migrated = ProfileMigration.migrate(raw)

check(ProfileSchema.VERSION == 10, "Current schema must be v10.")
check(migrated.SchemaVersion == 10, "v9 profile must migrate to v10.")
check(migrated.Characters.Slot1.Bestiary.Version == 1, "Bestiary version missing.")
check(
    next(migrated.Characters.Slot1.Bestiary.Entries) == nil,
    "Migration must not invent bestiary discoveries."
)
check(migrated.Characters.Slot1.Reputation.Version == 1, "Reputation version missing.")
check(
    migrated.Characters.Slot1.Reputation.Factions.Scholars.Points == 0,
    "Migrated Scholars reputation must start at zero."
)
check(
    migrated.Characters.Slot1.CraftingKnowledge.LearnedRecipes[
        "blacksmith_iron_guard_blueprint"
    ] == true,
    "Recipe knowledge sentinel must survive."
)
check(
    migrated.Characters.Slot1.Quests.Completed["migration_sentinel"] == true,
    "Quest sentinel must survive."
)
check(
    migrated.Characters.Slot1.ClassAdvancement.CompletedByRace.Elf == "Ranger",
    "Class advancement sentinel must survive."
)

local malformed = ProfileSchema.create_default(9102)
malformed.SchemaVersion = 9
malformed.Characters.Slot1.Bestiary = {
    Version = 999,
    Entries = {
        marauder = {
            Kills = -2,
            Milestones = {
                good = true,
                bad = "yes",
            },
        },
    },
}
malformed.Characters.Slot1.Reputation = {
    Version = 999,
    Factions = {
        Scholars = {
            Points = 2.5,
        },
    },
}

local safe = ProfileMigration.migrate(malformed)
local entry = safe.Characters.Slot1.Bestiary.Entries.marauder
check(entry.Kills == 0, "Negative bestiary kills must sanitize to zero.")
check(entry.Milestones.good == true, "True milestone membership must survive.")
check(entry.Milestones.bad == nil, "Non-boolean milestone membership must be removed.")
check(
    safe.Characters.Slot1.Reputation.Factions.Scholars.Points == 0,
    "Fractional reputation must sanitize to zero."
)

local again = ProfileMigration.migrate(safe)
check(
    again.Characters.Slot1.Bestiary.Entries.marauder.Kills == 0,
    "Repeated migration must preserve sanitized bestiary kills."
)
check(
    again.Characters.Slot1.Bestiary.Entries.marauder.Milestones.good == true,
    "Repeated migration must preserve valid milestones."
)
check(
    again.Characters.Slot1.Reputation.Factions.Scholars.Points == 0,
    "Repeated migration must preserve sanitized reputation."
)

local fresh_a = ProfileSchema.create_default(9103)
local fresh_b = ProfileSchema.create_default(9104)
fresh_a.Characters.Slot1.Bestiary.Entries.marauder = {
    Kills = 1,
    Milestones = {},
}
fresh_a.Characters.Slot1.Reputation.Factions.Scholars.Points = 5

check(
    fresh_b.Characters.Slot1.Bestiary.Entries.marauder == nil,
    "Fresh profiles must not share bestiary tables."
)
check(
    fresh_b.Characters.Slot1.Reputation.Factions.Scholars.Points == 0,
    "Fresh profiles must not share reputation tables."
)

print(string.format(
    "[Bestiary Reputation Migration Tests] PASS: %d assertions.",
    assertions
))