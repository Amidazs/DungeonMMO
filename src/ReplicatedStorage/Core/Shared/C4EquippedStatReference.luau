--!strict
-- Source-only item staging: C4 0x08 weapon sets, 0x10 armour adds,
-- then class formula at 0x20/0x30, before passive 0x30/0x40.
local C4EquippedStatReference = {}

--[[
Computes the original weapon base and class formula in source order.

Args:
    stats (any): Fresh original naked-stat dictionary.
    naked (any): Source-derived STR/INT/DEX and level modifiers.
    weapon (any): Verified source ID, slot and weapon XML values.

Returns:
    nil: Replaces only stats actually defined by this source weapon.
]]
local function apply_weapon(stats: any, naked: any, weapon: any)
    stats.PHYSICAL_ATTACK = math.floor(
        weapon.PhysicalAttack * naked.STRBonus * naked.LevelModifier
    )
    stats.MAGICAL_ATTACK = math.floor(
        weapon.MagicalAttack * naked.LevelModifier
            * naked.LevelModifier * naked.INTBonus * naked.INTBonus
    )
    stats.PHYSICAL_ATTACK_SPEED = math.floor(
        weapon.AttackSpeed * naked.DEXBonus + 0.5
    )
    -- FuncAtkCritical runs at 0x09, after the weapon's 0x08 set.
    stats.CRITICAL_RATE = math.floor(
        weapon.PhysicalCriticalRate * naked.DEXBonus * 10
    )
    stats.ACCURACY_COMBAT += weapon.Accuracy
end

--[[
Applies original C4 armour P.Def and paperdoll deductions in source order.

Every armour item's 0x10 P.Def add is summed before FuncPDefMod's 0x20
slot deductions and level multiplier. Creative one-slot body items may resolve
to a reviewed C4 chest+legs source set before this stage.

Args:
    stats (any): Fresh original naked-stat dictionary.
    naked (any): Source naked level and class multiplier data.
    items (any): Verified original source item records by paperdoll slot.
    is_mystic (boolean): Actual starter Mystic class identity.

Returns:
    nil: Replaces P.Def with the reviewed source paperdoll calculation.
]]
local function apply_armour(
    stats: any,
    naked: any,
    items: any,
    is_mystic: boolean
)
    local base = if is_mystic then 54 else 80
    local additive = 0
    local deduction = 0

    if items.Head then
        additive += items.Head.PhysicalDefence
        deduction += 12
    end

    if items.Body then
        additive += items.Body.PhysicalDefence
        deduction += if is_mystic then 15 else 31
    end

    if items.Legs then
        additive += items.Legs.PhysicalDefence
    end

    if items.Legs
        or (
            items.Body
            and items.Body.BodyPart == "FullArmor"
        )
    then
        deduction += if is_mystic then 8 else 18
    end

    if items.Gloves then
        additive += items.Gloves.PhysicalDefence
        deduction += 8
    end

    if items.Feet then
        additive += items.Feet.PhysicalDefence
        deduction += 7
    end

    stats.PHYSICAL_DEFENCE = math.floor(
        (base + additive - deduction) * naked.LevelModifier
    )
end

--[[
Stages verified original gear stats before separate passive operations.

Original magic armor MP at 0x60 must be applied after skill/passive stages.
Unreviewed enchantments and spell effects remain excluded.

Args:
    stats (any): Fresh source stat values, without passive modifiers.
    naked (any): Class-level original naked C4 derived stats.
    resolved (any): Only C4SourceItemReference-verified slot records.
    is_mystic (boolean): Whether the original class is a starter Mage.

Returns:
    any: Gear-staged values and deferred original 0x60 item operations.
]]
function C4EquippedStatReference.stage(
    stats: any, naked: any, resolved: any, is_mystic: boolean
): any
    local values = table.clone(stats)
    local weapon = resolved.Items.Weapon
    local body = resolved.Items.Body
    local legs = resolved.Items.Legs
    local offhand = resolved.Items.OffHand
    if weapon then apply_weapon(values, naked, weapon) end
    if resolved.Items.Head
        or body
        or legs
        or resolved.Items.Gloves
        or resolved.Items.Feet
    then
        apply_armour(values, naked, resolved.Items, is_mystic)
    end
    if offhand then
        values.EVASION_RATE -= offhand.EvasionPenalty
        values.SHIELD_DEFENCE_POWER = offhand.ShieldDefencePower
        values.SHIELD_DEFENCE_RATE = offhand.ShieldDefenceRate
    end
    return {
        Stats = values,
        DeferredMaxMp =
            (if body then body.MaxMpAfterModifiers or 0 else 0)
            + (if legs then legs.MaxMpAfterModifiers or 0 else 0),
        OriginalLegsSemanticsIntegrated = true,
        SourceOnly = true,
        LiveCombatIntegrated = false,
    }
end

return table.freeze(C4EquippedStatReference)
