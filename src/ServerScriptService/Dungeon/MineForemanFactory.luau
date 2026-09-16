--!strict
local MarauderCaptainFactory = require(script.Parent:WaitForChild("MarauderCaptainFactory"))
local MineForemanFactory = {}

function MineForemanFactory.create(options: any): Model
    local boss = MarauderCaptainFactory.create(options)
    boss.Name = "CorruptedForeman"
    boss:SetAttribute("BossId", "CorruptedForeman")
    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.DisplayName = "Corrupted Foreman" end
    local body = boss:FindFirstChild("Body")
    if body and body:IsA("BasePart") then
        body.Color = Color3.fromRGB(72, 84, 78)
        body.Material = Enum.Material.Metal
    end
    local head = boss:FindFirstChild("Head")
    if head and head:IsA("BasePart") then head.Color = Color3.fromRGB(142, 118, 91) end
    return boss
end

return table.freeze(MineForemanFactory)
