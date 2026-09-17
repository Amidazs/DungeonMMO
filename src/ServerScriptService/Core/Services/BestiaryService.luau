--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local BestiaryDefinitions = require(
    Shared:WaitForChild("BestiaryDefinitions")
)

local BestiaryService = {}
BestiaryService.__index = BestiaryService

function BestiaryService.new(profile_service: any): any
    assert(profile_service ~= nil, "BestiaryService requires ProfileService.")
    return setmetatable({
        _profiles = profile_service,
    }, BestiaryService)
end

function BestiaryService.apply_kill_to_character(
    character: any,
    creature_id: string
): any
    local definition = BestiaryDefinitions.get(creature_id)
    if not definition then
        return {
            ok = true,
            reason = nil,
            tracked = false,
            creature_id = creature_id,
            kill_count = nil,
            newly_unlocked = {},
        }
    end

    if type(character) ~= "table"
        or type(character.Bestiary) ~= "table"
        or type(character.Bestiary.Entries) ~= "table"
    then
        return {
            ok = false,
            reason = "BestiaryUnavailable",
        }
    end

    local entry = character.Bestiary.Entries[creature_id]
    if entry == nil then
        entry = {
            Kills = 0,
            Milestones = {},
        }
        character.Bestiary.Entries[creature_id] = entry
    end

    if type(entry) ~= "table"
        or type(entry.Kills) ~= "number"
        or entry.Kills ~= entry.Kills
        or entry.Kills < 0
        or entry.Kills >= math.huge
        or entry.Kills % 1 ~= 0
        or type(entry.Milestones) ~= "table"
    then
        return {
            ok = false,
            reason = "BestiaryUnavailable",
        }
    end

    entry.Kills += 1
    local newly_unlocked = {}

    for _, milestone in ipairs(definition.Milestones) do
        if entry.Kills >= milestone.RequiredKills
            and entry.Milestones[milestone.Id] ~= true
        then
            entry.Milestones[milestone.Id] = true
            table.insert(newly_unlocked, {
                id = milestone.Id,
                reputation = {
                    faction_id = milestone.Reputation.FactionId,
                    points = milestone.Reputation.Points,
                },
            })
        end
    end

    return {
        ok = true,
        reason = nil,
        tracked = true,
        creature_id = creature_id,
        kill_count = entry.Kills,
        newly_unlocked = newly_unlocked,
    }
end

function BestiaryService:get_snapshot(user_id: number): any
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
        bestiary = ProfileSchema.deep_clone(character.Bestiary),
    }
end

return table.freeze(BestiaryService)