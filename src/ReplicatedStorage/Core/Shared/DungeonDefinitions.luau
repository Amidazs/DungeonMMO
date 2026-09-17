--!strict
local LootTableConfig = require(script.Parent:WaitForChild("LootTableConfig"))
local DungeonDefinitions = {}

DungeonDefinitions.TEST_DUNGEON = table.freeze({
    Id = "TestDungeon",
    ContentVersion = 1,
    DisplayName = "Temple Dungeon",
    MinPlayers = 1,
    MaxPlayers = 4,
    SoloEntryEnabled = true,
    RoomSequence = table.freeze({"CombatRoom1", "CombatRoom2", "MarauderCaptain"}),
    RoomPacks = table.freeze({
        CombatRoom1 = table.freeze({MarauderCount = 2}),
        CombatRoom2 = table.freeze({MarauderCount = 3}),
    }),
    RoomCheckpointIds = table.freeze({"Room1Start", "Room2Start", "BossRoomStart"}),
    StandardMarauderMaxHealth = 40,
    CompletionGold = 50,
    StandardMarauderReward = table.freeze({XP = 10, GoldMin = 3, GoldMax = 6, BestiaryCreatureId = "marauder"}),
    MarauderCaptainReward = table.freeze({XP = 40, GoldMin = 15, GoldMax = 25, BestiaryCreatureId = "marauder_captain"}),
    Boss = table.freeze({DisplayName = "Marauder Captain"}),
    MarauderCaptain = table.freeze({MaxHealth = 120}),
    CompletionReward = table.freeze({Gold = 50, LootTable = LootTableConfig.TEST_DUNGEON}),
})

DungeonDefinitions.ABANDONED_MINE = table.freeze({
    Id = "AbandonedMine",
    ContentVersion = 1,
    DisplayName = "Abandoned Mine",
    MinPlayers = 1,
    MaxPlayers = 4,
    SoloEntryEnabled = true,
    RoomSequence = table.freeze({"CombatRoom1", "CombatRoom2", "MarauderCaptain"}),
    ModulePool = table.freeze({
        Room1 = table.freeze({"OreGallery", "RootedCavern"}),
        Room2 = table.freeze({"WinchChamber", "FloodedCut"}),
    }),
    RareStateChanceBasisPoints = 2000,
    RoomPacks = table.freeze({
        CombatRoom1 = table.freeze({MarauderCount = 2}),
        CombatRoom2 = table.freeze({MarauderCount = 3}),
    }),
    StateModifiers = table.freeze({
        CrystalBloom = table.freeze({Room2BonusMarauders = 1}),
        DeepEchoes = table.freeze({Room1BonusMarauders = 1}),
    }),
    StandardMarauderMaxHealth = 40,
    StandardMarauderReward = table.freeze({XP = 11, GoldMin = 3, GoldMax = 7, BestiaryCreatureId = "marauder"}),
    MarauderCaptainReward = table.freeze({XP = 45, GoldMin = 16, GoldMax = 27, BestiaryCreatureId = "marauder_captain"}),
    Boss = table.freeze({DisplayName = "Corrupted Foreman"}),
    MarauderCaptain = table.freeze({MaxHealth = 120}),
    CompletionReward = table.freeze({Gold = 55, LootTable = LootTableConfig.ABANDONED_MINE_NORMAL}),
    RareCompletionReward = table.freeze({Gold = 70, LootTable = LootTableConfig.ABANDONED_MINE_RARE}),
    EventCompletionReward = table.freeze({Gold = 85, LootTable = LootTableConfig.ABANDONED_MINE_EVENT}),
})

local BY_ID = table.freeze({
    [DungeonDefinitions.TEST_DUNGEON.Id] = DungeonDefinitions.TEST_DUNGEON,
    [DungeonDefinitions.ABANDONED_MINE.Id] = DungeonDefinitions.ABANDONED_MINE,
})

function DungeonDefinitions.get(dungeon_id: string): any?
    return BY_ID[dungeon_id]
end

function DungeonDefinitions.all(): any
    return BY_ID
end

return table.freeze(DungeonDefinitions)
