--!strict
local Dungeon = game:GetService("ServerScriptService"):WaitForChild("Dungeon")
local Gates = require(Dungeon:WaitForChild("DungeonOptionalEntranceGates"))
local count = 0
local function check(value: boolean, reason: string)
    count += 1
    assert(value, "[Optional Entrance Gates Tests] " .. reason)
end

-- Disposable detached fixture: no authored world or live place is modified.
local root = Instance.new("Folder")
root.Name = "DungeonMMOPlaceholderPhysicalContent"
root:SetAttribute("DungeonMMODungeonId", "TestDungeon")
local function make_gate(bridge_name: string, slot: string)
    local bridge = Instance.new("Model")
    bridge.Name = bridge_name
    bridge.Parent = root
    local gate = Instance.new("Part")
    gate.Name = "EntranceGate"
    gate:SetAttribute("DungeonMMOOptionalEntranceGate", true)
    gate:SetAttribute("DungeonMMOOptionalArena", slot)
    gate.Parent = bridge
    return gate
end
local event_gate = make_gate("EventBridge", "EventArena")
local secret_gate = make_gate("SecretBridge", "SecretArena")
local states = {Room1 = "Pending", Room2 = "Pending"}
local flow = {
    state_for_slot = function(_, id) return states[id] end,
}
local bindings = {by_slot = {EventArena = {}, SecretArena = {}}}

check(Gates.get(root, "EventArena") == event_gate
    and Gates.get(root, "SecretArena") == secret_gate,
    "only recognized tagged placeholder entrance markers can be controlled")
check(Gates.sync(root, bindings, flow).ok, "initial gate sync")
check(event_gate.CanCollide and secret_gate.CanCollide
    and event_gate:GetAttribute("DungeonMMOOptionalGateOpen") == false
    and secret_gate:GetAttribute("DungeonMMOOptionalGateOpen") == false,
    "both side entrances block access before predecessor clears")
check(Gates.status("EventArena", bindings, flow) == false,
    "Event entrance cannot be used before Room1")

states.Room1 = "Cleared"
check(Gates.sync(root, bindings, flow).ok, "room-one clear gate sync")
check(not event_gate.CanCollide and not event_gate.CanTouch
    and event_gate.Transparency == 1 and secret_gate.CanCollide,
    "Room1 unlocks eligible Event only; Secret still blocked")
states.Room2 = "Cleared"
check(Gates.sync(root, bindings, flow).ok, "room-two clear gate sync")
check(not secret_gate.CanCollide and not secret_gate.CanTouch,
    "eligible Secret becomes accessible after Room2 and for backtracking")
-- A skipped optional boss must remain physically enterable on return.
check(Gates.status("SecretArena", bindings, flow) == true,
    "skipping secret on next-room approach does not re-lock bridge")

bindings.by_slot.SecretArena = nil
check(Gates.sync(root, bindings, flow).ok and secret_gate.CanCollide,
    "secret never selected for this run remains physically sealed")
local allowed, reason = Gates.status("SecretArena", bindings, flow)
check(not allowed and reason == "Secret route unavailable this run.",
    "short no-unlock message does not reveal the hidden route")
bindings.by_slot.EventArena = nil
check(Gates.sync(root, bindings, flow).ok and event_gate.CanCollide,
    "inactive timed event stays physically gated")
check(Gates.sync(nil, bindings, flow).ok,
    "non-placeholder authored world is never modified")
root:Destroy()
print(string.format("[Optional Entrance Gates Tests] PASS: %d assertions.", count))
