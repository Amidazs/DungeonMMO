--!strict
-- Source-only contract: a passing test does NOT migrate live combat stats.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Source = require(Shared.C4PrimaryStatReference)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Profile = require(Shared.ProfileSchema)
local checks = 0

--[[
Asserts one independently evaluated historical source reference rule.

Args:
    valid (boolean): Expected source result.
    label (string): Exact failure diagnosis.

Returns:
    nil: Counts successful coverage without claiming live stat parity.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Primary Stats] " .. label)
end

--[[
Checks all six values and that returned records cannot mutate sources.

Args:
    race_id (string): Historical starting race.
    class_id (string): Supported starter or first-transfer class.
    expected (any): Independently recorded six historical attributes.

Returns:
    nil: Each separate source number and copy-isolation is tested.
]]
local function check_values(
    race_id: string, class_id: string, expected: any
)
    local reference = assert(Source.get(race_id, class_id))
    for _, key in ipairs({
        "STR", "DEX", "CON", "INT", "WIT", "MEN",
    }) do
        check(reference.Stats[key] == expected[key],
            race_id .. "/" .. class_id .. " must preserve " .. key)
    end
    reference.Stats.CON = -999
    check(assert(Source.get(race_id, class_id)).Stats.CON
        == expected.CON, "Source reference must be immutable by caller")
end

--[[
Validates historical starter and all five first-transfer stat baselines.

Args:
    None.

Returns:
    nil: Every original class path has correct six-stat source values.
]]
local function check_all_classes()
    local expected = {
        Human = {
            Fighter = {
                STR = 40, DEX = 30, CON = 43,
                INT = 21, WIT = 11, MEN = 25,
            },
            Mage = {
                STR = 22, DEX = 21, CON = 27,
                INT = 41, WIT = 20, MEN = 39,
            },
        },
        Elf = {
            Fighter = {
                STR = 36, DEX = 35, CON = 36,
                INT = 23, WIT = 14, MEN = 26,
            },
            Mage = {
                STR = 21, DEX = 24, CON = 25,
                INT = 37, WIT = 23, MEN = 40,
            },
        },
    }
    for race_id, starters in pairs(expected) do
        for class_id, stats in pairs(starters) do
            check_values(race_id, class_id, stats)
        end
    end
    for _, career in ipairs(Careers.all()) do
        check_values(
            career.RaceId, career.Id,
            expected[career.RaceId][career.BaseClassId]
        )
    end
end

--[[
Checks rejected legacy, forged class and unsourced level-growth paths.

Args:
    None.

Returns:
    nil: Unknown levels and copied advancement cannot mint source stats.
]]
local function check_fail_closed()
    local coverage = Source.coverage()
    check(coverage.PathCount == 9
        and coverage.VerifiedPrimaryStatBaselines == 4
        and coverage.VerifiedLevelGrowthTables == 0
        and not coverage.LiveCombatIntegrated,
        "Nine paths do not imply verified HP/MP/CP or live C4 migration")
    for _, path in ipairs(coverage.Paths) do
        local vitals, reason = Source.get_level_vitals(
            path.RaceId, path.ClassId, 30
        )
        check(vitals == nil
            and reason == "C4ClassLevelHpMpCpSourceUnverified",
            "Each C4 career must fail closed on unverified level growth")
    end
    check(Source.get("Human", "Ranger") == nil
        and Source.get("Elf", "Rogue") == nil
        and Source.get("Elf", "Oathguard") == nil,
        "Legacy identities and cross-race class labels are not C4")
    local character = Profile.create_default(920001).Characters.Slot1
    character.Identity = {
        Version = 1, RaceId = "Elf", BaseClassId = "Fighter",
        ClassId = "GreenwardWarden", CreationStage = "Complete",
    }
    check(Source.for_character(character) == nil,
        "Copied Warden class label needs original source award")
    character.Identity.ClassId = "Fighter"
    check(Source.for_character(character) ~= nil,
        "Genuine starter Fighter can read its source stat baseline")
    check(select(1, Source.get_level_vitals("Human", "Fighter", 0))
        == nil, "Invalid level never silently returns a stat")
end

--[[
Runs current original-class source-value coverage in unpublished Studio.

Args:
    None.

Returns:
    nil: Prints success only for verified baselines, never live C4 HP.
]]
local function main()
    check_all_classes()
    check_fail_closed()
    print(("[C4 Primary Stats] SOURCE_ONLY_PASS: %d assertions, "
        .. "9 paths, 4 baselines, 0 verified HP/MP/CP curves")
        :format(checks))
end

main()
