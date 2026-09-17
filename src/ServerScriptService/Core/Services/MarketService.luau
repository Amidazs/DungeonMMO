--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local MarketConfig = require(Shared:WaitForChild("MarketConfig"))
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ItemTransferRules = require(Shared:WaitForChild("ItemTransferRules"))
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))

local MarketService = {}
MarketService.__index = MarketService

local INDEX_KEY = "market:index"

local function listing_key(listing_id: string): string
    return "market:listing:" .. listing_id
end

local function clone(value: any): any
    return ProfileSchema.deep_clone(value)
end

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end
local function ensure_market(character: any): any
    if type(character.Market) ~= "table" then
        character.Market = {}
    end
    local market = character.Market
    market.Version = MarketConfig.VERSION
    if type(market.ActiveListingIds) ~= "table" then
        market.ActiveListingIds = {}
    end
    if type(market.History) ~= "table" then
        market.History = {}
    end
    if type(market.Recovery) ~= "table" then
        market.Recovery = {}
    end
    return market
end

local function remove_active(market: any, listing_id: string)
    for index = #market.ActiveListingIds, 1, -1 do
        if market.ActiveListingIds[index] == listing_id then
            table.remove(market.ActiveListingIds, index)
        end
    end
end

local function valid_id(value: any): boolean
    return type(value) == "string" and value ~= "" and #value <= 128
end
local function equipped_item(character: any, item_id: string): boolean
    if type(character.Equipment) ~= "table" then
        return false
    end
    for _, equipped in pairs(character.Equipment) do
        if equipped == item_id then
            return true
        end
    end
    return false
end

function MarketService.new(
    adapter: any,
    profile_service: any,
    clock: (() -> number)?,
    id_generator: (() -> string)?
): any
    assert(adapter ~= nil, "MarketService requires entity adapter")
    assert(profile_service ~= nil, "MarketService requires ProfileService")
    local self = setmetatable({}, MarketService)
    self._adapter = adapter
    self._profiles = profile_service
    self._clock = clock or os.time
    self._id_generator = id_generator or function()
        return HttpService:GenerateGUID(false)
    end
    return self
end

function MarketService:get_listing(listing_id: string): any?
    if not valid_id(listing_id) then return nil end
    local listing = self._adapter:load(listing_key(listing_id))
    return listing
end
function MarketService:_index_add(listing_id: string): (boolean, string?)
    local stored, err = self._adapter:update(INDEX_KEY, function(old: any)
        local index = if type(old) == "table" then old else {Version = 1, ListingIds = {}}
        if type(index.ListingIds) ~= "table" then index.ListingIds = {} end
        for _, existing in ipairs(index.ListingIds) do
            if existing == listing_id then return index end
        end
        if #index.ListingIds >= MarketConfig.MAX_INDEX_SIZE then
            return nil
        end
        table.insert(index.ListingIds, listing_id)
        return index
    end)
    return stored ~= nil, err
end

function MarketService:_index_remove(listing_id: string)
    self._adapter:update(INDEX_KEY, function(old: any)
        local index = if type(old) == "table" then old else {Version = 1, ListingIds = {}}
        if type(index.ListingIds) ~= "table" then index.ListingIds = {} end
        for i = #index.ListingIds, 1, -1 do
            if index.ListingIds[i] == listing_id then
                table.remove(index.ListingIds, i)
            end
        end
        return index
    end)
end

function MarketService:list_active(limit: number?): {any}
    local index = self._adapter:load(INDEX_KEY)
    local ids = if type(index) == "table" and type(index.ListingIds) == "table"
        then index.ListingIds else {}
    local listings = {}
    local maximum = math.clamp(math.floor(tonumber(limit) or 50), 1, 100)
    for _, listing_id in ipairs(ids) do
        local listing = self:get_listing(listing_id)
        if listing
            and listing.State == "Active"
            and (tonumber(listing.ExpiresAt) or 0) > self._clock()
        then
            table.insert(listings, clone(listing))
            if #listings >= maximum then break end
        end
    end
    table.sort(listings, function(a: any, b: any)
        local a_time = tonumber(a.CreatedAt) or 0
        local b_time = tonumber(b.CreatedAt) or 0
        if a_time == b_time then return tostring(a.ListingId) < tostring(b.ListingId) end
        return a_time < b_time
    end)
    return listings
end

