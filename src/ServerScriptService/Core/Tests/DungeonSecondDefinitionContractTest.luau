--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))
local EnvironmentAnchorDefinitions = require(Shared:WaitForChild("EnvironmentAnchorDefinitions"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Second Dungeon Definition Tests] " .. message, 2)
    end
end

check(DungeonDefinitions.ABANDONED_MINE ~= nil, "Abandoned Mine definition exists")
check(type(DungeonDefinitions.get) == "function", "definition lookup exists")

local mine = DungeonDefinitions.ABANDONED_MINE
if mine then
    check(mine.Id == "AbandonedMine", "Mine id is stable")
    check(mine.MaxPlayers == 4, "Mine supports 1-4 members")
    check(type(mine.ModulePool) == "table", "Mine module pool exists")
    check(type(mine.CompletionReward) == "table", "normal completion reward exists")
    check(type(mine.RareCompletionReward) == "table", "rare completion reward exists")
    check(type(mine.EventCompletionReward) == "table", "event completion reward exists")
end

check(EnvironmentAnchorDefinitions.ABANDONED_MINE ~= nil, "Mine environment anchor contract exists")

print(string.format("[Second Dungeon Definition Tests] PASS: %d assertions.", assertions))
