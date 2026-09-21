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
check(ThreatService.record_support(player_c, player_b, 8) == 1,
    "support must not pull an otherwise unengaged nearby enemy")
check(ThreatService.get_threat(enemy, player_c.UserId) == 14,
    "support threat must equal half the effective support amount")
check(ThreatService.get_threat(second_enemy, player_c.UserId) == 0,
    "unengaged enemies cannot receive free support threat")

ThreatService.record_damage(second_enemy, player_b, 1)
check(ThreatService.record_support(player_c, player_b, 8) == 2,
    "effective support must reach independently engaged enemies")
check(ThreatService.get_threat(enemy, player_c.UserId) == 18,
    "support must accumulate on the first enemy")
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

ThreatService.record_damage(third_enemy, player_b, 3)
check(ThreatService.record_support(player_c, player_b, 6) == 2,
    "even engaged enemies must exclude out-of-range casters")
check(ThreatService.get_threat(third_enemy, player_c.UserId) == 0,
    "engagement alone cannot grant off-encounter support threat")

local rejected_zero_support = pcall(function()
    ThreatService.record_support(player_c, player_b, 0)
end)
check(not rejected_zero_support,
    "zero effective healing and unabsorbed wards earn no threat")

local rejected_invalid_support = pcall(function()
    ThreatService.record_support(player_c, player_b, math.huge)
end)
check(not rejected_invalid_support,
    "non-finite support values cannot inflate a threat table")

ThreatService.clear(second_enemy)
check(ThreatService.record_support(player_c, player_b, 10) == 1,
    "cleared enemies cannot receive support threat")
check(ThreatService.get_threat(second_enemy, player_c.UserId) == 0,
    "encounter cleanup must discard the support threat ledger")
ThreatService.select_target(second_enemy, candidates)
check(ThreatService.record_support(player_c, player_b, 6) == 1,
    "a new enemy encounter must remain unengaged until real threat")
ThreatService.record_damage(second_enemy, player_b, 1)
check(ThreatService.record_support(player_c, player_b, 6) == 2,
    "a restarted enemy must only earn support on its new ledger")
ThreatService.remove_player(player_c.UserId)
check(ThreatService.get_threat(enemy, player_c.UserId) == 0,
    "disconnect must discard former caster threat")
check(ThreatService.get_threat(second_enemy, player_c.UserId) == 0,
    "disconnect cleanup must cover every enemy")
check(ThreatService.record_support(player_c, player_b, 6) == 0,
    "departed players cannot keep earning support through stale candidacy")
selected, mode = ThreatService.select_target(enemy, candidates)
check(selected == player_a and mode == "Threat",
    "reacquired candidate has no stale threat after disconnect")
ThreatService.remove_player(player_c.UserId)
check(ThreatService.record_support(player_c, player_b, 6) == 0,
    "repeating disconnect cleanup must be harmless")
check(ThreatService.record_damage(second_enemy, player_b, 4) == 5,
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

-- Args: None.
-- Returns:
--   nil: proves independent tank, damage and support aggro for four players.
local function run_four_player_contract()
    local room_a = Instance.new("Model")
    room_a.Name = "FourPlayerRoomA_TEMP"
    room_a.Parent = workspace
    local room_b = Instance.new("Model")
    room_b.Name = "FourPlayerRoomB_TEMP"
    room_b.Parent = workspace
    local player_d = {UserId = 98104} :: any
    local party = {
        {player = player_a, distance = 2},
        {player = player_b, distance = 6},
        {player = player_c, distance = 5},
        {player = player_d, distance = 10},
    }

    ThreatService.select_target(room_a, party)
    ThreatService.select_target(room_b, party)
    ThreatService.record_damage(room_a, player_b, 30)
    ThreatService.record_damage(room_a, player_a, 10)
    ThreatService.record_damage(room_a, player_d, 20)
    local leader = ThreatService.select_target(room_a, party)
    check(leader == player_b, "highest damage must initially lead")
    check(ThreatService.record_support(player_c, player_a, 10) == 1,
        "support reaches engaged room but not idle neighboring room")
    check(ThreatService.record_support(player_c, player_b, 80) == 1,
        "support threat accumulates on the engaged room only")
    leader = ThreatService.select_target(room_a, party)
    check(leader == player_c,
        "effective healing must allow the support role to draw aggro")

    check(ThreatService.taunt(room_a, player_a, 5) == 50,
        "tank Taunt must move above accumulated healer threat")
    leader = ThreatService.select_target(room_a, party)
    check(leader == player_a, "tank must retake aggro through Taunt")

    ThreatService.record_damage(room_b, player_d, 50)
    check(ThreatService.record_support(player_c, player_a, 10) == 2,
        "support can contribute to both independently engaged enemies")
    leader = ThreatService.select_target(room_a, party)
    check(leader == player_a, "nearer tank wins an equal-threat tie")
    leader = ThreatService.select_target(room_b, party)
    check(leader == player_d,
        "support on another enemy must not override room B's leader")

    ThreatService.remove_player(player_c.UserId)
    check(ThreatService.get_threat(room_a, player_c.UserId) == 0,
        "disconnect removes healer threat from the first enemy")
    check(ThreatService.get_threat(room_b, player_c.UserId) == 0,
        "disconnect removes healer threat from the second enemy")
    check(ThreatService.record_support(player_c, player_a, 10) == 0,
        "disconnected healer cannot accrue stale support threat")
    ThreatService.clear(room_a)
    ThreatService.clear(room_b)
    leader = ThreatService.select_target(room_a, party)
    check(leader == player_a,
        "room wipe resets surviving party back to nearest targeting")
    room_a:Destroy()
    room_b:Destroy()
end

run_four_player_contract()

ThreatService.clear(third_enemy)
enemy:Destroy()
second_enemy:Destroy()
third_enemy:Destroy()

print(string.format(
    "[Threat Service] PASS: %d assertions.", assertions))
