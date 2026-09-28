--!strict
-- Contract coverage for the pre-Section-D friend-test tutorial surface.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local TestRelease = require(
    Shared.DungeonTestPlaceholderRelease
)
local TutorialDefinitions = require(
    Shared.TutorialDefinitions
)

local checks = 0

--[[
Counts one tutorial/friend-test contract assertion.

Args:
    condition (boolean): Expected contract invariant.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Friend Test Tutorial] " .. label
    )
end

--[[
Validates tutorial ordering, controls and exact TEST routing constants.

Args:
    None.

Returns:
    nil: Prints a stable pass marker when every assertion succeeds.
]]
local function main()
    local steps = TutorialDefinitions.BASE_STEPS

    check(#steps == 5, "Base tutorial has five concise steps")
    check(
        TutorialDefinitions.FIRST_ADVENTURE_ID
            == "WorldrootRelic",
        "tutorial begins with the first launch Adventure"
    )

    local expected_ids = {
        "Welcome",
        "WorldrootKeeper",
        "AcceptAdventure",
        "PartyAndPortal",
        "CombatAndHud",
    }

    for index, expected_id in ipairs(expected_ids) do
        local step = steps[index]

        check(
            step.Id == expected_id,
            "step " .. tostring(index) .. " keeps reviewed order"
        )
        check(
            type(step.Title) == "string"
                and step.Title ~= "",
            expected_id .. " has a title"
        )
        check(
            type(step.Text) == "string"
                and step.Text ~= "",
            expected_id .. " has readable guidance"
        )
        check(
            type(step.ButtonText) == "string"
                and step.ButtonText ~= "",
            expected_id .. " has a control label"
        )
    end

    local combat = steps[5].Text
    check(
        combat:find("LMB", 1, true) ~= nil
            and combat:find("RMB", 1, true) ~= nil,
        "combat tutorial explains attack and block"
    )
    check(
        combat:find("Left Shift", 1, true) ~= nil
            and combat:find("Left Ctrl", 1, true) ~= nil,
        "combat tutorial explains dodge and view lock"
    )
    check(
        steps[2].Text:find("shimmering", 1, true) ~= nil
            and steps[2].Text:find("arrows", 1, true) ~= nil,
        "quest tutorial explains the floor guidance"
    )
    check(
        steps[4].Text:find("shimmering", 1, true) ~= nil
            and steps[4].Text:find("Create Party", 1, true) ~= nil
            and steps[4].Text:find("Ready", 1, true) ~= nil,
        "party tutorial explains trail and two-player entry"
    )
    check(
        TutorialDefinitions.DUNGEON_TEXT:
            find("hidden mechanisms", 1, true) ~= nil,
        "Dungeon tutorial teaches players to inspect secrets"
    )

    check(
        TestRelease.test_universe_id() == 10765241947,
        "TEST universe ID is exact"
    )
    check(
        TestRelease.test_base_place_id() == 134132328219009,
        "TEST Base place ID is exact"
    )
    check(
        TestRelease.test_dungeon_place_id() == 117293035754309,
        "TEST Dungeon place ID is exact"
    )
    check(
        TestRelease.test_base_place_id()
            ~= TestRelease.test_dungeon_place_id(),
        "Base and Dungeon TEST places remain distinct"
    )

    print(
        ("[Friend Test Tutorial] PASS: %d assertions")
            :format(checks)
    )
end

main()
