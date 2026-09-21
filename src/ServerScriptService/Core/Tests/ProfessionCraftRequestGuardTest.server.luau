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

print(string.format(
    "[Profession Craft Guard] PASS: %d assertions.", assertions))
