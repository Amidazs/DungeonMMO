--!strict
-- Deepclaimer secondary-salvage tables. These are distinct from normal loot.

local C4DwarfSalvageConfig = {}

local TABLES = table.freeze({
    Default = table.freeze({
        table.freeze({
            Weight = 40,
            ItemId = "dense_mineral_shard",
            Quantity = 1,
        }),
        table.freeze({
            Weight = 30,
            ItemId = "salvaged_mechanism_fragment",
            Quantity = 1,
        }),
        table.freeze({
            Weight = 20,
            ItemId = "ancient_binding_fragment",
            Quantity = 1,
        }),
        table.freeze({
            Weight = 10,
            ItemId = nil,
            Quantity = 0,
        }),
    }),
})

--[[
Returns one immutable secondary-salvage table.

Args:
    table_id (string): Server-authored salvage table identifier.

Returns:
    any?: Weighted salvage entries, or nil for an unknown table.
]]
function C4DwarfSalvageConfig.get(table_id: string): any?
    return TABLES[table_id]
end

--[[
Rolls one server-authored salvage table.

Args:
    table_id (string): Server-authored salvage table identifier.
    rng (any): Server-owned random provider with NextInteger.

Returns:
    any?: Detached item/quantity result, or nil when nothing is rolled.
    string?: Stable configuration refusal.
]]
function C4DwarfSalvageConfig.roll(
    table_id: string,
    rng: any
): (any?, string?)
    local entries = TABLES[table_id]
    if not entries
        or not rng
        or type(rng.NextInteger) ~= "function"
    then
        return nil, "InvalidC4SalvageTable"
    end

    local total = 0
    for _, entry in ipairs(entries) do
        total += entry.Weight
    end
    if total <= 0 then
        return nil, "InvalidC4SalvageTable"
    end

    local roll = rng:NextInteger(1, total)
    local running = 0
    for _, entry in ipairs(entries) do
        running += entry.Weight
        if roll <= running then
            if not entry.ItemId then
                return nil, nil
            end
            return {
                ItemId = entry.ItemId,
                Quantity = entry.Quantity,
            }, nil
        end
    end

    return nil, "InvalidC4SalvageTable"
end

return table.freeze(C4DwarfSalvageConfig)
