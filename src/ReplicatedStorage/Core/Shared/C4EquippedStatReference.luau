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
Applies original chest P.Def and class-specific paperdoll deduction.

Args:
    stats (any): Fresh original naked-stat dictionary.
    naked (any): Source naked level and class multiplier data.
    body (any): Verified original chest armour XML record.
    is_mystic (boolean): Actual starter Mystic class identity.

Returns:
    nil: Replaces only the P.Def derived from the equipped chest.
]]
local function apply_chest(
    stats: any, naked: any, body: any, is_mystic: boolean
)
    -- The 0x10 item add comes before the 0x20 class formula.
    -- Never add gear to the already-rounded naked P.Def.
    local base = if is_mystic then 54 else 80
    local paperdoll_deduction = if is_mystic then 15 else 31
    stats.PHYSICAL_DEFENCE = math.floor(
        (base + body.PhysicalDefence - paperdoll_deduction)
            * naked.LevelModifier
    )
end

--[[
Stages verified original gear stats before separate passive operations.

Original Robe MP at 0x60 must be applied after skill/passive stages.
Unreviewed enchantments, multi-slot armour and spell effects are excluded.

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
    local offhand = resolved.Items.OffHand
    if weapon then apply_weapon(values, naked, weapon) end
    if body then apply_chest(values, naked, body, is_mystic) end
    if offhand then
        values.EVASION_RATE -= offhand.EvasionPenalty
        values.SHIELD_DEFENCE_POWER = offhand.ShieldDefencePower
        values.SHIELD_DEFENCE_RATE = offhand.ShieldDefenceRate
    end
    return {
        Stats = values,
        DeferredMaxMp = if body
            then body.MaxMpAfterModifiers or 0 else 0,
        SourceOnly = true, LiveCombatIntegrated = false,
    }
end

return table.freeze(C4EquippedStatReference)
