--!strict
local DungeonDefinitions = require(
    script.Parent:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    script.Parent:WaitForChild("DungeonDifficultyDefinitions")
)
local DungeonRuntimeContentCatalog = require(
    script.Parent:WaitForChild("DungeonRuntimeContentCatalog")
)

local DungeonRuntimeContentReadiness = {}

local COMBAT_EXECUTOR_ID = "CombatPack"
local BOSS_EXECUTOR_ID = "Boss"

-- Returns whether a value is a usable stable identifier.
local function is_non_empty_string(value: any): boolean
    return type(value) == "string" and value ~= ""
end

-- Appends one detached machine-readable readiness issue.
local function add_issue(
    issues: {any},
    code: string,
    details: any?
)
    local issue = details or {}
    issue.Code = code
    table.insert(issues, issue)
end

-- Validates the static physical binding for one encounter.
local function analyze_slot(
    layout: any?,
    encounter: any,
    issues: {any}
)
    if not layout or type(layout.Slots) ~= "table" then
        return
    end

    if not is_non_empty_string(encounter.RoomSlotId) then
        add_issue(issues, "EncounterBindingMissing", {
            EncounterId = encounter.Id,
        })
        return
    end

    local slot_definition = layout.Slots[encounter.RoomSlotId]
    if type(slot_definition) ~= "table" then
        add_issue(issues, "EncounterBindingMissing", {
            EncounterId = encounter.Id,
            RoomSlotId = encounter.RoomSlotId,
        })
        return
    end

    for _, field in ipairs({
        "TriggerAnchor",
        "CheckpointAnchor",
    }) do
        if not is_non_empty_string(slot_definition[field]) then
            add_issue(issues, "PhysicalAnchorBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
                AnchorField = field,
            })
        end
    end

    if slot_definition.ExitBarrierRoomId ~= nil
        and (
            not is_non_empty_string(
                slot_definition.ExitBarrierRoomId
            )
            or not is_non_empty_string(
                slot_definition.ExitBarrierAnchor
            )
        )
    then
        add_issue(issues, "ExitBarrierBindingMissing", {
            EncounterId = encounter.Id,
            RoomSlotId = encounter.RoomSlotId,
        })
    end

    if encounter.ExecutorId == COMBAT_EXECUTOR_ID then
        if slot_definition.SupportsCombat ~= true then
            add_issue(issues, "EncounterBindingCapabilityMismatch", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end
        if not is_non_empty_string(
            slot_definition.EnvironmentRoomId
        ) then
            add_issue(issues, "EncounterRoomBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end
        if not is_non_empty_string(
            slot_definition.EnemySpawnGroup
        ) then
            add_issue(issues, "EnemySpawnBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end
        return
    end

    if encounter.ExecutorId == BOSS_EXECUTOR_ID then
        if slot_definition.SupportsBoss ~= true then
            add_issue(issues, "EncounterBindingCapabilityMismatch", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end
        if not is_non_empty_string(
            slot_definition.BossSpawnAnchor
        ) then
            add_issue(issues, "BossSpawnBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end
    end
end

-- Validates one combat-pack entry and records its stable EntryId.
local function analyze_pack_entry(
    encounter: any,
    pack_id: string,
    entry: any,
    entry_ids: any,
    issues: {any}
)
    local entry_id = entry.EntryId
    if not is_non_empty_string(entry_id)
        or entry_ids[entry_id]
        or not is_non_empty_string(entry.EnemyArchetypeId)
        or not is_non_empty_string(entry.EnemyNamePrefix)
        or type(entry.SpawnIndexBase) ~= "number"
        or type(entry.BaseCount) ~= "number"
        or entry.BaseCount < 0
    then
        add_issue(issues, "InvalidCombatPack", {
            EncounterId = encounter.Id,
            ContentId = pack_id,
        })
        return
    end

    entry_ids[entry_id] = true
    local archetype =
        DungeonRuntimeContentCatalog.get_enemy_archetype(
            entry.EnemyArchetypeId
        )
    if not archetype then
        add_issue(issues, "EnemyArchetypeNotRegistered", {
            EncounterId = encounter.Id,
            ContentId = entry.EnemyArchetypeId,
        })
        return
    end

    local factory_id = archetype.FactoryId
    if not is_non_empty_string(factory_id)
        or not DungeonRuntimeContentCatalog
            .is_enemy_factory_implemented(factory_id)
    then
        add_issue(issues, "EnemyFactoryNotRegistered", {
            EncounterId = encounter.Id,
            ContentId = factory_id,
        })
    end
end

-- Validates that all pack bonus rules target registered entries.
local function analyze_pack_bonus_rules(
    encounter: any,
    pack: any,
    entry_ids: any,
    issues: {any}
)
    for _, rule in ipairs(pack.BonusRules or {}) do
        if not is_non_empty_string(rule.EntryId)
            or not entry_ids[rule.EntryId]
        then
            add_issue(issues, "PackBonusTargetNotRegistered", {
                EncounterId = encounter.Id,
                ContentId = rule.EntryId,
            })
        end
    end
end

-- Validates one registered heterogeneous combat pack.
local function analyze_combat_pack(
    dungeon_id: string,
    encounter: any,
    issues: {any}
)
    local pack_id = encounter.PackId
    local pack = if is_non_empty_string(pack_id)
        then DungeonRuntimeContentCatalog.get_pack(
            dungeon_id,
            pack_id
        )
        else nil
    if not pack then
        add_issue(issues, "EncounterContentNotRegistered", {
            EncounterId = encounter.Id,
            ContentType = "CombatPack",
            ContentId = pack_id,
        })
        return
    end

    if type(pack.Entries) ~= "table"
        or #pack.Entries == 0
    then
        add_issue(issues, "InvalidCombatPack", {
            EncounterId = encounter.Id,
            ContentId = pack_id,
        })
        return
    end

    local entry_ids = {}
    for _, entry in ipairs(pack.Entries) do
        analyze_pack_entry(
            encounter,
            pack_id,
            entry,
            entry_ids,
            issues
        )
    end

    analyze_pack_bonus_rules(
        encounter,
        pack,
        entry_ids,
        issues
    )
end

-- Validates static executor and content registrations for one encounter.
local function analyze_content(
    dungeon_id: string,
    encounter: any,
    issues: {any}
)
    local executor_id = encounter.ExecutorId
    if not is_non_empty_string(executor_id)
        or not DungeonRuntimeContentCatalog
            .is_executor_implemented(executor_id)
    then
        add_issue(issues, "EncounterExecutorNotRegistered", {
            EncounterId = encounter.Id,
            ExecutorId = executor_id,
        })
        return
    end

    if executor_id == COMBAT_EXECUTOR_ID then
        analyze_combat_pack(
            dungeon_id,
            encounter,
            issues
        )
        return
    end

    if executor_id ~= BOSS_EXECUTOR_ID then
        return
    end

    local boss_id = encounter.BossId
    local boss_spec = if is_non_empty_string(boss_id)
        then DungeonRuntimeContentCatalog.get_boss(boss_id)
        else nil
    if not boss_spec then
        add_issue(issues, "EncounterContentNotRegistered", {
            EncounterId = encounter.Id,
            ContentType = "Boss",
            ContentId = boss_id,
        })
        return
    end

    local factory_id = boss_spec.FactoryId
    if not is_non_empty_string(factory_id)
        or not DungeonRuntimeContentCatalog
            .is_boss_factory_implemented(factory_id)
    then
        add_issue(issues, "EncounterContentNotRegistered", {
            EncounterId = encounter.Id,
            ContentType = "BossFactory",
            ContentId = factory_id,
        })
    end
end

-- Validates the registered layout shape before inspecting encounter slots.
local function analyze_layout(
    layout: any?,
    dungeon_id: string,
    layout_id: string,
    issues: {any}
)

    if not layout then
        add_issue(issues, "DungeonLayoutNotRegistered", {
            DungeonId = dungeon_id,
            LayoutId = layout_id,
        })
        return
    end

    if not is_non_empty_string(layout.EntranceAnchor)
        or type(layout.Slots) ~= "table"
    then
        add_issue(issues, "InvalidDungeonLayout", {
            DungeonId = dungeon_id,
            LayoutId = layout_id,
        })
    end
end

-- Adds duplicate-room diagnostics for an ordered encounter sequence.
local function analyze_duplicate_slots(
    encounters: {any},
    issues: {any}
)
    local seen = {}
    for _, encounter in ipairs(encounters) do
        local room_slot_id = encounter.RoomSlotId
        if is_non_empty_string(room_slot_id) then
            if seen[room_slot_id] then
                add_issue(issues, "DuplicatePhysicalRoomSlot", {
                    EncounterId = encounter.Id,
                    RoomSlotId = room_slot_id,
                })
            else
                seen[room_slot_id] = true
            end
        end
    end
end

-- Analyzes whether one difficulty has complete registered runtime content.
function DungeonRuntimeContentReadiness.analyze(
    dungeon_id: string,
    difficulty_id: string
): any
    if DungeonDefinitions.get(dungeon_id) == nil then
        return {
            ok = false,
            reason = "UnknownDungeon",
        }
    end

    local difficulty = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not difficulty then
        return {
            ok = false,
            reason = "UnknownDifficulty",
        }
    end

    local issues = {}
    local layout_id = difficulty.LayoutId
    local layout = if is_non_empty_string(layout_id)
        then DungeonRuntimeContentCatalog.get_layout(
            dungeon_id,
            layout_id
        )
        else nil

    analyze_layout(layout, dungeon_id, layout_id, issues)
    analyze_duplicate_slots(
        difficulty.EncounterSequence,
        issues
    )

    for _, encounter in ipairs(
        difficulty.EncounterSequence
    ) do
        analyze_slot(layout, encounter, issues)
        analyze_content(dungeon_id, encounter, issues)
    end

    local content_complete = #issues == 0
    local release_enabled =
        difficulty.RuntimeReleaseEnabled == true

    return {
        ok = true,
        reason = nil,
        Ready = content_complete and release_enabled,
        ContentComplete = content_complete,
        ReleaseEnabled = release_enabled,
        Issues = issues,
        Difficulty = difficulty,
    }
end

-- Returns whether one known difficulty may create new runtime sessions.
function DungeonRuntimeContentReadiness.is_ready(
    dungeon_id: string,
    difficulty_id: string
): boolean
    local analysis = DungeonRuntimeContentReadiness.analyze(
        dungeon_id,
        difficulty_id
    )
    return analysis.ok == true and analysis.Ready == true
end

return table.freeze(DungeonRuntimeContentReadiness)
