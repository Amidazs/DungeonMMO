--!strict
-- Dedicated unpublished physical first-transfer test; source-quest
-- interaction stages have their own already accepted two-client fixtures.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original transfer playtest requires an unpublished local Base place")
workspace:SetAttribute("DungeonMMOStudioTransferFocus", true)
require(game:GetService("ServerScriptService")
    .Core.Tests.C4OriginalSecondNpcLiveDriver)
