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
    if not value then error("[Race Change Migration Tests] " .. message, 2) end
end

local raw = ProfileSchema.create_default(8001)
raw.SchemaVersion = 11
raw.Characters.Slot1.Identity = {
    Version = 1,
    RaceId = "Human",
    BaseClassId = "Rogue",
    ClassId = "Rogue",
    CreationStage = "Complete",
}
raw.Characters.Slot1.ClassAdvancement = {
    Version = 1,
    CompletedByRace = {
        Human = {HumanRogueDuelist = true, BogusClass = true},
        BogusRace = {HumanRogueDuelist = true},
    },
    ActiveClassId = "HumanRogueDuelist",
}
raw.Characters.Slot1.RaceChange = {
    Version = 99,
    ArchivedByRace = {
        Human = {
            Skills = {
                DuelistDeadlyBlow = {
                    Known = true,
                    StarterGranted = false,
                    PurchasedRank = 2,
                    Proficiency = 250,
                },
                [5] = {Known = true},
            },
            Advancement = {garbage = true},
        },
        BogusRace = {Skills = {DuelistRush = {Known = true}}},
    },
    History = {
        tx1 = {
            TransactionId = "tx1",
            SourceRaceId = "Human",
            TargetRaceId = "Elf",
        },
        [9] = {TransactionId = "bad"},
    },
}

local migrated = ProfileMigration.migrate(raw)
check(
    migrated.SchemaVersion == ProfileSchema.VERSION,
    "Migration must advance to the current schema."
)
local character = migrated.Characters.Slot1
check(character.RaceChange.Version == 1, "Race Change state must sanitize to version 1.")
check(character.RaceChange.ArchivedByRace.BogusRace == nil,
    "Unknown archived races must be removed.")
check(character.RaceChange.ArchivedByRace.Human ~= nil,
    "Known archived race must survive migration.")
check(character.RaceChange.ArchivedByRace.Human.Skills.DuelistDeadlyBlow.PurchasedRank == 2,
    "Archived skill rank must be preserved through sanitization.")
check(character.RaceChange.History.tx1 ~= nil and character.RaceChange.History[9] == nil,
    "Only string-keyed Race Change receipts must survive.")
check(character.ClassAdvancement.CompletedByRace.Human.HumanRogueDuelist == true,
    "Canonical per-race advancement must survive.")
check(character.ClassAdvancement.CompletedByRace.Human.BogusClass == nil,
    "Unknown advancement IDs must be removed.")
check(character.ClassAdvancement.CompletedByRace.BogusRace == nil,
    "Unknown advancement race keys must be removed.")
check(character.ClassAdvancement.ActiveClassId == "HumanRogueDuelist",
    "Valid current-race active advancement must survive.")

local twice = ProfileMigration.migrate(migrated)
check(
    twice.SchemaVersion == ProfileSchema.VERSION,
    "Repeated migration must remain on the current schema."
)
check(twice.Characters.Slot1.RaceChange.ArchivedByRace.Human.Skills.DuelistDeadlyBlow.Proficiency == 250,
    "Repeated migration must preserve archived proficiency.")
check(twice.Characters.Slot1.ClassAdvancement.ActiveClassId == "HumanRogueDuelist",
    "Repeated migration must preserve valid active advancement.")

print(string.format("[Race Change Migration Tests] PASS: %d assertions.", assertions))
