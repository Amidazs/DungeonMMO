--!strict
-- Owner-bound source quest loot. Only a separately authenticated dungeon
-- world binder may authorize a monster event; this module never does so.
local Inventory = require(script.Parent.InventoryService)

local Drops = {}
local LETTER_ITEMS = table.freeze({
    PriasLetter1 = "prias_letter_1",
    PriasLetter2 = "prias_letter_2",
    PriasLetter3 = "prias_letter_3",
    PriasLetter4 = "prias_letter_4",
})

--[[
Checks real inventory and one equipped original trial weapon.

Args:
    character (any): Current owner profile, never a client inventory.

Returns:
    boolean: Whether this Rogue is equipped for the skeleton/bandit trial.
]]
local function has_trial_weapon(character: any): boolean
    local equipped = character.Equipment
    local weapon_id = if type(equipped) == "table"
        then equipped.Weapon else nil
    return (weapon_id == "neti_trial_dagger"
        or weapon_id == "neti_trial_bow")
        and Inventory.count_item(character, "neti_trial_dagger") == 1
        and Inventory.count_item(character, "neti_trial_bow") == 1
end

--[[
Resolves exactly one previously authenticated letter-fragment drop.

Args:
    event (any): Authenticated current-stage source monster event.

Returns:
    string?: Exact personal quest-item ID or nil for invalid evidence.
]]
local function letter_item(event: any): string?
    local found: string? = nil
    for proof_id, item_id in pairs(LETTER_ITEMS) do
        if event.VerifiedProofIds
            and event.VerifiedProofIds[proof_id] == true
        then
            if found then return nil end
            found = item_id
        end
    end
    return found
end

--[[
Validates equipment, previous personal drops and physical turn-in ownership.

Args:
    character (any): Authoritative current selected character.
    state (any): Ordered server-persisted original source quest.
    event (any): World-authenticated evidence already checked by quest rules.

Returns:
    (boolean, string?): Ownership and equipment eligibility or refusal.
]]
function Drops.validate(
    character: any, state: any, event: any
): (boolean, string?)
    if state.BranchId == "HumanRogue" then
        if state.Step == 3 or state.Step == 6 then
            if not has_trial_weapon(character) then
                return false, "OriginalTrialWeaponNotEquipped"
            end
        end
        if state.Step == 3
            and Inventory.count_item(character, "spartoi_bone")
                ~= state.Count
        then
            return false, "OriginalQuestProofOwnershipInvalid"
        end
        if state.Step == 4
            and Inventory.count_item(character, "spartoi_bone") ~= 10
        then
            return false, "OriginalQuestProofOwnershipInvalid"
        end
    elseif state.BranchId == "ElvenScout" then
        if state.Step == 3 then
            local item_id = letter_item(event)
            if not item_id or Inventory.count_item(character, item_id) ~= 0
            then
                return false, "OriginalQuestProofOwnershipInvalid"
            end
        elseif state.Step == 4 then
            for _, item_id in pairs(LETTER_ITEMS) do
                if Inventory.count_item(character, item_id) ~= 1 then
                    return false, "OriginalQuestProofOwnershipInvalid"
                end
            end
        end
    end
    return true, nil
end

--[[
Consumes exactly the owner's earned materials on a real stage-four turn-in.

Args:
    character (any): Mutable verified quest owner's selected character.
    branch_id (string): Current original source quest branch.

Returns:
    (boolean, string?): Successful full turn-in or transaction refusal.
]]
local function consume_return_items(
    character: any, branch_id: string
): (boolean, string?)
    if branch_id == "HumanRogue" then
        local removed = Inventory.apply_remove_from_character(
            character, "spartoi_bone", 10
        )
        return removed.ok, removed.reason
    end
    if branch_id == "ElvenScout" then
        for _, item_id in pairs(LETTER_ITEMS) do
            local removed = Inventory.apply_remove_from_character(
                character, item_id, 1
            )
            if not removed.ok then
                return false, removed.reason
            end
        end
    end
    return true, nil
end

--[[
Commits a real owner-bound quest drop or consumes a verified NPC turn-in.

Args:
    character (any): Mutable owner character inside ProfileService mutate.
    state (any): Mutable original source quest with current step/count.
    event (any): Authenticated and currently eligible monster event.

Returns:
    (boolean, string?): Committed candidate drop or explicit grant failure.
]]
function Drops.apply(
    character: any, state: any, event: any
): (boolean, string?)
    local valid, refusal = Drops.validate(character, state, event)
    if not valid then return false, refusal end
    if state.Step == 4 then
        return consume_return_items(character, state.BranchId)
    end
    local item_id: string? = nil
    if state.Step == 3 and state.BranchId == "HumanRogue" then
        item_id = "spartoi_bone"
    elseif state.Step == 3 and state.BranchId == "ElvenScout" then
        item_id = letter_item(event)
    end
    if not item_id then return true, nil end
    local before = Inventory.count_item(character, item_id)
    local grant = Inventory.apply_item_to_character(
        character, item_id, 1
    )
    if not grant.ok
        or Inventory.count_item(character, item_id) ~= before + 1
    then
        return false, grant.reason or "OriginalQuestDropGrantFailed"
    end
    return true, nil
end

return table.freeze(Drops)
