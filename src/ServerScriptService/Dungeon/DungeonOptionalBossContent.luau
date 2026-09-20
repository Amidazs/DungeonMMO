--!strict
-- Dormant optional-boss descriptors: no physical layouts are registered.
local DungeonOptionalBossContent = {}
local Catalog = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("DungeonOptionalBossVariantCatalog"))

local ANCHORS = table.freeze({
    Depth1 = {"CombatRoom1", "Depth1Boss"},
    Depth2 = {"Depth2Combat1", "Depth2Boss"},
    Depth3 = {"Depth3Combat1", "Depth3Boss"},
    Depth4 = {"Depth4Combat1", "Depth4FinalBoss"},
})

-- An unknown ID in an authoritative saved snapshot fails closed;
-- absent fields retain index-1 legacy descriptors for old callers.
local function selected(
    dungeon_id: string, kind: string, state: any?
): any?
    local identity = nil
    if type(state) == "table" then
        if kind == "Event" then
            identity = state.OptionalBossEventId
        elseif state.OptionalBossSecretUnlocked == true then
            for id, unlocked in pairs(
                state.OptionalBossSecretUnlocks or {}
            ) do
                if unlocked == true then
                    if identity ~= nil then return nil end
                    identity = id
                end
            end
            if identity == nil then return nil end
        end
    end
    if identity == nil then
        return Catalog.get(dungeon_id, kind, 1)
    end
    return Catalog.find(dungeon_id, kind, identity)
end

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
    difficulty_id: string,
    instance_state: any?
): {any}?
    local anchors = ANCHORS[difficulty_id]
    local event = selected(dungeon_id, "Event", instance_state)
    local secret = selected(dungeon_id, "Secret", instance_state)
    if not event or not secret or not anchors then
        return nil
    end

    return {
        {
            Encounter = encounter(
                event.BossId .. "Encounter",
                "EventBoss",
                event.BossId,
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
                EventId = event.Id,
            },
        },
        {
            Encounter = encounter(
                secret.BossId .. "Encounter",
                "SecretBoss",
                secret.BossId,
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
                UnlockId = secret.Id,
            },
        },
    }
end

return table.freeze(DungeonOptionalBossContent)
