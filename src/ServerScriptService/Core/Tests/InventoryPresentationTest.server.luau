--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local InventoryPresentation = require(
    Shared:WaitForChild("InventoryPresentation")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Inventory Presentation Tests] " .. message, 2)
    end
end

local rows = InventoryPresentation.build({
    {ItemId = "marauder_sword", Quantity = 1},
    {ItemId = "marauder_shield", Quantity = 1},
    {ItemId = "marauder_helmet", Quantity = 1},
    {ItemId = "marauder_armor", Quantity = 1},
    {ItemId = "marauder_gloves", Quantity = 1},
    {ItemId = "iron_ore", Quantity = 2},
    {ItemId = "iron_ore", Quantity = 4},
    {ItemId = "silverleaf", Quantity = 3},
    {ItemId = "tempering_oil", Quantity = 1},
    {ItemId = "ironbound_gloves", Quantity = 1},
    {ItemId = "skill_book_test", Quantity = 2},
})

check(
    #rows == 10,
    "Inventory browser must aggregate duplicate stacks without truncating types."
)

local by_id = {}
for _, row in ipairs(rows) do
    by_id[row.ItemId] = row
end

check(
    by_id.iron_ore.Quantity == 6
        and by_id.iron_ore.InventoryCategory == "Materials",
    "Iron Ore must aggregate and classify as Materials."
)
check(
    by_id.silverleaf.InventoryCategory == "Materials",
    "Silverleaf must classify as Materials."
)
check(
    by_id.tempering_oil.InventoryCategory == "Reagents",
    "Tempering Oil must classify as Reagents rather than generic Materials."
)
check(
    by_id.ironbound_gloves.InventoryCategory == "Equipment",
    "Crafted gloves must classify as Equipment."
)
check(
    by_id.skill_book_test.InventoryCategory == "SkillBooks",
    "Skill books must classify into the Skill Books tab."
)

local tabs = InventoryPresentation.tabs()
check(
    #tabs == 6
        and tabs[1] == "All"
        and tabs[2] == "Equipment"
        and tabs[3] == "Materials"
        and tabs[4] == "Reagents"
        and tabs[5] == "SkillBooks"
        and tabs[6] == "Other",
    "Inventory tab order must remain stable."
)

local counts = InventoryPresentation.counts(rows)
check(counts.All == 10, "All-tab count must include every item type.")
check(counts.Equipment == 6, "Equipment-tab count must include six equipment types.")
check(counts.Materials == 2, "Materials-tab count must include Iron Ore and Silverleaf.")
check(counts.Reagents == 1, "Reagents-tab count must include Tempering Oil.")
check(counts.SkillBooks == 1, "Skill Books-tab count must include the test book.")

local reagents = InventoryPresentation.filter(rows, "Reagents")
check(
    #reagents == 1 and reagents[1].ItemId == "tempering_oil",
    "Reagents tab must filter to Tempering Oil."
)

local equipment = InventoryPresentation.filter(rows, "Equipment")
check(
    #equipment == 6,
    "Equipment tab must filter to equipment only."
)

check(
    InventoryPresentation.tab_label("Reagents", counts) == "Reagents (1)",
    "Tab label must expose category count."
)

print(string.format(
    "[Inventory Presentation Tests] PASS: %d assertions.",
    assertions
))
