--!strict
-- Source family totals for all currently supported C4 base class/race pairs.
-- Corrects the old Elven Fighter level-15 omission of regeneration ranks.

local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Inventory = require(Shared.C4BaseSkillInventory)
local Targets = require(Shared.C4SkillVolumeTargets)

local EXPECTED = table.freeze({
    Human = table.freeze({
        Fighter = table.freeze({[1] = 2, [5] = 13,
            [10] = 12, [15] = 12}),
        Mage = table.freeze({[1] = 7, [5] = 1,
            [7] = 15, [14] = 21}),
    }),
    Elf = table.freeze({
        Fighter = table.freeze({[1] = 2, [5] = 13,
            [10] = 13, [15] = 15}),
        Mage = table.freeze({[1] = 7, [5] = 1,
            [7] = 14, [14] = 20}),
    }),
})

local assertions = 0

--[[
Checks a single source-backed rank-total invariant.

Args:
    condition (boolean): Whether the source/inventory counts reconcile.
    description (string): Diagnostic identifying race, class or bracket.

Returns:
    nil: Records a pass or raises for an incorrect source count.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Source] " .. description)
end

--[[
Audits all four starting class and race source rank inventories.

Args:
    None.

Returns:
    nil: Verifies every source family count and prints coverage totals.
]]
local function main()
    for race_id, classes in pairs(EXPECTED) do
        for class_id, levels in pairs(classes) do
            local source = assert(Inventory.get(race_id, class_id))
            local target = assert(Targets.get(race_id, class_id))
            local totals = assert(Inventory.count(race_id, class_id))
            check(source.SourceUrl == target.SourceUrl,
                race_id .. " " .. class_id .. " source URL mismatch")
            local total = 0
            for level, expected in pairs(levels) do
                local row = assert(source.Levels[level])
                local row_count = 0
                for family, count in pairs(row) do
                    check(type(family) == "string"
                        and type(count) == "number" and count > 0
                        and count == math.floor(count),
                        "Invalid source rank family in " .. race_id)
                    row_count += count
                end
                check(row_count == expected,
                    race_id .. " " .. class_id .. " level "
                        .. level .. " source rank total differs")
                check(totals.Levels[level] == expected,
                    "Source audit count differs at " .. level)
                check(target.Levels[level] == expected,
                    "Reference target diverges at " .. level)
                total += expected
            end
            check(totals.Total == total,
                "Raw base-class source total mismatched")
            print(("[C4 Base Source] %s %s: %d raw rank entries.")
                :format(race_id, class_id, total))
        end
    end
    check(Inventory.get("Orc", "Fighter") == nil,
        "Unsupported race must not claim source completeness")
    print(("[C4 Base Source] PASS: %d assertions.")
        :format(assertions))
end

main()
