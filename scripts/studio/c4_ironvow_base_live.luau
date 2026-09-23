--!strict
-- Dedicated genuine two-client physical Warrior quest/mentor/trainer test.
-- Earlier raid loot is prepared only in this unpublished test environment.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Ironvow physical Base playtest requires unpublished Studio")
workspace:SetAttribute("DungeonMMOStudioIronvowFocus", true)
require(game:GetService("ServerScriptService")
    .Core.Tests.C4OriginalSecondNpcLiveDriver)
