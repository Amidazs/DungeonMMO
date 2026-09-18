--!strict
local Dungeon = script.Parent

local DungeonEncounterRuntimeState = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeState")
)
local DungeonRoomLayoutDefinitions = require(
    Dungeon:WaitForChild("DungeonRoomLayoutDefinitions")
)

local DungeonEncounterBindings = {}

local BOSS_EXECUTOR_ID = "Boss"
local COMBAT_EXECUTOR_ID = "CombatPack"

local function clone_table(source: any): any
    local result = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = clone_table(value)
        else
            result[key] = value
        end
    end
    return result
end

local function result(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end

local function anchor_exists(
    environment: any,
    anchor_id: string
): boolean
    if type(environment) ~= "table"
        or type(environment.get) ~= "function"
    then
        return false
    end

    local ok, anchor = pcall(function()
        return environment:get(anchor_id)
    end)
    return ok and typeof(anchor) == "Instance"
        and anchor:IsA("BasePart")
end

local function validate_slot_capability(
    encounter: any,
    slot_definition: any
): (boolean, string?)
    if encounter.ExecutorId == COMBAT_EXECUTOR_ID then
        if slot_definition.SupportsCombat ~= true then
            return false, "CombatSlotNotSupported"
        end
        return true, nil
    end

    if encounter.ExecutorId == BOSS_EXECUTOR_ID then
        if slot_definition.SupportsBoss ~= true then
            return false, "BossSlotNotSupported"
        end
        if type(slot_definition.BossSpawnAnchor) ~= "string"
            or slot_definition.BossSpawnAnchor == ""
        then
            return false, "BossSpawnBindingMissing"
        end
        return true, nil
    end

    return true, nil
end

-- Resolves an encounter plan against one explicit physical layout.
function DungeonEncounterBindings.resolve_layout(
    layout: any,
    encounters: {any},
    environment: any
): any
    if type(layout) ~= "table"
        or type(layout.Id) ~= "string"
        or type(layout.Slots) ~= "table"
    then
        return result(false, "InvalidDungeonLayout")
    end

    if type(encounters) ~= "table" or #encounters == 0 then
        return result(false, "InvalidEncounterPlan")
    end

    if type(layout.EntranceAnchor) ~= "string"
        or layout.EntranceAnchor == ""
        or not anchor_exists(
            environment,
            layout.EntranceAnchor
        )
    then
        return result(false, "EntranceAnchorMissing", {
            AnchorId = layout.EntranceAnchor,
        })
    end

    local by_slot = {}
    local by_encounter = {}
    local by_runtime = {}
    local ordered = {}

    for sequence, encounter in ipairs(encounters) do
        if type(encounter) ~= "table"
            or type(encounter.Id) ~= "string"
            or encounter.Id == ""
            or type(encounter.RoomSlotId) ~= "string"
            or encounter.RoomSlotId == ""
        then
            return result(false, "InvalidEncounter")
        end

        local room_slot_id = encounter.RoomSlotId
        local slot_definition = layout.Slots[room_slot_id]
        if type(slot_definition) ~= "table" then
            return result(false, "EncounterBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = room_slot_id,
            })
        end

        if by_slot[room_slot_id] then
            return result(false, "DuplicatePhysicalRoomSlot", {
                EncounterId = encounter.Id,
                RoomSlotId = room_slot_id,
            })
        end

        local capable, capability_error =
            validate_slot_capability(
                encounter,
                slot_definition
            )
        if not capable then
            return result(false, capability_error, {
                EncounterId = encounter.Id,
                RoomSlotId = room_slot_id,
            })
        end

        for _, anchor_field in ipairs({
            "TriggerAnchor",
            "CheckpointAnchor",
        }) do
            local anchor_id = slot_definition[anchor_field]
            if type(anchor_id) ~= "string"
                or anchor_id == ""
                or not anchor_exists(environment, anchor_id)
            then
                return result(false, "PhysicalAnchorMissing", {
                    EncounterId = encounter.Id,
                    RoomSlotId = room_slot_id,
                    AnchorField = anchor_field,
                    AnchorId = anchor_id,
                })
            end
        end

        if encounter.ExecutorId == BOSS_EXECUTOR_ID
            and not anchor_exists(
                environment,
                slot_definition.BossSpawnAnchor
            )
        then
            return result(false, "BossSpawnAnchorMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = room_slot_id,
                AnchorId = slot_definition.BossSpawnAnchor,
            })
        end

        local runtime_encounter_id =
            encounter.RuntimeEncounterId or encounter.Id
        if type(runtime_encounter_id) ~= "string"
            or runtime_encounter_id == ""
        then
            return result(false, "RuntimeEncounterIdMissing", {
                EncounterId = encounter.Id,
            })
        end

        if by_runtime[runtime_encounter_id] then
            return result(false, "DuplicateRuntimeEncounterId", {
                EncounterId = encounter.Id,
                RuntimeEncounterId = runtime_encounter_id,
            })
        end

        local binding = {
            PlanEncounterId = encounter.Id,
            RoomSlotId = room_slot_id,
            RuntimeEncounterId = runtime_encounter_id,
            EnvironmentRoomId =
                slot_definition.EnvironmentRoomId,
            EnemySpawnGroup =
                slot_definition.EnemySpawnGroup,
            TriggerAnchor = slot_definition.TriggerAnchor,
            CheckpointAnchor =
                slot_definition.CheckpointAnchor,
            ExitBarrierRoomId =
                slot_definition.ExitBarrierRoomId,
            ExitBarrierAnchor =
                slot_definition.ExitBarrierAnchor,
            BossSpawnAnchor =
                slot_definition.BossSpawnAnchor,
            CheckpointId =
                DungeonEncounterRuntimeState.checkpoint_id(
                    encounter.Id
                ),
            CheckpointSequence = sequence,
            Kind = encounter.Kind,
            ExecutorId = encounter.ExecutorId,
            PackId = encounter.PackId,
            BossId = encounter.BossId,
            Encounter = clone_table(encounter),
        }

        by_slot[room_slot_id] = binding
        by_encounter[encounter.Id] = binding
        by_runtime[runtime_encounter_id] = binding
        table.insert(ordered, binding)
    end

    return result(true, nil, {
        layout_id = layout.Id,
        entrance_anchor = layout.EntranceAnchor,
        by_slot = by_slot,
        by_encounter = by_encounter,
        by_runtime = by_runtime,
        ordered = ordered,
    })
end

-- Resolves one registered physical layout for a dungeon/difficulty.
function DungeonEncounterBindings.resolve(
    dungeon_id: string,
    layout_id: string,
    encounters: {any},
    environment: any
): any
    local layout = DungeonRoomLayoutDefinitions.get(
        dungeon_id,
        layout_id
    )
    if not layout then
        return result(false, "DungeonLayoutNotRegistered", {
            DungeonId = dungeon_id,
            LayoutId = layout_id,
        })
    end

    return DungeonEncounterBindings.resolve_layout(
        layout,
        encounters,
        environment
    )
end

return table.freeze(DungeonEncounterBindings)
