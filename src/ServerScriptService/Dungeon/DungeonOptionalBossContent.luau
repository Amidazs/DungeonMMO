--!strict
-- Dormant optional-boss descriptors: no physical layouts are registered.
local DungeonOptionalBossContent = {}

local ANCHORS = table.freeze({
    Depth1 = {"CombatRoom1", "Depth1Boss"},
    Depth2 = {"Depth2Combat1", "Depth2Boss"},
    Depth3 = {"Depth3Combat1", "Depth3Boss"},
    Depth4 = {"Depth4Combat1", "Depth4FinalBoss"},
})

local DUNGEONS = table.freeze({
    TestDungeon = {
        EventBossId = "TempleEventBoss",
        SecretBossId = "TempleSecretBoss",
        EventId = "TempleEclipse",
        UnlockId = "TempleHiddenSanctum",
    },
    AbandonedMine = {
        EventBossId = "AbandonedMineEventBoss",
        SecretBossId = "AbandonedMineSecretBoss",
        EventId = "MineEchoSurge",
        UnlockId = "MineSealedGallery",
    },
})

-- Builds one optional encounter with a distinct, persistent identity.
-- Args: id (string): Stable encounter ID.
--       kind (string): EventBoss or SecretBoss.
--       boss_id (string): Registered boss-content ID.
--       slot_id (string): Future physical room-slot ID.
-- Returns: any: Encounter definition for the generic runtime.
local function encounter(
    id: string,
    kind: string,
    boss_id: string,
    slot_id: string
): any
    return {
        Id = id,
        RoomSlotId = slot_id,
        RuntimeEncounterId = id,
        Kind = kind,
        ExecutorId = "Boss",
        BossId = boss_id,
    }
end

-- Builds dormant Event/Secret definitions for one dungeon difficulty.
-- Args: dungeon_id (string): Registered dungeon ID.
--       difficulty_id (string): Requested depth.
-- Returns: {any}?: Separate optional definitions, or nil if unknown.
function DungeonOptionalBossContent.for_difficulty(
    dungeon_id: string,
    difficulty_id: string
): {any}?
    local dungeon = DUNGEONS[dungeon_id]
    local anchors = ANCHORS[difficulty_id]
    if not dungeon or not anchors then
        return nil
    end

    return {
        {
            Encounter = encounter(
                dungeon.EventBossId .. "Encounter",
                "EventBoss",
                dungeon.EventBossId,
                "EventArena"
            ),
            InsertAfterId = anchors[1],
            CompletionRequired = true,
            AllowedDifficulties = {[difficulty_id] = true},
            Activation = {
                Type = "InstanceFlag",
                Key = "OptionalBossEventActive",
                Value = true,
            },
            Trigger = {
                Type = "TimedEvent",
                EventId = dungeon.EventId,
            },
        },
        {
            Encounter = encounter(
                dungeon.SecretBossId .. "Encounter",
                "SecretBoss",
                dungeon.SecretBossId,
                "SecretArena"
            ),
            InsertBeforeId = anchors[2],
            CompletionRequired = false,
            AllowedDifficulties = {[difficulty_id] = true},
            Activation = {
                Type = "InstanceFlag",
                Key = "OptionalBossSecretUnlocked",
                Value = true,
            },
            Trigger = {
                Type = "SecretUnlock",
                UnlockId = dungeon.UnlockId,
            },
        },
    }
end

return table.freeze(DungeonOptionalBossContent)
