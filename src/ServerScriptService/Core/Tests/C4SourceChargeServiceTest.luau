--!strict
-- Server-owned C4 source charge authority regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Service = require(
    ServerScriptService.Core.Services.C4SourceChargeService
)

local OWNER = table.freeze({UserId = 938290})
local OTHER = table.freeze({UserId = 938291})
local checks = 0

--[[
Counts one source-charge assertion.

Args:
    condition (boolean): Expected charge-authority condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and increments the check count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Charge] " .. label)
end

--[[
Runs the exact source charge lifecycle.

Args:
    None.

Returns:
    nil: Prints bounded server-owned charge evidence.
]]
local function main()
    local charges = Service.new()

    check(assert(charges:get(OWNER)) == 0, "new owner starts at zero")

    local first = assert(charges:add_one(OWNER, 1))
    check(
        first.ChargeBefore == 0
            and first.ChargeAfter == 1
            and first.MaximumCharges == 1
            and first.Added,
        "one Focus Force cast reaches maxCharges one"
    )

    local capped = assert(charges:add_one(OWNER, 1))
    check(
        capped.ChargeBefore == 1
            and capped.ChargeAfter == 1
            and not capped.Added,
        "source maximum prevents overcharging"
    )

    local spent = assert(charges:consume(OWNER, 1))
    check(
        spent.ChargeBefore == 1
            and spent.ChargeAfter == 0
            and spent.ChargesConsumed == 1,
        "Force Burst consumes its exact one-charge requirement"
    )

    local missing, reason = charges:consume(OWNER, 1)
    check(
        missing == nil and reason == "C4SourceChargeInsufficient",
        "charged attack fails closed without a charge"
    )

    assert(charges:add_one(OWNER, 1))
    assert(charges:add_one(OTHER, 1))
    charges:clear_owner(OWNER)
    check(
        assert(charges:get(OWNER)) == 0
            and assert(charges:get(OTHER)) == 1,
        "owner cleanup does not leak across players"
    )

    local capability = charges:capability()
    check(
        capability.ServerOwned
            and capability.OneChargeIncrement
            and capability.SourceMaximumEnforced
            and capability.ExactConsumption
            and not capability.ClientAuthority,
        "capability keeps force charges server authoritative"
    )

    print((
        "[C4 Source Charge] PASS: %d assertions max=1 consume=1"
    ):format(checks))
end

main()
