--!strict
-- Focused, disposable unpublished first-transfer and profile migration proof.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original first-transfer tests require unpublished local Base Studio")

local tests = game:GetService("ServerScriptService").Core.Tests
local FILES = table.freeze({
    "OriginalFirstTransferServiceTest",
    "ProfileMigrationQuestAdvancementV8Test",
})

--[[
Runs one source-owned server regression as an isolated disposable module.

Args:
    file_name (string): Exact registered ServerScriptService test script.

Returns:
    boolean: True only when its complete suite executed without errors.
]]
local function run_one(file_name: string): boolean
    local source = tests:FindFirstChild(file_name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[Original First Transfer Focus] Missing " .. file_name)
        return false
    end
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. file_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests
    local ok, result = pcall(require, fixture)
    fixture:Destroy()
    if not ok or result ~= true then
        warn("[Original First Transfer Focus] FAIL "
            .. file_name .. ": " .. tostring(result))
        return false
    end
    print("[Original First Transfer Focus] PASS " .. file_name)
    return true
end

--[[
Runs only the new class award and adjacent saved-profile contract tests.

Args:
    None.

Returns:
    nil: Fails unless both actual server regressions have passed.
]]
local function main()
    local passed = 0
    for _, name in ipairs(FILES) do
        if run_one(name) then passed += 1 end
    end
    print(("[Original First Transfer Focus] RESULT %d/%d")
        :format(passed, #FILES))
    assert(passed == #FILES, "Original first-transfer focus failed")
end

main()
