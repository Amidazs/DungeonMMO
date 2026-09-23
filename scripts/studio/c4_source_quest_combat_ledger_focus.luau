--!strict
-- Unpublished Dungeon combat test: physical model and damage subscriber.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original quest combat requires an unpublished local Dungeon")

local sss = game:GetService("ServerScriptService")
local fixtures = {
    {
        Folder = sss.Dungeon.Tests,
        Name = "C4QuestMonsterCombatLedgerTest",
    },
    {
        Folder = sss.Combat.Tests,
        Name = "ContributionDamageBridgeTest",
    },
}

--[[
Executes a source-controlled server fixture in the disposable Studio place.

Args:
    entry (any): Exact built ServerScriptService test folder and script.

Returns:
    boolean: True only when require completed its test without an error.
]]
local function run_test(entry: any): boolean
    local source = entry.Folder:FindFirstChild(entry.Name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[C4 Quest Combat Focus] MISSING " .. entry.Name)
        return false
    end
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. entry.Name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = entry.Folder
    local ok, value = pcall(require, fixture)
    fixture:Destroy()
    if not ok or value ~= true then
        warn("[C4 Quest Combat Focus] FAIL "
            .. entry.Name .. " " .. tostring(value))
        return false
    end
    print("[C4 Quest Combat Focus] PASS " .. entry.Name)
    return true
end

--[[
Verifies only the two affected server-only combat contracts.

Args:
    None.

Returns:
    nil: Asserts each actual test ran and reported a successful result.
]]
local function main()
    local passed = 0
    for _, fixture in ipairs(fixtures) do
        if run_test(fixture) then passed += 1 end
    end
    print(("[C4 Quest Combat Focus] RESULT passed=%d total=%d")
        :format(passed, #fixtures))
    assert(passed == #fixtures,
        "Original quest combat ledger or contribution regression failed")
end

main()
