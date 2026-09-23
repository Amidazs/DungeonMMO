--!strict
-- Unpublished editor-only read-only source rank reconciliation.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Run source audit only in an unpublished local Studio place.")

local shared = game:GetService("ReplicatedStorage").Core.Shared
local audit = require(shared.C4BaseImplementationAudit)
local coverage = require(shared.C4CatalogueCoverage)

--[[
Prints current audited rank counts without modifying original source data.

Args:
    None.

Returns:
    nil: Emits all four class families and the full in-scope report.
]]
local function main()
    for _, race in {"Human", "Elf"} do
        for _, class_id in {"Fighter", "Mage"} do
            local result = assert(audit.audit(race, class_id))
            local missing = {}
            for family, count in pairs(result.MissingFamilies) do
                table.insert(missing, family .. "=" .. tostring(count))
            end
            table.sort(missing)
            print(("[C4 SOURCE AUDIT] %s %s functional=%d raw=%d "
                .. "missing=%d families=%s"):format(
                race, class_id, result.Functional,
                result.Raw, result.Missing, table.concat(missing, ",")
            ))
        end
    end
    local report = coverage.report()
    print(("[C4 SOURCE AUDIT] combined=%d/%d missing=%d")
        :format(
            report.Base.Functional + report.FirstTransferMapped.Functional,
            report.Base.Raw + report.FirstTransferMapped.Raw,
            report.Base.Missing + report.FirstTransferMapped.Missing
        ))
end

main()
