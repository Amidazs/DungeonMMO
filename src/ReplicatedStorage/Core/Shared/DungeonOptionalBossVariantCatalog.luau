--!strict
-- Stable server-owned optional encounter identities; existing implemented
-- boss factories act as TEMP variants until purpose-built art is accepted.
-- Never expose rollout or random selection to a client request.
local Catalog = {}

local DUNGEONS = table.freeze({
    TestDungeon = table.freeze({
        Event = table.freeze({
            table.freeze({Id = "TempleEclipse", BossId = "TempleEventBoss"}),
            table.freeze({Id = "TempleEchoHunt", BossId = "TempleDepth2Boss"}),
        }),
        Secret = table.freeze({
            table.freeze({Id = "TempleHiddenSanctum",
                BossId = "TempleSecretBoss"}),
            table.freeze({Id = "TempleForgottenVault",
                BossId = "TempleDepth3Boss"}),
        }),
    }),
    AbandonedMine = table.freeze({
        Event = table.freeze({
            table.freeze({Id = "MineEchoSurge",
                BossId = "AbandonedMineEventBoss"}),
            table.freeze({Id = "MineFaultSurge",
                BossId = "AbandonedMineDepth2Boss"}),
        }),
        Secret = table.freeze({
            table.freeze({Id = "MineSealedGallery",
                BossId = "AbandonedMineSecretBoss"}),
            table.freeze({Id = "MineDeepCache",
                BossId = "AbandonedMineDepth3Boss"}),
        }),
    }),
})

-- Returns only explicitly registered server-owned optional boss variants.
-- Args: dungeon_id (string): Existing Temple or Mine dungeon.
--       kind (string): Event or Secret.
--       index (number): Stable one-based variant index.
-- Returns: any?: Registered immutable identity and implemented boss ID.
function Catalog.get(dungeon_id: string, kind: string, index: number): any?
    local dungeon = DUNGEONS[dungeon_id]
    local entries = dungeon and dungeon[kind]
    return entries and entries[index] or nil
end

-- Resolves an exact saved ID to a known variant, never a fallback boss.
-- Args: dungeon_id (string): Existing dungeon ID.
--       kind (string): Event or Secret.
--       identity (string): Server-frozen event/unlock ID.
-- Returns: any?: Registered variant or nil for an invalid saved identity.
function Catalog.find(dungeon_id: string, kind: string, identity: string): any?
    local dungeon = DUNGEONS[dungeon_id]
    local entries = dungeon and dungeon[kind]
    if not entries or type(identity) ~= "string" then return nil end
    for _, entry in ipairs(entries) do
        if entry.Id == identity then return entry end
    end
    return nil
end

-- Counts catalogued boss variants without exposing a release switch.
function Catalog.count(dungeon_id: string, kind: string): number
    local dungeon = DUNGEONS[dungeon_id]
    local entries = dungeon and dungeon[kind]
    return if entries then #entries else 0
end

return table.freeze(Catalog)
