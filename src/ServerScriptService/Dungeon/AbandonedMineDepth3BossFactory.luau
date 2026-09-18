--!strict
local MineForemanFactory = require(
    script.Parent:WaitForChild("MineForemanFactory")
)

local AbandonedMineDepth3BossFactory = {}

-- Creates the Depth3 Mine boss using accepted Foreman combat behavior.
function AbandonedMineDepth3BossFactory.create(
    options: any
): Model
    local boss = MineForemanFactory.create(options)
    boss.Name = "AbandonedMineDepth3Boss"
    boss:SetAttribute(
        "BossId",
        "AbandonedMineDepth3Boss"
    )

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Hollow Taskmaster"
    end

    return boss
end

return table.freeze(AbandonedMineDepth3BossFactory)
