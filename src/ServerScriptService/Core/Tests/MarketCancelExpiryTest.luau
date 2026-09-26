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
    if not value then error("[Market Cancel Expiry Tests] " .. message, 2) end
end

local now = 4000
local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(7301))
local inventory = InventoryService.new(profiles)
assert(inventory:add_item(7301, "iron_ore", 4).ok)
local entities = InMemoryEntityAdapter.new()
local next_id = 0
local market = MarketService.new(entities, profiles, function() return now end, function()
    next_id += 1
    return "return-listing-" .. tostring(next_id)
end)
local first = market:create_listing(7301, "iron_ore", 1, 25, "cancel-create")
check(first.ok == true, "Cancel fixture listing must be created.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 3,
    "Cancel fixture must escrow one item.")
local cancelled = market:cancel(7301, first.listing.ListingId, "cancel-tx")
check(cancelled.ok == true, "Seller must be able to cancel Active listing.")
check(market:get_listing(first.listing.ListingId).State == "Cancelled",
    "Cancelled listing must be terminal.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 4,
    "Cancel must return item exactly once.")
local replay_cancel = market:cancel(7301, first.listing.ListingId, "cancel-tx")
check(replay_cancel.ok == true and replay_cancel.already_applied == true,
    "Cancel replay must be idempotent.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 4,
    "Cancel replay must not duplicate returned item.")

local second = market:create_listing(7301, "iron_ore", 2, 30, "expiry-create")
check(second.ok == true, "Expiry fixture listing must be created.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 2,
    "Expiry fixture must escrow exact quantity.")
now = second.listing.ExpiresAt
local sweep = market:expire_indexed()
check(sweep.ok == true and sweep.expired == 1, "Indexed expiry sweep must expire due listing.")
check(market:get_listing(second.listing.ListingId).State == "Expired",
    "Expired listing must become terminal.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 4,
    "Expiry must return escrowed quantity exactly once.")

local replay_expire = market:expire(second.listing.ListingId)
check(replay_expire.ok == true and replay_expire.already_applied == true,
    "Expiry replay must be idempotent.")
check(InventoryService.count_item(assert(profiles:get_character(7301, 1)), "iron_ore") == 4,
    "Expiry replay must not duplicate returned items.")

local other_cancel = market:cancel(9999, second.listing.ListingId, "wrong-owner")
check(other_cancel.ok == false and other_cancel.reason == "NotListingOwner",
    "Only seller may cancel listing.")

print(string.format(
    "[Market Cancel Expiry Tests] PASS: %d assertions.",
    assertions
))
