--!strict
-- Nine original paths with pinned C4 item XML/SQL stat order.
-- Strictly read-only: no Roblox inventory, class unlock or live combat.
local Shared = game:GetService("ReplicatedStorage").Core.Shared
local Unified = require(Shared.C4UnifiedStatReference)
local Items = require(Shared.C4SourceItemReference)

local checks = 0

--[[
Counts an actual original item-stat or fail-closed equipment assertion.

Args:
    valid (boolean): Whether the independent expected source value holds.
    label (string): Diagnostic for a malformed item or formula.

Returns:
    nil: Adds one successful assertion or raises an explicit failure.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Original Item Stats] " .. label)
end

--[[
Verifies all nine class templates can use the same original gear rules.

Each gear choice contains source IDs, never a forged category string.
All source HP/MP/CP values remain distinct at original class level 30.

Args:
    None.

Returns:
    nil: Checks original vitals, source-only flags and complete gear.
]]
local function check_all_nine()
    local rows = {
        {"Human", "Fighter", 922, {Weapon = 1, Body = 22}},
        {"Human", "Mage", 699, {Weapon = 6, Body = 425}},
        {"Elf", "Fighter", 792, {Weapon = 1, Body = 22}},
        {"Elf", "Mage", 666, {Weapon = 6, Body = 425}},
        {"Human", "Ironvow", 1070, {Weapon = 4, Body = 25}},
        {"Human", "Oathguard", 1018,
            {Weapon = 1, Body = 25, OffHand = 102}},
        {"Human", "Ashenblade", 983, {Weapon = 10, Body = 22}},
        {"Elf", "GreenwardWarden", 902,
            {Weapon = 1, Body = 25, OffHand = 102}},
        {"Elf", "GreenwardScout", 874, {Weapon = 13, Body = 22}},
    }
    for _, row in ipairs(rows) do
        local snapshot, reason = Unified.get_with_source_items(
            row[1], row[2], 30, row[4], {}
        )
        check(snapshot ~= nil and reason == nil,
            row[2] .. " accepts actual pinned C4 item IDs")
        check(snapshot.Naked.MaxHP == row[3]
                and snapshot.EquippedStats.MAX_HP == row[3],
            row[2] .. " keeps its distinct historical HP curve")
        check(not snapshot.LiveCombatIntegrated
                and not snapshot.ExactFinalC4StatsCertified,
            row[2] .. " gear source is not falsely live-certified")
    end
end

--[[
Checks precise weapon 0x08 and paperdoll chest 0x10/0x20 ordering.

Args:
    None.

Returns:
    nil: Source weapon/class/armor orders and late robe MP are tested.
]]
local function check_stat_order()
    local fighter = assert(Unified.get_with_source_items(
        "Human", "Fighter", 30, {Weapon = 1, Body = 22}, {}
    ))
    local stats = fighter.EquippedStats
    local naked = fighter.Naked
    check(stats.PHYSICAL_ATTACK == math.floor(
        8 * naked.STRBonus * naked.LevelModifier
    ), "Source sword P.Atk is set BEFORE STR and level multipliers")
    check(stats.MAGICAL_ATTACK == math.floor(
        6 * naked.LevelModifier * naked.LevelModifier
            * naked.INTBonus * naked.INTBonus
    ), "Source sword M.Atk is set BEFORE INT and level multipliers")
    check(stats.PHYSICAL_DEFENCE == math.floor(
        (80 + 43 - 31) * naked.LevelModifier
    ), "Fighter chest deducts original 31 before level multiplier")
    check(stats.PHYSICAL_DEFENCE ~= naked.NakedPDef + 43,
        "Already-derived naked P.Def must never receive raw item add")
    check(stats.CRITICAL_RATE == math.floor(
        8 * naked.DEXBonus * 10
    ), "Original sword critical value precedes 0x09 DEX formula")
    local mage = assert(Unified.get_with_source_items(
        "Elf", "Mage", 30, {Weapon = 6, Body = 425}, {}
    ))
    check(mage.EquippedStats.PHYSICAL_DEFENCE == math.floor(
        (54 + 17 - 15) * mage.Naked.LevelModifier
    ), "Mystic chest uses original 15, not Fighter's 31 deduction")
    check(mage.EquippedStats.MAX_MP == mage.Naked.MaxMP + 19,
        "Original robe MP 0x60 add occurs after source stat stages")
    local bare = assert(Unified.get_with_source_items(
        "Elf", "Fighter", 30, {}, {}
    ))
    check(bare.EquippedStats.CRITICAL_RATE == 40,
        "Unarmed original character retains critical override")
end

--[[
Checks source-validated shield, mutually exclusive weapons and passives.

Args:
    None.

Returns:
    nil: Tests class/equipment restrictions without creative item tags.
]]
local function check_shield_and_passives()
    local knight = assert(Unified.get_with_source_items(
        "Human", "Oathguard", 30,
        {Weapon = 1, Body = 25, OffHand = 102},
        {{SkillId = 232, Rank = 1}}
    ))
    local untrained = assert(Unified.get_with_source_items(
        "Human", "Oathguard", 30,
        {Weapon = 1, Body = 25, OffHand = 102}, {}
    ))
    check(knight.EquippedStats.PHYSICAL_DEFENCE
            == untrained.EquippedStats.PHYSICAL_DEFENCE + 17.7,
        "Heavy Knight passive applies only after source chest P.Def")
    check(knight.EquippedStats.SHIELD_DEFENCE_POWER == 79
        and knight.EquippedStats.SHIELD_DEFENCE_RATE == 20
        and knight.EquippedStats.EVASION_RATE
            == knight.Naked.Evasion - 8,
        "Original shield values and evasion penalty remain distinct")
    local scout = assert(Unified.get_with_source_items(
        "Elf", "GreenwardScout", 30,
        {Weapon = 13, Body = 22}, {
            {SkillId = 208, Rank = 1}, {SkillId = 233, Rank = 1},
        }
    ))
    local scout_bare = assert(Unified.get_with_source_items(
        "Elf", "GreenwardScout", 30,
        {Weapon = 13, Body = 22}, {}
    ))
    check(scout.EquippedStats.PHYSICAL_ATTACK
            > scout_bare.EquippedStats.PHYSICAL_ATTACK
        and scout.EquippedStats.EVASION_RATE
            > scout_bare.EquippedStats.EVASION_RATE,
        "Scout Bow and Light passives apply to correct source gear")
end

--[[
Rejects unknown, incorrectly slotted or cross-class original items.

Args:
    None.

Returns:
    nil: Demonstrates no fictitious original item stat entitlement.
]]
local function check_rejected_loadouts()
    local cases = {
        {{Weapon = 999999}, "UnknownOriginalSourceItem"},
        {{Weapon = 102}, "OriginalItemWrongEquipmentSlot"},
        {{Body = 1}, "OriginalItemWrongEquipmentSlot"},
        {{Weapon = 13, OffHand = 102},
            "TwoHandedSourceWeaponCannotCarryShield"},
        {{Weapon = 1, Bonus = 22}, "InvalidOriginalItemLoadout"},
    }
    for _, case in ipairs(cases) do
        local _, reason = Unified.get_with_source_items(
            "Elf", "GreenwardScout", 30, case[1], {}
        )
        check(reason == case[2],
            "Original slot/source-ID failure must remain closed")
    end
    local _, foreign = Unified.get_with_source_items(
        "Human", "Oathguard", 30, {Weapon = 13},
        {{SkillId = 208, Rank = 1}}
    )
    check(foreign == "OriginalPassiveNotLearnableByClassOrLevel",
        "Human Knight cannot borrow an original Elven Scout mastery")
    local _, wrong_race = Unified.get_with_source_items(
        "Human", "GreenwardWarden", 30, {Weapon = 1}, {}
    )
    check(wrong_race == "UnreviewedClassOrSourceRanks",
        "Wrong-race class identity cannot acquire a source stat profile")
    check(Items.get(123456) == nil,
        "Unknown C4 item IDs never inherit a guessed stat record")
end

--[[
Runs focused item-and-class source stat checks without live migration.

Args:
    None.

Returns:
    nil: Emits an assertion count and explicit source-only status.
]]
local function main()
    check_all_nine()
    check_stat_order()
    check_shield_and_passives()
    check_rejected_loadouts()
    print(("[C4 Original Item Stats] SOURCE_ONLY_PASS: %d assertions "
        .. "nine_paths=9 live=false"):format(checks))
end

main()
