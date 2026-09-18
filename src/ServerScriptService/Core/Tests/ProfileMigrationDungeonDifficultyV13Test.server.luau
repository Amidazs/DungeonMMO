--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))

local assertion_count = 0

-- Verifies one migration expectation.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty v13 Migration Tests] " .. message,
            2
        )
    end
end

check(
    ProfileSchema.VERSION == 13,
    "RED: progressive dungeon difficulty requires profile schema v13."
)
local source = ProfileSchema.create_default(9401)
source.SchemaVersion = 12
source.Characters.Slot1.DungeonDifficultyProgress = nil
source.Characters.Slot1.DungeonProgress = {
    TestDungeon = "BossRoomStart",
    LegacyShape = {
        Clears = 7,
        Marker = "PreserveMe",
    },
}

local migrated = ProfileMigration.migrate(source)
local character = migrated.Characters.Slot1

check(
    migrated.SchemaVersion == 13,
    "v12 profile must migrate to schema v13."
)
check(
    character.DungeonProgress.TestDungeon == "BossRoomStart",
    "Legacy DungeonProgress checkpoint data must remain untouched."
)
check(
    character.DungeonProgress.LegacyShape.Clears == 7
        and character.DungeonProgress.LegacyShape.Marker == "PreserveMe",
    "Legacy DungeonProgress table shape must remain untouched."
)
check(
    character.DungeonDifficultyProgress.Version == 1,
    "New difficulty progress version must be 1."
)
check(
    next(character.DungeonDifficultyProgress.Dungeons) == nil,
    "Legacy profiles must not receive invented difficulty clears."
)

local dirty = ProfileSchema.create_default(9402)
dirty.SchemaVersion = 12
dirty.Characters.Slot1.DungeonDifficultyProgress = {
    Version = 99,
    Dungeons = {
        TestDungeon = {
            Completed = {
                Depth1 = true,
                Depth2 = true,
                UnknownDepth = true,
            },
            HighestClearedOrder = 99,
        },
        UnknownDungeon = {
            Completed = {Depth1 = true},
            HighestClearedOrder = 4,
        },
    },
}
local sanitized = ProfileMigration.migrate(dirty)
local difficulty_progress =
    sanitized.Characters.Slot1.DungeonDifficultyProgress
local temple = difficulty_progress.Dungeons.TestDungeon

check(difficulty_progress.Version == 1, "Difficulty progress version must sanitize.")
check(temple ~= nil, "Known dungeon progress must survive.")
check(temple.Completed.Depth1 == true, "Valid Depth1 clear must survive.")
check(temple.Completed.Depth2 == true, "Valid Depth2 clear must survive.")
check(
    temple.Completed.UnknownDepth == nil,
    "Unknown difficulty clears must be removed."
)
check(
    temple.HighestClearedOrder == 2,
    "Highest cleared order must be recomputed from valid clears."
)
check(
    difficulty_progress.Dungeons.UnknownDungeon == nil,
    "Unknown dungeon progress must be removed."
)

local twice = ProfileMigration.migrate(sanitized)
check(
    ProfileSchema.deep_clone(twice).Characters.Slot1
        .DungeonDifficultyProgress.Dungeons.TestDungeon
        .HighestClearedOrder == 2,
    "Repeat migration must remain stable."
)

print(string.format(
    "[Dungeon Difficulty v13 Migration Tests] PASS: %d assertions.",
    assertion_count
))
