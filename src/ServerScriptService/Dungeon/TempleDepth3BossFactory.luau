--!strict
local MarauderCaptainFactory = require(
    script.Parent:WaitForChild("MarauderCaptainFactory")
)

local TempleDepth3BossFactory = {}

-- Creates the Depth3 Temple boss using accepted Captain combat behavior.
function TempleDepth3BossFactory.create(options: any): Model
    local boss = MarauderCaptainFactory.create(options)
    boss.Name = "TempleDepth3Boss"
    boss:SetAttribute("BossId", "TempleDepth3Boss")

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Relic Guardian"
    end

    return boss
end

return table.freeze(TempleDepth3BossFactory)
