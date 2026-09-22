--!strict
local EnemyWeakeningService = require(
    script.Parent:WaitForChild("EnemyWeakeningService")
)
local EnemyDamageMultiplierRules = {}

-- Returns the authoritative outgoing-damage multiplier stored on an enemy.
function EnemyDamageMultiplierRules.get(enemy: Instance): number
    local value = enemy:GetAttribute("DungeonDamageMultiplier")
    if type(value) ~= "number" or value ~= value then
        value = 1
    end
    return math.max(0, value)
        * EnemyWeakeningService.get_damage_multiplier(enemy)
end

return table.freeze(EnemyDamageMultiplierRules)
