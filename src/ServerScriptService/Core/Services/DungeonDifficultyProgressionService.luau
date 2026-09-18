--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local ProfileSchema = require(
    Shared:WaitForChild("ProfileSchema")
)
local DungeonDifficultyDefinitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local DungeonRuntimeContentReadiness = require(
    Shared:WaitForChild("DungeonRuntimeContentReadiness")
)

local DungeonDifficultyProgressionService = {}
DungeonDifficultyProgressionService.__index =
    DungeonDifficultyProgressionService

local function result(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end
local function progress_for_character(character: any): any?
    if type(character) ~= "table" then
        return nil
    end
    local progress = character.DungeonDifficultyProgress
    if type(progress) ~= "table"
        or type(progress.Dungeons) ~= "table"
    then
        return nil
    end
    return progress
end

local function completed_for(
    character: any,
    dungeon_id: string
): {[string]: boolean}
    local progress = progress_for_character(character)
    if not progress then
        return {}
    end

    local dungeon = progress.Dungeons[dungeon_id]
    if type(dungeon) ~= "table"
        or type(dungeon.Completed) ~= "table"
    then
        return {}
    end
    return dungeon.Completed
end
-- Creates the profile-backed difficulty progression authority.
function DungeonDifficultyProgressionService.new(
    profile_service: any,
    content_readiness: any?
): any
    assert(
        profile_service ~= nil,
        "DungeonDifficultyProgressionService requires ProfileService."
    )

    return setmetatable({
        _profiles = profile_service,
        _content_readiness =
            content_readiness or DungeonRuntimeContentReadiness,
    }, DungeonDifficultyProgressionService)
end

-- Returns whether one character has earned access to a logical difficulty.
function DungeonDifficultyProgressionService.is_unlocked_character(
    character: any,
    dungeon_id: string,
    difficulty_id: string
): boolean
    local difficulty = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not difficulty then
        return false
    end
    if difficulty.Order == 1 then
        return true
    end
    local previous_id =
        difficulty.RequiredPreviousDifficultyId
    if not previous_id then
        return false
    end

    local completed = completed_for(character, dungeon_id)
    return completed[previous_id] == true
end

-- Returns whether one loaded player has earned access to a difficulty.
function DungeonDifficultyProgressionService:is_unlocked(
    user_id: number,
    dungeon_id: string,
    difficulty_id: string
): boolean
    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return false
    end

    return DungeonDifficultyProgressionService
        .is_unlocked_character(
            character,
            dungeon_id,
            difficulty_id
        )
end
-- Validates logical unlock and runtime readiness for one player entry.
function DungeonDifficultyProgressionService:validate_entry(
    user_id: number,
    dungeon_id: string,
    difficulty_id: string
): any
    local default_id =
        DungeonDifficultyDefinitions.default_id(dungeon_id)
    if not default_id then
        return result(false, "UnknownDungeon")
    end

    local difficulty = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not difficulty then
        return result(false, "UnknownDifficulty")
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not DungeonDifficultyProgressionService
        .is_unlocked_character(
            character,
            dungeon_id,
            difficulty_id
        )
    then
        return result(false, "DifficultyLocked")
    end

    local readiness = self._content_readiness.analyze(
        dungeon_id,
        difficulty_id
    )
    if readiness.ok ~= true or readiness.Ready ~= true then
        return result(false, "DifficultyContentNotReady", {
            difficulty = difficulty,
            readiness = readiness,
        })
    end

    return result(true, nil, {
        difficulty = difficulty,
        readiness = readiness,
    })
end

local function clear_state_for(
    character: any,
    dungeon_id: string
): any
    local progress = character.DungeonDifficultyProgress
    local dungeon = progress.Dungeons[dungeon_id]
    if type(dungeon) ~= "table" then
        dungeon = {
            Completed = {},
            HighestClearedOrder = 0,
        }
        progress.Dungeons[dungeon_id] = dungeon
    end
    if type(dungeon.Completed) ~= "table" then
        dungeon.Completed = {}
    end
    if type(dungeon.HighestClearedOrder) ~= "number" then
        dungeon.HighestClearedOrder = 0
    end
    return dungeon
end

-- Records one successful depth clear exactly once.
function DungeonDifficultyProgressionService:record_clear(
    user_id: number,
    dungeon_id: string,
    difficulty_id: string
): any
    if not DungeonDifficultyDefinitions.default_id(dungeon_id) then
        return result(false, "UnknownDungeon")
    end

    local difficulty = DungeonDifficultyDefinitions.get(
        dungeon_id,
        difficulty_id
    )
    if not difficulty then
        return result(false, "UnknownDifficulty")
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if difficulty.Order > 1 then
        local previous_id =
            difficulty.RequiredPreviousDifficultyId
        local completed = completed_for(character, dungeon_id)

        if not previous_id
            or completed[previous_id] ~= true
        then
            return result(
                false,
                "PreviousDifficultyNotCleared"
            )
        end
    end

    local already_completed = false
    local mutated, mutate_error =
        self._profiles:mutate(user_id, function(profile: any)
            local selected_slot =
                profile.Account.SelectedCharacterSlot
            local slot_key =
                "Slot" .. tostring(selected_slot)
            local mutable_character =
                profile.Characters[slot_key]
            if not mutable_character then
                error("Selected character slot is missing")
            end

            local dungeon = clear_state_for(
                mutable_character,
                dungeon_id
            )
            if dungeon.Completed[difficulty_id] == true then
                already_completed = true
                return
            end

            dungeon.Completed[difficulty_id] = true
            dungeon.HighestClearedOrder = math.max(
                dungeon.HighestClearedOrder,
                difficulty.Order
            )
        end)

    if not mutated then
        return result(
            false,
            mutate_error or "ProfileMutationFailed"
        )
    end

    return result(true, nil, {
        already_completed = already_completed,
        completed_difficulty_id = difficulty_id,
        highest_cleared_order = difficulty.Order,
        unlocked_next_id =
            DungeonDifficultyDefinitions.next_id(
                dungeon_id,
                difficulty_id
            ),
    })
end

-- Returns a detached snapshot of the loaded player's difficulty progress.
function DungeonDifficultyProgressionService:get_snapshot(
    user_id: number
): any
    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    local progress = progress_for_character(character)
    if not progress then
        return result(false, "ProgressMissing")
    end

    return result(true, nil, {
        progress = ProfileSchema.deep_clone(progress),
    })
end

return table.freeze(
    DungeonDifficultyProgressionService
)
