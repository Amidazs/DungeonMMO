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
        error("[Recipe Knowledge Migration Tests] " .. message, 2)
    end
end

check(ProfileSchema.VERSION == 10, "Recipe knowledge gate must use schema v9.")

local raw = ProfileSchema.create_default(8401)
raw.SchemaVersion = 8
raw.Characters.Slot1.CraftingKnowledge = nil
raw.Characters.Slot1.Inventory = {
    {ItemId = "iron_ore", Quantity = 7},
}
raw.Characters.Slot1.Quests.Completed["MigrationProof"] = true
raw.Characters.Slot1.ClassAdvancement.CompletedByRace["Human"] = {
    HumanArcanist = true,
}
raw.Account.Bank.Items = {
    {ItemId = "captain_emblem", Quantity = 2},
}

local migrated = ProfileMigration.migrate(raw)
local character = migrated.Characters.Slot1

check(migrated.SchemaVersion == 10, "v8 profile must migrate to schema v9.")
check(
    type(character.CraftingKnowledge) == "table",
    "Migration must create CraftingKnowledge."
)
check(
    character.CraftingKnowledge.Version == 1,
    "CraftingKnowledge version must be 1."
)
check(
    type(character.CraftingKnowledge.LearnedRecipes) == "table",
    "Migration must create LearnedRecipes."
)
check(
    next(character.CraftingKnowledge.LearnedRecipes) == nil,
    "Migration must not infer historical blueprint knowledge."
)
check(
    character.Inventory[1].ItemId == "iron_ore"
        and character.Inventory[1].Quantity == 7,
    "Migration must preserve Inventory."
)
check(
    character.Quests.Completed["MigrationProof"] == true,
    "Migration must preserve quest state."
)
check(
    character.ClassAdvancement.CompletedByRace["Human"].HumanArcanist == true,
    "Migration must preserve advancement state."
)
check(
    migrated.Account.Bank.Items[1].ItemId == "captain_emblem",
    "Migration must preserve Bank state."
)

character.CraftingKnowledge.LearnedRecipes["blacksmith_iron_guard_blueprint"] = true
local migrated_again = ProfileMigration.migrate(migrated)
local again_character = migrated_again.Characters.Slot1

check(
    migrated_again.SchemaVersion == 10,
    "Current profile must remain schema v9 after re-migration."
)
check(
    again_character.CraftingKnowledge
        .LearnedRecipes["blacksmith_iron_guard_blueprint"] == true,
    "Recipe knowledge migration must be idempotent and preserve learned state."
)

print(string.format(
    "[Recipe Knowledge Migration Tests] PASS: %d assertions.",
    assertions
))
