--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Abandoned Mine Environment Contract Tests] " .. message, 2)
    end
end

check(Dungeon:FindFirstChild("AbandonedMineEnvironmentAdapter") ~= nil, "Mine environment adapter exists")
check(Dungeon:FindFirstChild("AbandonedMineSyntheticEnvironment") ~= nil, "Mine synthetic environment exists")
check(Dungeon:FindFirstChild("DungeonEnvironmentRouter") ~= nil, "environment router exists")
check(Dungeon:FindFirstChild("DungeonRuntimeSelection") ~= nil, "runtime selection exists")

print(string.format("[Abandoned Mine Environment Contract Tests] PASS: %d assertions.", assertions))
