--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local RateLimitService = require(Services:WaitForChild("RateLimitService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Rate Limit Tests] " .. message, 2) end
end

local now = 100
local limiter = RateLimitService.new(function() return now end)
check(limiter:allow(1, "MarketCreate", 2, 10) == true, "First request must pass.")
check(limiter:allow(1, "MarketCreate", 2, 10) == true, "Second request must pass.")
check(limiter:allow(1, "MarketCreate", 2, 10) == false, "Third request must be limited.")
check(limiter:allow(1, "MarketBuy", 2, 10) == true,
    "Different action must have independent window.")
check(limiter:allow(2, "MarketCreate", 2, 10) == true,
    "Different user must have independent window.")
now = 110
check(limiter:allow(1, "MarketCreate", 2, 10) == true,
    "Window boundary must reset request count.")
limiter:clear_user(1)
check(limiter:allow(1, "MarketCreate", 2, 10) == true,
    "Cleared user must start a fresh window.")
check(limiter:allow(0, "MarketCreate", 2, 10) == false,
    "Invalid user must fail closed.")

print(string.format("[Rate Limit Tests] PASS: %d assertions.", assertions))