function MarketService:_rollback_create(
    user_id: number,
    listing_id: string,
    transaction_id: string,
    item: any
)
    self._profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        local market = ensure_market(character)
        local recovery = market.Recovery[listing_id]
        if type(recovery) == "table" and recovery.State ~= "Returned" then
            local restored = InventoryService.apply_item_to_character(
                character, item.ItemId, item.Quantity
            )
            if not restored.ok then error(restored.reason) end
            recovery.State = "Returned"
        end
        remove_active(market, listing_id)
        market.History[transaction_id] = {
            Kind = "Create",
            ListingId = listing_id,
            State = "CreateFailedReturned",
        }
    end)
end

function MarketService:create_listing(
    user_id: number,
    item_id: string,
    quantity: number,
    price: number,
    transaction_id: string
): any
    if not valid_id(transaction_id) then return result(false, "InvalidTransactionId") end
    if not MarketConfig.is_valid_price(price) then return result(false, "InvalidPrice") end
    if type(quantity) ~= "number" or quantity < 1 or quantity % 1 ~= 0 then
        return result(false, "InvalidQuantity")
    end
    local definition = ItemDefinitions.get(item_id)
    if not definition then return result(false, "UnknownItem") end
    local tradeable, trade_error = ItemTransferRules.can_trade(item_id)
    if not tradeable then return result(false, trade_error or "ItemNotTradeable") end
    if definition.Stackable ~= true and quantity ~= 1 then
        return result(false, "InvalidQuantity")
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then return result(false, "ProfileNotLoaded") end
    local existing_market = ensure_market(character)
    local prior = existing_market.History[transaction_id]
    if type(prior) == "table" and type(prior.ListingId) == "string" then
        local prior_listing = self:get_listing(prior.ListingId)
        if prior_listing then
            return result(true, nil, {already_applied = true, listing = prior_listing})
        end
    end
    if #existing_market.ActiveListingIds >= MarketConfig.MAX_ACTIVE_LISTINGS then
        return result(false, "ListingLimitReached")
    end
    if equipped_item(character, item_id) then
        return result(false, "ItemEquipped")
    end
    if InventoryService.count_item(character, item_id) < quantity then
        return result(false, "ItemNotOwned")
    end

    local listing_id = self._id_generator()
    if not valid_id(listing_id) then return result(false, "InvalidListingId") end
    local now = self._clock()
    local item = {ItemId = item_id, Quantity = quantity}
    local listing = {
        Version = MarketConfig.VERSION,
        ListingId = listing_id,
        SellerUserId = user_id,
        SellerSlot = 1,
        Item = clone(item),
        Price = price,
        TaxRate = MarketConfig.TAX_RATE,
        CreatedAt = now,
        ExpiresAt = now + MarketConfig.LISTING_DURATION_SECONDS,
        State = "Active",
        ActiveTransactionId = nil,
    }

    local mutation_result: any = nil
    local mutated, mutate_error = self._profiles:mutate(user_id, function(profile: any)
        local live_character = profile.Characters.Slot1
        local market = ensure_market(live_character)
        if market.History[transaction_id] then
            mutation_result = market.History[transaction_id]
            return
        end
        if #market.ActiveListingIds >= MarketConfig.MAX_ACTIVE_LISTINGS then
            error("ListingLimitReached")
        end
        if equipped_item(live_character, item_id) then
            error("ItemEquipped")
        end
        local removed = InventoryService.apply_remove_from_character(
            live_character, item_id, quantity
        )
        if not removed.ok then error(removed.reason) end
        table.insert(market.ActiveListingIds, listing_id)
        market.Recovery[listing_id] = {
            State = "Escrowed",
            Item = clone(item),
            TransactionId = transaction_id,
            CreatedAt = now,
        }
        market.History[transaction_id] = {
            Kind = "Create",
            ListingId = listing_id,
            State = "Escrowed",
        }
        mutation_result = market.History[transaction_id]
    end)
    if not mutated then
        return result(false, mutate_error or "ProfileMutationFailed")
    end
    local stored, store_error = self._adapter:update(listing_key(listing_id), function(old: any)
        if old ~= nil then return nil end
        return listing
    end)
    if not stored then
        self:_rollback_create(user_id, listing_id, transaction_id, item)
        return result(false, store_error or "ListingCreateFailed")
    end

    local indexed, index_error = self:_index_add(listing_id)
    if not indexed then
        self._adapter:remove(listing_key(listing_id))
        self:_rollback_create(user_id, listing_id, transaction_id, item)
        return result(false, index_error or "MarketIndexFull")
    end

    self._profiles:mutate(user_id, function(profile: any)
        local market = ensure_market(profile.Characters.Slot1)
        local recovery = market.Recovery[listing_id]
        if type(recovery) == "table" then recovery.State = "Listed" end
        local receipt = market.History[transaction_id]
        if type(receipt) == "table" then receipt.State = "Active" end
    end)

    return result(true, nil, {
        already_applied = false,
        listing = clone(stored),
        receipt = clone(mutation_result),
    })
