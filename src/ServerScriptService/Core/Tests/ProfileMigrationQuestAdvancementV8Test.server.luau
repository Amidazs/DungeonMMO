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
        error("[Quest Advancement Migration Tests] " .. message, 2)
    end
end

check(ProfileSchema.VERSION == 8, "Quest/advancement foundation must use schema v8.")

local raw = ProfileSchema.create_default(5301)
raw.SchemaVersion = 7
raw.Characters.Slot1.Quests = nil
raw.Characters.Slot1.ClassAdvancement = nil
raw.Account.Bank = {
    Version = 1,
    Items = {},
}
raw.Characters.Slot1.Professions.Blacksmithing = {
    Level = 3,
    XP = 60,
}

local migrated = ProfileMigration.migrate(raw)
check(migrated.SchemaVersion == 8, "v7 profile must migrate to v8.")
check(
    migrated.Account.Bank ~= nil
        and migrated.Account.Bank.Version == 1
        and type(migrated.Account.Bank.Items) == "table",
    "v8 migration must preserve accepted Bank state."
)
check(
    migrated.Characters.Slot1.Professions.Blacksmithing.XP == 60,
    "v8 migration must preserve profession XP."
)
check(
    migrated.Characters.Slot1.Quests.Version == 1,
    "v8 migration must create quest state."
)
check(
    next(migrated.Characters.Slot1.Quests.Active) == nil
        and next(migrated.Characters.Slot1.Quests.Completed) == nil,
    "Existing v7 characters must receive empty quest history."
)
check(
    migrated.Characters.Slot1.ClassAdvancement.Version == 1,
    "v8 migration must create class-advancement state."
)
check(
    next(migrated.Characters.Slot1.ClassAdvancement.CompletedByRace) == nil,
    "Migration must not manufacture advancement completion."
)

print(string.format(
    "[Quest Advancement Migration Tests] PASS: %d assertions.",
    assertions
))
