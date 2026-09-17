--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Combat = ServerScriptService:WaitForChild("Combat")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local DungeonContributionBridge = require(
    Dungeon:WaitForChild("DungeonContributionBridge")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Contribution Support Bridge Tests] " .. message, 2)
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

local caster = {
    UserId = 8001,
}
local target = {
    UserId = 8002,
}

local heal = DungeonContributionBridge.record_heal(
    caster,
    target,
    18,
    "MageHeal"
)
check(heal.ok == true, "Effective heal bridge must record.")
check(#captured == 1, "Heal bridge must emit one contribution.")
check(captured[1].Event.Type == "EffectiveHealing", "Heal type mismatch.")
check(captured[1].Event.Amount == 18, "Heal amount must be effective amount.")

local no_heal = DungeonContributionBridge.record_heal(
    caster,
    target,
    0,
    "MageHeal"
)
check(no_heal.ok == false, "Zero-effect heal must not record.")
check(#captured == 1, "Zero-effect heal must emit no contribution.")

local ward = DungeonContributionBridge.record_ward(
    caster,
    target,
    9,
    "ArcaneWard"
)
check(ward.ok == true, "Effective ward bridge must record.")
check(#captured == 2, "Ward bridge must emit one additional contribution.")
check(captured[2].Event.Type == "EffectiveWard", "Ward type mismatch.")
check(captured[2].Event.Amount == 9, "Ward amount must be absorbed amount.")

local mitigation = DungeonContributionBridge.record_mitigation(
    8001,
    6,
    "ValidatedMitigation"
)
check(mitigation.ok == true, "Trusted mitigation bridge helper must record.")
check(#captured == 3, "Mitigation must emit one additional contribution.")
check(captured[3].Event.Type == "DamageMitigated", "Mitigation type mismatch.")

DungeonContributionBridge.set_recorder_for_test(nil)

print(string.format(
    "[Contribution Support Bridge Tests] PASS: %d assertions.",
    assertions
))
