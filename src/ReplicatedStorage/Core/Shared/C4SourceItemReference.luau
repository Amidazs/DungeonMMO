--!strict
-- Pinned Chronicle 4 SOURCE items, not DungeonMMO item grants.
-- Source stats/classifications: C4 stats XML and weapon/armor SQL.
local C4SourceItemReference = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local SOURCE_ROOT = "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/" .. SOURCE_COMMIT
local SOURCE_DATA = SOURCE_ROOT .. "/L2jAdmins_Data/"
local ITEM_REFERENCES = table.freeze({
    -- SQL bodypart/weaponType and XML stat operations are both pinned.
    [1] = table.freeze({
        Id = 1, Slot = "Weapon", Kind = "Sword",
        PhysicalAttack = 8, MagicalAttack = 6,
        PhysicalCriticalRate = 8, Accuracy = 0, AttackSpeed = 379,
    }),
    [4] = table.freeze({
        Id = 4, Slot = "Weapon", Kind = "Blunt",
        PhysicalAttack = 8, MagicalAttack = 6,
        PhysicalCriticalRate = 4, Accuracy = 4, AttackSpeed = 379,
    }),
    [6] = table.freeze({
        Id = 6, Slot = "Weapon", Kind = "Blunt",
        PhysicalAttack = 5, MagicalAttack = 7,
        PhysicalCriticalRate = 4, Accuracy = 4, AttackSpeed = 379,
    }),
    [10] = table.freeze({
        Id = 10, Slot = "Weapon", Kind = "Dagger",
        PhysicalAttack = 5, MagicalAttack = 5,
        PhysicalCriticalRate = 12, Accuracy = -3, AttackSpeed = 433,
    }),
    [13] = table.freeze({
        Id = 13, Slot = "Weapon", Kind = "Bow",
        PhysicalAttack = 16, MagicalAttack = 6,
        PhysicalCriticalRate = 12, Accuracy = -3,
        AttackSpeed = 293, TwoHanded = true,
    }),
    [291] = table.freeze({
        Id = 291, Slot = "Weapon", Kind = "Polearm", Grade = "D",
        PhysicalAttack = 40, MagicalAttack = 10,
        PhysicalCriticalRate = 8, Accuracy = -3,
        AttackSpeed = 325, TwoHanded = true,
    }),
    [1181] = table.freeze({
        Id = 1181, Slot = "Weapon", Kind = "Bow",
        PhysicalAttack = 45, MagicalAttack = 5,
        PhysicalCriticalRate = 12, Accuracy = -3,
        AttackSpeed = 293, TwoHanded = true,
    }),
    [1182] = table.freeze({
        Id = 1182, Slot = "Weapon", Kind = "Dagger",
        PhysicalAttack = 19, MagicalAttack = 5,
        PhysicalCriticalRate = 12, Accuracy = -3,
        AttackSpeed = 433,
    }),
    [22] = table.freeze({
        Id = 22, Slot = "Body", Kind = "Light",
        PhysicalDefence = 43,
    }),
    [25] = table.freeze({
        Id = 25, Slot = "Body", Kind = "Heavy",
        PhysicalDefence = 62,
    }),
    [352] = table.freeze({
        Id = 352, Slot = "Body", Kind = "Heavy", Grade = "D",
        PhysicalDefence = 103,
    }),
    [395] = table.freeze({
        Id = 395, Slot = "Body", Kind = "Light", Grade = "D",
        PhysicalDefence = 77,
    }),
    [425] = table.freeze({
        Id = 425, Slot = "Body", Kind = "Robe",
        PhysicalDefence = 17, MaxMpAfterModifiers = 19,
    }),
    [102] = table.freeze({
        Id = 102, Slot = "OffHand", Kind = "Shield",
        EvasionPenalty = 8, ShieldDefencePower = 79,
        ShieldDefenceRate = 20,
    }),
})

--[[
Returns a pinned C4 item with its original stat and slot semantics.

Args:
    source_item_id (number): Historical SQL/XML item identifier.

Returns:
    any?: One immutable source item or nil for unreviewed gear.
]]
function C4SourceItemReference.get(source_item_id: number): any?
    return ITEM_REFERENCES[source_item_id]
end

--[[
Resolves only reviewed original item IDs in their verified paperdoll slots.

Args:
    item_ids (any): Optional Weapon, Body and OffHand source item IDs.

Returns:
    (any?, string?): Verified original kinds and records, or refusal.
]]
function C4SourceItemReference.resolve(
    item_ids: any
): (any?, string?)
    if type(item_ids) ~= "table" then
        return nil, "InvalidOriginalItemLoadout"
    end
    local allowed = {Weapon = true, Body = true, OffHand = true}
    local kinds = {}
    local items = {}
    for slot, item_id in pairs(item_ids) do
        if not allowed[slot] or type(item_id) ~= "number"
            or item_id % 1 ~= 0
        then return nil, "InvalidOriginalItemLoadout" end
        local item = ITEM_REFERENCES[item_id]
        if not item then return nil, "UnknownOriginalSourceItem" end
        if item.Slot ~= slot then
            return nil, "OriginalItemWrongEquipmentSlot"
        end
        kinds[slot] = item.Kind
        items[slot] = item
    end
    if items.Weapon and items.Weapon.TwoHanded and items.OffHand then
        return nil, "TwoHandedSourceWeaponCannotCarryShield"
    end
    return {
        Kinds = kinds, Items = items,
        SourceCommit = SOURCE_COMMIT,
        SourceOnly = true, LiveCombatIntegrated = false,
    }, nil
end

--[[
Lists immutable C4 source file URLs for the limited reviewed item set.

Args:
    None.

Returns:
    any: Source XML, classification SQL and precise pinned commit.
]]
function C4SourceItemReference.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        WeaponStats = SOURCE_DATA .. "data/xml/stats/weapon/",
        ArmorStats = SOURCE_DATA .. "data/xml/stats/armor/",
        WeaponTypes = SOURCE_DATA .. "sql/game/weapon.sql",
        ArmorTypes = SOURCE_DATA .. "sql/game/armor.sql",
    }
end

return table.freeze(C4SourceItemReference)
