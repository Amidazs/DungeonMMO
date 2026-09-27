--!strict
-- Deepclaimer secondary-salvage economy/config regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Salvage = require(Shared.C4DwarfSalvageConfig)
local Items = require(Shared.ItemDefinitions)

local checks = 0

--[[
Counts one salvage configuration assertion.

Args:
    valid (boolean): Expected economy/config condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Salvage Config] " .. label)
end

local BoundaryRng = {}
BoundaryRng.__index = BoundaryRng

--[[
Creates one deterministic weighted-table roll provider.

Args:
    value (number): Exact inclusive weighted roll to return.

Returns:
    any: Deterministic random provider.
]]
function BoundaryRng.new(value: number): any
    return setmetatable({
        _value = value,
    }, BoundaryRng)
end

--[[
Returns the configured deterministic weighted roll.

Args:
    minimum (number): Required inclusive lower bound.
    maximum (number): Required inclusive upper bound.

Returns:
    number: Configured weighted result.
]]
function BoundaryRng:NextInteger(
    minimum: number,
    maximum: number
): number
    assert(minimum == 1 and maximum == 100)
    return self._value
end

--[[
Runs tradeability and every weighted-boundary salvage check.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all checks pass.
]]
local function main()
    local entries = assert(Salvage.get("Default"))
    local total = 0

    for _, entry in ipairs(entries) do
        total += entry.Weight

        if entry.ItemId then
            local item = assert(Items.get(entry.ItemId))
            check(
                item.Kind == "Material"
                    and item.Stackable == true
                    and item.Bound == false
                    and item.Tradeable == true,
                entry.ItemId .. " is a tradeable specialist material"
            )
        end
    end

    check(total == 100, "default secondary-salvage weights total 100")

    local first = assert(Salvage.roll(
        "Default",
        BoundaryRng.new(1)
    ))
    check(
        first.ItemId == "dense_mineral_shard",
        "roll 1 selects mineral shard bracket"
    )

    local mechanism = assert(Salvage.roll(
        "Default",
        BoundaryRng.new(41)
    ))
    check(
        mechanism.ItemId == "salvaged_mechanism_fragment",
        "roll 41 selects mechanism fragment bracket"
    )

    local binding = assert(Salvage.roll(
        "Default",
        BoundaryRng.new(71)
    ))
    check(
        binding.ItemId == "ancient_binding_fragment",
        "roll 71 selects binding fragment bracket"
    )

    local nothing, nothing_reason = Salvage.roll(
        "Default",
        BoundaryRng.new(91)
    )
    check(
        nothing == nil and nothing_reason == nil,
        "roll 91 enters the explicit no-salvage bracket"
    )

    local invalid, invalid_reason = Salvage.roll(
        "MadeUpTable",
        BoundaryRng.new(1)
    )
    check(
        invalid == nil
            and invalid_reason == "InvalidC4SalvageTable",
        "unknown salvage table fails closed"
    )

    print(
        ("[Dwarf Salvage Config] PASS: %d assertions")
            :format(checks)
    )
end

main()
