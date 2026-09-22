--!strict
-- Source-confirmed C4 first transfers, distinct from game role analogues.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Inventory = require(Shared.C4ScoutSkillInventory)

local EXPECTED = {
    Human = {
        Fighter = {"Warrior", "Human Knight", "Rogue"},
        Mage = {"Wizard", "Cleric"},
    },
    Elf = {
        Fighter = {"Elven Knight", "Elven Scout"},
        Mage = {"Elven Wizard", "Elven Oracle"},
    },
}
local assertions = 0

--[[
Counts one verified source-class or real-implementation requirement.

Args:
    condition (boolean): Expected authentic first-transfer invariant.
    description (string): Diagnostic identifying a missing class branch.

Returns:
    nil: Increments the successful check count or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 First Transfers] " .. description)
end

--[[
Checks all currently supported original Chronicle 4 Human/Elf
first-transfer choices without claiming incomplete skills as complete.

Args:
    None.

Returns:
    nil: Prints source branch coverage after all checks pass.
]]
local function main()
    local total = 0
    local partial = 0
    for race_id, classes in pairs(EXPECTED) do
        for class_id, names in pairs(classes) do
            local options = assert(Branches.get(race_id, class_id))
            check(#options == #names,
                race_id .. " " .. class_id .. " C4 branch count changed")
            for index, source_class in ipairs(names) do
                local option = options[index]
                check(option.SourceClass == source_class,
                    "Wrong C4 first-transfer class " .. source_class)
                check(option.SourceRace == race_id
                    and option.SourceTransferLevel == 20,
                    source_class .. " has wrong original race or level")
                check(not Branches.is_complete(option),
                    "Unfinished C4 first-transfer class marked complete")
                if option.GameplayStatus == "Partial" then
                    partial += 1
                    check(option.SourceSkillInventory
                        == "C4ScoutSkillInventory",
                        "Unsupported C4 class claims functional skill inventory")
                    local audit = assert(Inventory.audit(race_id))
                    check(audit.Missing > 0,
                        "Partially implemented source class has no missing ranks")
                else
                    check(option.GameplayStatus == "NotImplemented",
                        source_class .. " has an unverified completion label")
                end
                total += 1
            end
        end
    end
    check(total == 9 and partial == 2,
        "Expected nine source paths, two partially mapped Scout classes")
    check(Branches.get("Orc", "Fighter") == nil,
        "Unsupported class tree should not be assumed implemented")
    print(("[C4 First Transfers] PASS: %d assertions, "
        .. "%d source classes, %d partially mapped."):format(
        assertions, total, partial
    ))
end

main()
