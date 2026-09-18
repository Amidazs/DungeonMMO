--!strict
local DungeonEnvironmentLayoutActivation = {}

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

local function resolve_anchor(
    resolved_environment: any,
    anchor_id: string
): BasePart?
    if type(resolved_environment) ~= "table"
        or type(resolved_environment.by_id) ~= "table"
    then
        return nil
    end

    local anchor = resolved_environment.by_id[anchor_id]
    if typeof(anchor) ~= "Instance"
        or not anchor:IsA("BasePart")
    then
        return nil
    end
    return anchor
end

local function activate_trigger(
    resolved_environment: any,
    anchor_id: string
): boolean
    local trigger = resolve_anchor(
        resolved_environment,
        anchor_id
    )
    if not trigger then
        return false
    end

    trigger.CanTouch = true
    trigger.CanCollide = false
    trigger.Transparency = 1
    return true
end

local function activate_barrier(
    resolved_environment: any,
    anchor_id: string
): boolean
    local barrier = resolve_anchor(
        resolved_environment,
        anchor_id
    )
    if not barrier then
        return false
    end

    barrier.CanTouch = false
    barrier.CanCollide = true
    barrier.Transparency = 1
    return true
end

-- Activates physical triggers and barriers declared by one layout.
function DungeonEnvironmentLayoutActivation.apply(
    layout: any,
    resolved_environment: any
): any
    if type(layout) ~= "table"
        or type(layout.Slots) ~= "table"
    then
        return result(false, "InvalidDungeonLayout")
    end

    local trigger_count = 0
    local barrier_count = 0

    for room_slot_id, slot_definition in pairs(layout.Slots) do
        if type(slot_definition) ~= "table"
            or type(slot_definition.TriggerAnchor) ~= "string"
            or slot_definition.TriggerAnchor == ""
        then
            return result(false, "InvalidDungeonLayout", {
                RoomSlotId = room_slot_id,
            })
        end

        if not activate_trigger(
            resolved_environment,
            slot_definition.TriggerAnchor
        ) then
            return result(false, "LayoutAnchorMissing", {
                RoomSlotId = room_slot_id,
                AnchorId = slot_definition.TriggerAnchor,
            })
        end
        trigger_count += 1

        local barrier_anchor =
            slot_definition.ExitBarrierAnchor
        if barrier_anchor ~= nil then
            if type(barrier_anchor) ~= "string"
                or barrier_anchor == ""
            then
                return result(false, "InvalidDungeonLayout", {
                    RoomSlotId = room_slot_id,
                })
            end

            if not activate_barrier(
                resolved_environment,
                barrier_anchor
            ) then
                return result(false, "LayoutAnchorMissing", {
                    RoomSlotId = room_slot_id,
                    AnchorId = barrier_anchor,
                })
            end
            barrier_count += 1
        end
    end

    return result(true, nil, {
        TriggerCount = trigger_count,
        BarrierCount = barrier_count,
    })
end

return table.freeze(DungeonEnvironmentLayoutActivation)
