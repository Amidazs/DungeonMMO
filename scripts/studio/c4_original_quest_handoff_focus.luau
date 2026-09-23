--!strict
-- Disposable Studio verification of two separate source/destination caches.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original quest handoff test requires an unpublished local Base")

local source = game:GetService("ServerScriptService")
    .Core.Tests:WaitForChild("C4OriginalQuestHandoffTest")

--[[
Executes the real coordinator/shared-store source handoff contract fixture.

Args:
    None.

Returns:
    nil: Asserts the completed test instead of inferring a network teleport.
]]
local function main()
    assert(source:IsA("LuaSourceContainer"),
        "Focused source quest handoff test is missing")
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_C4OriginalQuestHandoffTest"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = source.Parent
    local ok, result = pcall(require, fixture)
    fixture:Destroy()
    assert(ok and result == true,
        "Source quest profile handoff regression: " .. tostring(result))
    print("[C4 Quest Handoff Focus] PASS 1/1")
end

main()
