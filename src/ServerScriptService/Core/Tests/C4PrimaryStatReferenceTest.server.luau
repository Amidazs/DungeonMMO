--!strict
-- Exact C4 source contract. Passing still does NOT migrate live combat.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Source = require(Shared.C4PrimaryStatReference)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Profile = require(Shared.ProfileSchema)

local checks = 0
local EPSILON = 0.00001

--[[
Asserts one independently evaluated source or formula contract.

Args:
    valid (boolean): Expected source result.
    label (string): Failure diagnosis.

Returns:
    nil: Counts one source-only assertion.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Primary Stats] " .. label)
end

--[[
Compares floating source results without hiding formula differences.

Args:
    actual (number): Calculated raw C4 resource value.
    expected (number): Independently precomputed source vector.
    label (string): Exact vector being checked.

Returns:
    nil: Passes only inside a narrow floating arithmetic tolerance.
]]
local function check_close(
    actual: number, expected: number, label: string
)
    check(math.abs(actual - expected) <= EPSILON, label)
end

--[[
Checks one source path's six primary stats and exact template identity.

Args:
    race_id (string): Human or Elf.
    class_id (string): DungeonMMO identity mapped to the C4 class.
    source_id (number): Original C4 class template ID.
    base_level (number): Original class template base level.
    expected (any): Six original primary values.

Returns:
    nil: Verifies source template and caller isolation.
]]
local function check_template(
    race_id: string, class_id: string,
    source_id: number, base_level: number, expected: any
)
    local reference = assert(Source.get(race_id, class_id))
    check(reference.Template.SourceClassId == source_id
        and reference.Template.ClassBaseLevel == base_level,
        race_id .. "/" .. class_id .. " source class identity")
    for _, key in ipairs({
        "STR", "DEX", "CON", "INT", "WIT", "MEN",
    }) do
        check(reference.Stats[key] == expected[key],
            race_id .. "/" .. class_id .. " preserves " .. key)
    end
    reference.Template.HpBase = -100
    check(assert(Source.get(race_id, class_id)).Template.HpBase > 0,
        "Source template copy cannot mutate immutable history")
end

--[[
Validates all four starters and five current original first transfers.

Args:
    None.

Returns:
    nil: Nine exact C4 templates retain their class-specific identities.
]]
local function check_all_templates()
    local human = {
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
    }
    local human_mage = {
        STR = 22, DEX = 21, CON = 27,
        INT = 41, WIT = 20, MEN = 39,
    }
    local elf = {
        STR = 36, DEX = 35, CON = 36,
        INT = 23, WIT = 14, MEN = 26,
    }
    local elf_mage = {
        STR = 21, DEX = 24, CON = 25,
        INT = 37, WIT = 23, MEN = 40,
    }
    check_template("Human", "Fighter", 0, 1, human)
    check_template("Human", "Mage", 10, 1, human_mage)
    check_template("Elf", "Fighter", 18, 1, elf)
    check_template("Elf", "Mage", 25, 1, elf_mage)
    check_template("Human", "Ironvow", 1, 20, human)
    check_template("Human", "Oathguard", 4, 20, human)
    check_template("Human", "Ashenblade", 7, 20, human)
    check_template("Elf", "GreenwardWarden", 19, 20, elf)
    check_template("Elf", "GreenwardScout", 22, 20, elf)
end

--[[
Checks independently precomputed exact C4 HP/MP/CP formula vectors.

Args:
    race_id (string): Historical race.
    class_id (string): Exact class template path.
    level (number): Valid level for that C4 template.
    expected (any): Raw and integer resource outputs.

Returns:
    nil: Verifies source growth plus CON/MEN multiplication.
]]
local function check_vitals(
    race_id: string, class_id: string,
    level: number, expected: any
)
    local actual, reason = Source.get_level_vitals(
        race_id, class_id, level
    )
    check(actual ~= nil and reason == nil,
        race_id .. "/" .. class_id .. " has verified level vitals")
    check(actual.MaxHP == expected.HP
        and actual.MaxMP == expected.MP
        and actual.MaxCP == expected.CP,
        race_id .. "/" .. class_id .. " integer C4 vitals")
    check_close(actual.RawMaxHP, expected.RawHP,
        race_id .. "/" .. class_id .. " raw HP")
    check_close(actual.RawMaxMP, expected.RawMP,
        race_id .. "/" .. class_id .. " raw MP")
    check_close(actual.RawMaxCP, expected.RawCP,
        race_id .. "/" .. class_id .. " raw CP")
end

--[[
Exercises starter and transfer growth at representative launch levels.

Args:
    None.

Returns:
    nil: Covers each distinct C4 class-growth template through level 30.
]]
local function check_growth_vectors()
    check_vitals("Human", "Fighter", 1, {
        HP = 126, MP = 38, CP = 50,
        RawHP = 126.4, RawMP = 38.4, RawCP = 50.56,
    })
    check_vitals("Human", "Fighter", 30, {
        HP = 922, MP = 319, CP = 418,
        RawHP = 922.7516, RawMP = 319.0272,
        RawCP = 418.4946,
    })
    check_vitals("Human", "Mage", 30, {
        HP = 699, MP = 466, CP = 366,
        RawHP = 699.2104, RawMP = 466.0816,
        RawCP = 366.0888,
    })
    check_vitals("Elf", "Fighter", 30, {
        HP = 792, MP = 324, CP = 353,
        RawHP = 792.8448, RawMP = 324.012,
        RawCP = 353.664,
    })
    check_vitals("Elf", "Mage", 30, {
        HP = 666, MP = 469, CP = 348,
        RawHP = 666.3264, RawMP = 469.2308,
        RawCP = 348.8058,
    })
    check_vitals("Human", "Ironvow", 30, {
        HP = 1070, MP = 320, CP = 849,
        RawHP = 1070.213, RawMP = 320.896,
        RawCP = 849.566,
    })
    check_vitals("Human", "Oathguard", 30, {
        HP = 1018, MP = 320, CP = 610,
        RawHP = 1018.073, RawMP = 320.896,
        RawCP = 610.67,
    })
    check_vitals("Human", "Ashenblade", 30, {
        HP = 983, MP = 320, CP = 399,
        RawHP = 983.313, RawMP = 320.896,
        RawCP = 399.582,
    })
    check_vitals("Elf", "GreenwardWarden", 30, {
        HP = 902, MP = 325, CP = 453,
        RawHP = 902.848, RawMP = 325.91,
        RawCP = 453.888,
    })
    check_vitals("Elf", "GreenwardScout", 30, {
        HP = 874, MP = 325, CP = 354,
        RawHP = 874.688, RawMP = 325.91,
        RawCP = 354.944,
    })
end

--[[
Checks exact growth remains source-only and unsupported identities fail.

Args:
    None.

Returns:
    nil: No legacy or forged class gains a historical template.
]]
local function check_scope_boundaries()
    local coverage = Source.coverage()
    check(coverage.PathCount == 9
        and coverage.VerifiedPrimaryStatTemplates == 9
        and coverage.VerifiedLevelGrowthTemplates == 9
        and coverage.VerifiedLevelCap == 30
        and not coverage.LiveCombatIntegrated,
        "Nine exact templates do not imply live combat migration")
    check(Source.get("Human", "Ranger") == nil
        and Source.get("Elf", "Rogue") == nil
        and Source.get("Elf", "Oathguard") == nil,
        "Legacy/cross-race labels cannot masquerade as C4 classes")
    check(select(1, Source.get_level_vitals(
        "Human", "Ironvow", 19
    )) == nil, "First-transfer template cannot extrapolate below level20")
    check(select(1, Source.get_level_vitals(
        "Human", "Fighter", 31
    )) == nil, "Initial source migration remains capped through level30")

    local character = Profile.create_default(920001).Characters.Slot1
    character.Identity = {
        Version = 1, RaceId = "Elf", BaseClassId = "Fighter",
        ClassId = "GreenwardWarden", CreationStage = "Complete",
    }
    check(Source.for_character(character) == nil,
        "Copied Warden label cannot access first-transfer source template")
    character.Identity.ClassId = "Fighter"
    check(Source.for_character(character) ~= nil,
        "Genuine starter can resolve exact C4 source template")

    for _, career in ipairs(Careers.all()) do
        local reference = assert(Source.get(career.RaceId, career.Id))
        check(reference.Template.ClassBaseLevel == 20,
            "Every currently authored first transfer uses C4 level20 base")
    end
end

--[[
Runs the exact C4 nine-template source regression.

Args:
    None.

Returns:
    nil: Prints source coverage without claiming live-stat integration.
]]
local function main()
    check_all_templates()
    check_growth_vectors()
    check_scope_boundaries()
    print(("[C4 Primary Stats] EXACT_SOURCE_PASS: %d assertions, "
        .. "9 templates, 9 growth curves through level 30, live=false")
        :format(checks))
end

main()
