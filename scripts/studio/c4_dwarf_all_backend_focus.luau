--!strict
-- Combined unpublished-Studio acceptance for both Dwarf first transfers.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Dwarf backend focus requires an unpublished Studio place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local TEST_NAMES = table.freeze({
    "C4DwarfArtisanSourceAuditTest",
    "C4DwarfArtisanProgressionTest",
    "DwarfArtisanProfessionCapacityTest",
    "C4DwarfArtisanQuestRulesTest",
    "C4DwarfScavengerSourceAuditTest",
    "C4DwarfScavengerProgressionTest",
    "DwarfScavengerProfessionCapacityTest",
    "C4DwarfScavengerQuestRulesTest",
    "C4DwarfFirstTransferAwardTest",
    "C4DwarfSalvageConfigTest",
    "C4DwarfSalvageServiceTest",
    "C4SourceSalvageCastServiceTest",
    "C4DwarfSourceInheritanceTest",
    "C4FirstTransferBranchesTest",
    "C4CreativeSkillLinkAuditTest",
    "C4Level30SkillTreeSourceTest",
    "C4SkillEffectSourceTest",
    "C4PrimaryStatReferenceTest",
    "C4OwnedPassiveSourceResolverTest",
    "C4ActiveSourceEffectResolverTest",
    "C4UnifiedStatReferenceTest",
    "C4SourcePhysicalCastServiceTest",
    "C4SourceSelfEffectCastServiceTest",
    "C4SourceCompanionCastServiceTest",
    "C4SourceCastRuntimeCompositionTest",
})

--[[
Runs one repository test from a disposable ModuleScript copy.

Args:
    test_name (string): Exact Core.Tests child to execute.

Returns:
    nil: Raises when the test is unavailable or does not complete.
]]
local function run_test(test_name: string)
    local source = assert(
        tests:FindFirstChild(test_name),
        "Dwarf focused test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Dwarf focused fixture must contain Luau: " .. test_name
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = test_name .. "_DWARF_TEMP"
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
Runs the complete GitHub-prepared Dwarf backend acceptance package.

Args:
    None.

Returns:
    nil: Prints stable evidence only after every included suite passes.
]]
local function main()
    for _, test_name in ipairs(TEST_NAMES) do
        run_test(test_name)
    end

    print(
        ("[Dwarf Backend Focus] %d/%d PASS")
            :format(#TEST_NAMES, #TEST_NAMES)
    )
    print("VERIFIED_DWARF_BACKEND_FOCUS_PASS")
end

main()
