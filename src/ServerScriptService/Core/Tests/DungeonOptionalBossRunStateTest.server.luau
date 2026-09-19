--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Core")
    :WaitForChild("Services")
local Issuer = require(
    Services:WaitForChild("DungeonOptionalBossRunState")
)

local assertion_count = 0

-- Checks one authoritative optional-boss issuance invariant.
-- Args: condition (boolean): Expected result.
--       message (string): Failure explanation.
-- Returns: nil: Raises when the contract fails.
local function check(condition: boolean, message: string)
    assertion_count += 1
    assert(condition, "[Optional Boss Run State Tests] " .. message)
end

local options = {
    optional_boss_event_start = 100,
    optional_boss_event_end = 200,
    optional_boss_secret_chance_basis_points = 10000,
}

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local disabled = Issuer.issue(dungeon_id, 150, 42, options, false)
    check(disabled.OptionalBossEnabled == false,
        dungeon_id .. " rollout must default to disabled")
    check(disabled.OptionalBossEventActive == false,
        dungeon_id .. " must not issue a locked event")
    check(disabled.OptionalBossSecretUnlocked == false,
        dungeon_id .. " must not issue a locked secret")
    check(next(disabled.OptionalBossEventWindows) == nil
        and next(disabled.OptionalBossSecretUnlocks) == nil,
        dungeon_id .. " must not mint locked event or secret data")

    local available = Issuer.issue(
        dungeon_id, 150, 42, options, true
    )
    check(available.OptionalBossEnabled == true,
        dungeon_id .. " enabled run needs a selected encounter")
    check(available.OptionalBossEventActive == true,
        dungeon_id .. " valid entry must receive event")
    check(available.OptionalBossSecretUnlocked == true,
        dungeon_id .. " 100% hidden-route chance must select route")
    check(available.OptionalBossEventId ~= nil
        and available.OptionalBossEventWindows[
            available.OptionalBossEventId
        ].EndUnix == 200,
        dungeon_id .. " must snapshot its own event window")
    check(next(available.OptionalBossSecretUnlocks) ~= nil,
        dungeon_id .. " must snapshot its own secret identity")

    local outside = Issuer.issue(dungeon_id, 200, 42, {
        optional_boss_event_start = 100,
        optional_boss_event_end = 200,
    }, true)
    check(outside.OptionalBossEventActive == false,
        dungeon_id .. " event end boundary must be exclusive")
    check(outside.OptionalBossEnabled == false,
        dungeon_id .. " absence of optional content keeps run disabled")
end

local secret_only = Issuer.issue("TestDungeon", 201, 0, {
    optional_boss_secret_chance_basis_points = 10000,
}, true)
check(secret_only.OptionalBossSecretUnlocked
    and not secret_only.OptionalBossEventActive,
    "Hidden route may be eligible independently from timed event")
local event_only = Issuer.issue("AbandonedMine", 150, 42, {
    optional_boss_event_start = 100,
    optional_boss_event_end = 200,
    optional_boss_secret_chance_basis_points = 0,
}, true)
check(event_only.OptionalBossEventActive
    and not event_only.OptionalBossSecretUnlocked,
    "Timed boss event must not require secret route")
check(not Issuer.issue("Unknown", 150, 42, options, true)
    .OptionalBossEnabled,
    "Unknown dungeon cannot issue optional content")
check(not Issuer.issue("TestDungeon", 150, 42, {
    optional_boss_event_start = 200,
    optional_boss_event_end = 100,
}, true).OptionalBossEventActive,
    "Invalid schedule must never activate optional bosses")
check(not Issuer.issue("TestDungeon", 150, 42, {
    optional_boss_secret_chance_basis_points = 10001,
}, true).OptionalBossSecretUnlocked,
    "Out-of-range hidden-route probability must fail closed")
check(not Issuer.issue("TestDungeon", 150, 42, {
    optional_boss_secret_chance_basis_points = 0.5,
}, true).OptionalBossSecretUnlocked,
    "Fractional hidden-route probability must fail closed")

print(string.format(
    "[Optional Boss Run State Tests] PASS: %d assertions.",
    assertion_count
))
