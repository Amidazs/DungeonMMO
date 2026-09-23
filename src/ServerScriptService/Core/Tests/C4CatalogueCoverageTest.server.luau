--!strict
-- Strict source-coverage acceptance; never mark incomplete C4 trees done.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Coverage = require(Shared.C4CatalogueCoverage)

local assertions = 0

--[[
Checks one exact source-backed total or incomplete career requirement.

Args:
    condition (boolean): Required source audit or completion invariant.
    description (string): Specific diagnostic on incorrect coverage.

Returns:
    nil: Records a passing audit check or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Catalogue Coverage] " .. description)
end

--[[
Rejects false parity across every supported starting class and original
C4 first-transfer choice, including the seven unmapped class branches.

Args:
    None.

Returns:
    nil: Prints reconciled rank totals and explicit completion status.
]]
local function main()
    local report = Coverage.report()
    local base = report.Base
    local scout = report.FirstTransferMapped
    local branches = report.Branches

    check(base.Raw == 168
        and base.Functional == 168
        and base.Missing == 0,
        "Original Fighter/Mystic first-tier rank inventory diverged")
    check(scout.Raw == 228
        and scout.Functional == 203
        and scout.Missing == 25,
        "Human Rogue and Elven Scout partial-rank totals diverged")
    check(branches.Total == 9 and branches.Partial == 2
        and branches.Complete == 0,
        "Not all nine first-transfer C4 classes are accounted for")
    check(#branches.Unimplemented == 7,
        "Unmapped first-transfer skill catalogues were silently dropped")
    check(base.Functional + base.Missing == base.Raw,
        "Base source skills counted twice or disappeared")
    check(scout.Functional + scout.Missing == scout.Raw,
        "Scout source skills counted twice or disappeared")
    check(report.Completed == false,
        "Incomplete first-transfer C4 catalogue was marked complete")

    print(("[C4 Catalogue Coverage] Base=%d/%d, "
        .. "Scout=%d/%d, class paths=%d/%d, unmapped=%d")
        :format(
            base.Functional, base.Raw,
            scout.Functional, scout.Raw,
            branches.Complete, branches.Total,
            #branches.Unimplemented
        ))
    print(("[C4 Catalogue Coverage] PASS: %d assertions; "
        .. "overall complete=false."):format(assertions))
end

main()
