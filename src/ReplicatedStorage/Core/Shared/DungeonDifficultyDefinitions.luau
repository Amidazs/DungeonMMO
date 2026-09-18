--!strict
local DungeonDefinitions = require(
    script.Parent:WaitForChild("DungeonDefinitions")
)

local DungeonDifficultyDefinitions = {}

local ORDER = table.freeze({
    "Depth1",
    "Depth2",
    "Depth3",
    "Depth4",
})

local SCALING = table.freeze({
    Depth1 = table.freeze({
        EnemyHealthMultiplier = 1.00,
        EnemyDamageMultiplier = 1.00,
        MonsterRewardMultiplier = 1.00,
        CompletionGoldMultiplier = 1.00,
    }),
    Depth2 = table.freeze({
        EnemyHealthMultiplier = 1.25,
        EnemyDamageMultiplier = 1.10,
        MonsterRewardMultiplier = 1.15,
        CompletionGoldMultiplier = 1.20,
    }),
    Depth3 = table.freeze({
        EnemyHealthMultiplier = 1.55,
        EnemyDamageMultiplier = 1.20,
        MonsterRewardMultiplier = 1.30,
        CompletionGoldMultiplier = 1.45,
    }),
    Depth4 = table.freeze({
        EnemyHealthMultiplier = 1.90,
        EnemyDamageMultiplier = 1.35,
        MonsterRewardMultiplier = 1.50,
        CompletionGoldMultiplier = 1.75,
    }),
})

-- Creates one frozen ordinary combat encounter descriptor.
local function combat(
    encounter_id: string,
    room_slot_id: string,
    pack_id: string
): any
    return table.freeze({
        Id = encounter_id,
        RoomSlotId = room_slot_id,
        Kind = "Combat",
        PackId = pack_id,
    })
end
-- Creates one frozen boss-family encounter descriptor.
local function boss_encounter(
    encounter_id: string,
    room_slot_id: string,
    kind: string,
    boss_id: string
): any
    return table.freeze({
        Id = encounter_id,
        RoomSlotId = room_slot_id,
        Kind = kind,
        BossId = boss_id,
    })
end

-- Copies one scaling row into a frozen difficulty definition.
local function difficulty(
    id: string,
    order: number,
    runtime_ready: boolean,
    previous_id: string?,
    encounters: {any}
): any
    local scaling = SCALING[id]
    assert(scaling ~= nil, "Missing scaling for " .. id)

    return table.freeze({
        Id = id,
        Order = order,
        Version = 1,
        DisplayName = "Depth " .. tostring(order),
        RuntimeReady = runtime_ready,
        RequiredPreviousDifficultyId = previous_id,
        EnemyHealthMultiplier = scaling.EnemyHealthMultiplier,
        EnemyDamageMultiplier = scaling.EnemyDamageMultiplier,
        MonsterRewardMultiplier = scaling.MonsterRewardMultiplier,
        CompletionGoldMultiplier = scaling.CompletionGoldMultiplier,
        EncounterSequence = table.freeze(encounters),
    })
end

