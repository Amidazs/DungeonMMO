--!strict
local MarauderCaptainFactory = require(
    script.Parent:WaitForChild("MarauderCaptainFactory")
)

local TempleDepth4BossFactory = {}

-- Creates the Depth4 Temple final boss with accepted Captain combat behavior.
function TempleDepth4BossFactory.create(options: any): Model
    local boss = MarauderCaptainFactory.create(options)
    boss.Name = "TempleDepth4Boss"
    boss:SetAttribute("BossId", "TempleDepth4Boss")
    if type(options.BossRole) == "string" then
        boss:SetAttribute("BossRole", options.BossRole)
    end

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Sanctum Ascendant"
    end

    return boss
end

return table.freeze(TempleDepth4BossFactory)
