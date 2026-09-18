--!strict
local MarauderCaptainFactory = require(
    script.Parent:WaitForChild("MarauderCaptainFactory")
)

local TempleDepth2BossFactory = {}

-- Creates the Depth2 Temple boss using accepted Captain combat behavior.
function TempleDepth2BossFactory.create(options: any): Model
    local boss = MarauderCaptainFactory.create(options)
    boss.Name = "TempleDepth2Boss"
    boss:SetAttribute("BossId", "TempleDepth2Boss")

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Temple Warden"
    end

    return boss
end

return table.freeze(TempleDepth2BossFactory)
