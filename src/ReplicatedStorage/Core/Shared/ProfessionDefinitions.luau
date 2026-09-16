--!strict
local ProfessionDefinitions = {}

ProfessionDefinitions.MAX_LEVEL = 5

local XP_TO_NEXT = table.freeze({
    [1] = 30,
    [2] = 60,
    [3] = 100,
    [4] = 150,
})

local DEFINITIONS = table.freeze({
    Mining = table.freeze({
        Id = "Mining",
        Name = "Mining",
        Kind = "Gathering",
        Pair = "Blacksmithing",
    }),
    Blacksmithing = table.freeze({
        Id = "Blacksmithing",
        Name = "Blacksmithing",
        Kind = "Creation",
        Pair = "Mining",
        CraftingMinigameId = "BlacksmithingForge",
    }),
    Herbalism = table.freeze({
        Id = "Herbalism",
        Name = "Herbalism",
        Kind = "Gathering",
        Pair = "Alchemy",
    }),
    Alchemy = table.freeze({
        Id = "Alchemy",
        Name = "Alchemy",
        Kind = "Creation",
        Pair = "Herbalism",
        CraftingMinigameId = "AlchemyBrewing",
    }),
})

local ORDER = table.freeze({
    "Mining",
    "Blacksmithing",
    "Herbalism",
    "Alchemy",
})

function ProfessionDefinitions.get(profession_id: string): any?
    return DEFINITIONS[profession_id]
end

function ProfessionDefinitions.all(): any
    return DEFINITIONS
end

function ProfessionDefinitions.order(): {string}
    return ORDER
end

function ProfessionDefinitions.xp_to_next(level: number): number?
    local cleaned = math.floor(tonumber(level) or 1)
    return XP_TO_NEXT[cleaned]
end

function ProfessionDefinitions.level_from_xp(total_xp: number): number
    local remaining = math.max(0, math.floor(tonumber(total_xp) or 0))
    local level = 1

    while level < ProfessionDefinitions.MAX_LEVEL do
        local required = XP_TO_NEXT[level]
        if not required or remaining < required then
            break
        end
        remaining -= required
        level += 1
    end

    return level
end

function ProfessionDefinitions.progress_in_level(total_xp: number): (number, number?)
    local remaining = math.max(0, math.floor(tonumber(total_xp) or 0))
    local level = 1

    while level < ProfessionDefinitions.MAX_LEVEL do
        local required = XP_TO_NEXT[level]
        if not required or remaining < required then
            break
        end
        remaining -= required
        level += 1
    end

    return remaining, XP_TO_NEXT[level]
end

return table.freeze(ProfessionDefinitions)
