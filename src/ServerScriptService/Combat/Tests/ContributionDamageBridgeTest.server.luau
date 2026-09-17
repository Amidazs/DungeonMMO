--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local DungeonContributionBridge = require(
    Dungeon:WaitForChild("DungeonContributionBridge")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Contribution Damage Bridge Tests] " .. message, 2)
    end
end

local captured = {}

DungeonContributionBridge.set_recorder_for_test(function(
    user_id: number,
    event: any
): any
    table.insert(captured, {
        UserId = user_id,
        Event = event,
    })
    return {ok = true}
end)

local attacker = {
    UserId = 8101,
}

local target = Instance.new("Model")
target.Name = "ContributionDamageTarget"

local applied = DungeonContributionBridge.record_damage(
    {
        attacker = attacker,
        target = target,
        source_id = "Slash1",
        attack_id = "Slash1",
        sequence_id = 4,
    },
    25
)

check(applied.ok == true, "Applied authoritative damage must record.")
check(#captured == 1, "Applied damage must emit one contribution event.")
check(captured[1].UserId == 8101, "Damage must attribute to attacker.")
check(captured[1].Event.Type == "DamageDealt", "Damage type mismatch.")
check(captured[1].Event.Amount == 25, "Damage must use effective applied amount.")

local zero = DungeonContributionBridge.record_damage(
    {
        attacker = attacker,
        target = target,
        source_id = "Slash1",
        attack_id = "Slash1",
        sequence_id = 5,
    },
    0
)
check(zero.ok == false, "Zero applied damage must not record.")
check(#captured == 1, "Zero damage must emit no contribution.")

local no_owner = DungeonContributionBridge.record_damage(
    {
        attacker = nil,
        target = target,
        source_id = "Slash1",
        sequence_id = 6,
    },
    25
)
check(no_owner.ok == false, "Damage without authoritative player owner must reject.")
check(#captured == 1, "Ownerless damage must emit no contribution.")

DungeonContributionBridge.set_recorder_for_test(nil)
target:Destroy()

print(string.format(
    "[Contribution Damage Bridge Tests] PASS: %d assertions.",
    assertions
))
