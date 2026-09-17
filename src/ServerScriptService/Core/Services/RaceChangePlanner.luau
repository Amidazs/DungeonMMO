--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local RaceDefinitions = require(Shared:WaitForChild("RaceDefinitions"))
local ClassDefinitions = require(Shared:WaitForChild("ClassProgressionDefinitions"))
local SecondaryDefinitions = require(Shared:WaitForChild("SecondaryClassDefinitions"))
local SkillDefinitions = require(Shared:WaitForChild("SkillProgressionDefinitions"))
local SkillConfig = require(Shared:WaitForChild("SkillProgressionConfig"))
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local EquipmentRules = require(Shared:WaitForChild("EquipmentRules"))
local CharacterIdentityRules = require(Shared:WaitForChild("CharacterIdentityRules"))
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))

local RaceChangePlanner = {}
local ATTRIBUTES = {"Strength", "Dexterity", "Vitality", "Intellect", "Spirit"}

local function contains(values: any, expected: string): boolean
    if type(values) ~= "table" then return false end
    for _, value in ipairs(values) do
        if value == expected then return true end
    end
    return false
end

local function base_allows_skill(base_class_id: string, skill_id: string): boolean
    local definition = ClassDefinitions.get(base_class_id)
    if not definition then return false end
    return contains(definition.StarterSkills, skill_id)
        or contains(definition.TeachableSkills, skill_id)
end
local function secondary_allows_skill(definition: any?, skill_id: string): boolean
    return definition ~= nil and contains(definition.TeachableSkills, skill_id)
end

local function purchased_cost(skill_id: string, state: any): number
    local definition = SkillDefinitions.get(skill_id)
    if not definition or type(state) ~= "table" or state.Known ~= true then return 0 end
    local total = 0
    local rank = math.max(0, math.floor(tonumber(state.PurchasedRank) or 0))
    for purchased_rank = 1, rank do
        if not (purchased_rank == 1 and state.StarterGranted == true) then
            total += SkillConfig.get_rank_cost(definition.Tier, purchased_rank) or 0
        end
    end
    return total
end

local function sorted_keys(values: any): {string}
    local keys = {}
    if type(values) == "table" then
        for key in pairs(values) do
            if type(key) == "string" then table.insert(keys, key) end
        end
    end
    table.sort(keys)
    return keys
end

local function stable_hash(value: string): string
    local hash = 2166136261
    for index = 1, #value do
        hash = bit32.bxor(hash, string.byte(value, index))
        hash = (hash * 16777619) % 4294967296
    end
    return string.format("%08x", hash)
end
local function target_advancement(character: any, target_race_id: string, base_class_id: string): string?
    local candidate = SecondaryDefinitions.resolve(target_race_id, base_class_id)
    if not candidate then return nil end
    local advancement = character.ClassAdvancement
    local completed = type(advancement) == "table"
        and type(advancement.CompletedByRace) == "table"
        and advancement.CompletedByRace[target_race_id]
        or nil
    if type(completed) == "table" and completed[candidate.Id] == true then
        return candidate.Id
    end
    return nil
end

local function translated_attributes(character: any, source_race_id: string, target_race_id: string): any
    local source = assert(RaceDefinitions.get_base_attributes(source_race_id))
    local target = assert(RaceDefinitions.get_base_attributes(target_race_id))
    local current = character.Progression and character.Progression.Attributes or {}
    local result = {}
    for _, attribute_name in ipairs(ATTRIBUTES) do
        local delta = (tonumber(current[attribute_name]) or source[attribute_name]) - source[attribute_name]
        result[attribute_name] = math.max(target[attribute_name], target[attribute_name] + delta)
    end
    return result
end

local function invalid_equipment_slots(character: any, target_race_id: string): {string}
    local probe = ProfileSchema.deep_clone(character)
    probe.Identity.RaceId = target_race_id
    local slots = {}
    for slot, item_id in pairs(character.Equipment or {}) do
        local definition = type(item_id) == "string" and ItemDefinitions.get(item_id) or nil
        if definition and EquipmentRules.validate(probe, definition, slot).ok ~= true then
            table.insert(slots, slot)
        end
    end
    table.sort(slots)
    return slots
