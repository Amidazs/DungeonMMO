--!strict
local EnemyDamageMultiplierRules = {}

-- Returns the authoritative outgoing-damage multiplier stored on an enemy.
function EnemyDamageMultiplierRules.get(enemy: Instance): number
    local value = enemy:GetAttribute("DungeonDamageMultiplier")
    if type(value) ~= "number" or value ~= value then
        return 1
    end
    return math.max(0, value)
end

return table.freeze(EnemyDamageMultiplierRules)