-- Builds the four-depth ladder for one authored dungeon.
local function build_ladder(boss_ids: {string}): any
    assert(#boss_ids == 4, "Difficulty ladder requires four boss IDs.")

    local depth1 = difficulty(
        "Depth1",
        1,
        true,
        nil,
        {
            combat("CombatRoom1", "Room1", "StandardRoom1"),
            combat("CombatRoom2", "Room2", "StandardRoom2"),
            boss_encounter(
                "Depth1Boss",
                "Room3",
                "Boss",
                boss_ids[1]
            ),
        }
    )

    local depth2 = difficulty(
        "Depth2",
        2,
        false,
        "Depth1",
        {
            combat("Depth2Combat1", "Room1", "Depth2Room1"),
            combat("Depth2Combat2", "Room2", "Depth2Room2"),
            combat("Depth2Combat3", "Room3", "Depth2Room3"),
            boss_encounter(
                "Depth2Boss",
                "Room4",
                "Boss",
                boss_ids[2]
            ),
        }
    )

    local depth3 = difficulty(
        "Depth3",
        3,
        false,
        "Depth2",
        {
            combat("Depth3Combat1", "Room1", "Depth3Room1"),
            combat("Depth3Combat2", "Room2", "Depth3Room2"),
            combat("Depth3Combat3", "Room3", "Depth3Room3"),
            combat("Depth3Combat4", "Room4", "Depth3Room4"),
            boss_encounter(
                "Depth3Boss",
                "Room5",
                "Boss",
                boss_ids[3]
            ),
        }
    )

    local depth4 = difficulty(
        "Depth4",
        4,
        false,
        "Depth3",
        {
            combat("Depth4Combat1", "Room1", "Depth4Room1"),
            boss_encounter(
                "Depth4MiniBoss1",
                "Room2",
                "MiniBoss",
                boss_ids[1]
            ),
            combat("Depth4Combat2", "Room3", "Depth4Room3"),
            boss_encounter(
                "Depth4MiniBoss2",
                "Room4",
                "MiniBoss",
                boss_ids[2]
            ),
            boss_encounter(
                "Depth4MiniBoss3",
                "Room5",
                "MiniBoss",
                boss_ids[3]
            ),
            boss_encounter(
                "Depth4FinalBoss",
                "Room6",
                "FinalBoss",
                boss_ids[4]
            ),
        }
    )

    return table.freeze({
        Depth1 = depth1,
        Depth2 = depth2,
        Depth3 = depth3,
        Depth4 = depth4,
    })
end

local BY_DUNGEON = table.freeze({
    [DungeonDefinitions.TEST_DUNGEON.Id] = build_ladder(
        DungeonDefinitions.TEST_DUNGEON.DifficultyBossIds
    ),
    [DungeonDefinitions.ABANDONED_MINE.Id] = build_ladder(
        DungeonDefinitions.ABANDONED_MINE.DifficultyBossIds
    ),
})

-- Returns one difficulty definition or nil for unknown IDs.
function DungeonDifficultyDefinitions.get(
    dungeon_id: string,
    difficulty_id: string
): any?
    local ladder = BY_DUNGEON[dungeon_id]
    if not ladder then
        return nil
    end
    return ladder[difficulty_id]
end

-- Returns ordered difficulty definitions for one known dungeon.
function DungeonDifficultyDefinitions.ordered(
    dungeon_id: string
): {any}
    local ladder = BY_DUNGEON[dungeon_id]
    if not ladder then
        return {}
    end

    local result = {}
    for _, difficulty_id in ipairs(ORDER) do
        table.insert(result, ladder[difficulty_id])
    end
    return result
end

-- Returns the stable default difficulty ID for one known dungeon.
function DungeonDifficultyDefinitions.default_id(
    dungeon_id: string
): string?
    local definition = DungeonDefinitions.get(dungeon_id)
    if not definition then
        return nil
    end
    return definition.DefaultDifficultyId
end

-- Resolves an optional difficulty ID to its authoritative definition.
function DungeonDifficultyDefinitions.resolve(
    dungeon_id: string,
    difficulty_id: string?
): any?
    local selected_id = difficulty_id
        or DungeonDifficultyDefinitions.default_id(dungeon_id)
    if not selected_id then
        return nil
    end
    return DungeonDifficultyDefinitions.get(dungeon_id, selected_id)
end

-- Returns the next difficulty ID or nil after the final depth.
function DungeonDifficultyDefinitions.next_id(
    dungeon_id: string,
    difficulty_id: string
): string?
    local current = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not current or current.Order >= #ORDER then
        return nil
    end
    return ORDER[current.Order + 1]
end

-- Returns the previous prerequisite difficulty ID when one exists.
function DungeonDifficultyDefinitions.previous_id(
    dungeon_id: string,
    difficulty_id: string
): string?
    local current = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not current then
        return nil
    end
    return current.RequiredPreviousDifficultyId
end

-- Returns the stable ordered difficulty IDs.
function DungeonDifficultyDefinitions.order(): {string}
    local result = {}
    for _, difficulty_id in ipairs(ORDER) do
        table.insert(result, difficulty_id)
    end
    return result
end

return table.freeze(DungeonDifficultyDefinitions)
