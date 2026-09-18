--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonDefinitions = require(
    Shared:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")
local DungeonInstanceDirector = require(
    Services:WaitForChild("DungeonInstanceDirector")
)

local StudioSessionFactory = {}

local function session_difficulty_id(
    session: any,
    dungeon_id: string,
    requested_difficulty_id: string?
): string?
    local session_difficulty = session
        and session.Difficulty
        and session.Difficulty.Id
    if type(session_difficulty) == "string" then
        return session_difficulty
    end

    if type(requested_difficulty_id) == "string" then
        return requested_difficulty_id
    end

    return DungeonDifficultyDefinitions.default_id(dungeon_id)
end

local function routing_data(
    session: any,
    difficulty_id: string?
): any
    return {
        SessionId = session.SessionId,
        DungeonId = session.DungeonId,
        DifficultyId = difficulty_id,
    }
end

local function member_user_ids(players: {any}): {number}
    local result = {}
    for _, player in ipairs(players) do
        table.insert(result, player.UserId)
    end
    return result
end

local function reusable_session(
    players: {any},
    sessions: any,
    requested_difficulty_id: string?
): any?
    for _, player in ipairs(players) do
        local existing = sessions:get_for_user(player.UserId)
        if existing
            and (
                existing.State == "Creating"
                or existing.State == "Active"
            )
        then
            local difficulty_id = session_difficulty_id(
                existing,
                existing.DungeonId,
                requested_difficulty_id
            )
            return {
                ok = true,
                session = existing,
                teleport_data = routing_data(
                    existing,
                    difficulty_id
                ),
                reused = true,
            }
        end
    end
    return nil
end

-- Creates or reuses one authoritative Studio-only dungeon session.
function StudioSessionFactory.create_for_players(
    players: {any},
    sessions: any,
    dungeon_id: string?,
    difficulty_id: string?
): any
    if not RunService:IsStudio() then
        return {
            ok = false,
            reason = "StudioOnly",
        }
    end

    local definition = DungeonDefinitions.get(
        dungeon_id or DungeonDefinitions.TEST_DUNGEON.Id
    )
    if not definition then
        return {
            ok = false,
            reason = "UnknownDungeon",
        }
    end

    if #players < definition.MinPlayers
        or #players > definition.MaxPlayers
    then
        return {
            ok = false,
            reason = "PlayerCountOutOfRange",
        }
    end

    local reused = reusable_session(
        players,
        sessions,
        difficulty_id
    )
    if reused then
        return reused
    end

    local session, create_error = sessions:create(
        definition.Id,
        member_user_ids(players),
        0,
        "StudioReservedServer",
        difficulty_id
    )
    if not session then
        return {
            ok = false,
            reason = create_error,
        }
    end

    local selected_difficulty_id = session_difficulty_id(
        session,
        definition.Id,
        difficulty_id
    )
    local instance_state = DungeonInstanceDirector.resolve(
        definition.Id,
        session.SessionId,
        os.time(),
        DungeonInstanceDirector.runtime_options(),
        selected_difficulty_id
    )
    local state_result = sessions:set_instance_state(
        session.SessionId,
        instance_state
    )
    if state_result.ok ~= true then
        return {
            ok = false,
            reason = state_result.reason,
        }
    end

    session = state_result.session
    selected_difficulty_id = session_difficulty_id(
        session,
        definition.Id,
        selected_difficulty_id
    )

    return {
        ok = true,
        session = session,
        teleport_data = routing_data(
            session,
            selected_difficulty_id
        ),
        reused = false,
    }
end

return table.freeze(StudioSessionFactory)
