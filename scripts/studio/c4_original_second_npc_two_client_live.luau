--!strict
-- Real physical Neti and Guard Moretti second-stage quest playtest.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original C4 Neti/Moretti test must be an unpublished local Base")
require(game:GetService("ServerScriptService")
    .Core.Tests.C4OriginalSecondNpcLiveDriver)