end

function MarketService:_apply_buyer_sale(
    buyer_user_id: number,
    listing: any,
    transaction_id: string
): any
    local applied: any = nil
    local ok, err = self._profiles:mutate(buyer_user_id, function(profile: any)
        local character = profile.Characters.Slot1
        local market = ensure_market(character)
        local prior = market.History[transaction_id]
        if type(prior) == "table" and prior.Kind == "Buy" then
            applied = clone(prior)
            return
        end
        if character.Gold < listing.Price then
            error("InsufficientGold")
        end
        local added = InventoryService.apply_item_to_character(
            character,
            listing.Item.ItemId,
            listing.Item.Quantity
        )
        if not added.ok then error(added.reason) end
        character.Gold -= listing.Price
        market.History[transaction_id] = {
            Kind = "Buy",
            ListingId = listing.ListingId,
            GoldDelta = -listing.Price,
            Item = clone(listing.Item),
        }
        applied = clone(market.History[transaction_id])
    end)
    if not ok then return result(false, err or "BuyerMutationFailed") end
    return result(true, nil, {receipt = applied})
end

function MarketService:_apply_seller_sale(
    seller_user_id: number,
    listing: any,
    transaction_id: string
): any
    local applied: any = nil
    local proceeds = MarketConfig.seller_proceeds(listing.Price)
    local tax = MarketConfig.tax_amount(listing.Price)
    local ok, err = self._profiles:mutate(seller_user_id, function(profile: any)
        local character = profile.Characters.Slot1
        local market = ensure_market(character)
        local prior = market.History[transaction_id]
        if type(prior) == "table" and prior.Kind == "Sale" then
            applied = clone(prior)
            return
        end
        character.Gold += proceeds
        remove_active(market, listing.ListingId)
        local recovery = market.Recovery[listing.ListingId]
        if type(recovery) == "table" then recovery.State = "Sold" end
        market.History[transaction_id] = {
            Kind = "Sale",
            ListingId = listing.ListingId,
            GoldDelta = proceeds,
            Tax = tax,
        }
        applied = clone(market.History[transaction_id])
    end)
    if not ok then return result(false, err or "SellerMutationFailed") end
    return result(true, nil, {receipt = applied, proceeds = proceeds, tax = tax})
end

function MarketService:buy(
    buyer_user_id: number,
    listing_id: string,
    transaction_id: string
): any
    if not valid_id(listing_id) or not valid_id(transaction_id) then
        return result(false, "InvalidMarketRequest")
    end
    local listing = self:get_listing(listing_id)
    if not listing then return result(false, "ListingNotFound") end
    if listing.SellerUserId == buyer_user_id then
        return result(false, "CannotBuyOwnListing")
    end
    if listing.State == "Sold" and listing.ActiveTransactionId == transaction_id then
        return result(true, nil, {already_applied = true, listing = listing})
    end
    if listing.State ~= "Active"
        and not (listing.State == "PendingSale" and listing.ActiveTransactionId == transaction_id)
    then
        return result(false, "ListingUnavailable")
    end
    if (tonumber(listing.ExpiresAt) or 0) <= self._clock() then
        return result(false, "ListingExpired")
    end

    local claimed, claim_error = self._adapter:update(listing_key(listing_id), function(current: any)
        if type(current) ~= "table" then return nil end
        if current.State == "Active" then
            current.State = "PendingSale"
            current.ActiveTransactionId = transaction_id
            return current
        end
        if current.State == "PendingSale" and current.ActiveTransactionId == transaction_id then
            return current
        end
        if current.State == "Sold" and current.ActiveTransactionId == transaction_id then
            return current
        end
        return nil
    end)
    if not claimed then
        return result(false, claim_error or "ListingClaimFailed")
    end

    local buyer_result = self:_apply_buyer_sale(
        buyer_user_id,
        claimed,
        transaction_id
    )
    if not buyer_result.ok then
        return buyer_result
    end

    local seller_result = self:_apply_seller_sale(
        claimed.SellerUserId,
        claimed,
        transaction_id
    )
    if not seller_result.ok then
        return result(false, seller_result.reason or "SellerRecoveryPending", {
            pending_recovery = true,
            listing = claimed,
            buyer_receipt = buyer_result.receipt,
        })
    end

    local sold, sold_error = self._adapter:update(listing_key(listing_id), function(current: any)
        if type(current) ~= "table" then return nil end
        if current.ActiveTransactionId ~= transaction_id then return nil end
        current.State = "Sold"
        current.SoldAt = self._clock()
        return current
    end)
    if not sold then
        return result(false, sold_error or "ListingFinalizeFailed", {pending_recovery = true})
    end
    self:_index_remove(listing_id)

    return result(true, nil, {
        already_applied = false,
        listing = sold,
        buyer_receipt = buyer_result.receipt,
        seller_receipt = seller_result.receipt,
        tax = seller_result.tax,
    })
