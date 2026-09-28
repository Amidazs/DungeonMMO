--!strict
-- Focused unpublished-Studio acceptance for Dwarven Fighter / Gearwright.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Gearwright backend focus requires an unpublished Studio place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local TEST_NAMES = table.freeze({
    "C4DwarfArtisanSourceAuditTest",
    "C4DwarfArtisanProgressionTest",
    "DwarfArtisanProfessionCapacityTest",
    "C4DwarfArtisanQuestRulesTest",
    "C4DwarfFirstTransferAwardTest",
    "C4FirstTransferBranchesTest",
    "C4CreativeSkillLinkAuditTest",
    "C4OwnedPassiveSourceResolverTest",
    "C4DwarfSourceInheritanceTest",
    "C4UnifiedStatReferenceTest",
    "C4ActiveSourceEffectStateTest",
    "C4PrimaryStatReferenceTest",
    "C4SourcePhysicalCastServiceTest",
    "C4SourceSelfEffectCastServiceTest",
    "C4SourceCompanionCastServiceTest",
})

--[[
Runs one repository server test from a disposable ModuleScript copy.

Args:
    test_name (string): Exact ServerScriptService.Core.Tests child name.

Returns:
    nil: Raises if the source is missing or the required test fails.
]]
local function run_test(test_name: string)
    local source = assert(
        tests:FindFirstChild(test_name),
        "Gearwright focused test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Gearwright focused fixture must contain Luau: " .. test_name
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = test_name .. "_GEARWRIGHT_TEMP"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    assert(
        ok and result == true,
        test_name .. " failed: " .. tostring(result)
    )
end

--[[
Runs the complete focused Gearwright backend package.

Args:
    None.

Returns:
    nil: Prints a stable pass marker only after every suite succeeds.
]]
local function main()
    for _, test_name in ipairs(TEST_NAMES) do
        run_test(test_name)
    end

    print(
        ("[Gearwright Backend Focus] %d/%d PASS")
            :format(#TEST_NAMES, #TEST_NAMES)
    )
    print("VERIFIED_GEARWRIGHT_BACKEND_FOCUS_PASS")
end

main()
