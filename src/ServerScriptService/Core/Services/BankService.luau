--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local BankConfig = require(Shared:WaitForChild("BankConfig"))
local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ItemTransferRules = require(
    Shared:WaitForChild("ItemTransferRules")
)
local InventoryService = require(
    Services:WaitForChild("InventoryService")
)

local BankService = {}
BankService.__index = BankService

local RARITY_ORDER = table.freeze({
    Basic = 1,
    Common = 2,
    Uncommon = 3,
    Rare = 4,
    Epic = 5,
    Legendary = 6,
})

local function rejected(reason: string): any
    return {
        ok = false,
        reason = reason,
    }
end

local function valid_quantity(value: any): boolean
    return (
        type(value) == "number"
        and value == value
        and value > 0
        and value < math.huge
        and value % 1 == 0
    )
end

local function selected_slot_key(profile: any): string?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end

    local selected = math.floor(
        tonumber(profile.Account.SelectedCharacterSlot) or 1
    )
    local key = "Slot" .. tostring(selected)

    if type(profile.Characters[key]) ~= "table" then
        return nil
    end

    return key
end

local function ensure_bank(profile: any): any?
    if type(profile) ~= "table" then
        return nil
    end

    if type(profile.Account) ~= "table" then
        profile.Account = {}
    end

    if type(profile.Account.Bank) ~= "table" then
        profile.Account.Bank = {
            Version = BankConfig.VERSION,
            Items = {},
        }
    end

    local bank = profile.Account.Bank
    bank.Version = BankConfig.VERSION

    if type(bank.Items) ~= "table" then
        bank.Items = {}
    end

    return bank
end

local function count_item(items: any, item_id: string): number
    if type(items) ~= "table" then
        return 0
    end

    local total = 0
    for _, entry in ipairs(items) do
        if type(entry) == "table" and entry.ItemId == item_id then
            local quantity = tonumber(entry.Quantity)
            if quantity and quantity > 0 then
                total += math.floor(quantity)
            end
        end
    end

    return total
end

local function equipped_count(character: any, item_id: string): number
    if type(character) ~= "table"
        or type(character.Equipment) ~= "table"
    then
        return 0
    end

    local total = 0
    for _, equipped_item_id in pairs(character.Equipment) do
        if equipped_item_id == item_id then
            total += 1
        end
    end
    return total
end

local function used_slots(items: any): number
    if type(items) ~= "table" then
        return 0
    end

    local total = 0
    for _, entry in ipairs(items) do
        if type(entry) == "table"
            and type(entry.ItemId) == "string"
        then
            local definition = ItemDefinitions.get(entry.ItemId)
            local quantity = math.max(
                0,
                math.floor(tonumber(entry.Quantity) or 0)
            )

            if definition and quantity > 0 then
                if definition.Stackable == true then
                    total += 1
                else
                    total += quantity
                end
            end
        end
    end

    return total
end

local function additional_slots(
    bank_items: any,
    item_id: string,
    quantity: number
): number
    local definition = ItemDefinitions.get(item_id)
    if not definition then
        return math.huge
    end

    if definition.Stackable == true then
        return if count_item(bank_items, item_id) > 0 then 0 else 1
    end

    return quantity
end

local function remove_from_items(
    items: any,
    item_id: string,
    quantity: number
): boolean
    if count_item(items, item_id) < quantity then
        return false
    end

    local remaining = quantity

    for index = #items, 1, -1 do
        if remaining <= 0 then
            break
        end

        local entry = items[index]
        if type(entry) == "table" and entry.ItemId == item_id then
            local current = math.max(
                0,
                math.floor(tonumber(entry.Quantity) or 1)
            )
            local take = math.min(current, remaining)
            current -= take
            remaining -= take

            if current <= 0 then
                table.remove(items, index)
            else
                entry.Quantity = current
            end
        end
    end

    return remaining == 0
end

