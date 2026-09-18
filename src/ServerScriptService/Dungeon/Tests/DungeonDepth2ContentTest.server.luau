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
        error("[Dungeon Depth2 Content Tests] " .. message, 2)
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
        Depth2Room1 = 3,
        Depth2Room2 = 4,
        Depth2Room3 = 5,
    },
    AbandonedMine = {
        Depth2Room1 = 3,
        Depth2Room2 = 4,
        Depth2Room3 = 5,
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
    "Depth2Room1"
)
if mine_room1 then
    check(
        SpawnCatalog.resolve_pack_count(
            mine_room1,
            {EventActive = true}
        ) == 4,
        "Deep Echoes must add one Depth2 Room1 enemy."
    )
end

local mine_room2 = Catalog.get_pack(
    "AbandonedMine",
    "Depth2Room2"
)
if mine_room2 then
    check(
        SpawnCatalog.resolve_pack_count(
            mine_room2,
            {RareStateId = "CrystalBloom"}
        ) == 5,
        "Crystal Bloom must add one Depth2 Room2 enemy."
    )
end

local bosses = {
    TempleDepth2Boss = {
        FactoryId = "TempleDepth2Boss",
        DisplayName = "Temple Warden",
    },
    AbandonedMineDepth2Boss = {
        FactoryId = "AbandonedMineDepth2Boss",
        DisplayName = "Deep Overseer",
    },
}

for boss_id, expected in pairs(bosses) do
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

for _, dungeon_id in ipairs({
    "TestDungeon",
    "AbandonedMine",
}) do
    local analysis = Readiness.analyze(
        dungeon_id,
        "Depth2"
    )
    check(
        analysis.ok == true,
        dungeon_id .. " Depth2 analysis must succeed."
    )
    check(
        analysis.Ready == false
            and analysis.ReleaseEnabled == false,
        dungeon_id .. " Depth2 must remain release-disabled."
    )
    check(
        has_issue(
            analysis,
            "DungeonLayoutNotRegistered"
        ),
        dungeon_id .. " Depth2 must still require its layout."
    )
    check(
        not has_issue(
            analysis,
            "EncounterContentNotRegistered"
        ),
        dungeon_id .. " Depth2 content must be registered."
    )
    check(
        #(analysis.Issues or {}) == 1,
        dungeon_id .. " Depth2 must have only"
            .. " the missing-layout issue."
    )
end

print(string.format(
    "[Dungeon Depth2 Content Tests] PASS: %d assertions.",
    assertion_count
))
