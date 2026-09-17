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
    if not value then error("[Market Purchase Recovery Tests] " .. message, 2) end
end

local profile_adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(profile_adapter)
assert(profiles:load(7201))
assert(profiles:load(7202))
local inventory = InventoryService.new(profiles)
assert(inventory:add_item(7201, "iron_bar", 1).ok)
assert(profiles:mutate(7202, function(profile: any)
    profile.Characters.Slot1.Gold = 500
end))

local entities = InMemoryEntityAdapter.new()
local market = MarketService.new(entities, profiles, function() return 2000 end, function()
    return "recovery-listing"
end)
local listed = market:create_listing(7201, "iron_bar", 1, 100, "create-recovery")
check(listed.ok == true, "Seller listing must be created.")
check(assert(profiles:get_character(7201, 1)).Gold == 0, "Listing must not grant seller Gold early.")

assert(profiles:save(7201, "MarketRecoverySetup"))
assert(profiles:release(7201, "MarketRecoverySetup"))

local interrupted = market:buy(7202, "recovery-listing", "buy-recovery")
check(interrupted.ok == false and interrupted.pending_recovery == true,
    "Offline seller must leave purchase in recoverable pending state.")
local buyer_after = assert(profiles:get_character(7202, 1))
check(buyer_after.Gold == 400, "Buyer must be charged exactly once before seller recovery.")
check(InventoryService.count_item(buyer_after, "iron_bar") == 1,
    "Buyer must receive escrowed item exactly once.")
check(market:get_listing("recovery-listing").State == "PendingSale",
    "Interrupted purchase must persist PendingSale state.")

local retry_pending = market:buy(7202, "recovery-listing", "buy-recovery")
check(retry_pending.ok == false and retry_pending.pending_recovery == true,
    "Retry while seller remains offline must stay recoverable.")
buyer_after = assert(profiles:get_character(7202, 1))
check(buyer_after.Gold == 400, "Pending retry must not charge buyer twice.")
check(InventoryService.count_item(buyer_after, "iron_bar") == 1,
    "Pending retry must not grant item twice.")
assert(profiles:load(7201))
local recovered = market:recover_user(7201)
check(recovered.ok == true and recovered.recovered == 1,
    "Seller reload must complete pending sale recovery.")
local seller_after = assert(profiles:get_character(7201, 1))
check(seller_after.Gold == 95, "Seller must receive exactly 95% after 5% tax.")
check(market:get_listing("recovery-listing").State == "Sold",
    "Recovered listing must become Sold.")

local replay = market:buy(7202, "recovery-listing", "buy-recovery")
check(replay.ok == true and replay.already_applied == true,
    "Completed purchase replay must return stored terminal result.")
check(assert(profiles:get_character(7202, 1)).Gold == 400,
    "Completed purchase replay must not charge buyer twice.")
check(assert(profiles:get_character(7201, 1)).Gold == 95,
    "Completed purchase replay must not pay seller twice.")

local self_listing = MarketService.new(entities, profiles, function() return 3000 end, function()
    return "self-listing"
end)
assert(inventory:add_item(7201, "silverleaf", 1).ok)
check(self_listing:create_listing(7201, "silverleaf", 1, 10, "self-create").ok,
    "Self-buy fixture listing must be created.")
local self_buy = self_listing:buy(7201, "self-listing", "self-buy")
check(self_buy.ok == false and self_buy.reason == "CannotBuyOwnListing",
    "Seller must never buy own listing.")

print(string.format("[Market Purchase Recovery Tests] PASS: %d assertions.", assertions))
