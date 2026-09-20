--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dungeon = script.Parent
local ContentCatalog = require(
    ReplicatedStorage:WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("DungeonRuntimeContentCatalog")
)
local Triggers = require(
    Dungeon:WaitForChild("DungeonOptionalBossTriggers")
)

local DungeonOptionalBossPolicy = {}
local OPTIONAL_KINDS = table.freeze({
    EventBoss = "TimedEvent",
    SecretBoss = "SecretUnlock",
})

-- Checks structural identity before considering the trigger result.
-- Args: encounter (any): Candidate optional boss encounter.
--       seen (table): Encounter IDs already examined.
-- Returns: boolean: Whether the candidate is structurally valid.
local function valid_identity(
    encounter: any,
    seen: {[string]: boolean}
): boolean
    return type(encounter) == "table"
        and type(encounter.Id) == "string"
        and encounter.Id ~= ""
        and not seen[encounter.Id]
        and OPTIONAL_KINDS[encounter.Kind] ~= nil
        and encounter.ExecutorId == "Boss"
        and type(encounter.BossId) == "string"
        and encounter.BossId ~= ""
        and type(encounter.RoomSlotId) == "string"
        and encounter.RoomSlotId ~= ""
end

-- Checks explicit insertion placement and eligible difficulty.
-- Args: entry (any): Optional encounter configuration.
--       difficulty_id (string): Difficulty selected for this run.
-- Returns: boolean: True when insertion and difficulty are allowed.
local function valid_insertion(entry: any, difficulty_id: string): boolean
    local before = type(entry.InsertBeforeId) == "string"
        and entry.InsertBeforeId ~= ""
    local after = type(entry.InsertAfterId) == "string"
        and entry.InsertAfterId ~= ""
    return before ~= after
        and type(entry.AllowedDifficulties) == "table"
        and entry.AllowedDifficulties[difficulty_id] == true
end

-- Requires an implemented boss and an explicit boss-capable room slot.
-- Args: encounter (any): Active optional boss encounter.
--       allowed_slots (table): Slots in the selected physical layout.
-- Returns: boolean: True only for implemented, physically supported content.
local function content_ready(
    encounter: any,
    entry: any,
    allowed_slots: {[string]: any}
): boolean
    local slot = allowed_slots[encounter.RoomSlotId]
    local boss = ContentCatalog.get_boss(encounter.BossId)
    return type(boss) == "table"
        and ContentCatalog.is_boss_factory_implemented(boss.FactoryId)
        and type(slot) == "table"
        and slot.SupportsBoss == true
        and type(slot.BossSpawnAnchor) == "string"
        and slot.BossSpawnAnchor ~= ""
        and (entry.RequiresPlacementContract ~= true
            or (type(entry.InsertAfterId) == "string"
                and slot.OptionalInsertAfterId == entry.InsertAfterId
                and slot.OptionalPlacementVerified == true))
end

-- Filters server-configured optional bosses by run trigger and layout.
-- Args: definition (any): Server-owned optional encounter definitions.
--       difficulty_id (string): Session-selected difficulty.
--       allowed_slots (table?): Registered layout slot definitions.
--       enabled (boolean): Server and session opt-in together.
--       instance_state (any?): Authoritative saved run conditions.
-- Returns: any: Selected encounters, or a fail-closed rejection.
function DungeonOptionalBossPolicy.evaluate(
    definition: any,
    difficulty_id: string,
    allowed_slots: {[string]: any}?,
    enabled: boolean,
    instance_state: any?
): any
    if enabled ~= true then
        return {ok = true, encounters = {}}
    end
    if type(definition) ~= "table"
        or type(definition.OptionalEncounters) ~= "table"
        or type(difficulty_id) ~= "string"
        or type(allowed_slots) ~= "table"
    then
        return {ok = false, reason = "OptionalBossPolicyMissing"}
    end

    local accepted = {}
    local seen: {[string]: boolean} = {}
    local accepted_kinds: {[string]: boolean} = {}
    local accepted_slots: {[string]: boolean} = {}
    for _, entry in ipairs(definition.OptionalEncounters) do
        local encounter = type(entry) == "table"
            and entry.Encounter
        if not valid_identity(encounter, seen) then
            return {ok = false, reason = "OptionalBossIdentityInvalid"}
        end
        seen[encounter.Id] = true
        if type(entry.Trigger) ~= "table"
            or entry.Trigger.Type ~= OPTIONAL_KINDS[encounter.Kind]
        then
            return {ok = false, reason = "OptionalBossTriggerInvalid"}
        end
        local triggered = Triggers.evaluate(entry, instance_state)
        if triggered.ok ~= true then
            return {ok = false, reason = triggered.reason}
        end

        if triggered.active then
            -- The existing runtime has one Event entrance and one Secret
            -- route per run. Two templates may never claim either kind
            -- or the same physical room in a single materialized plan.
            if accepted_kinds[encounter.Kind] then
                return {ok = false,
                    reason = "OptionalBossFrequencyExceeded"}
            end
            if accepted_slots[encounter.RoomSlotId] then
                return {ok = false,
                    reason = "OptionalBossRoomSlotConflict"}
            end
            if not valid_insertion(entry, difficulty_id) then
                return {ok = false, reason = "OptionalBossEligibilityMissing"}
            end
            if not content_ready(encounter, entry, allowed_slots) then
                return {
                    ok = false,
                    reason = "OptionalBossContentUnavailable",
                }
            end
            accepted_kinds[encounter.Kind] = true
            accepted_slots[encounter.RoomSlotId] = true
            table.insert(accepted, entry)
        end
    end

    return {ok = true, encounters = accepted}
end

return table.freeze(DungeonOptionalBossPolicy)
