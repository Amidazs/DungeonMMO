--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)
local SecondaryClassDefinitions = require(
    Shared:WaitForChild("SecondaryClassDefinitions")
)
local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)
local SkillUnlockRules = require(
    Shared:WaitForChild("SkillUnlockRules")
)

local QuestService = require(script.Parent:WaitForChild("QuestService"))

local ClassAdvancementService = {}
ClassAdvancementService.__index = ClassAdvancementService

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

local function selected_character(profile: any): any?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end

    local slot = profile.Account.SelectedCharacterSlot
    if type(slot) ~= "number" then
        return nil
    end

    return profile.Characters["Slot" .. tostring(slot)]
end

local function resolve_candidate(character: any): any?
    if not CharacterIdentityRules.is_complete(character) then
        return nil
    end

    local identity = character.Identity
    local race_id = identity.RaceId
    local base_class_id = identity.BaseClassId

    if type(race_id) ~= "string"
        or type(base_class_id) ~= "string"
    then
        return nil
    end

    return SecondaryClassDefinitions.resolve(
        race_id,
        base_class_id
    )
end

local function ensure_advancement(character: any): any
    if type(character.ClassAdvancement) ~= "table" then
        character.ClassAdvancement = {}
    end

    local advancement = character.ClassAdvancement
    advancement.Version = 1

    if type(advancement.CompletedByRace) ~= "table" then
        advancement.CompletedByRace = {}
    end

    return advancement
end

local function completed_for(
    character: any,
    definition: any
): boolean
    local advancement = ensure_advancement(character)
    local by_race = advancement.CompletedByRace[definition.RaceId]

    return type(by_race) == "table"
        and by_race[definition.Id] == true
end

function ClassAdvancementService.new(
    profile_service: any,
    quest_service: any,
    place_kind: string
): any
    assert(
        profile_service ~= nil and quest_service ~= nil,
        "ClassAdvancementService requires ProfileService and QuestService."
    )
    assert(
        place_kind == "Base" or place_kind == "Dungeon",
        "place_kind must be Base or Dungeon"
    )

    local self = setmetatable({}, ClassAdvancementService)
    self._profiles = profile_service
    self._quests = quest_service
    self._place_kind = place_kind
    return self
end

function ClassAdvancementService:start_trial(user_id: number): any
    if self._place_kind ~= "Base" then
        return result(false, "BaseOnlyAction")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return result(false, "IdentityIncomplete")
    end

    local candidate = resolve_candidate(character)
    if not candidate then
        return result(false, "AdvancementUnavailable")
    end

    if completed_for(character, candidate) then
        return result(false, "AdvancementAlreadyCompleted")
    end

    local trial = QuestDefinitions.get(candidate.QuestId)
    local ready, missing_reason, missing_requirement =
        SkillUnlockRules.can_start_trial(character, trial)
    if not ready then
        return result(false, "AdvancementRequirementsNotMet", {
            requirement_reason = missing_reason,
            missing_requirement = missing_requirement,
        })
    end

    local started = self._quests:start(
        user_id,
        candidate.QuestId
    )

    if not started.ok then
        return result(false, "QuestStartFailed", {
            quest_reason = started.reason,
        })
    end

    return result(true, nil, {
        class_id = candidate.Id,
        role_id = candidate.RoleId,
        quest_id = candidate.QuestId,
    })
end

function ClassAdvancementService:claim(user_id: number): any
    if self._place_kind ~= "Base" then
        return result(false, "BaseOnlyAction")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return result(false, "IdentityIncomplete")
    end

    local candidate = resolve_candidate(character)
    if not candidate then
        return result(false, "AdvancementUnavailable")
    end

    if completed_for(character, candidate) then
        return result(false, "AdvancementAlreadyCompleted")
    end

    local trial = QuestDefinitions.get(candidate.QuestId)
    local ready, missing_reason, missing_requirement =
        SkillUnlockRules.can_start_trial(character, trial)
    if not ready then
        return result(false, "AdvancementRequirementsNotMet", {
            requirement_reason = missing_reason,
            missing_requirement = missing_requirement,
        })
    end

    local quest_state = QuestService.character_state(
        character,
        candidate.QuestId
    )

    if type(quest_state) ~= "table"
        or quest_state.Ready ~= true
    then
        return result(false, "AdvancementQuestNotReady")
    end

    local mutation_ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local live_character = selected_character(profile)
            if not live_character
                or not CharacterIdentityRules.is_complete(live_character)
            then
                error("IdentityChanged")
            end

            local live_candidate = resolve_candidate(live_character)
            if not live_candidate
                or live_candidate.Id ~= candidate.Id
            then
                error("AdvancementChanged")
            end

            if completed_for(live_character, live_candidate) then
                error("AdvancementAlreadyCompleted")
            end
            local current_trial = QuestDefinitions.get(
                live_candidate.QuestId
            )
            if not select(1, SkillUnlockRules.can_start_trial(
                live_character, current_trial
            )) then
                error("AdvancementRequirementsChanged")
            end

            local completed, quest_error =
                QuestService.complete_ready_character_quest(
                    live_character,
                    live_candidate.QuestId
                )

            if not completed then
                error(quest_error or "QuestNotReady")
            end

            local advancement = ensure_advancement(live_character)
            local race_id = live_candidate.RaceId

            if type(advancement.CompletedByRace[race_id]) ~= "table" then
                advancement.CompletedByRace[race_id] = {}
            end

            advancement.CompletedByRace[race_id][live_candidate.Id] = true
            advancement.ActiveClassId = live_candidate.Id
        end
    )

    if not mutation_ok then
        if mutation_error == "ProfileNotLoaded" then
            return result(false, "ProfileNotLoaded")
        end
        return result(false, "ProfileMutationFailed")
    end

    return result(true, nil, {
        class_id = candidate.Id,
        display_name = candidate.DisplayName,
        role_id = candidate.RoleId,
    })
end

function ClassAdvancementService:build_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return result(false, "IdentityIncomplete")
    end

    local candidate = resolve_candidate(character)
    local advancement = ensure_advancement(character)
    local quest_state = if candidate
        then QuestService.character_state(character, candidate.QuestId)
        else nil
    local trial = candidate and QuestDefinitions.get(candidate.QuestId)
    local requirements_met, requirement_reason, missing_requirement =
        SkillUnlockRules.can_start_trial(character, trial)

    return result(true, nil, {
        ActiveClassId = advancement.ActiveClassId,
        CandidateClassId = if candidate then candidate.Id else nil,
        CandidateDisplayName = if candidate then candidate.DisplayName else nil,
        CandidateRoleId = if candidate then candidate.RoleId else nil,
        RequiredLevel = trial and trial.MinimumLevel or nil,
        SkillRequirements = trial and trial.SkillPrerequisites or {},
        RequirementsMet = requirements_met,
        MissingRequirementReason = requirement_reason,
        MissingRequirement = missing_requirement,
        QuestId = if candidate then candidate.QuestId else nil,
        QuestReady = type(quest_state) == "table"
            and quest_state.Ready == true,
        Completed = if candidate
            then completed_for(character, candidate)
            else false,
    })
end

return table.freeze(ClassAdvancementService)
