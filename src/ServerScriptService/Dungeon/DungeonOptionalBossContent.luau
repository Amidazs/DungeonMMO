--!strict
-- Dormant optional-boss descriptors: no physical layouts are registered.
local DungeonOptionalBossContent = {}
local Catalog = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("DungeonOptionalBossVariantCatalog"))
local Templates = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("DungeonOptionalEncounterTemplateCatalog"))

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
    local event = selected(dungeon_id, "Event", instance_state)
    local secret = selected(dungeon_id, "Secret", instance_state)
    local selected_template = if type(instance_state) == "table"
        and instance_state.OptionalBossEventTemplateId ~= nil
        then instance_state.OptionalBossEventTemplateId
        else "EventAfterRoom1"
    local event_template = Templates.get(
        dungeon_id, difficulty_id, "Event", selected_template)
    local secret_template = Templates.get(
        dungeon_id, difficulty_id, "Secret", "SecretBeforeFinal")
    if not event or not secret or not event_template
        or not secret_template
    then
        return nil
    end

    return {
        {
            Encounter = encounter(
                event.BossId .. event_template.EncounterSuffix,
                "EventBoss",
                event.BossId,
                event_template.RoomSlotId
            ),
            InsertAfterId = event_template.InsertAfterId,
            RequiresPlacementContract =
                event_template.RequiresPlacementContract,
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
                secret.BossId .. secret_template.EncounterSuffix,
                "SecretBoss",
                secret.BossId,
                secret_template.RoomSlotId
            ),
            InsertBeforeId = secret_template.InsertBeforeId,
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
