--!strict
local MarketConfig = {}

MarketConfig.VERSION = 1
MarketConfig.MAX_ACTIVE_LISTINGS = 5
MarketConfig.LISTING_DURATION_SECONDS = 24 * 60 * 60
MarketConfig.TAX_RATE = 0.05
MarketConfig.MIN_PRICE = 1
MarketConfig.MAX_PRICE = 50000
MarketConfig.MAX_INDEX_SIZE = 250

function MarketConfig.is_valid_price(value: any): boolean
    return type(value) == "number"
        and value == value
        and value >= MarketConfig.MIN_PRICE
        and value <= MarketConfig.MAX_PRICE
        and value < math.huge
        and value % 1 == 0
end

function MarketConfig.seller_proceeds(price: number): number
    return math.floor(price * (1 - MarketConfig.TAX_RATE))
end

function MarketConfig.tax_amount(price: number): number
    return price - MarketConfig.seller_proceeds(price)
end

return table.freeze(MarketConfig)
