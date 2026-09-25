--!strict
-- Reviewed DungeonMMO creative-item links to the pinned C4 source items.
-- A link identifies the intended historical source stat record; it does not
-- make the current creative item's custom CombatModifiers C4-equivalent.

local Shared = script.Parent

local C4SourceItemReference = require(
    Shared:WaitForChild("C4SourceItemReference")
)
local ItemDefinitions = require(
    Shared:WaitForChild("ItemDefinitions")
)

local C4CreativeItemSourceMap = {}

local LINKS = table.freeze({
    marauder_sword = 1,
    greenward_training_mace = 4,
    stonewatch_training_mace = 4,
    apprentice_arcane_wand = 6,
    scout_dagger = 10,
    apprentice_longbow = 13,
    neti_trial_dagger = 1182,
    neti_trial_bow = 1181,
    ironroot_training_halberd = 291,
    scout_leather_vest = 22,
    ironroot_light_vest = 22,
    marauder_armor = 25,
    stonewatch_d_grade_armor = 352,
    greenward_d_grade_armor = 352,
    ironroot_d_grade_armor = 352,
    scout_expert_leather_vest = 395,
    apprentice_mystic_robe = 425,
    marauder_shield = 102,
    marauder_helmet = 43,
    test_elf_helmet = 44,
    marauder_gloves = 49,
    ironbound_gloves = 51,
    leatherbound_gloves = 50,
    tempered_ironbound_gloves = 63,
    runic_ironbound_gloves = 61,
    warded_leatherbound_gloves = 61,
    marauder_boots = 38,
})

-- DungeonMMO has one visible Body slot. These reviewed source legs complete
-- the matching C4 armor set so armor conditions and FuncPDefMod can reproduce
-- the original chest+legs semantics without adding a second player-facing
-- inventory slot.
local BODY_LEGS = table.freeze({
    scout_leather_vest = 29,
    ironroot_light_vest = 29,
    marauder_armor = 32,
    stonewatch_d_grade_armor = 2378,
    greenward_d_grade_armor = 2378,
    ironroot_d_grade_armor = 2378,
    scout_expert_leather_vest = 417,
    apprentice_mystic_robe = 461,
})

local SLOT_MAP = table.freeze({
    Weapon = "Weapon",
    Body = "Body",
    OffHand = "OffHand",
    Helmet = "Head",
    Gloves = "Gloves",
    Boots = "Feet",
})

local CORE_SLOTS = table.freeze({
    "Weapon",
    "OffHand",
    "Helmet",
    "Body",
    "Gloves",
    "Boots",
})

--[[
Returns the reviewed source-item link for one current creative item.

The current item must still exist and occupy the same equipment slot as the
pinned original item. Current CombatModifiers are deliberately ignored.

Args:
    creative_item_id (string): Current DungeonMMO inventory item ID.

Returns:
    (any?, string?): Source link record or explicit unsupported reason.
]]
function C4CreativeItemSourceMap.resolve(
    creative_item_id: string
): (any?, string?)
    if type(creative_item_id) ~= "string" then
        return nil, "InvalidCreativeItemId"
    end

    local source_item_id = LINKS[creative_item_id]
    if not source_item_id then
        return nil, "CreativeItemNotReviewedForC4"
    end

    local current = ItemDefinitions.get(creative_item_id)
    if not current or current.Kind ~= "Equipment" then
        return nil, "CreativeEquipmentDefinitionMissing"
    end

    local source = C4SourceItemReference.get(source_item_id)
    if not source then
        return nil, "OriginalSourceItemMissing"
    end

    local expected_slot = SLOT_MAP[current.Slot]
    if not expected_slot or source.Slot ~= expected_slot then
        return nil, "CreativeAndOriginalSlotMismatch"
    end

    local source_legs_item_id = BODY_LEGS[creative_item_id]
    local source_legs = nil

    if current.Slot == "Body" then
        if not source_legs_item_id then
            return nil, "CreativeBodySourceLegsMissing"
        end

        source_legs = C4SourceItemReference.get(source_legs_item_id)
        if not source_legs
            or source_legs.Slot ~= "Legs"
            or source_legs.Kind ~= source.Kind
            or source_legs.Grade ~= source.Grade
        then
            return nil, "CreativeBodySourceSetMismatch"
        end
    elseif source_legs_item_id then
        return nil, "CreativeBodySourceSetMismatch"
    end

    return {
        CreativeItemId = creative_item_id,
        CreativeSlot = current.Slot,
        CreativeCategory = current.Category,
        SourceItemId = source_item_id,
        SourceSlot = source.Slot,
        SourceKind = source.Kind,
        SourceLegsItemId = source_legs_item_id,
        SourceLegsKind = if source_legs
            then source_legs.Kind
            else nil,
        CompleteSourceArmorSet = current.Slot ~= "Body"
            or source_legs ~= nil,
        SourceOnly = true,
        CurrentCombatModifiersIgnored = true,
        LiveIntegrated = false,
    }, nil
end

--[[
Converts a reviewed six-slot loadout to its full C4 source paperdoll.

Empty slots are allowed. Any equipped current item without an explicit reviewed
link fails the whole conversion so mixed custom/source equipment cannot leak
into an alleged C4 stat snapshot.

Args:
    equipment (any): Server-owned current Equipment table.

Returns:
    (any?, string?): Source item IDs by slot, or strict denial reason.
]]
function C4CreativeItemSourceMap.resolve_loadout(
    equipment: any
): (any?, string?)
    if type(equipment) ~= "table" then
        return nil, "InvalidCreativeEquipmentLoadout"
    end

    local result = {}

    for _, slot in ipairs(CORE_SLOTS) do
        local creative_item_id = equipment[slot]

        if creative_item_id ~= nil then
            if type(creative_item_id) ~= "string" then
                return nil, "InvalidCreativeEquipmentLoadout"
            end

            local link, reason =
                C4CreativeItemSourceMap.resolve(creative_item_id)

            if not link then
                return nil, reason
            end

            result[link.SourceSlot] = link.SourceItemId

            if link.SourceLegsItemId then
                result.Legs = link.SourceLegsItemId
            end
        end
    end

    local resolved, reason = C4SourceItemReference.resolve(result)
    if not resolved then
        return nil, reason
    end

    return {
        SourceItemIds = result,
        SourceKinds = resolved.Kinds,
        SourceCommit = resolved.SourceCommit,
        SourceOnly = true,
        CompleteReviewedLoadout = true,
        OriginalBodyLegSemanticsIntegrated = true,
        LiveIntegrated = false,
    }, nil
end

--[[
Lists all reviewed creative-to-source equipment links.

Args:
    None.

Returns:
    any: Detached link rows for audit and tests.
]]
function C4CreativeItemSourceMap.all(): any
    local result = {}

    for creative_item_id, source_item_id in pairs(LINKS) do
        table.insert(result, {
            CreativeItemId = creative_item_id,
            SourceItemId = source_item_id,
            SourceLegsItemId = BODY_LEGS[creative_item_id],
        })
    end

    table.sort(result, function(left, right)
        return left.CreativeItemId < right.CreativeItemId
    end)

    return result
end

return table.freeze(C4CreativeItemSourceMap)
