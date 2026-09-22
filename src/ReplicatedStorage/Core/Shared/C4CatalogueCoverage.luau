--!strict
-- Read-only C4 source-vs-game completion gate for supported Human/Elf
-- base classes and every distinct source first-transfer class.
local Shared = script.Parent

local BaseAudit = require(Shared.C4BaseImplementationAudit)
local ScoutAudit = require(Shared.C4ScoutSkillInventory)
local Branches = require(Shared.C4FirstTransferBranches)

local C4CatalogueCoverage = {}
local BASE_CLASSES = {"Fighter", "Mage"}
local RACES = {"Human", "Elf"}

--[[
Accumulates genuine C4 source and functional ranks for a named class.

Args:
    totals (any): Mutable local count of raw, functional and missing.
    result (any): One validated source-specific rank audit.

Returns:
    nil: Adds the sourced counts to this report only.
]]
local function add_counts(totals: any, result: any)
    totals.Raw += result.Raw
    totals.Functional += result.Functional
    totals.Missing += result.Missing
end

--[[
Computes a conservative first-tier + first-transfer coverage result.

The original nine distinct C4 first-transfer choices are required.
The Human Rogue and Elven Scout inventories are only partial source
class analogues, not completed first-transfer implementations.
The other seven source careers remain unimplemented regardless of
whether DungeonMMO already has a similar gameplay role.

Args:
    None.

Returns:
    any: Exact audited rank counts, unimplemented branch names and an
        explicit overall Completed flag that cannot pass from names alone.
]]
function C4CatalogueCoverage.report(): any
    local base = {Raw = 0, Functional = 0, Missing = 0}
    local first_transfer = {Raw = 0, Functional = 0, Missing = 0}
    local branches = {
        Total = 0, Complete = 0, Partial = 0, Unimplemented = {},
    }

    for _, race_id in ipairs(RACES) do
        for _, class_id in ipairs(BASE_CLASSES) do
            add_counts(base, assert(BaseAudit.audit(race_id, class_id)))
            for _, branch in ipairs(assert(
                Branches.get(race_id, class_id)
            )) do
                branches.Total += 1
                if Branches.is_complete(branch) then
                    branches.Complete += 1
                elseif branch.GameplayStatus == "Partial" then
                    branches.Partial += 1
                    add_counts(
                        first_transfer, assert(ScoutAudit.audit(race_id))
                    )
                else
                    table.insert(
                        branches.Unimplemented,
                        race_id .. ": " .. branch.SourceClass
                    )
                end
            end
        end
    end
    table.sort(branches.Unimplemented)

    return {
        Base = base,
        FirstTransferMapped = first_transfer,
        Branches = branches,
        Completed = base.Missing == 0
            and first_transfer.Missing == 0
            and branches.Complete == branches.Total,
    }
end

return table.freeze(C4CatalogueCoverage)
