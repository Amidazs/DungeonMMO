--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local EnvironmentConfig = require(Shared:WaitForChild("EnvironmentConfig"))
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local RaceChangePlanner = require(script.Parent:WaitForChild("RaceChangePlanner"))

local RaceChangeService = {}
RaceChangeService.__index = RaceChangeService

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

local function valid_id(value: any): boolean
    return type(value) == "string" and value ~= "" and #value <= 128
end

local function ensure_state(character: any): any
    if type(character.RaceChange) ~= "table" then character.RaceChange = {} end
    local state = character.RaceChange
    state.Version = 1
    if type(state.ArchivedByRace) ~= "table" then state.ArchivedByRace = {} end
    if type(state.History) ~= "table" then state.History = {} end
    return state
end

local function ensure_archive(state: any, race_id: string): any
    local archive = state.ArchivedByRace[race_id]
    if type(archive) ~= "table" then
        archive = {Skills = {}, Advancement = {}}
        state.ArchivedByRace[race_id] = archive
    end
    if type(archive.Skills) ~= "table" then archive.Skills = {} end
    if type(archive.Advancement) ~= "table" then archive.Advancement = {} end
    return archive
end
function RaceChangeService.new(
    profile_service: any,
    environment_override: string?,
    clock: (() -> number)?
): any
    assert(profile_service ~= nil, "RaceChangeService requires ProfileService")
    local self = setmetatable({}, RaceChangeService)
    self._profiles = profile_service
    self._environment_override = environment_override
    self._clock = clock or os.time
    self._audit = nil
    return self
end

function RaceChangeService:set_audit_service(audit_service: any?)
    self._audit = audit_service
end

function RaceChangeService:_record_audit(event: any)
    if not self._audit then return end
    local ok, response = pcall(function() return self._audit:record(event) end)
    if not ok or type(response) ~= "table" or response.ok ~= true then
        warn("[Economy Audit] Race Change event failed: " .. tostring(if ok then response and response.reason else response))
    end
end

function RaceChangeService:_environment(): string
    return self._environment_override or EnvironmentConfig.get_environment()
end

function RaceChangeService:_guard(): any?
    local environment = self:_environment()
    if environment ~= "DEV" and environment ~= "TEST" then
        return result(false, "RaceChangeUnavailable")
    end
    return nil
end

-- A pending original C4 class choice belongs to the chosen race.
-- Do not allow development-only race change to strand a foreign branch.
local function has_original_c4_choice(character: any): boolean
    local advancement = character and character.ClassAdvancement
    return type(advancement) == "table"
        and type(advancement.OriginalFirstTransferChoiceId) == "string"
end

function RaceChangeService:preview(user_id: number, target_race_id: string): any
    local blocked = self:_guard()
    if blocked then return blocked end
    local character = self._profiles:get_character(user_id, 1)
    if not character then return result(false, "ProfileNotLoaded") end
    if has_original_c4_choice(character) then
        return result(false, "OriginalClassRaceLocked")
    end
    return RaceChangePlanner.preview(character, target_race_id)
end

local function copy_skill_state(state: any): any
    return {
        Known = state.Known == true,
        StarterGranted = state.StarterGranted == true,
        PurchasedRank = math.max(0, math.floor(tonumber(state.PurchasedRank) or 0)),
        Proficiency = math.max(0, math.floor(tonumber(state.Proficiency) or 0)),
    }
end
local function archive_source(character: any, preview: any)
    local state = ensure_state(character)
    local archive = ensure_archive(state, preview.SourceRaceId)
    local skills = character.Progression.Skills
    for _, skill_id in ipairs(preview.SkillsToArchive) do
        local skill_state = skills[skill_id]
        if type(skill_state) == "table" then
            archive.Skills[skill_id] = copy_skill_state(skill_state)
            skill_state.Known = false
            skill_state.StarterGranted = false
            skill_state.PurchasedRank = 0
            skill_state.Proficiency = 0
        end
    end
    archive.Advancement = ProfileSchema.deep_clone(character.ClassAdvancement or {})
end

local function restore_target(character: any, preview: any)
    local state = ensure_state(character)
    local archive = state.ArchivedByRace[preview.TargetRaceId]
    if type(archive) ~= "table" or type(archive.Skills) ~= "table" then return end
    local skills = character.Progression.Skills
    for _, skill_id in ipairs(preview.SkillsToRestore) do
        local archived = archive.Skills[skill_id]
        if type(archived) == "table" then
            local starter = archived.StarterGranted == true
            skills[skill_id] = {
                Known = true,
                StarterGranted = starter,
                PurchasedRank = if starter then 1 else 0,
                Proficiency = math.max(0, math.floor(tonumber(archived.Proficiency) or 0)),
            }
        end
    end
