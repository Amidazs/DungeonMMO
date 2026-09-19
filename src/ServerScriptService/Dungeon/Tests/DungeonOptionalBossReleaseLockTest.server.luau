--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core")
    :WaitForChild("Shared")
local Definitions = require(Shared:WaitForChild(
    "DungeonDefinitions"
))
local Content = require(Shared:WaitForChild(
    "DungeonRuntimeContentCatalog"
))
local count = 0

-- Checks that unfinished optional boss rollout remains unavailable.
-- Args: condition (boolean): Required release-lock invariant.
--       message (string): Actionable test failure description.
-- Returns: nil: Raises when a release lock changes unexpectedly.
local function check(condition: boolean, message: string)
    count += 1
    assert(condition, "[Optional Boss Release Lock Tests] " .. message)
end

for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local definition = Definitions.get(dungeon_id)
    check(definition.OptionalBossRuntimeEnabled == false,
        dungeon_id .. " must keep optional bosses disabled")
    check(definition.OptionalEncounters == nil,
        dungeon_id .. " must not expose legacy auto-insert content")

    local depth1 = Content.get_layout(dungeon_id, "Depth1")
    check(depth1 ~= nil and depth1.Slots.EventArena == nil,
        dungeon_id .. " Depth1 must not expose an Event arena")
    check(depth1.Slots.SecretArena == nil,
        dungeon_id .. " Depth1 must not expose a Secret arena")

    for _, depth_id in ipairs({"Depth2", "Depth3", "Depth4"}) do
        check(Content.get_layout(dungeon_id, depth_id) == nil,
            dungeon_id .. " " .. depth_id
                .. " must remain physically unregistered")
    end
end

print(string.format(
    "[Optional Boss Release Lock Tests] PASS: %d assertions.",
    count
))
