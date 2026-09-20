--!strict
-- Physical gates for the replaceable TEST Temple placeholder side bridges.
-- Purely server-owned collision; the encounter plan still decides eligibility.
local Gates = {}

local ENTRANCES = table.freeze({
    EventArena = table.freeze({Bridge = "EventBridge", Prerequisite = "Room1"}),
    SecretArena = table.freeze({Bridge = "SecretBridge", Prerequisite = "Room2"}),
})

function Gates.get(root: Instance?, slot_id: string): BasePart?
    local spec = ENTRANCES[slot_id]
    if not spec or not root
        or root.Name ~= "DungeonMMOPlaceholderPhysicalContent"
        or root:GetAttribute("DungeonMMODungeonId") ~= "TestDungeon"
    then
        return nil
    end
    local bridge = root:FindFirstChild(spec.Bridge)
    local gate = bridge and bridge:FindFirstChild("EntranceGate")
    if gate and gate:IsA("BasePart")
        and gate:GetAttribute("DungeonMMOOptionalEntranceGate") == true
        and gate:GetAttribute("DungeonMMOOptionalArena") == slot_id
    then
        return gate
    end
    return nil
end

-- Finds the preceding required room in the frozen encounter plan.
-- Args: slot_id (string): EventArena or SecretArena side entrance.
--       bindings (any): Server-authoritative ordered encounter bindings.
-- Returns: string?: Required room slot, or nil for a malformed plan.
local function prerequisite_for(slot_id: string, bindings: any): string?
    if type(bindings.ordered) ~= "table" then
        -- Legacy Depth1 detached tests have no ordered binding array.
        return ENTRANCES[slot_id].Prerequisite
    end
    for index, binding in ipairs(bindings.ordered) do
        if binding.RoomSlotId == slot_id then
            local preceding = bindings.ordered[index - 1]
            if type(preceding) == "table"
                and type(preceding.RoomSlotId) == "string"
                and preceding.RoomSlotId:match("^Room%d+$")
            then
                return preceding.RoomSlotId
            end
            return nil
        end
    end
    return nil
end

-- Reads entrance eligibility from the same frozen plan as the encounter.
-- Args: slot_id (string): Optional arena to open or keep sealed.
--       bindings (any): Saved run's resolved encounter bindings.
--       flow (any): Current server-owned encounter lifecycle.
-- Returns: boolean, string: Whether the gate opens and a short objective.
function Gates.status(slot_id: string, bindings: any, flow: any): (boolean, string)
    local spec = ENTRANCES[slot_id]
    if not spec or not bindings or not flow then
        return false, "Entrance unavailable."
    end
    if not bindings.by_slot or not bindings.by_slot[slot_id] then
        return false, if slot_id == "EventArena"
            then "Event unavailable this run."
            else "Secret route unavailable this run."
    end
    local prerequisite = prerequisite_for(slot_id, bindings)
    if not prerequisite then
        return false, "Entrance unavailable."
    end
    if flow:state_for_slot(prerequisite) ~= "Cleared" then
        local number = prerequisite:match("^Room(%d+)$")
        return false, if number then "Clear Room " .. number .. " first."
            else "Clear preceding room first."
    end
    return true, ""
end

function Gates.sync(root: Instance?, bindings: any, flow: any): any
    if not root or root.Name ~= "DungeonMMOPlaceholderPhysicalContent"
        or root:GetAttribute("DungeonMMODungeonId") ~= "TestDungeon"
    then
        return {ok = true, gates_present = false}
    end
    for _, slot_id in ipairs({"EventArena", "SecretArena"}) do
        local gate = Gates.get(root, slot_id)
        if not gate then
            return {ok = false, reason = "OptionalEntranceGateMissing",
                slot_id = slot_id}
        end
        local open = Gates.status(slot_id, bindings, flow)
        gate.CanCollide = not open
        gate.CanTouch = not open
        gate.Transparency = if open then 1 else 0.2
        gate:SetAttribute("DungeonMMOOptionalGateOpen", open)
    end
    return {ok = true, gates_present = true}
end

return table.freeze(Gates)
