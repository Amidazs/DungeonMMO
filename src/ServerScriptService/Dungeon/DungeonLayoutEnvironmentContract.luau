--!strict
local DungeonLayoutEnvironmentContract = {}

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

local function is_non_empty_string(value: any): boolean
    return type(value) == "string" and value ~= ""
end

local function append_unique(
    values: {string},
    seen: {[string]: boolean},
    value: string
)
    if seen[value] then
        return
    end
    seen[value] = true
    table.insert(values, value)
end

local function sorted_slot_ids(slots: any): {string}
    local ids = {}
    for slot_id in pairs(slots) do
        if type(slot_id) == "string" then
            table.insert(ids, slot_id)
        end
    end
    table.sort(ids)
    return ids
end

local function copy_base_exact_anchors(
    base_contract: any
): ({string}, {[string]: boolean}, {string})
    local required = {}
    local required_seen = {}
    local optional = {}

    for _, anchor_id in ipairs(base_contract.Required or {}) do
        append_unique(required, required_seen, anchor_id)
    end
    for _, anchor_id in ipairs(base_contract.Optional or {}) do
        if not required_seen[anchor_id] then
            table.insert(optional, anchor_id)
        end
    end

    return required, required_seen, optional
end

local function copy_base_groups(
    base_contract: any
): ({any}, {[string]: any})
    local groups = {}
    local by_name = {}

    for _, group in ipairs(base_contract.Groups or {}) do
        local copied = {
            Name = group.Name,
            Prefix = group.Prefix,
            MinCount = group.MinCount,
        }
        table.insert(groups, copied)
        if type(group.Name) == "string" then
            by_name[group.Name] = copied
        end
    end

    return groups, by_name
end

local function add_group(
    groups: {any},
    groups_by_name: {[string]: any},
    slot_id: string,
    slot_definition: any
): any
    local group_name = slot_definition.EnemySpawnGroup
    local prefix = slot_definition.EnemySpawnPrefix
    local min_count = slot_definition.EnemySpawnMinCount

    if not is_non_empty_string(group_name)
        or not is_non_empty_string(prefix)
        or type(min_count) ~= "number"
        or min_count < 1
    then
        return result(false, "InvalidEnemySpawnGroup", {
            RoomSlotId = slot_id,
        })
    end

    local existing = groups_by_name[group_name]
    if existing then
        if existing.Prefix ~= prefix
            or existing.MinCount ~= min_count
        then
            return result(false, "DuplicateEnvironmentGroup", {
                RoomSlotId = slot_id,
                GroupName = group_name,
            })
        end
        return result(true, nil)
    end

    local group = {
        Name = group_name,
        Prefix = prefix,
        MinCount = min_count,
    }
    groups_by_name[group_name] = group
    table.insert(groups, group)
    return result(true, nil)
end

local function add_slot_anchors(
    required: {string},
    required_seen: {[string]: boolean},
    slot_id: string,
    slot_definition: any
): any
    if type(slot_definition) ~= "table" then
        return result(false, "InvalidDungeonLayout", {
            RoomSlotId = slot_id,
        })
    end

    for _, field in ipairs({
        "TriggerAnchor",
        "CheckpointAnchor",
    }) do
        local anchor_id = slot_definition[field]
        if not is_non_empty_string(anchor_id) then
            return result(false, "InvalidDungeonLayout", {
                RoomSlotId = slot_id,
                AnchorField = field,
            })
        end
        append_unique(required, required_seen, anchor_id)
    end

    for _, field in ipairs({
        "ExitBarrierAnchor",
        "BossSpawnAnchor",
    }) do
        local anchor_id = slot_definition[field]
        if anchor_id ~= nil then
            if not is_non_empty_string(anchor_id) then
                return result(false, "InvalidDungeonLayout", {
                    RoomSlotId = slot_id,
                    AnchorField = field,
                })
            end
            append_unique(required, required_seen, anchor_id)
        end
    end

    return result(true, nil)
end

local function freeze_groups(groups: {any}): {any}
    local frozen = {}
    for _, group in ipairs(groups) do
        table.insert(frozen, table.freeze({
            Name = group.Name,
            Prefix = group.Prefix,
            MinCount = group.MinCount,
        }))
    end
    return table.freeze(frozen)
end

-- Builds one resolver contract from an environment base plus selected layout.
function DungeonLayoutEnvironmentContract.build(
    base_contract: any,
    layout: any
): any
    if type(base_contract) ~= "table"
        or not is_non_empty_string(base_contract.EnvironmentId)
    then
        return result(false, "InvalidEnvironmentBaseContract")
    end

    if type(layout) ~= "table"
        or not is_non_empty_string(layout.EntranceAnchor)
        or type(layout.Slots) ~= "table"
    then
        return result(false, "InvalidDungeonLayout")
    end

    local required, required_seen, optional =
        copy_base_exact_anchors(base_contract)
    local groups, groups_by_name =
        copy_base_groups(base_contract)

    append_unique(
        required,
        required_seen,
        layout.EntranceAnchor
    )

    for _, slot_id in ipairs(
        sorted_slot_ids(layout.Slots)
    ) do
        local slot_definition = layout.Slots[slot_id]
        local anchors_added = add_slot_anchors(
            required,
            required_seen,
            slot_id,
            slot_definition
        )
        if anchors_added.ok ~= true then
            return anchors_added
        end

        if slot_definition.SupportsCombat == true then
            local group_added = add_group(
                groups,
                groups_by_name,
                slot_id,
                slot_definition
            )
            if group_added.ok ~= true then
                return group_added
            end
        end
    end

    local filtered_optional = {}
    for _, anchor_id in ipairs(optional) do
        if not required_seen[anchor_id] then
            table.insert(filtered_optional, anchor_id)
        end
    end

    local contract = table.freeze({
        EnvironmentId = base_contract.EnvironmentId,
        Required = table.freeze(required),
        Optional = table.freeze(filtered_optional),
        Groups = freeze_groups(groups),
    })

    return result(true, nil, {
        Contract = contract,
    })
end

return table.freeze(DungeonLayoutEnvironmentContract)