local function add_to_items(
    items: any,
    item_id: string,
    quantity: number
)
    local definition = assert(ItemDefinitions.get(item_id))

    if definition.Stackable == true then
        for _, entry in ipairs(items) do
            if type(entry) == "table" and entry.ItemId == item_id then
                entry.Quantity = math.max(
                    0,
                    math.floor(tonumber(entry.Quantity) or 0)
                ) + quantity
                return
            end
        end

        table.insert(items, {
            ItemId = item_id,
            Quantity = quantity,
        })
        return
    end

    for _ = 1, quantity do
        table.insert(items, {
            ItemId = item_id,
            Quantity = 1,
        })
    end
end

local function category_for(definition: any): string
    return tostring(
        definition.InventoryCategory
            or definition.Category
            or definition.Kind
            or "Other"
    )
end

local function sort_rows(rows: any)
    table.sort(rows, function(left: any, right: any): boolean
        local left_category = tostring(left.Category or "")
        local right_category = tostring(right.Category or "")
        if left_category ~= right_category then
            return left_category < right_category
        end

        local left_rarity = RARITY_ORDER[left.Rarity] or 999
        local right_rarity = RARITY_ORDER[right.Rarity] or 999
        if left_rarity ~= right_rarity then
            return left_rarity < right_rarity
        end

        return tostring(left.Name) < tostring(right.Name)
    end)
end

local function aggregate_rows(
    items: any,
    character: any?,
    include_bankability: boolean
): any
    local totals = {}

    if type(items) == "table" then
        for _, entry in ipairs(items) do
            if type(entry) == "table"
                and type(entry.ItemId) == "string"
            then
                local quantity = math.max(
                    0,
                    math.floor(tonumber(entry.Quantity) or 0)
                )
                if quantity > 0 then
                    totals[entry.ItemId] =
                        (totals[entry.ItemId] or 0) + quantity
                end
            end
        end
    end

    local rows = {}
    for item_id, quantity in pairs(totals) do
        local definition = ItemDefinitions.get(item_id)
        if definition then
            local row = {
                ItemId = item_id,
                Name = definition.Name or item_id,
                Quantity = quantity,
                Kind = definition.Kind or "Other",
                Category = category_for(definition),
                Rarity = definition.Rarity or "Basic",
                Stackable = definition.Stackable == true,
            }

            if include_bankability then
                local bankable, reason =
                    ItemTransferRules.can_bank(item_id)
                local equipped = equipped_count(
                    character,
                    item_id
                )
                row.Bankable = bankable
                row.Reason = reason
                row.EquippedQuantity = equipped
                row.AvailableQuantity = math.max(
                    0,
                    quantity - equipped
                )
            end

            table.insert(rows, row)
        end
    end

    sort_rows(rows)
    return rows
end

