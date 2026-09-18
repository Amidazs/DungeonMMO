--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local Catalog = require(
    Shared:WaitForChild("DungeonRuntimeContentCatalog")
)
local Definitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local DungeonDefinitions = require(
    Shared:WaitForChild("DungeonDefinitions")
)
local Readiness = require(
    Shared:WaitForChild("DungeonRuntimeContentReadiness")
)
local SpawnCatalog = require(
    Dungeon:WaitForChild("DungeonEncounterSpawnCatalog")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Depth4 Content Tests] " .. message, 2)
    end
end

local function has_issue(analysis: any, code: string): boolean
    for _, issue in ipairs(analysis.Issues or {}) do
        if issue.Code == code then
            return true
        end
    end
    return false
end

local pack_expectations = {
    TestDungeon = {
        Depth4Room1 = 5,
        Depth4Room3 = 7,
    },
    AbandonedMine = {
        Depth4Room1 = 5,
        Depth4Room3 = 7,
    },
}

for dungeon_id, packs in pairs(pack_expectations) do
    for pack_id, expected_count in pairs(packs) do
        local pack = Catalog.get_pack(dungeon_id, pack_id)
        check(
            pack ~= nil,
            dungeon_id .. " " .. pack_id
                .. " must be registered."
        )
        if pack then
            check(
                SpawnCatalog.resolve_pack_count(pack, {})
                    == expected_count,
                dungeon_id .. " " .. pack_id
                    .. " base count mismatch."
            )
        end
    end
end

local mine_room1 = Catalog.get_pack(
    "AbandonedMine",
    "Depth4Room1"
)
if mine_room1 then
    check(
        SpawnCatalog.resolve_pack_count(
            mine_room1,
            {EventActive = true}
        ) == 6,
        "Deep Echoes must add one Depth4 Room1 enemy."
    )
end

local mine_room3 = Catalog.get_pack(
    "AbandonedMine",
    "Depth4Room3"
)
if mine_room3 then
    check(
        SpawnCatalog.resolve_pack_count(
            mine_room3,
            {RareStateId = "CrystalBloom"}
        ) == 8,
        "Crystal Bloom must add one Depth4 Room3 enemy."
    )
end

local final_bosses = {
    TempleDepth4Boss = {
        FactoryId = "TempleDepth4Boss",
        DisplayName = "Sanctum Ascendant",
    },
    AbandonedMineDepth4Boss = {
        FactoryId = "AbandonedMineDepth4Boss",
        DisplayName = "Buried Tyrant",
    },
}

for boss_id, expected in pairs(final_bosses) do
    local spec = Catalog.get_boss(boss_id)
    check(spec ~= nil, boss_id .. " must be registered.")
    if spec then
        check(
            spec.FactoryId == expected.FactoryId,
            boss_id .. " factory ID mismatch."
        )
        check(
            spec.DisplayName == expected.DisplayName,
            boss_id .. " display name mismatch."
        )
        check(
            Catalog.is_boss_factory_implemented(
                expected.FactoryId
            ),
            boss_id .. " factory must be declared implemented."
        )
    end
end

local dungeons = {
    DungeonDefinitions.TEST_DUNGEON,
    DungeonDefinitions.ABANDONED_MINE,
}

for _, dungeon in ipairs(dungeons) do
    local depth4 = assert(
        Definitions.get(dungeon.Id, "Depth4")
    )
    local encounters = depth4.EncounterSequence

    check(
        #encounters == 6,
        dungeon.Id .. " Depth4 must keep six encounters."
    )
    check(
        encounters[2].Kind == "MiniBoss"
            and encounters[2].BossId
                == dungeon.DifficultyBossIds[1],
        dungeon.Id .. " Room2 must reuse the Depth1 boss."
    )
    check(
        encounters[4].Kind == "MiniBoss"
            and encounters[4].BossId
                == dungeon.DifficultyBossIds[2],
        dungeon.Id .. " Room4 must reuse the Depth2 boss."
    )
    check(
        encounters[5].Kind == "MiniBoss"
            and encounters[5].BossId
                == dungeon.DifficultyBossIds[3],
        dungeon.Id .. " Room5 must reuse the Depth3 boss."
    )
    check(
        encounters[6].Kind == "FinalBoss"
            and encounters[6].BossId
                == dungeon.DifficultyBossIds[4],
        dungeon.Id .. " Room6 must use the new final boss."
    )

    local analysis = Readiness.analyze(
        dungeon.Id,
        "Depth4"
    )
    check(
        analysis.ok == true,
        dungeon.Id .. " Depth4 analysis must succeed."
    )
    check(
        analysis.Ready == false
            and analysis.ReleaseEnabled == false,
        dungeon.Id .. " Depth4 must remain release-disabled."
    )
    check(
        has_issue(
            analysis,
            "DungeonLayoutNotRegistered"
        ),
        dungeon.Id .. " Depth4 must still require its layout."
    )
    check(
        not has_issue(
            analysis,
            "EncounterContentNotRegistered"
        ),
        dungeon.Id .. " Depth4 content must be registered."
    )
    check(
        #(analysis.Issues or {}) == 1,
        dungeon.Id .. " Depth4 must have only"
            .. " the missing-layout issue."
    )
end

print(string.format(
    "[Dungeon Depth4 Content Tests] PASS: %d assertions.",
    assertion_count
))