end
local function canonical(preview: any): string
    local parts = {
        preview.SourceRaceId,
        preview.TargetRaceId,
        preview.BaseClassId,
        preview.SourceActiveClassId or "",
        preview.TargetActiveClassId or "",
        tostring(preview.RefundableSP),
    }
    for _, skill_id in ipairs(preview.SkillsToArchive) do table.insert(parts, "A:" .. skill_id) end
    for _, skill_id in ipairs(preview.SkillsToRestore) do table.insert(parts, "R:" .. skill_id) end
    for _, slot in ipairs(preview.LoadoutSlotsToClear) do table.insert(parts, "L:" .. tostring(slot)) end
    for _, slot in ipairs(preview.EquipmentSlotsToUnequip) do table.insert(parts, "E:" .. slot) end
    for _, name in ipairs(ATTRIBUTES) do table.insert(parts, name .. ":" .. tostring(preview.TargetAttributes[name])) end
    return table.concat(parts, "|")
end

function RaceChangePlanner.preview(character: any, target_race_id: string): any
    if type(character) ~= "table" or not CharacterIdentityRules.is_complete(character) then
        return {ok = false, reason = "IdentityIncomplete"}
    end
    if not RaceDefinitions.get(target_race_id) then return {ok = false, reason = "UnknownRace"} end
    local identity = character.Identity
    local source_race_id = identity.RaceId
    if source_race_id == target_race_id then return {ok = false, reason = "SameRace"} end
    local base_class_id = identity.BaseClassId
    local base_definition = type(base_class_id) == "string" and ClassDefinitions.get(base_class_id) or nil
    if not base_definition or not contains(base_definition.AllowedRaces, target_race_id) then
        return {ok = false, reason = "RaceNotEligibleForClass"}
    end

    local source_active = type(character.ClassAdvancement) == "table" and character.ClassAdvancement.ActiveClassId or nil
    local source_secondary = type(source_active) == "string" and SecondaryDefinitions.get(source_active) or nil
    local target_active = target_advancement(character, target_race_id, base_class_id)
    local target_secondary = type(target_active) == "string" and SecondaryDefinitions.get(target_active) or nil
    local archive = {}
    local refundable_sp = 0
    local skills = character.Progression and character.Progression.Skills or {}
    for skill_id, state in pairs(skills) do
        if type(skill_id) == "string" and type(state) == "table" and state.Known == true then
            local base_ok = base_allows_skill(base_class_id, skill_id)
            local target_ok = secondary_allows_skill(target_secondary, skill_id)
            local source_specific = secondary_allows_skill(source_secondary, skill_id)
            if source_specific and not base_ok and not target_ok then
                table.insert(archive, skill_id)
                refundable_sp += purchased_cost(skill_id, state)
            end
        end
    end
    table.sort(archive)

    local restore = {}
    local race_change = character.RaceChange
    local target_archive = type(race_change) == "table"
        and type(race_change.ArchivedByRace) == "table"
        and race_change.ArchivedByRace[target_race_id]
        or nil
    for _, skill_id in ipairs(sorted_keys(target_archive and target_archive.Skills or nil)) do
        if base_allows_skill(base_class_id, skill_id)
            or secondary_allows_skill(target_secondary, skill_id)
        then
            table.insert(restore, skill_id)
        end
    end

    local archive_set = {}
    for _, skill_id in ipairs(archive) do archive_set[skill_id] = true end
    local loadout_slots = {}
    for slot, skill_id in pairs(character.Progression.Loadout or {}) do
        if archive_set[skill_id] then table.insert(loadout_slots, tonumber(slot) or 0) end
    end
    table.sort(loadout_slots)

    local preview = {
        ok = true,
        SourceRaceId = source_race_id,
        TargetRaceId = target_race_id,
        BaseClassId = base_class_id,
        SourceActiveClassId = source_active,
        TargetActiveClassId = target_active,
        SkillsToArchive = archive,
        SkillsToRestore = restore,
        RefundableSP = refundable_sp,
        LoadoutSlotsToClear = loadout_slots,
        EquipmentSlotsToUnequip = invalid_equipment_slots(character, target_race_id),
        TargetAttributes = translated_attributes(character, source_race_id, target_race_id),
    }
    preview.Hash = stable_hash(canonical(preview))
    return preview
end

return table.freeze(RaceChangePlanner)