function BankService.apply_deposit_to_profile(
    profile: any,
    slot_key: string,
    item_id: string,
    quantity: number
): any
    if not valid_quantity(quantity) then
        return rejected("InvalidQuantity")
    end

    local bankable, transfer_reason =
        ItemTransferRules.can_bank(item_id)
    if not bankable then
        return rejected(transfer_reason or "ItemNotBankable")
    end

    if type(profile) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return rejected("ProfileNotLoaded")
    end

    local character = profile.Characters[slot_key]
    if type(character) ~= "table" then
        return rejected("ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return rejected("IdentityIncomplete")
    end

    if type(character.Inventory) ~= "table" then
        character.Inventory = {}
    end

    local bank = ensure_bank(profile)
    if not bank then
        return rejected("ProfileNotLoaded")
    end

    local owned = InventoryService.count_item(
        character,
        item_id
    )
    if owned < quantity then
        return rejected("ItemNotOwned")
    end

    local equipped = equipped_count(character, item_id)
    if quantity > owned - equipped then
        return rejected("ItemEquipped")
    end

    local slots_needed = additional_slots(
        bank.Items,
        item_id,
        quantity
    )
    if used_slots(bank.Items) + slots_needed > BankConfig.CAPACITY then
        return rejected("BankFull")
    end

    local removed = remove_from_items(
        character.Inventory,
        item_id,
        quantity
    )
    if not removed then
        return rejected("ItemNotOwned")
    end

    add_to_items(bank.Items, item_id, quantity)

    return {
        ok = true,
        item_id = item_id,
        quantity = quantity,
    }
end

function BankService.apply_withdraw_to_profile(
    profile: any,
    slot_key: string,
    item_id: string,
    quantity: number
): any
    if not valid_quantity(quantity) then
        return rejected("InvalidQuantity")
    end

    if not ItemDefinitions.get(item_id) then
        return rejected("UnknownItem")
    end

    if type(profile) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return rejected("ProfileNotLoaded")
    end

    local character = profile.Characters[slot_key]
    if type(character) ~= "table" then
        return rejected("ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return rejected("IdentityIncomplete")
    end

    if type(character.Inventory) ~= "table" then
        character.Inventory = {}
    end

    local bank = ensure_bank(profile)
    if not bank then
        return rejected("ProfileNotLoaded")
    end

    if count_item(bank.Items, item_id) < quantity then
        return rejected("ItemNotOwned")
    end

    local removed = remove_from_items(
        bank.Items,
        item_id,
        quantity
    )
    if not removed then
        return rejected("ItemNotOwned")
    end

    add_to_items(character.Inventory, item_id, quantity)

    return {
        ok = true,
        item_id = item_id,
        quantity = quantity,
    }
end

function BankService.new(
    profile_service: any,
    context: string?
): any
    assert(
        profile_service ~= nil,
        "BankService requires ProfileService"
    )

    return setmetatable({
        _profiles = profile_service,
        _context = context or "Base",
    }, BankService)
end

function BankService:_base_only(): any?
    if self._context ~= "Base" then
        return rejected("BaseOnlyAction")
    end
    return nil
end

function BankService:build_snapshot(user_id: number): any
    local profile = self._profiles:get_profile(user_id)
    if not profile then
        return rejected("ProfileNotLoaded")
    end

    local slot_key = selected_slot_key(profile)
    if not slot_key then
        return rejected("ProfileNotLoaded")
    end

    local character = profile.Characters[slot_key]
    if not CharacterIdentityRules.is_complete(character) then
        return rejected("IdentityIncomplete")
    end

    local bank = ensure_bank(profile)
    if not bank then
        return rejected("ProfileNotLoaded")
    end

    local used = used_slots(bank.Items)

    return {
        ok = true,
        Capacity = BankConfig.CAPACITY,
        UsedSlots = used,
        RemainingSlots = math.max(
            0,
            BankConfig.CAPACITY - used
        ),
        Inventory = aggregate_rows(
            character.Inventory,
            character,
            true
        ),
        Items = aggregate_rows(
            bank.Items,
            nil,
            false
        ),
    }
end

function BankService:deposit(
    user_id: number,
    item_id: string,
    quantity: number
): any
    local blocked = self:_base_only()
    if blocked then
        return blocked
    end

    local result: any = nil
    local ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local slot_key = selected_slot_key(profile)
            if not slot_key then
                result = rejected("ProfileNotLoaded")
                error("ProfileNotLoaded")
            end

            result = BankService.apply_deposit_to_profile(
                profile,
                slot_key,
                item_id,
                quantity
            )
            if result.ok ~= true then
                error(result.reason or "BankDepositRejected")
            end
        end
    )

    if not ok then
        return if result and result.ok == false
            then result
            else rejected(
                mutation_error or "ProfileMutationFailed"
            )
    end

    return result
end

function BankService:withdraw(
    user_id: number,
    item_id: string,
    quantity: number
): any
    local blocked = self:_base_only()
    if blocked then
        return blocked
    end

    local result: any = nil
    local ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local slot_key = selected_slot_key(profile)
            if not slot_key then
                result = rejected("ProfileNotLoaded")
                error("ProfileNotLoaded")
            end

            result = BankService.apply_withdraw_to_profile(
                profile,
                slot_key,
                item_id,
                quantity
            )
            if result.ok ~= true then
                error(result.reason or "BankWithdrawRejected")
            end
        end
    )

    if not ok then
        return if result and result.ok == false
            then result
            else rejected(
                mutation_error or "ProfileMutationFailed"
            )
    end

    return result
end

return table.freeze(BankService)
