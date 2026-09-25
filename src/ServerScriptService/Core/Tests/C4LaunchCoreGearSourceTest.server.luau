--!strict
-- Exact pinned C4 source values for newly reviewed launch core equipment.

local Shared = game:GetService("ReplicatedStorage").Core.Shared

local SourceItems = require(Shared.C4SourceItemReference)

local checks = 0

--[[
Counts one exact source-item assertion.

Args:
    valid (boolean): Expected pinned C4 item value or loadout rule.
    label (string): Diagnostic description for a failed source check.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Launch Core Gear] " .. label)
end

--[[
Checks the additional original weapon source records.

Args:
    None.

Returns:
    nil: Confirms exact C4 weapon values and two-handed semantics.
]]
local function check_weapons()
    local trident = assert(SourceItems.get(291))
    check(
        trident.Kind == "Polearm"
            and trident.Grade == "D"
            and trident.PhysicalAttack == 40
            and trident.MagicalAttack == 10,
        "Trident source identity and attack values"
    )
    check(
        trident.PhysicalCriticalRate == 8
            and trident.Accuracy == -3
            and trident.AttackSpeed == 325
            and trident.TwoHanded,
        "Trident critical accuracy speed and two-hand rule"
    )

    local neti_bow = assert(SourceItems.get(1181))
    check(
        neti_bow.Kind == "Bow"
            and neti_bow.PhysicalAttack == 45
            and neti_bow.MagicalAttack == 5
            and neti_bow.AttackSpeed == 293
            and neti_bow.TwoHanded,
        "Neti bow exact source values"
    )

    local neti_dagger = assert(SourceItems.get(1182))
    check(
        neti_dagger.Kind == "Dagger"
            and neti_dagger.PhysicalAttack == 19
            and neti_dagger.MagicalAttack == 5
            and neti_dagger.AttackSpeed == 433,
        "Neti dagger exact source values"
    )
end

--[[
Checks exact pinned rnd_dam values for every reviewed source weapon.

Args:
    None.

Returns:
    nil: Confirms current creative weapon mappings have source variance data.
]]
local function check_random_damage()
    check(
        assert(SourceItems.get(1)).RandomDamage == 10
            and assert(SourceItems.get(4)).RandomDamage == 20
            and assert(SourceItems.get(6)).RandomDamage == 20,
        "starter sword blunt and wand random damage"
    )
    check(
        assert(SourceItems.get(10)).RandomDamage == 5
            and assert(SourceItems.get(13)).RandomDamage == 5,
        "starter dagger and bow random damage"
    )
    check(
        assert(SourceItems.get(291)).RandomDamage == 10,
        "Trident random damage"
    )
    check(
        assert(SourceItems.get(1181)).RandomDamage == 5
            and assert(SourceItems.get(1182)).RandomDamage == 5,
        "Neti bow and dagger random damage"
    )
end

--[[
Checks exact source shot counts and grades for reviewed launch weapons.

Args:
    None.

Returns:
    nil: Confirms source shot inventory requirements are pinned to weapon data.
]]
local function check_shot_requirements()
    check(
        assert(SourceItems.get(1)).Grade == "None"
            and assert(SourceItems.get(1)).SoulShotCount == 1
            and assert(SourceItems.get(1)).SpiritShotCount == 1
            and assert(SourceItems.get(4)).SoulShotCount == 1
            and assert(SourceItems.get(6)).SpiritShotCount == 1
            and assert(SourceItems.get(10)).SoulShotCount == 1
            and assert(SourceItems.get(13)).SpiritShotCount == 1,
        "starter source weapons use one no-grade shot"
    )
    check(
        assert(SourceItems.get(291)).Grade == "D"
            and assert(SourceItems.get(291)).SoulShotCount == 2
            and assert(SourceItems.get(291)).SpiritShotCount == 2,
        "Trident uses two D-grade shots"
    )
    check(
        assert(SourceItems.get(1181)).Grade == "None"
            and assert(SourceItems.get(1181)).SoulShotCount == 7
            and assert(SourceItems.get(1181)).SpiritShotCount == 2
            and assert(SourceItems.get(1182)).SoulShotCount == 2
            and assert(SourceItems.get(1182)).SpiritShotCount == 2,
        "Neti source weapons retain exact multi-shot requirements"
    )
end

--[[
Checks the additional original D-grade body source records.

Args:
    None.

Returns:
    nil: Confirms exact pinned physical-defence values.
]]
local function check_body_armour()
    local brigandine = assert(SourceItems.get(352))
    check(
        brigandine.Kind == "Heavy"
            and brigandine.Grade == "D"
            and brigandine.PhysicalDefence == 103,
        "Brigandine Tunic exact heavy source values"
    )

    local manticore = assert(SourceItems.get(395))
    check(
        manticore.Kind == "Light"
            and manticore.Grade == "D"
            and manticore.PhysicalDefence == 77,
        "Manticore Skin Shirt exact light source values"
    )
end

--[[
Checks source paperdoll rules remain strict for new two-handed gear.

Args:
    None.

Returns:
    nil: Confirms a shield cannot accompany the reviewed source polearm.
]]
local function check_loadout_rules()
    local resolved, reason = SourceItems.resolve({
        Weapon = 291,
        Body = 352,
    })
    check(
        resolved ~= nil
            and reason == nil
            and resolved.Kinds.Weapon == "Polearm"
            and resolved.Kinds.Body == "Heavy",
        "reviewed polearm and D-grade heavy body resolve together"
    )

    local _, shield_reason = SourceItems.resolve({
        Weapon = 291,
        OffHand = 102,
    })
    check(
        shield_reason == "TwoHandedSourceWeaponCannotCarryShield",
        "reviewed polearm cannot borrow an offhand shield"
    )
end

--[[
Runs exact source checks for the v2.58 launch-core expansion.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_weapons()
    check_random_damage()
    check_shot_requirements()
    check_body_armour()
    check_loadout_rules()

    print((
        "[C4 Launch Core Gear] SOURCE_ONLY_PASS: %d assertions "
        .. "new_source_items=5 live=false"
    ):format(checks))
end

main()
