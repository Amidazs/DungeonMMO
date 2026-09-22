--!strict
-- Rejects source rank-count parity unless actual server effect ranks exist.

local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Audit = require(Shared.C4BaseImplementationAudit)
local Source = require(Shared.C4BaseSkillInventory)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local EXPECTED = {
    Human = {
        Fighter = {Raw = 39, Functional = 27, Missing = 12},
        Mage = {Raw = 44, Functional = 12, Missing = 32},
    },
    Elf = {
        Fighter = {Raw = 43, Functional = 27, Missing = 16},
        Mage = {Raw = 42, Functional = 12, Missing = 30},
    },
}
local assertions = 0

--[[
Asserts one genuine sourced first-tier skill coverage invariant.

Args:
    condition (boolean): True when the implementation matches source.
    description (string): Actionable diagnostic for a mismatch.

Returns:
    nil: Counts the assertion or raises for an incorrect catalogue.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Coverage] " .. description)
end

--[[
Checks all Human and Elf starting classes against source level families.

Args:
    None.

Returns:
    nil: Prints accurate functional/missing rank counts for each class.
]]
local function main()
    for race_id, classes in pairs(EXPECTED) do
        for class_id, expected in pairs(classes) do
            local audit = assert(Audit.audit(race_id, class_id))
            local source = assert(Source.get(race_id, class_id))
            for field, count in pairs(expected) do
                check(audit[field] == count,
                    race_id .. " " .. class_id .. " wrong " .. field)
            end
            local missing = 0
            for family, count in pairs(audit.MissingFamilies) do
                check(count > 0,
                    race_id .. " " .. class_id .. " zero missing rank")
                check(source.Levels[1][family] ~= false,
                    race_id .. " " .. class_id .. " unknown family")
                missing += count
            end
            check(missing == audit.Missing,
                race_id .. " " .. class_id .. " missing ledger differs")
            check(audit.Functional + audit.Missing == audit.Raw,
                race_id .. " " .. class_id .. " counted a rank twice")
            print(("[C4 Base Coverage] %s %s %d/%d; missing %d")
                :format(
                    race_id, class_id, audit.Functional,
                    audit.Raw, audit.Missing
                ))
        end
    end
    check(Combat.get_for_rank("FighterBowShot", 9).BASE_DAMAGE
        > Combat.get_for_rank("FighterBowShot", 1).BASE_DAMAGE,
        "Fighter longbow ranks have no actual damage progression")
    check(Combat.get_for_rank("MysticHealingPrayer", 6).TOTAL_HEAL
        > Combat.get_for_rank("MysticHealingPrayer", 1).TOTAL_HEAL,
        "Mystic healing ranks have no actual healing progression")
    check(Audit.audit("Orc", "Fighter") == nil,
        "Unmapped C4 races must not claim base-class completion")
    print(("[C4 Base Coverage] PASS: %d assertions.")
        :format(assertions))
end

main()
