--!strict
-- Converts server-persisted contribution totals to reward eligibility.
-- ContributionService:get_player_snapshot returns fields at its top level,
-- not in a nested "snapshot" property.
local WorldBossContributionRules = {}

-- Args:
--   result: any; authoritative ContributionService player response.
-- Returns:
--   boolean: true only when positive, finite server-recorded work exists.
function WorldBossContributionRules.is_eligible(result: any): boolean
    if type(result) ~= "table" or result.ok ~= true then
        return false
    end
    for _, channel in ipairs({"Damage", "Tank", "Support"}) do
        local amount = result[channel]
        if type(amount) == "number" and amount == amount
            and amount > 0 and amount < math.huge
        then
            return true
        end
    end
    return false
end

return table.freeze(WorldBossContributionRules)
