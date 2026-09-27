--!strict
-- Focused unpublished-Studio check for spoiled corpse retention.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Dwarf corpse retention focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local tests = ServerScriptService.Dungeon.Tests

--[[
Executes the real Dungeon enemy-cleanup regression in a disposable module.

Args:
    None.

Returns:
    nil: Raises on cleanup/retention regressions.
]]
local function main()
    local source = assert(
        tests:FindFirstChild("DungeonEnemyCleanupTest"),
        "DungeonEnemyCleanupTest is missing from the Dungeon project"
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Dungeon cleanup fixture must contain Luau source"
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = "DungeonEnemyCleanupTest_DWARF_TEMP"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    assert(
        ok and result == true,
        "Dwarf corpse retention regression failed: " .. tostring(result)
    )

    print("VERIFIED_DWARF_CORPSE_RETENTION_PASS")
end

main()