end
function MarketService:_apply_return(
    seller_user_id: number,
    listing: any,
    transaction_id: string,
    terminal_state: string
): any
    local applied: any = nil
    local ok, err = self._profiles:mutate(seller_user_id, function(profile: any)
        local character = profile.Characters.Slot1
        local market = ensure_market(character)
        local prior = market.History[transaction_id]
        if type(prior) == "table" and prior.ListingId == listing.ListingId then
            applied = clone(prior)
            return
        end
        local recovery = market.Recovery[listing.ListingId]
        if type(recovery) ~= "table" or recovery.State == "Sold" then
            error("MarketRecoveryMissing")
        end
        if recovery.State ~= "Returned" then
            local restored = InventoryService.apply_item_to_character(
                character,
                listing.Item.ItemId,
                listing.Item.Quantity
            )
            if not restored.ok then error(restored.reason) end
            recovery.State = "Returned"
        end
        remove_active(market, listing.ListingId)
        market.History[transaction_id] = {
            Kind = terminal_state,
            ListingId = listing.ListingId,
            Item = clone(listing.Item),
        }
        applied = clone(market.History[transaction_id])
    end)
    if not ok then return result(false, err or "ReturnMutationFailed") end
    return result(true, nil, {receipt = applied})
end
function MarketService:_begin_return(
    listing_id: string,
    transaction_id: string,
    terminal_state: string
): any
    local claimed, err = self._adapter:update(listing_key(listing_id), function(current: any)
        if type(current) ~= "table" then return nil end
        if current.State == "Active" then
            current.State = "PendingReturn"
            current.ActiveTransactionId = transaction_id
            current.ReturnState = terminal_state
            return current
        end
        if current.State == "PendingReturn"
            and current.ActiveTransactionId == transaction_id
            and current.ReturnState == terminal_state
        then
            return current
        end
        if current.State == terminal_state and current.ActiveTransactionId == transaction_id then
            return current
        end
        return nil
    end)
    if not claimed then return result(false, err or "ListingClaimFailed") end
    return result(true, nil, {listing = claimed})
end

function MarketService:cancel(
    seller_user_id: number,
    listing_id: string,
    transaction_id: string
): any
    if not valid_id(listing_id) or not valid_id(transaction_id) then
        return result(false, "InvalidMarketRequest")
    end
    local listing = self:get_listing(listing_id)
    if not listing then return result(false, "ListingNotFound") end
    if listing.SellerUserId ~= seller_user_id then return result(false, "NotListingOwner") end
    if listing.State == "Cancelled" and listing.ActiveTransactionId == transaction_id then
        return result(true, nil, {already_applied = true, listing = listing})
    end
    local claimed = self:_begin_return(listing_id, transaction_id, "Cancelled")
    if not claimed.ok then return claimed end
    local returned = self:_apply_return(
        seller_user_id,
        claimed.listing,
        transaction_id,
        "Cancelled"
    )
    if not returned.ok then return returned end
    local terminal, err = self._adapter:update(listing_key(listing_id), function(current: any)
        if type(current) ~= "table" or current.ActiveTransactionId ~= transaction_id then
            return nil
        end
        current.State = "Cancelled"
        current.CancelledAt = self._clock()
        return current
    end)
    if not terminal then return result(false, err or "ListingFinalizeFailed") end
    self:_index_remove(listing_id)
    return result(true, nil, {already_applied = false, listing = terminal})
