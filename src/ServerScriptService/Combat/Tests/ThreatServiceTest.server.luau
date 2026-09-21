--!strict
local SSS = game:GetService("ServerScriptService")
local ThreatService = require(SSS.Combat.ThreatService)

local assertions = 0
local enemy = Instance.new("Model")
enemy.Name = "ThreatServiceEnemy_TEMP"
enemy.Parent = workspace

local second_enemy = Instance.new("Model")
second_enemy.Name = "ThreatServiceEnemy2_TEMP"
second_enemy.Parent = workspace

local player_a = {UserId = 98101} :: any
local player_b = {UserId = 98102} :: any
local player_c = {UserId = 98103} :: any

-- Args:
--   condition: boolean; expected threat-selection invariant.
--   message: string; failure context.
-- Returns:
--   nil: records a passing assertion or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Threat Service] " .. message)
end

local candidates = {
    {player = player_a, distance = 4},
    {player = player_b, distance = 9},
    {player = player_c, distance = 12},
}

local selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_a and mode == "Nearest",
    "nearest player must be chosen before any threat exists")

check(ThreatService.record_damage(enemy, player_b, 2) == 2,
    "real damage must add one threat per applied damage")
selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_b and mode == "Threat",
    "any positive eligible threat overrides nearest fallback")

check(ThreatService.record_damage(enemy, player_a, 7) == 7,
    "second attacker must maintain an independent threat total")
selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_a and mode == "Threat",
    "highest eligible threat must become the target")

local taunted = ThreatService.taunt(enemy, player_c, 3)
check(taunted == 10,
    "zero-damage taunt must move above current leader by bonus threat")
selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_c and mode == "Threat",
    "taunt-generated threat must select the taunter without damage")

check(ThreatService.get_threat(second_enemy, player_c.UserId) == 0,
    "threat must be isolated per enemy")

ThreatService.select_target(second_enemy, candidates)
local support_affected = ThreatService.record_support(
    player_c,
    player_b,
    8
)
check(support_affected == 2,
    "effective support must create threat on each shared engaged enemy")
check(ThreatService.get_threat(enemy, player_c.UserId) == 14,
    "support threat must equal half the effective support amount")
check(ThreatService.get_threat(second_enemy, player_c.UserId) == 4,
    "support threat must be tracked independently on every enemy")

local third_enemy = Instance.new("Model")
third_enemy.Name = "ThreatServiceEnemy3_TEMP"
third_enemy.Parent = workspace
ThreatService.select_target(third_enemy, {
    {player = player_a, distance = 3},
    {player = player_b, distance = 7},
})
check(ThreatService.record_support(player_c, player_b, 6) == 2,
    "support must ignore enemies where the caster is not eligible")
check(ThreatService.get_threat(third_enemy, player_c.UserId) == 0,
    "out-of-encounter support cannot seed threat on that enemy")
check(ThreatService.record_damage(second_enemy, player_b, 4) == 4,
    "another enemy must own a separate threat table")
check(ThreatService.get_threat(enemy, player_b.UserId) == 2,
    "second enemy damage cannot alter first enemy threat")

selected, mode = ThreatService.select_target(enemy, {
    {player = player_a, distance = 8},
    {player = player_b, distance = 2},
})
check(selected == player_a and mode == "Threat",
    "an absent high-threat player cannot remain a target candidate")

ThreatService.clear(enemy)
selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_a and mode == "Nearest",
    "clearing an encounter must restore nearest-player fallback")

local invalid_zero = pcall(function()
    ThreatService.add_threat(enemy, 0, 1)
end)
check(not invalid_zero, "UserId zero cannot enter a threat ledger")

local invalid_amount = pcall(function()
    ThreatService.add_threat(enemy, player_a.UserId, 0)
end)
check(not invalid_amount, "zero threat increments must be rejected")

ThreatService.clear(third_enemy)
enemy:Destroy()
second_enemy:Destroy()
third_enemy:Destroy()

print(string.format(
    "[Threat Service] PASS: %d assertions.", assertions))
