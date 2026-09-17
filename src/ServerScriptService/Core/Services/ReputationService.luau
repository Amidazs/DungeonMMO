--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local ReputationDefinitions = require(
    Shared:WaitForChild("ReputationDefinitions")
)

local ReputationService = {}
ReputationService.__index = ReputationService

function ReputationService.new(profile_service: any): any
    assert(profile_service ~= nil, "ReputationService requires ProfileService.")
    return setmetatable({
        _profiles = profile_service,
    }, ReputationService)
end

function ReputationService.apply_points_to_character(
    character: any,
    faction_id: string,
    points: number
): any
    if ReputationDefinitions.get(faction_id) == nil then
        return {
            ok = false,
            reason = "UnknownFaction",
        }
    end

    if type(points) ~= "number"
        or points ~= points
        or points <= 0
        or points >= math.huge
        or points % 1 ~= 0
    then
        return {
            ok = false,
            reason = "InvalidPoints",
        }
    end

    if type(character) ~= "table"
        or type(character.Reputation) ~= "table"
        or type(character.Reputation.Factions) ~= "table"
    then
        return {
            ok = false,
            reason = "ReputationUnavailable",
        }
    end

    local state = character.Reputation.Factions[faction_id]
    if type(state) ~= "table"
        or type(state.Points) ~= "number"
        or state.Points ~= state.Points
        or state.Points < 0
        or state.Points >= math.huge
        or state.Points % 1 ~= 0
    then
        return {
            ok = false,
            reason = "ReputationUnavailable",
        }
    end

    state.Points += points

    return {
        ok = true,
        reason = nil,
        faction_id = faction_id,
        points_granted = points,
        new_points = state.Points,
    }
end

function ReputationService:get_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {
            ok = false,
            reason = "ProfileNotLoaded",
        }
    end

    return {
        ok = true,
        reason = nil,
        reputation = ProfileSchema.deep_clone(character.Reputation),
    }
end

return table.freeze(ReputationService)