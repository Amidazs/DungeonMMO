--!strict
-- Exactly scoped published TEST placeholder opt-in. No attributes, user
-- input or teleport payload can turn this on in a different experience.
local Release = {}
local UNIVERSE_ID = 10765241947
local TEST_BASE_ID = 134132328219009
local TEST_DUNGEON_ID = 117293035754309

function Release.is_test_lobby(): boolean
    return game.GameId == UNIVERSE_ID and game.PlaceId == TEST_BASE_ID
end

function Release.is_test_dungeon(): boolean
    return game.GameId == UNIVERSE_ID and game.PlaceId == TEST_DUNGEON_ID
end

function Release.is_test_temple_context(): boolean
    return Release.is_test_lobby() or Release.is_test_dungeon()
end

function Release.treat_as_test_temple(dungeon_id: string): boolean
    return dungeon_id == "TestDungeon"
        and Release.is_test_temple_context()
end

return table.freeze(Release)
