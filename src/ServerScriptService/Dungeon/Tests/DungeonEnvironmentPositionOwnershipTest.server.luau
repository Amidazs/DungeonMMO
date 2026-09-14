--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local DungeonDefinitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("DungeonDefinitions")
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
        error("[Dungeon Environment Position Tests] " .. message, 2)
    end
end

check(
    DungeonDefinitions.TEST_DUNGEON.MarauderCaptain.SpawnPosition == nil,
    "DungeonDefinitions must not own Captain world coordinates"
)

local environment = Adapter.wait_for_ready(Workspace, 15)
check(environment.ok == true, "Temple adapter must resolve")
check(
    typeof(environment:captain_spawn_cframe()) == "CFrame",
    "Temple adapter must own Captain spawn CFrame"
)

print(string.format(
    "[Dungeon Environment Position Tests] PASS: %d assertions.",
    assertions
))
