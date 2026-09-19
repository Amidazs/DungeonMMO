--!strict
local BaseFactory = require(
    script.Parent:WaitForChild("MarauderCaptainFactory")
)
local Factory = {}

-- Creates a named optional boss using the accepted combat controller.
-- Args: options (any): Authoritative boss-spawn and reward options.
-- Returns: Model: Spawned boss retaining the requested encounter role.
function Factory.create(options: any): Model
    local boss = BaseFactory.create(options)
    boss.Name = "TempleEventBoss"
    boss:SetAttribute("BossId", "TempleEventBoss")
    boss:SetAttribute("BossRole", options.BossRole)

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayName = "Eclipse Herald"
    end
    return boss
end

return table.freeze(Factory)
