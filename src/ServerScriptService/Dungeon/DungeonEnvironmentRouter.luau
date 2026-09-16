--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonDefinitions = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("DungeonDefinitions")
)
local TempleAdapter = require(script.Parent:WaitForChild("TempleEnvironmentAdapter"))
local MineAdapter = require(script.Parent:WaitForChild("AbandonedMineEnvironmentAdapter"))

local DungeonEnvironmentRouter = {}
local READY_ATTRIBUTE = "DungeonMMODungeonEnvironmentReady"
local ERROR_ATTRIBUTE = "DungeonMMODungeonEnvironmentError"

function DungeonEnvironmentRouter.wait_for_ready(root: Instance, dungeon_id: string, timeout_seconds: number?): any
    local deadline = os.clock() + (timeout_seconds or 15)
    repeat
        local error_reason = root:GetAttribute(ERROR_ATTRIBUTE)
        if type(error_reason) == "string" and error_reason ~= "" then
            return {ok = false, reason = error_reason}
        end
        if root:GetAttribute(READY_ATTRIBUTE) == true then
            if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id then
                return TempleAdapter.resolve(root)
            elseif dungeon_id == DungeonDefinitions.ABANDONED_MINE.Id then
                return MineAdapter.resolve(root)
            end
            return {ok = false, reason = "UnknownDungeonEnvironment"}
        end
        task.wait(0.1)
    until os.clock() >= deadline
    return {ok = false, reason = "DungeonEnvironmentBootstrapTimeout"}
end

return table.freeze(DungeonEnvironmentRouter)
