--!strict
-- Focused unpublished-Studio acceptance for Dwarven Fighter / Deepclaimer.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Deepclaimer backend focus requires an unpublished Studio place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local TEST_NAMES = table.freeze({
    "C4DwarfScavengerSourceAuditTest",
    "C4DwarfScavengerProgressionTest",
    "DwarfScavengerProfessionCapacityTest",
    "C4DwarfScavengerQuestRulesTest",
    "C4DwarfFirstTransferAwardTest",
    "C4DwarfSalvageConfigTest",
    "C4DwarfSalvageServiceTest",
    "C4SourceSalvageCastServiceTest",
    "C4FirstTransferBranchesTest",
    "C4CreativeSkillLinkAuditTest",
    "C4Level30SkillTreeSourceTest",
    "C4SkillEffectSourceTest",
    "C4PrimaryStatReferenceTest",
    "C4Level30LaunchCoverageTest",
    "C4OwnedPassiveSourceResolverTest",
    "C4SourcePhysicalCastServiceTest",
    "C4SourceSelfEffectCastServiceTest",
    "C4SourceCastRuntimeCompositionTest",
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
        "Deepclaimer focused test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Deepclaimer fixture must contain Luau: " .. test_name
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = test_name .. "_DEEPCLAIMER_TEMP"
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
Runs the complete focused Deepclaimer backend package.

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
        ("[Deepclaimer Backend Focus] %d/%d PASS")
            :format(#TEST_NAMES, #TEST_NAMES)
    )
    print("VERIFIED_DEEPCLAIMER_BACKEND_FOCUS_PASS")
end

main()
