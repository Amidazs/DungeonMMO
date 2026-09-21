--!strict
-- Pure server-side concurrency contract for ProfessionRuntime's RemoteEvent
-- path. It does not simulate a client; Studio integration is a later gate.
local SSS = game:GetService("ServerScriptService")
local Runtime = require(
    SSS.Core.Services:WaitForChild("ProfessionRuntime"))

local assertions = 0
local function check(ok: boolean, message: string)
    assertions += 1
    assert(ok, "[Profession Craft Guard] " .. message)
end

-- Distance authority is independent of the request guard: a fabricated
-- recipe request is still useless unless the server sees the player at the
-- correct station anchor.
local station = Instance.new("Part")
station.Anchored = true
station.Position = Vector3.new(0, 5, 0)
station.Parent = workspace
local character = Instance.new("Model")
local root = Instance.new("Part")
root.Name = "HumanoidRootPart"
root.Anchored = true
root.Position = Vector3.new(0, 5, 10)
root.Parent = character
local player_like = ({Character = character} :: any)
check(Runtime.within_station_range(player_like, station, 18),
    "server range check accepts a player physically near the station")
root.Position = Vector3.new(0, 5, 30)
check(not Runtime.within_station_range(player_like, station, 18),
    "server range check rejects a fabricated remote request from afar")
character:Destroy()
station:Destroy()

local guard = Runtime.new_craft_request_guard()
check(guard:try_begin(70101),
    "first request for a player must acquire")
check(guard:is_active(70101),
    "acquired player is active")
check(not guard:try_begin(70101),
    "overlapping request from same player must be rejected")
check(guard:try_begin(70102),
    "different player retains independent craft lane")
check(guard:is_active(70102),
    "second player is active independently")

guard:finish(70101)
check(not guard:is_active(70101),
    "finish releases first player")
check(guard:try_begin(70101),
    "released player can retry")
guard:finish(70101)
guard:finish(70101)
check(not guard:is_active(70101),
    "duplicate cleanup remains harmless")

check(guard:is_active(70102),
    "first player cleanup cannot release second player")
guard:finish(70102)
check(not guard:is_active(70102),
    "second player can be independently released")

-- PlayerRemoving invalidates the old request; a newly admitted request
-- with the SAME UserId must not lose its guard when the stale handler ends.
local acquired, old_ticket = guard:try_begin(70103)
check(acquired and old_ticket ~= nil
    and guard:is_current(70103, old_ticket),
    "original connection must receive a unique active request ticket")
check(guard:finish(70103, old_ticket),
    "PlayerRemoving should release the original request ticket")
local reconnected, new_ticket = guard:try_begin(70103)
check(reconnected and new_ticket ~= old_ticket,
    "same-account reconnect must acquire a fresh request ticket")
check(not guard:is_current(70103, old_ticket),
    "the disconnected request must not be accepted after reconnect")
check(not guard:finish(70103, old_ticket),
    "stale completion must not release the reconnected user's lock")
check(guard:is_current(70103, new_ticket)
    and guard:is_active(70103),
    "reconnected user's live request remains protected")
check(not guard:try_begin(70103),
    "duplicate request still rejected during new account session")
check(guard:finish(70103, new_ticket)
    and not guard:is_active(70103),
    "new request may complete and release normally")
check(guard:try_begin(70103),
    "same account can retry immediately after successful completion")
guard:finish(70103)

print(string.format(
    "[Profession Craft Guard] PASS: %d assertions.", assertions))
