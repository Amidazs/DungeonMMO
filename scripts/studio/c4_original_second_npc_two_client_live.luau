--!strict
-- Real two-client Vela, Thorne and Captain Ashford NPC quest playtest.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source quest NPC test requires an unpublished local Base")
require(game:GetService("ServerScriptService")
    .Core.Tests.C4OriginalSecondNpcLiveDriver)
