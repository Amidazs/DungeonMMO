--!strict
local LootTableConfig = {}

LootTableConfig.TEST_DUNGEON = table.freeze({
    table.freeze({Weight = 50, Kind = "Nothing"}),
    table.freeze({Weight = 30, Kind = "ItemPool", ItemIds = table.freeze({"marauder_sword", "marauder_shield", "marauder_armor"})}),
    table.freeze({Weight = 15, Kind = "Item", ItemId = "captain_emblem"}),
})

LootTableConfig.ABANDONED_MINE_NORMAL = table.freeze({
    table.freeze({Weight = 42, Kind = "Nothing"}),
    table.freeze({Weight = 38, Kind = "Item", ItemId = "iron_ore"}),
    table.freeze({Weight = 15, Kind = "Item", ItemId = "captain_emblem"}),
})

LootTableConfig.ABANDONED_MINE_RARE = table.freeze({
    table.freeze({Weight = 25, Kind = "Nothing"}),
    table.freeze({Weight = 45, Kind = "Item", ItemId = "iron_ore"}),
    table.freeze({Weight = 20, Kind = "Item", ItemId = "tempering_oil"}),
})

LootTableConfig.ABANDONED_MINE_EVENT = table.freeze({
    table.freeze({Weight = 15, Kind = "Nothing"}),
    table.freeze({Weight = 40, Kind = "Item", ItemId = "iron_ore"}),
    table.freeze({Weight = 30, Kind = "Item", ItemId = "tempering_oil"}),
})

return table.freeze(LootTableConfig)
