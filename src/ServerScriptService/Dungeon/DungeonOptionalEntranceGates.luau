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

function Gates.status(slot_id: string, bindings: any, flow: any): (boolean, string)
    local spec = ENTRANCES[slot_id]
    if not spec or not bindings or not flow then
        return false, "Entrance unavailable."
    end
    if flow:state_for_slot(spec.Prerequisite) ~= "Cleared" then
        return false, if slot_id == "EventArena"
            then "Clear Room 1 first." else "Clear Room 2 first."
    end
    if not bindings.by_slot or not bindings.by_slot[slot_id] then
        return false, if slot_id == "EventArena"
            then "Event unavailable this run."
            else "Secret route unavailable this run."
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
