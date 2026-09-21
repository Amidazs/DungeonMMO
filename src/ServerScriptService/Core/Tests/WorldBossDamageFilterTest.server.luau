--!strict
-- A world-boss damage event must have the actual guarded Model,
-- not just its visible name or an arbitrary hostile target.
local SSS = game:GetService("ServerScriptService")
local Bridge = require(
    SSS.Dungeon:WaitForChild("DungeonContributionBridge")
)

local count = 0
local assertions = 0

-- Args:
--   condition: boolean; expected server-only damage filter behavior.
--   reason: string; failure description.
-- Returns:
--   nil: increments a check or fails the focused contract.
local function check(condition: boolean, reason: string)
    assertions += 1
    assert(condition, "[World Boss Damage Filter] " .. reason)
end

local guardian = Instance.new("Model")
guardian.Name = "AncientGuardianPlaceholder"
local impostor = Instance.new("Model")
impostor.Name = guardian.Name
local other = Instance.new("Model")
other.Name = "UnrelatedEnemy"

Bridge.set_recorder_for_test(function(_user_id, _event)
    count += 1
    return {ok = true}
end)
Bridge.bind_damage_target_validator(function(context)
    return context.target == guardian
end)

local attacker = {UserId = 8675309}
for _, target in ipairs({impostor, other}) do
    local denied = Bridge.record_damage({
        attacker = attacker, target = target, source_id = "Slash",
    }, 25)
    check(not denied.ok and denied.reason == "IneligibleDamageTarget",
        "a same-name impostor or unrelated target must be rejected")
end
check(count == 0, "rejected damage cannot create contribution events")
check(Bridge.record_damage({
    attacker = attacker, target = guardian, source_id = "Slash",
}, 25).ok, "the exact server-owned guardian may record damage")
check(count == 1, "a valid hit must record exactly once")

Bridge.bind_damage_target_validator(nil)
check(Bridge.record_damage({
    attacker = attacker, target = other, source_id = "Slash",
}, 5).ok, "normal Dungeon contributor rules remain unchanged")
check(count == 2, "clearing the filter restores normal Dungeon behavior")

Bridge.set_recorder_for_test(nil)
guardian:Destroy()
impostor:Destroy()
other:Destroy()

print(string.format(
    "[World Boss Damage Filter] PASS: %d assertions.", assertions))
