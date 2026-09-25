--!strict
-- Exact C4 six-slot paperdoll and Expertise source regression.

local Shared = game:GetService("ReplicatedStorage").Core.Shared

local Expertise = require(Shared.C4EquipmentExpertiseRules)
local SourceItems = require(Shared.C4SourceItemReference)
local Stats = require(Shared.C4UnifiedStatReference)

local checks = 0

--[[
Counts one source paperdoll or Expertise assertion.

Args:
    valid (boolean): Expected exact source calculation or gate.
    label (string): Diagnostic description for a failed check.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Six-Slot Paperdoll] " .. label)
end

--[[
Checks exact head, gloves and feet source item records.

Args:
    None.

Returns:
    nil: Confirms reviewed P.Def values and D-grade metadata.
]]
local function check_source_items()
    local wooden_helmet = assert(SourceItems.get(43))
    local leather_helmet = assert(SourceItems.get(44))
    local low_boots = assert(SourceItems.get(38))
    local gloves = assert(SourceItems.get(49))
    local bracer = assert(SourceItems.get(51))
    local mithril_gloves = assert(SourceItems.get(61))
    local gauntlets = assert(SourceItems.get(63))

    check(
        wooden_helmet.Slot == "Head"
            and wooden_helmet.PhysicalDefence == 19
            and leather_helmet.PhysicalDefence == 23,
        "gradeless head source P.Def is exact"
    )
    check(
        low_boots.Slot == "Feet"
            and low_boots.PhysicalDefence == 15,
        "gradeless feet source P.Def is exact"
    )
    check(
        gloves.Slot == "Gloves"
            and gloves.PhysicalDefence == 13
            and bracer.PhysicalDefence == 17,
        "gradeless glove source P.Def is exact"
    )
    check(
        mithril_gloves.Grade == "D"
            and mithril_gloves.PhysicalDefence == 29
            and gauntlets.Grade == "D"
            and gauntlets.PhysicalDefence == 24,
        "D-grade glove source P.Def is exact"
    )
end

--[[
Checks original C4 paperdoll 0x10 adds and 0x20 deductions.

Args:
    None.

Returns:
    nil: Confirms six-slot current paperdoll P.Def source ordering.
]]
local function check_paperdoll_formula()
    local fighter = assert(Stats.get_with_source_items(
        "Human",
        "Fighter",
        30,
        {
            Head = 43,
            Body = 25,
            Gloves = 49,
            Feet = 38,
        },
        {}
    ))

    check(
        fighter.EquippedStats.PHYSICAL_DEFENCE == 155,
        "Fighter six-slot armour P.Def follows C4 source order"
    )
    check(
        fighter.CurrentSixSlotPaperdollIntegrated
            and not fighter.FullOriginalPaperdollIntegrated
            and not fighter.LiveCombatIntegrated,
        "current paperdoll is source-complete without claiming full C4 gear"
    )

    local mystic = assert(Stats.get_with_source_items(
        "Human",
        "Mage",
        30,
        {
            Head = 43,
            Body = 425,
            Gloves = 49,
            Feet = 38,
        },
        {}
    ))

    check(
        mystic.EquippedStats.PHYSICAL_DEFENCE == 90,
        "Mystic uses its separate C4 chest paperdoll deduction"
    )
    check(
        mystic.EquippedStats.MAX_MP == mystic.Naked.MaxMP + 19,
        "robe deferred MP remains after source passive stage"
    )
end

--[[
Checks exact C4 Expertise skill 239 grade thresholds used at launch.

Args:
    None.

Returns:
    nil: Confirms gradeless and D-grade acceptance around level 20.
]]
local function check_expertise()
    local gradeless, gradeless_reason = Expertise.validate(
        1,
        {Head = 43, Gloves = 49, Feet = 38}
    )
    check(
        gradeless ~= nil
            and gradeless_reason == nil
            and gradeless.SourceExpertiseSkillId == 239,
        "gradeless equipment is valid before first Expertise rank"
    )

    local _, early_reason = Expertise.validate(
        19,
        {Gloves = 61}
    )
    check(
        early_reason == "OriginalEquipmentGradeExpertiseRequired",
        "level 19 cannot use D-grade source equipment"
    )

    local d_grade, d_grade_reason = Expertise.validate(
        20,
        {Weapon = 291, Body = 352, Gloves = 61}
    )
    check(
        d_grade ~= nil
            and d_grade_reason == nil
            and d_grade.HighestRequiredGrade == "D"
            and d_grade.HighestRequiredLevel == 20,
        "level 20 gains the original D-grade Expertise boundary"
    )
end

--[[
Runs six-slot source paperdoll and equipment Expertise acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_source_items()
    check_paperdoll_formula()
    check_expertise()

    print((
        "[C4 Six-Slot Paperdoll] SOURCE_ONLY_PASS: %d assertions "
        .. "six_slots=true expertise239=true live=false"
    ):format(checks))
end

main()
