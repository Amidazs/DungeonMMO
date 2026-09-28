--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonEncounterSpawnCatalog"
)
if not module then
    error(
        "[Dungeon Encounter Spawn Catalog Tests] RED: "
            .. "DungeonEncounterSpawnCatalog is missing."
    )
end

local Catalog = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Spawn Catalog Tests] "
                .. message,
            2
        )
    end
end

local temple_room1 = assert(
    Catalog.get_pack("TestDungeon", "StandardRoom1")
)
check(
    Catalog.resolve_pack_count(temple_room1, {}) == 2,
    "Temple Room1 pack count must remain 2."
)
local temple_room1_entries =
    Catalog.resolve_pack_entries(temple_room1, {})
check(
    #temple_room1.Entries == 2
        and #temple_room1_entries == 2
        and temple_room1_entries[1].Entry.EnemyArchetypeId
            == "Marauder"
        and temple_room1_entries[1].Count == 1
        and temple_room1_entries[2].Entry.EnemyArchetypeId
            == "Wolf"
        and temple_room1_entries[2].Count == 1,
    "Temple Room1 must contain one Marauder and one Forest Wolf."
)

local temple_room2 = assert(
    Catalog.get_pack("TestDungeon", "StandardRoom2")
)
check(
    Catalog.resolve_pack_count(temple_room2, {}) == 3,
    "Temple Room2 pack count must remain 3."
)

local mine_room1 = assert(
    Catalog.get_pack("AbandonedMine", "StandardRoom1")
)
check(
    Catalog.resolve_pack_count(
        mine_room1,
        {EventActive = true}
    ) == 3,
    "Deep Echoes must add one Room1 Marauder."
)
local mine_room1_entries = Catalog.resolve_pack_entries(
    mine_room1,
    {EventActive = true}
)
check(
    #mine_room1_entries == 1
        and mine_room1_entries[1].Count == 3,
    "Deep Echoes bonus must target the Marauder entry."
)

local mine_room2 = assert(
    Catalog.get_pack("AbandonedMine", "StandardRoom2")
)
check(
    Catalog.resolve_pack_count(
        mine_room2,
        {RareStateId = "CrystalBloom"}
    ) == 4,
    "Crystal Bloom must add one Room2 Marauder."
)
local mine_room2_entries = Catalog.resolve_pack_entries(
    mine_room2,
    {RareStateId = "CrystalBloom"}
)
check(
    #mine_room2_entries == 1
        and mine_room2_entries[1].Count == 4,
    "Crystal Bloom bonus must target the Marauder entry."
)

local marauder = assert(
    Catalog.get_enemy_archetype("Marauder")
)
check(
    marauder.FactoryId == "Marauder",
    "Marauder archetype factory ID mismatch."
)
local wolf = assert(
    Catalog.get_enemy_archetype("Wolf")
)
check(
    wolf.FactoryId == "ForestWolf",
    "Wolf archetype must route through the ForestWolf factory."
)
check(
    Catalog.get_enemy_archetype("Unknown") == nil,
    "Unknown enemy archetypes must fail closed."
)

check(
    Catalog.get_pack("TestDungeon", "MissingPack") == nil,
    "Unknown pack IDs must fail closed."
)

local captain = assert(Catalog.get_boss("MarauderCaptain"))
check(
    captain.FactoryId == "MarauderCaptain",
    "Temple Depth1 boss factory ID mismatch."
)
check(
    captain.RewardKey == "MarauderCaptainReward",
    "Temple boss reward key mismatch."
)
check(
    captain.BestiaryCreatureId == "marauder_captain",
    "Temple Captain must own its explicit bestiary identity."
)

local foreman = assert(Catalog.get_boss("CorruptedForeman"))
check(
    foreman.FactoryId == "CorruptedForeman",
    "Mine Depth1 boss factory ID mismatch."
)
check(
    foreman.BestiaryCreatureId == "corrupted_foreman",
    "Mine Foreman must own a distinct bestiary identity."
)

local temple_depth2 = assert(
    Catalog.get_boss("TempleDepth2Boss")
)
check(
    temple_depth2.FactoryId == "TempleDepth2Boss",
    "Temple Depth2 boss factory ID mismatch."
)

local mine_depth2 = assert(
    Catalog.get_boss("AbandonedMineDepth2Boss")
)
check(
    mine_depth2.FactoryId == "AbandonedMineDepth2Boss",
    "Mine Depth2 boss factory ID mismatch."
)

local temple_depth3 = assert(
    Catalog.get_boss("TempleDepth3Boss")
)
check(
    temple_depth3.FactoryId == "TempleDepth3Boss",
    "Temple Depth3 boss factory ID mismatch."
)

local mine_depth3 = assert(
    Catalog.get_boss("AbandonedMineDepth3Boss")
)
check(
    mine_depth3.FactoryId == "AbandonedMineDepth3Boss",
    "Mine Depth3 boss factory ID mismatch."
)

local temple_depth4 = assert(
    Catalog.get_boss("TempleDepth4Boss")
)
check(
    temple_depth4.FactoryId == "TempleDepth4Boss",
    "Temple Depth4 boss factory ID mismatch."
)

local mine_depth4 = assert(
    Catalog.get_boss("AbandonedMineDepth4Boss")
)
check(
    mine_depth4.FactoryId == "AbandonedMineDepth4Boss",
    "Mine Depth4 boss factory ID mismatch."
)

check(
    Catalog.get_boss("UnknownBoss") == nil,
    "Unknown boss IDs must fail closed."
)

print(string.format(
    "[Dungeon Encounter Spawn Catalog Tests] PASS: %d assertions.",
    assertion_count
))
