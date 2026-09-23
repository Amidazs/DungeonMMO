--!strict
-- Actual first NPC world playtest; checked-in driver owns temporary hooks.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 original NPC client test must be unpublished")
require(game:GetService("ServerScriptService")
    .Core.Tests.C4OriginalQuestNpcLiveDriver)
