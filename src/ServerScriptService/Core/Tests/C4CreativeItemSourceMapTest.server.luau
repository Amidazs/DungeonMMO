--!strict
-- Reviewed current-item to pinned C4 source-item mapping regression.

local Shared = game:GetService("ReplicatedStorage").Core.Shared

local ItemMap = require(Shared.C4CreativeItemSourceMap)

local checks = 0

--[[
Counts one current-to-source equipment mapping assertion.

Args:
    valid (boolean): Expected reviewed mapping or denial condition.
    label (string): Diagnostic text for a failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Creative Item Map] " .. label)
end

--[[
Checks all nine reviewed creative equipment links.

Args:
    None.

Returns:
    nil: Confirms exact source IDs without accepting current custom modifiers.
]]
local function check_reviewed_links()
    local expected = {
        marauder_sword = 1,
        greenward_training_mace = 4,
        apprentice_arcane_wand = 6,
        scout_dagger = 10,
        apprentice_longbow = 13,
        scout_leather_vest = 22,
        marauder_armor = 25,
        apprentice_mystic_robe = 425,
        marauder_shield = 102,
    }

    local rows = ItemMap.all()
    check(#rows == 9, "exactly nine creative items are reviewed")

    for creative_item_id, source_item_id in pairs(expected) do
        local link, reason = ItemMap.resolve(creative_item_id)

        check(
            link ~= nil and reason == nil,
            creative_item_id .. " has a reviewed source link"
        )
        check(
            link.SourceItemId == source_item_id
                and link.SourceOnly
                and link.CurrentCombatModifiersIgnored
                and not link.LiveIntegrated,
            creative_item_id .. " keeps source stats separate from custom stats"
        )
    end
end

--[[
Checks full reviewed loadout conversion and explicit unsupported gear denial.

Args:
    None.

Returns:
    nil: Prevents mixed current custom gear from entering source stat math.
]]
local function check_loadout_boundary()
    local loadout, reason = ItemMap.resolve_loadout({
        Weapon = "marauder_sword",
        Body = "marauder_armor",
        OffHand = "marauder_shield",
    })

    check(
        loadout ~= nil and reason == nil,
        "reviewed sword heavy shield loadout converts"
    )
    check(
        loadout.SourceItemIds.Weapon == 1
            and loadout.SourceItemIds.Body == 25
            and loadout.SourceItemIds.OffHand == 102
            and loadout.CompleteReviewedLoadout
            and not loadout.LiveIntegrated,
        "reviewed loadout resolves exact source item IDs"
    )

    local _, polearm_reason = ItemMap.resolve_loadout({
        Weapon = "ironroot_training_halberd",
    })
    check(
        polearm_reason == "CreativeItemNotReviewedForC4",
        "unreviewed current polearm fails closed"
    )

    local _, d_grade_reason = ItemMap.resolve_loadout({
        Body = "stonewatch_d_grade_armor",
    })
    check(
        d_grade_reason == "CreativeItemNotReviewedForC4",
        "unreviewed D-grade body item fails closed"
    )

    local empty, empty_reason = ItemMap.resolve_loadout({})
    check(
        empty ~= nil
            and empty_reason == nil
            and empty.CompleteReviewedLoadout,
        "empty equipment remains a valid naked source loadout"
    )
end

--[[
Runs the source-only creative equipment mapping regression.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_reviewed_links()
    check_loadout_boundary()

    print((
        "[C4 Creative Item Map] SOURCE_ONLY_PASS: %d assertions "
        .. "reviewed_items=9 live=false"
    ):format(checks))
end

main()
