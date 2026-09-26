--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryMapAdapter = require(Adapters:WaitForChild("InMemoryMapAdapter"))
local DungeonSessionService = require(Services:WaitForChild("DungeonSessionService"))

local now = 5000
local function clock(): number
    return now
end

local sessions = DungeonSessionService.new(
    InMemoryMapAdapter.new(clock),
    clock
)

local session = assert(
    sessions:create(
        "TestDungeon",
        {7001, 7002},
        123,
        "profession-resource-test"
    )
)
assert(sessions:mark_connected(session.SessionId, 7001).ok)
assert(sessions:mark_connected(session.SessionId, 7002).ok)

local first = sessions:claim_resource_node_once(
    session.SessionId,
    7001,
    "Temple.RichIronVein"
)
assert(first.ok == true, "First personal gather claim must succeed.")

local duplicate = sessions:claim_resource_node_once(
    session.SessionId,
    7001,
    "Temple.RichIronVein"
)
assert(
    duplicate.ok == false and duplicate.reason == "ResourceAlreadyClaimed",
    "The same player cannot claim one resource twice in the run."
)

local other_player = sessions:claim_resource_node_once(
    session.SessionId,
    7002,
    "Temple.RichIronVein"
)
assert(
    other_player.ok == true,
    "A second party member must retain their personal gather from the same node."
)

local claimed = sessions:get_claimed_resource_nodes(
    session.SessionId,
    7001
)
assert(claimed.ok == true, "Claim snapshot must be available for reconnect.")
assert(
    #claimed.node_ids == 1
        and claimed.node_ids[1] == "Temple.RichIronVein",
    "Reconnect snapshot must preserve the player's claimed node IDs."
)

-- Failed inventory/profile mutation can roll back the concurrency claim so the
-- player is not permanently deprived of the resource.
local released = sessions:release_resource_node_claim(
    session.SessionId,
    7001,
    "Temple.RichIronVein"
)
assert(released.ok == true, "Failed gather must be able to roll back its claim.")

local retry = sessions:claim_resource_node_once(
    session.SessionId,
    7001,
    "Temple.RichIronVein"
)
assert(retry.ok == true, "Rolled-back claim must become gatherable again.")

print("[Profession Resource Claim Tests] PASS")
