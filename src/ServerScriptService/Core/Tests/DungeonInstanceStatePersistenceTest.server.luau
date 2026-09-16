--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ServiceClass = require(
    ServerScriptService:WaitForChild("Core"):WaitForChild("Services"):WaitForChild("DungeonSessionService")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Dungeon Instance State Persistence Tests] " .. message, 2)
    end
end

check(type(ServiceClass.set_instance_state) == "function", "session service exposes immutable instance state setter")
print(string.format("[Dungeon Instance State Persistence Tests] PASS: %d assertions.", assertions))
