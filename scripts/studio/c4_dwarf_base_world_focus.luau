--!strict
-- Focused unpublished-Studio acceptance for Dwarf Base world binding.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Dwarf Base world focus requires an unpublished Studio place"
)

local SSS = game:GetService("ServerScriptService")

local TESTS = table.freeze({
    table.freeze({
        Parent = SSS.Core.Tests,
        Name = "C4OriginalQuestNpcBindingTest",
    }),
    table.freeze({
        Parent = SSS.Core.Tests,
        Name = "C4FirstTransferMentorBindingTest",
    }),
    table.freeze({
        Parent = SSS.Base.Tests,
        Name = "BaseDwarfQuestHubContractTest",
    }),
})

--[[
Runs one repository test from a disposable ModuleScript copy.

Args:
    parent (Instance): Folder containing the source-controlled test.
    test_name (string): Exact child test name to execute.

Returns:
    nil: Raises when the test is unavailable or does not complete.
]]
local function run_test(parent: Instance, test_name: string)
    local source = assert(
        parent:FindFirstChild(test_name),
        "Dwarf Base world test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Dwarf Base world fixture must contain Luau: " .. test_name
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = test_name .. "_DWARF_BASE_TEMP"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = parent

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    assert(
        ok and result == true,
        test_name .. " failed: " .. tostring(result)
    )
end

--[[
Runs Dwarf quest-NPC, mentor/trainer and hub-anchor acceptance.

Args:
    None.

Returns:
    nil: Prints a stable marker only after every suite passes.
]]
local function main()
    for _, test in ipairs(TESTS) do
        run_test(test.Parent, test.Name)
    end

    print(
        ("[Dwarf Base World Focus] %d/%d PASS")
            :format(#TESTS, #TESTS)
    )
    print("VERIFIED_DWARF_BASE_WORLD_FOCUS_PASS")
end

main()
