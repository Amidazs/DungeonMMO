--!strict
local MineForemanFactory = require(
    script.Parent:WaitForChild("MineForemanFactory")
)

local AbandonedMineDepth2BossFactory = {}

-- Creates the Depth2 Mine boss using accepted Foreman combat behavior.
function AbandonedMineDepth2BossFactory.create(
    options: any
): Model
    local boss = MineForemanFactory.create(options)
    boss.Name = "AbandonedMineDepth2Boss"
    boss:SetAttribute(
        "BossId",
        "AbandonedMineDepth2Boss"
    )

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Deep Overseer"
    end

    return boss
end

return table.freeze(AbandonedMineDepth2BossFactory)
