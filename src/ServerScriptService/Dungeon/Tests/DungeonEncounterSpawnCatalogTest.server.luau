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

local foreman = assert(Catalog.get_boss("CorruptedForeman"))
check(
    foreman.FactoryId == "CorruptedForeman",
    "Mine Depth1 boss factory ID mismatch."
)

check(
    Catalog.get_boss("TempleDepth2Boss") == nil,
    "Unimplemented future bosses must fail closed."
)
check(
    Catalog.get_boss("AbandonedMineDepth4Boss") == nil,
    "Unimplemented final bosses must fail closed."
)

print(string.format(
    "[Dungeon Encounter Spawn Catalog Tests] PASS: %d assertions.",
    assertion_count
))
