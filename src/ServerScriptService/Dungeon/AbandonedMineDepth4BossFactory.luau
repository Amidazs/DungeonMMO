--!strict
local MineForemanFactory = require(
    script.Parent:WaitForChild("MineForemanFactory")
)

local AbandonedMineDepth4BossFactory = {}

-- Creates the Depth4 Mine final boss with accepted Foreman combat behavior.
function AbandonedMineDepth4BossFactory.create(
    options: any
): Model
    local boss = MineForemanFactory.create(options)
    boss.Name = "AbandonedMineDepth4Boss"
    boss:SetAttribute(
        "BossId",
        "AbandonedMineDepth4Boss"
    )
    if type(options.BossRole) == "string" then
        boss:SetAttribute("BossRole", options.BossRole)
    end

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Buried Tyrant"
    end

    return boss
end

return table.freeze(AbandonedMineDepth4BossFactory)
