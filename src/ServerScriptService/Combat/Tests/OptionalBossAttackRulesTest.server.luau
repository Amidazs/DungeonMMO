--!strict
local Combat = game:GetService("ServerScriptService"):WaitForChild("Combat")
local Rules = require(Combat:WaitForChild("OptionalBossAttackRules"))
local MarauderAttackRules = require(Combat:WaitForChild("MarauderAttackRules"))

local assertions = 0
local function check(ok: boolean, reason: string)
    assertions += 1
    assert(ok, "[Optional Boss Attack Rules Tests] " .. reason)
end

local cases = {
    {"TempleEventBoss", "EclipseSweep", "EclipsePulse"},
    {"TempleSecretBoss", "VeilLunge", "VeilCounter"},
    {"AbandonedMineEventBoss", "EchoQuake", "EchoCrush"},
    {"AbandonedMineSecretBoss", "GalleryFeint", "GallerySeal"},
}
local seen = {}
local boss = Instance.new("Model")
for _, item in ipairs(cases) do
    boss:SetAttribute("BossId", item[1])
    local first = Rules.resolve(boss, 1, 1)
    local phase_two = Rules.resolve(boss, 1, 0.5)
    check(first ~= nil and first.AbilityId == item[2],
        item[1] .. " needs its own opening ability")
    check(phase_two ~= nil and phase_two.AbilityId == item[3],
        item[1] .. " switches abilities below half health")
    check(first.Phase == "PhaseOne" and phase_two.Phase == "PhaseTwo",
        item[1] .. " phase is server-health-owned")
    check(not seen[first.AbilityId] and not seen[phase_two.AbilityId],
        item[1] .. " must not share ability identities")
    seen[first.AbilityId] = true
    seen[phase_two.AbilityId] = true

    for _, attack in ipairs({first, phase_two, Rules.resolve(boss, 2, 1)}) do
        check(attack.AttackName == "Normal" or attack.AttackName == "Heavy",
            item[1] .. " must reuse the supported attack poses")
        check(attack.NextPatternIndex >= 1 and attack.NextPatternIndex <= 3,
            item[1] .. " needs a bounded repeated pattern")
        check(attack.Definition.ATTACK_REACH_STUDS > 0
            and attack.Definition.WIND_UP_SECONDS > 0
            and attack.Definition.HEALTH_DAMAGE > 0
            and attack.Definition.ATTACK_ARC_DEGREES > 0,
            item[1] .. " must retain legal server damage/telegraph data")
    end
end
boss:SetAttribute("BossId", "MarauderCaptain")
check(Rules.resolve(boss, 1, 1) == nil,
    "ordinary bosses keep the accepted combat pattern")
boss:SetAttribute("BossId", "CorruptedForeman")
check(Rules.resolve(boss, 1, 1) == nil,
    "ordinary Mine final boss is not silently overridden")
boss:SetAttribute("BossId", "Unknown")
check(Rules.resolve(boss, 1, 1) == nil, "unregistered boss has no abilities")
local baseline = MarauderAttackRules.get_attack_definition("Normal")
check(baseline.ATTACK_REACH_STUDS == 5.5,
    "optional attack resolution never mutates default Marauder damage")
boss:Destroy()
print(string.format(
    "[Optional Boss Attack Rules Tests] PASS: %d assertions.", assertions
))