end

function MarketService:expire(listing_id: string, transaction_id: string?): any
    if not valid_id(listing_id) then return result(false, "InvalidListingId") end
    local tx = transaction_id or ("Expire:" .. listing_id)
    if not valid_id(tx) then return result(false, "InvalidTransactionId") end
    local listing = self:get_listing(listing_id)
    if not listing then return result(false, "ListingNotFound") end
    if listing.State == "Expired" and listing.ActiveTransactionId == tx then
        return result(true, nil, {already_applied = true, listing = listing})
    end
    if listing.State == "Active" and (tonumber(listing.ExpiresAt) or 0) > self._clock() then
        return result(false, "ListingNotExpired")
    end
    local claimed = self:_begin_return(listing_id, tx, "Expired")
    if not claimed.ok then return claimed end
    local returned = self:_apply_return(
        claimed.listing.SellerUserId,
        claimed.listing,
        tx,
        "Expired"
    )
    if not returned.ok then
        return result(false, returned.reason or "ExpiryRecoveryPending", {
            pending_recovery = true,
            listing = claimed.listing,
        })
    end
    local terminal, err = self._adapter:update(listing_key(listing_id), function(current: any)
        if type(current) ~= "table" or current.ActiveTransactionId ~= tx then
            return nil
        end
        current.State = "Expired"
        current.ExpiredAt = self._clock()
        return current
    end)
    if not terminal then return result(false, err or "ListingFinalizeFailed") end
    self:_index_remove(listing_id)
    return result(true, nil, {already_applied = false, listing = terminal})
end

function MarketService:expire_indexed(): any
    local index = self._adapter:load(INDEX_KEY)
    local ids = if type(index) == "table" and type(index.ListingIds) == "table"
        then clone(index.ListingIds) else {}
    local expired = 0
    local pending = 0
    for _, listing_id in ipairs(ids) do
        local listing = self:get_listing(listing_id)
        if listing and listing.State == "Active"
            and (tonumber(listing.ExpiresAt) or 0) <= self._clock()
        then
            local response = self:expire(listing_id)
            if response.ok then expired += 1
            elseif response.pending_recovery then pending += 1 end
        end
    end
    return result(true, nil, {expired = expired, pending = pending})
end
function MarketService:recover_user(user_id: number): any
    local character = self._profiles:get_character(user_id, 1)
    if not character then return result(false, "ProfileNotLoaded") end
    local market = ensure_market(character)
    local recovered = 0
    local pending = 0

    for listing_id in pairs(market.Recovery) do
        local listing = self:get_listing(listing_id)
        if listing and listing.SellerUserId == user_id then
            if listing.State == "PendingSale" and valid_id(listing.ActiveTransactionId) then
                local seller = self:_apply_seller_sale(
                    user_id, listing, listing.ActiveTransactionId
                )
                if seller.ok then
                    self._adapter:update(listing_key(listing_id), function(current: any)
                        if type(current) ~= "table" then return nil end
                        current.State = "Sold"
                        current.SoldAt = self._clock()
                        return current
                    end)
                    self:_index_remove(listing_id)
                    recovered += 1
                else
                    pending += 1
                end
            elseif listing.State == "PendingReturn"
                and valid_id(listing.ActiveTransactionId)
                and (listing.ReturnState == "Cancelled" or listing.ReturnState == "Expired")
            then
                local returned = self:_apply_return(
                    user_id,
                    listing,
                    listing.ActiveTransactionId,
                    listing.ReturnState
                )
                if returned.ok then
                    local terminal_state = listing.ReturnState
                    self._adapter:update(listing_key(listing_id), function(current: any)
                        if type(current) ~= "table" then return nil end
                        current.State = terminal_state
                        current[terminal_state .. "At"] = self._clock()
                        return current
                    end)
                    self:_index_remove(listing_id)
                    recovered += 1
                else
                    pending += 1
                end
            elseif listing.State == "Active"
                and (tonumber(listing.ExpiresAt) or 0) <= self._clock()
            then
                local expired = self:expire(listing_id)
                if expired.ok then recovered += 1 else pending += 1 end
            end
        end
    end

    return result(true, nil, {
        recovered = recovered,
        pending = pending,
    })
end

return table.freeze(MarketService)
