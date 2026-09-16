--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))

local InventoryPresentation = {}

local TAB_ORDER = table.freeze({
    "All",
    "Equipment",
    "Materials",
    "Reagents",
    "SkillBooks",
    "Other",
})

local TAB_NAMES = table.freeze({
    All = "All",
    Equipment = "Equipment",
    Materials = "Materials",
    Reagents = "Reagents",
    SkillBooks = "Skill Books",
    Other = "Other",
})

local CATEGORY_ORDER = table.freeze({
    Equipment = 1,
    Materials = 2,
    Reagents = 3,
    SkillBooks = 4,
    Other = 5,
})

local VALID_CATEGORY = table.freeze({
    Equipment = true,
    Materials = true,
    Reagents = true,
    SkillBooks = true,
    Other = true,
})

local function fallback_category(definition: any): string
    if not definition then
        return "Other"
    end

    -- Compatibility bridge for older definitions that already used
    -- Category="Reagent" before InventoryCategory existed.
    if definition.Category == "Reagent" then
        return "Reagents"
    end

    if definition.Kind == "Equipment" then
        return "Equipment"
    elseif definition.Kind == "Material" then
        return "Materials"
    elseif definition.Kind == "SkillBook" then
        return "SkillBooks"
    end

    return "Other"
end

local function inventory_category(definition: any): string
    local explicit = definition and definition.InventoryCategory
    if type(explicit) == "string" and VALID_CATEGORY[explicit] == true then
        return explicit
    end

    return fallback_category(definition)
end

function InventoryPresentation.tabs(): {string}
    return TAB_ORDER
end

function InventoryPresentation.category_name(category: string): string
    return TAB_NAMES[category] or TAB_NAMES.Other
end

function InventoryPresentation.build(entries: any): {any}
    local totals: {[string]: number} = {}

    if type(entries) == "table" then
        for _, entry in ipairs(entries) do
            if type(entry) == "table" and type(entry.ItemId) == "string" then
                local quantity = math.max(
                    0,
                    math.floor(tonumber(entry.Quantity) or 1)
                )

                if quantity > 0 then
                    totals[entry.ItemId] = (totals[entry.ItemId] or 0)
                        + quantity
                end
            end
        end
    end

    local rows = {}

    for item_id, quantity in pairs(totals) do
        local definition = ItemDefinitions.get(item_id)
        local category = inventory_category(definition)

        table.insert(rows, {
            ItemId = item_id,
            Name = if definition then tostring(definition.Name) else item_id,
            Quantity = quantity,
            InventoryCategory = category,
            CategoryName = InventoryPresentation.category_name(category),
            ItemCategory = if definition and definition.Category
                then tostring(definition.Category)
                else nil,
            Rarity = if definition and definition.Rarity
                then tostring(definition.Rarity)
                else "Unknown",
        })
    end

    table.sort(rows, function(a: any, b: any): boolean
        local a_order = CATEGORY_ORDER[a.InventoryCategory]
            or CATEGORY_ORDER.Other
        local b_order = CATEGORY_ORDER[b.InventoryCategory]
            or CATEGORY_ORDER.Other

        if a_order ~= b_order then
            return a_order < b_order
        end

        local a_name = string.lower(tostring(a.Name))
        local b_name = string.lower(tostring(b.Name))

        if a_name ~= b_name then
            return a_name < b_name
        end

        return tostring(a.ItemId) < tostring(b.ItemId)
    end)

    return rows
end

function InventoryPresentation.counts(rows: any): any
    local result = {
        All = 0,
        Equipment = 0,
        Materials = 0,
        Reagents = 0,
        SkillBooks = 0,
        Other = 0,
    }

    if type(rows) ~= "table" then
        return result
    end

    for _, row in ipairs(rows) do
        if type(row) == "table" then
            result.All += 1
            local category = row.InventoryCategory
            if type(category) == "string" and result[category] ~= nil then
                result[category] += 1
            else
                result.Other += 1
            end
        end
    end

    return result
end

function InventoryPresentation.filter(rows: any, category: string): {any}
    if type(rows) ~= "table" then
        return {}
    end

    if category == "All" then
        return rows
    end

    local filtered = {}

    for _, row in ipairs(rows) do
        if (
            type(row) == "table"
            and row.InventoryCategory == category
        ) then
            table.insert(filtered, row)
        end
    end

    return filtered
end

function InventoryPresentation.tab_label(
    category: string,
    counts: any
): string
    local name = InventoryPresentation.category_name(category)
    local count = if type(counts) == "table"
        then math.max(0, math.floor(tonumber(counts[category]) or 0))
        else 0

    return string.format("%s (%d)", name, count)
end

return table.freeze(InventoryPresentation)
