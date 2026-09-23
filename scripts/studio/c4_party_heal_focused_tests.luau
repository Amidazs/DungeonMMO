--!strict
-- Local, unpublished Dungeon source-ranked party healing acceptance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 party-heal focused tests require an unpublished Studio place.")

local server = game:GetService("ServerScriptService")
local tests = {
    {server.Core.Tests, "C4PartyHealTrainingTest"},
    {server.Core.Tests, "C4BaseImplementationAuditTest"},
    {server.Core.Tests, "C4CatalogueCoverageTest"},
    {server.Core.Tests, "C4BaseSourceInventoryTest"},
    {server.Combat.Tests, "MageHealServiceTest"},
}
local passed = 0

--[[
Runs a genuine source-controlled server test as a disposable module.

Args:
    folder (Instance): The original test script's parent.
    name (string): Exact authored test name.

Returns:
    nil: Prints a pass or raises the original failure.
]]
local function run_test(folder: Instance, name: string)
    local fixture = assert(folder:FindFirstChild(name),
        "Missing C4 party heal fixture " .. name)
    local module = Instance.new("ModuleScript")
    module.Name = "TEMP_" .. name
    module.Source = fixture.Source .. "\nreturn true\n"
    module.Parent = server
    local ok, reason = pcall(require, module)
    module:Destroy()
    if not ok then
        warn("[C4 Party Heal Focus] FAIL " .. name .. " "
            .. tostring(reason))
        error(reason)
    end
    passed += 1
    print("[C4 Party Heal Focus] PASS " .. name)
end

--[[
Runs only party-healing sources and the existing Mage healing primitive.

Args:
    None.

Returns:
    nil: Fails the Studio run on any missing source-rank contract.
]]
local function main()
    for _, entry in ipairs(tests) do
        run_test(entry[1], entry[2])
    end
    print(("[C4 Party Heal Focus] RESULT passed=%d failed=0 total=%d")
        :format(passed, #tests))
end

main()
