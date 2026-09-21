--!strict
-- Verify an offline world-boss departure keeps its profile lease until
-- a failed save is safely retried. Never touches live player data.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World boss profile-exit tests require unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Profiles = require(Core.Services.ProfileService)
local ProfileStore = require(Core.Adapters.InMemoryProfileAdapter)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Leases = require(Core.Services.ProfileLeaseService)
local Exit = require(SSS.WorldBoss.WorldBossProfileExit)

local USER_ID = 97801
local assertions = 0
local now = 1000

-- Args:
--   condition: boolean; required exclusive departure-save invariant.
--   message: string; failure description.
-- Returns:
--   nil: records passing assertions or raises the test failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[World Boss Profile Exit] " .. message)
end

-- Args: None.
-- Returns:
--   number: deterministic clock shared by both simulated servers.
local function clock(): number
    return now
end

-- Args:
--   store: any; normal in-memory persistent-profile adapter.
-- Returns:
--   any: transiently failing wrapper around only storage writes.
local function failing_adapter(store: any): any
    local adapter = {remaining_failures = 0}

    -- Args:
    --   user_id: number; trusted account for a profile update.
    --   transform: (any) -> any; normal profile-store mutation.
    -- Returns:
    --   (any?, string?): stored profile or injected transient failure.
    function adapter:update(user_id: number, transform: (any) -> any)
        if self.remaining_failures > 0 then
            self.remaining_failures -= 1
            return nil, "SimulatedDepartureSaveFailure"
        end
        return store:update(user_id, transform)
    end

    return adapter
end

local store = ProfileStore.new()
local flaky = failing_adapter(store)
local shared_map = MapAdapter.new(clock)
local lease_a = Leases.new(shared_map, "WorldBoss:ServerA", clock)
local lease_b = Leases.new(shared_map, "Base:ServerB", clock)
local profiles_a = Profiles.new(flaky, lease_a)
check(profiles_a:load(USER_ID) ~= nil,
    "source server must load its lease-protected character")

local changed = profiles_a:mutate(USER_ID, function(profile)
    profile.Characters.Slot1.Gold += 100
end)
check(changed == true, "source must own a dirty pending profile")
local exits = Exit.new(profiles_a, lease_a)
flaky.remaining_failures = 2
local saved, failure = exits:release(
    USER_ID, "WorldBossPlayerRemoving")
check(not saved and failure == "SimulatedDepartureSaveFailure"
    and exits:is_pending(USER_ID),
    "first failed save must retain an explicitly pending account")
check(not lease_b:claim(USER_ID).ok,
    "another server cannot claim the account during failed save")
local observer = Profiles.new(store)
check(observer:load(USER_ID) ~= nil
    and assert(observer:get_character(USER_ID, 1)).Gold == 0,
    "the first failed save must not appear in persistent storage")

check(exits:retry_pending() == 1
    and exits:is_pending(USER_ID),
    "a second transient failure retains the original lease")
check(not lease_b:claim(USER_ID).ok,
    "the second failure cannot release another writer early")
check(exits:retry_pending() == 0
    and not exits:is_pending(USER_ID),
    "successful retry must persist and release the departing account")
check(lease_b:claim(USER_ID).ok,
    "the Base server may claim only after source persistence completes")
local profiles_b = Profiles.new(store, lease_b)
check(profiles_b:load(USER_ID) ~= nil
    and assert(profiles_b:get_character(USER_ID, 1)).Gold == 100,
    "newly claimed server must load the original reward exactly once")
check(exits:retry_pending() == 0
    and assert(profiles_b:get_character(USER_ID, 1)).Gold == 100,
    "finished retries cannot mutate a different server's profile")

print(string.format(
    "[World Boss Profile Exit] PASS: %d assertions.", assertions))
