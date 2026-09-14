--!strict
-- Historical filename retained so existing test discovery continues to include
-- the environment contract test after the legacy greybox builder is removed.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)
local Adapter = require(
    ServerScriptService
        :WaitForChild("Dungeon")
        :WaitForChild("TempleEnvironmentAdapter")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Temple Environment Contract Tests] " .. message, 2)
    end
end

local environment = Adapter.wait_for_ready(Workspace, 15)
check(environment.ok == true, "Temple environment must resolve")
check(
    Workspace:FindFirstChild("DungeonRuntime") == nil,
    "legacy DungeonRuntime greybox must not be the environment contract"
)

for _, anchor_id in ipairs({
    "Temple.EntrySpawn",
    "Temple.Room1.Checkpoint",
    "Temple.Room1.Trigger",
    "Temple.Room2.Checkpoint",
    "Temple.Room2.Trigger",
    "Temple.Room3.Checkpoint",
    "Temple.Room3.Trigger",
    "Temple.Room3.CaptainSpawn",
    "Temple.CompletionPosition",
    "Temple.ReturnToBase",
}) do
    check(
        environment:get(anchor_id) ~= nil,
        anchor_id .. " must resolve"
    )
end

check(
    #environment:get_group("Room1EnemySpawns") >= 2,
    "Room 1 requires at least two enemy spawns"
)
check(
    #environment:get_group("Room2EnemySpawns") >= 3,
    "Room 2 requires at least three enemy spawns"
)

local required_lookup = {}
for _, anchor_id in ipairs(Definitions.TEMPLE.Required) do
    required_lookup[anchor_id] = true
end
check(
    required_lookup["Temple.CheckpointRoom"] ~= true,
    "a standalone checkpoint room must not be required"
)
check(
    required_lookup["Temple.CompletionRoom"] ~= true,
    "a standalone completion room must not be required"
)

print(string.format(
    "[Temple Environment Contract Tests] PASS: %d assertions.",
    assertions
))
