--!strict
-- Explicit original C4 first-transfer choice. Selecting a branch NEVER
-- grants a class, starts a fake quest, or changes an existing legacy save.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Paths = require(Shared.C4ClassPathRules)
local Branches = require(Shared.C4FirstTransferBranches)
local SkillCoverage = require(Shared.C4OriginalClassSkillCoverage)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)

local Selection = {}
Selection.__index = Selection

local function result(ok: boolean, reason: string?, extra: any?): any
    local value = extra or {}
    value.ok = ok
    value.reason = reason
    return value
end

local function selected_character(profile: any): any?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end
    return profile.Characters[
        "Slot" .. tostring(profile.Account.SelectedCharacterSlot)
    ]
end

--[[
Determines whether a character already owns an old completed/active
advancement that needs its separate, non-destructive migration.

Args:
    character (any): Authoritative current selected character.

Returns:
    boolean: True when an earlier trial or advanced class exists.
]]
local function has_legacy_advancement(character: any): boolean
    local old = character and character.ClassAdvancement
    if type(old) == "table" and old.ActiveClassId ~= nil then
        return true
    end
    local quests = character and character.Quests
    local active = quests and quests.Active
    if type(active) == "table" then
        for _, id in ipairs({
            "FighterAdvancementTrial", "MageAdvancementTrial",
            "RangerAdvancementTrial", "RogueAdvancementTrial",
        }) do
            if active[id] ~= nil then
                return true
            end
        end
    end
    return false
end

--[[
Constructs a Base-only server-owned first-transfer choice service.

Args:
    profiles (any): Actual exclusive writer-owned ProfileService.
    place_kind (string): Base or Dungeon execution context.

Returns:
    any: Profile-backed explicit-choice service.
]]
function Selection.new(profiles: any, place_kind: string): any
    assert(profiles and (place_kind == "Base" or place_kind == "Dungeon"))
    return setmetatable({
        _profiles = profiles, _place_kind = place_kind,
    }, Selection)
end

--[[
Lists the currently available authentic branch names for this character.

Args:
    user_id (number): Authenticated selected profile owner.

Returns:
    any: Race-specific options, current persistent choice and quest status.
]]
function Selection:build_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end
    local available = Paths.options(character)
    if not available.ok then
        return result(false, available.reason, {Options = {}})
    end
    local stored = character.ClassAdvancement
    local choice_id = type(stored) == "table"
        and stored.OriginalFirstTransferChoiceId or nil
    local legacy = has_legacy_advancement(character)
    local options = {}
    for _, branch in ipairs(available.branches) do
        local skill_status = SkillCoverage.for_branch(branch)
        local quest_source = QuestStages.get(branch.Id)
        table.insert(options, {
            Id = branch.Id,
            DisplayName = branch.SourceClass,
            QuestName = branch.SourceQuestName,
            MinimumLevel = branch.SourceQuestStartLevel,
            QuestImplemented = type(branch.GameQuestId) == "string"
                and Branches.is_complete(branch),
            QuestSourceMapped = quest_source ~= nil,
            QuestWorldReady = quest_source ~= nil
                and quest_source.WorldBindingStatus == "Implemented",
            SkillInventoryStatus = skill_status.SourceInventoryStatus,
            MappedAnalogueRanks = skill_status.MappedAnalogueRanks,
            ExactOriginalLevel20RankEntries =
                skill_status.ExactOriginalLevel20RankEntries,
            ImplementedOriginalLevel20Ranks =
                skill_status.ImplementedOriginalLevel20Ranks,
            ExactC4SkillParityCertified =
                skill_status.ExactC4RankParityCertified,
        })
    end
    return result(true, nil, {
        Options = options,
        SelectedClassId = choice_id,
        CanChoose = (tonumber(character.Level) or 0) >= 18
            and choice_id == nil and not legacy,
        LegacyAdvancementNeedsMigration = legacy,
        QuestImplemented = false,
        MinimumLevel = 18,
    })
end

--[[
Persists one explicit branch choice; no branch or loot is awarded.

Args:
    user_id (number): Authenticated owner of the selected profile.
    requested_id (string): Exact race/family branch identifier.

Returns:
    any: Selection outcome; the original quest remains separately gated.
]]
function Selection:choose(user_id: number, requested_id: string): any
    if self._place_kind ~= "Base" then
        return result(false, "BaseOnlyAction")
    end
    if type(requested_id) ~= "string" then
        return result(false, "InvalidClassChoice")
    end
    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end
    local options = Paths.options(character)
    if not options.ok then
        return result(false, options.reason)
    end
    if (tonumber(character.Level) or 0) < 18 then
        return result(false, "OriginalTransferLevelTooLow")
    end
    local branch = Branches.find(
        character.Identity.RaceId,
        character.Identity.BaseClassId, requested_id
    )
    if not branch then
        return result(false, "OriginalClassChoiceUnavailable")
    end
    if has_legacy_advancement(character) then
        return result(false, "LegacyClassMigrationRequired")
    end
    local current = character.ClassAdvancement
    if type(current) == "table"
        and current.OriginalFirstTransferChoiceId ~= nil
    then
        return result(false, "OriginalClassChoiceAlreadyMade")
    end

    local ok, failure = self._profiles:mutate(
        user_id, function(profile: any)
            local live = selected_character(profile)
            local eligible = live and Paths.options(live)
            if not eligible or not eligible.ok
                or (tonumber(live.Level) or 0) < 18
                or not Branches.find(
                    live.Identity.RaceId, live.Identity.BaseClassId,
                    requested_id
                )
            then
                error("OriginalClassChoiceUnavailable")
            end
            if type(live.ClassAdvancement) ~= "table" then
                live.ClassAdvancement = {
                    Version = 1, CompletedByRace = {},
                }
            end
            if has_legacy_advancement(live) then
                error("LegacyClassMigrationRequired")
            end
            if live.ClassAdvancement.OriginalFirstTransferChoiceId
                ~= nil
            then
                error("OriginalClassChoiceAlreadyMade")
            end
            live.ClassAdvancement.OriginalFirstTransferChoiceId =
                requested_id
        end
    )
    if not ok then
        return result(false, failure or "ClassChoiceMutationFailed")
    end
    return result(true, nil, {
        class_id = requested_id,
        quest_status = "OriginalQuestNotImplemented",
    })
end

return table.freeze(Selection)
