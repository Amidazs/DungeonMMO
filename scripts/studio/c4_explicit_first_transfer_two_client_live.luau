--!strict
-- Small unpublished Studio entry point; real two-client driver is in GitHub.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original C4 two-client choice must run in unpublished Studio")
require(game:GetService("ServerScriptService")
    .Core.Tests.C4ChoiceTwoClientLiveDriver)
