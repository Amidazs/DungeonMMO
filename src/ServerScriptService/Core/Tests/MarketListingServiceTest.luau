--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local MarketService = require(Services:WaitForChild("MarketService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Market Listing Service Tests] " .. message, 2) end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(7101))
assert(profiles:load(7102))
local inventory = InventoryService.new(profiles)
assert(inventory:add_item(7101, "iron_ore", 10).ok)
assert(inventory:add_item(7101, "arc_slash_book_bound", 1).ok)
assert(inventory:add_item(7102, "silverleaf", 6).ok)

local next_id = 0
local market = MarketService.new(InMemoryEntityAdapter.new(), profiles, function() return 1000 end, function()
    next_id += 1
    return "listing-" .. tostring(next_id)
end)
local created = market:create_listing(7101, "iron_ore", 2, 100, "create-a")
check(created.ok == true, "Valid listing must be created.")
check(created.listing.State == "Active", "New listing must be Active.")
check(InventoryService.count_item(assert(profiles:get_character(7101, 1)), "iron_ore") == 8,
    "Escrow must remove exact listed quantity once.")

local replay = market:create_listing(7101, "iron_ore", 2, 100, "create-a")
check(replay.ok == true and replay.already_applied == true,
    "Duplicate create transaction must reuse listing.")
check(InventoryService.count_item(assert(profiles:get_character(7101, 1)), "iron_ore") == 8,
    "Duplicate create must not remove inventory twice.")

local bound = market:create_listing(7101, "arc_slash_book_bound", 1, 100, "bound-a")
check(bound.ok == false and bound.reason == "ItemNotTradeable",
    "Bound/non-tradeable items must be rejected.")
local bad_price = market:create_listing(7101, "iron_ore", 1, 0, "bad-price")
check(bad_price.ok == false and bad_price.reason == "InvalidPrice",
    "Price below configured minimum must reject.")

for index = 1, 5 do
    local response = market:create_listing(
        7102,
        "silverleaf",
        1,
        10 + index,
        "limit-" .. tostring(index)
    )
    check(response.ok == true, "First five listings must be accepted.")
end
local sixth = market:create_listing(7102, "silverleaf", 1, 99, "limit-6")
check(sixth.ok == false and sixth.reason == "ListingLimitReached",
    "Sixth active listing must be rejected.")
check(InventoryService.count_item(assert(profiles:get_character(7102, 1)), "silverleaf") == 1,
    "Listing-limit rejection must not consume inventory.")

local active = market:list_active(100)
check(#active == 6, "Bounded index must expose six active listings across both sellers.")

print(string.format(
    "[Market Listing Service Tests] PASS: %d assertions.",
    assertions
))