end

local function apply_loadout_and_equipment(character: any, preview: any)
    local progression = character.Progression
    for _, slot in ipairs(preview.LoadoutSlotsToClear) do
        progression.Loadout[slot] = nil
    end
    for _, slot in ipairs(preview.EquipmentSlotsToUnequip) do
        character.Equipment[slot] = nil
    end
end
function RaceChangeService:apply(
    user_id: number,
    target_race_id: string,
    preview_hash: string,
    transaction_id: string
): any
    local blocked = self:_guard()
    if blocked then return blocked end
    if not valid_id(target_race_id)
        or not valid_id(preview_hash)
        or not valid_id(transaction_id)
    then
        return result(false, "InvalidRaceChangeRequest")
    end

    local current = self._profiles:get_character(user_id, 1)
    if not current then return result(false, "ProfileNotLoaded") end
    if has_original_c4_choice(current) then
        return result(false, "OriginalClassRaceLocked")
    end
    local current_state = ensure_state(current)
    local prior = current_state.History[transaction_id]
    if type(prior) == "table" then
        return result(true, nil, {
            already_applied = true,
            receipt = ProfileSchema.deep_clone(prior),
        })
    end

    local initial_preview = RaceChangePlanner.preview(current, target_race_id)
    if initial_preview.ok ~= true then return initial_preview end
    if initial_preview.Hash ~= preview_hash then
        return result(false, "RaceChangePreviewStale")
    end

    local receipt: any = nil
    local failure: string? = nil
    local newly_applied = false
    local mutated, mutate_error = self._profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        if has_original_c4_choice(character) then
            failure = "OriginalClassRaceLocked"
            error(failure)
        end
        local state = ensure_state(character)
        local replay = state.History[transaction_id]
        if type(replay) == "table" then
            receipt = ProfileSchema.deep_clone(replay)
            return
        end

        local authoritative = RaceChangePlanner.preview(character, target_race_id)
        if authoritative.ok ~= true or authoritative.Hash ~= preview_hash then
            failure = "RaceChangePreviewStale"
            error(failure)
        end
        archive_source(character, authoritative)
        restore_target(character, authoritative)
        apply_loadout_and_equipment(character, authoritative)

        character.Identity.RaceId = authoritative.TargetRaceId
        character.Identity.ClassId = authoritative.BaseClassId
        character.Progression.Attributes = ProfileSchema.deep_clone(
            authoritative.TargetAttributes
        )

        if type(character.ClassAdvancement) ~= "table" then
            character.ClassAdvancement = {Version = 1, CompletedByRace = {}}
        end
        character.ClassAdvancement.Version = 1
        if type(character.ClassAdvancement.CompletedByRace) ~= "table" then
            character.ClassAdvancement.CompletedByRace = {}
        end
        character.ClassAdvancement.ActiveClassId = authoritative.TargetActiveClassId

        receipt = {
            Version = 1,
            TransactionId = transaction_id,
            SourceRaceId = authoritative.SourceRaceId,
            TargetRaceId = authoritative.TargetRaceId,
            PreviewHash = authoritative.Hash,
            RefundableSP = authoritative.RefundableSP,
            ArchivedSkills = ProfileSchema.deep_clone(authoritative.SkillsToArchive),
            RestoredSkills = ProfileSchema.deep_clone(authoritative.SkillsToRestore),
            UnequippedSlots = ProfileSchema.deep_clone(authoritative.EquipmentSlotsToUnequip),
            AppliedAt = self._clock(),
        }
        state.History[transaction_id] = ProfileSchema.deep_clone(receipt)
        newly_applied = true
    end)

    if not mutated then
        return result(false, failure or mutate_error or "ProfileMutationFailed")
    end

    if newly_applied and receipt then
        self:_record_audit({
            TransactionId = transaction_id,
            Kind = "RaceChangeApply",
            UserId = user_id,
            Reason = tostring(receipt.SourceRaceId) .. "->" .. tostring(receipt.TargetRaceId),
            Timestamp = self._clock(),
        })
    end

    return result(true, nil, {
        already_applied = false,
        receipt = receipt,
    })
end

return table.freeze(RaceChangeService)
