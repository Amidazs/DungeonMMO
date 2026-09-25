--!strict
-- Disposable unpublished focused runner for C4 v2.55-v2.67 resource work.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "C4 v2.55-v2.67 focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests
local combat = ServerScriptService:FindFirstChild("Combat")
local combat_tests = if combat
    then combat:FindFirstChild("Tests")
    else nil

local fixtures = {
    {
        Parent = core_tests,
        Name = "C4SkillRuntimeRulesTest",
    },
    {
        Parent = core_tests,
        Name = "C4NineClassAuthenticatedSkillPreviewTest",
    },
    {
        Parent = core_tests,
        Name = "C4ResourceMigrationBoundaryTest",
    },
    {
        Parent = core_tests,
        Name = "C4CreativeItemSourceMapTest",
    },
    {
        Parent = core_tests,
        Name = "C4LaunchCoreGearSourceTest",
    },
    {
        Parent = core_tests,
        Name = "C4SixSlotPaperdollSourceTest",
    },
    {
        Parent = core_tests,
        Name = "C4OwnedPassiveSourceResolverTest",
    },
    {
        Parent = core_tests,
        Name = "C4CombinedStatEffectReferenceTest",
    },
    {
        Parent = core_tests,
        Name = "C4ActiveSourceEffectStateTest",
    },
    {
        Parent = core_tests,
        Name = "C4PersistentActiveCoverageTest",
    },
    {
        Parent = core_tests,
        Name = "C4CombatPointRuntimeTest",
    },
    {
        Parent = core_tests,
        Name = "C4ResourceRegenSourceTest",
    },
    {
        Parent = core_tests,
        Name = "C4ResourceCutoverServiceTest",
    },
}

if combat_tests then
    table.insert(fixtures, 2, {
        Parent = combat_tests,
        Name = "ManaServiceTest",
    })
end

local function run_test(fixture: any): boolean
    local source = assert(
        fixture.Parent:FindFirstChild(fixture.Name),
        "Missing focused test: " .. fixture.Name
    )
    local module = Instance.new("ModuleScript")
    module.Name = "TEMP_" .. fixture.Name
    module.Source = source.Source .. "\nreturn true\n"
    module.Parent = fixture.Parent

    local ok, result = pcall(require, module)
    module:Destroy()

    if not ok or result ~= true then
        warn(
            "[C4 v2.55-v2.67 Focus] FAIL "
                .. fixture.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[C4 v2.55-v2.67 Focus] PASS " .. fixture.Name)
    return true
end

local function main()
    local passed = 0

    for _, fixture in ipairs(fixtures) do
        if run_test(fixture) then
            passed += 1
        end
    end

    local environment = if combat_tests then "Dungeon" else "Base"

    print((
        "[C4 v2.55-v2.67 Focus] RESULT "
            .. "environment=%s passed=%d total=%d"
    ):format(environment, passed, #fixtures))

    assert(
        passed == #fixtures,
        "One or more C4 v2.55-v2.67 focused regressions failed"
    )
end

main()
