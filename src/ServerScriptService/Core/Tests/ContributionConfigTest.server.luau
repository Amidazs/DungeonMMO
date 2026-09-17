--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local ContributionConfig = require(Shared:WaitForChild("ContributionConfig"))

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Contribution Config Tests] " .. message, 2)
    end
end

check(ContributionConfig.Version == 1, "Contribution config must be v1.")

local expected = {
    DamageDealt = {"Damage", "DamageDealt"},
    DamageMitigated = {"Tank", "DamageMitigated"},
    AggroHeld = {"Tank", "AggroHeld"},
    EffectiveHealing = {"Support", "EffectiveHealing"},
    EffectiveWard = {"Support", "EffectiveWard"},
    UtilitySupport = {"Support", "UtilitySupport"},
}

for event_type, contract in pairs(expected) do
    local definition = ContributionConfig.EventTypes[event_type]
    check(definition ~= nil, event_type .. " must exist.")
    check(definition.Channel == contract[1], event_type .. " channel mismatch.")
    check(definition.Breakdown == contract[2], event_type .. " breakdown mismatch.")
    check(definition.Weight == 1.0, event_type .. " default weight must be 1.0.")
end

print(string.format("[Contribution Config Tests] PASS: %d assertions.", assertions))
