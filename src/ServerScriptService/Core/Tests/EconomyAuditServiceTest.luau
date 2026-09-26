--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local EconomyAuditService = require(Services:WaitForChild("EconomyAuditService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Economy Audit Tests] " .. message, 2) end
end

local service = EconomyAuditService.new(nil, function() return 444 end)
local original = {
    TransactionId = "tx-a",
    Kind = "MonsterGoldReward",
    UserId = 1,
    GoldDelta = 10,
    Reason = "Monster:Marauder",
}
local first = service:record(original)
check(first.ok == true and first.already_recorded == false,
    "First audit event must record.")
original.GoldDelta = 999
local snapshot = service:snapshot()
check(#snapshot == 1 and snapshot[1].GoldDelta == 10 and snapshot[1].Timestamp == 444,
    "Audit must retain immutable copied event values.")

local duplicate = service:record({
    TransactionId = "tx-a",
    Kind = "MonsterGoldReward",
    UserId = 1,
    GoldDelta = 500,
    Reason = "Duplicate",
})
check(duplicate.ok == true and duplicate.already_recorded == true and service:count() == 1,
    "Transaction+kind replay must dedupe.")
local invalid = service:record({Kind = "MissingTransaction", Reason = "Bad"})
check(invalid.ok == false and invalid.reason == "InvalidTransactionId",
    "Invalid audit event must fail closed.")

local failing = EconomyAuditService.new(function(_event: any)
    error("sink down")
end, function() return 555 end)
local sink_result = failing:record({
    TransactionId = "tx-sink",
    Kind = "MarketTax",
    GoldDelta = -5,
    Reason = "MarketSale",
})
check(sink_result.ok == false and sink_result.reason == "AuditSinkFailed"
        and sink_result.recorded == true and failing:count() == 1,
    "Sink failure must be surfaced after immutable local recording.")
local sink_replay = failing:record({
    TransactionId = "tx-sink",
    Kind = "MarketTax",
    GoldDelta = -5,
    Reason = "MarketSale",
})
check(sink_replay.ok == true and sink_replay.already_recorded == true,
    "Sink failure replay must not duplicate the event.")

print(string.format("[Economy Audit Tests] PASS: %d assertions.", assertions))
