--!strict
-- Original C4 stage progression. No client remote accepts quest evidence.
-- Until an authenticated world binder supplies true NPC/combat/item proof,
-- actual class quest progression and level-20 class awards stay locked.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Source = require(Shared.C4OriginalFirstTransferQuestStages)
local Rules = require(Shared.C4OriginalQuestProgressRules)

local Service = {}
Service.__index = Service

local function result(ok: boolean, reason: string?, extra: any?): any
    local value = extra or {}
    value.ok = ok
    value.reason = reason
    return value
end

local function selected_character(profile: any): any?
    local slot = profile and profile.Account
        and profile.Account.SelectedCharacterSlot
    return slot and profile.Characters
        and profile.Characters["Slot" .. tostring(slot)] or nil
end

--[[
Creates an original C4 quest service around real profile and world authority.

Args:
    profiles (any): Exclusive writer of the selected character.
    place_kind (string): Only Base may begin first-class quests.
    world (any?): Server-only NPC/monster/drop verifier. Nil until built.

Returns:
    any: Service that fails closed when genuine world binding is absent.
]]
function Service.new(
    profiles: any, place_kind: string, world: any?
): any
    assert(profiles and (place_kind == "Base" or place_kind == "Dungeon"))
    return setmetatable({
        _profiles = profiles,
        _place_kind = place_kind,
        _world = world,
    }, Service)
end

--[[
Returns actual server progress without treating it as an awarded class.

Args:
    user_id (number): Authenticated profile owner.

Returns:
    any: Current original quest step, bound status and no class award.
]]
function Service:build_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id)
    if not character then return result(false, "ProfileNotLoaded") end
    local advancement = character.ClassAdvancement
    local branch_id = advancement
        and advancement.OriginalFirstTransferChoiceId
    local quest = branch_id and Source.get(branch_id)
    if not quest then
        return result(false, "OriginalQuestNotMapped")
    end
    local state = advancement.OriginalFirstTransferQuest
    local stage_index = if type(state) == "table"
        then state.Step else 1
    local first_npc_ready = self._world ~= nil
        and self._world:available(quest, 1) == true
    local world_ready = self._world ~= nil
        and self._world:available(quest, stage_index) == true
    return result(true, nil, {
        BranchId = branch_id,
        QuestId = quest.Id,
        QuestTitle = quest.SourceTitle,
        SourceUrl = quest.SourceUrl,
        WorldReady = world_ready,
        FirstNpcReady = first_npc_ready,
        FullWorldReady = quest.WorldBindingStatus == "Implemented"
            and world_ready,
        Started = type(state) == "table"
            and state.BranchId == branch_id,
        Step = if type(state) == "table"
            then state.Step else 1,
        Ready = type(state) == "table" and state.Ready == true,
        ClassAwarded = false,
        TransferRequiresLevel = quest.TransferLevel,
    })
end

--[[
Starts a separate authored C4 branch quest only when real world hooks exist.

Args:
    user_id (number): Actual character selected class choice owner.

Returns:
    any: Saved quest state or explicit unavailable/repeated-start refusal.
]]
function Service:start(user_id: number): any
    if self._place_kind ~= "Base" then
        return result(false, "BaseOnlyAction")
    end
    local character = self._profiles:get_character(user_id)
    if not character then return result(false, "ProfileNotLoaded") end
    local advancement = character.ClassAdvancement
    local branch_id = advancement
        and advancement.OriginalFirstTransferChoiceId
    local allowed, refusal, quest = Rules.can_start(character, branch_id)
    if not allowed then return result(false, refusal) end
    if not self._world or self._world:available(quest) ~= true then
        return result(false, "OriginalQuestWorldNotReady")
    end
    if type(advancement.OriginalFirstTransferQuest) == "table" then
        return result(false, "OriginalQuestAlreadyStarted")
    end
    local ok, reason = self._profiles:mutate(
        user_id, function(profile: any)
            local live = selected_character(profile)
            local accepted, why = Rules.can_start(live, branch_id)
            if not accepted then error(why) end
            if live.ClassAdvancement.OriginalFirstTransferQuest then
                error("OriginalQuestAlreadyStarted")
            end
            live.ClassAdvancement.OriginalFirstTransferQuest = {
                QuestId = quest.Id, BranchId = branch_id,
                Step = 1, Count = 0, Ready = false,
                AppliedEvents = {}, Proofs = {},
            }
        end
    )
    if not ok then return result(false, reason or "QuestMutationFailed") end
    return result(true, nil, {quest_id = quest.Id, branch_id = branch_id})
end

--[[
Consumes only verified original NPC/combat/drop actions from server world code.

Args:
    user_id (number): Actual player whose world action is being observed.
    evidence (any): World-binder verified target, unique event and loot proof.

Returns:
    any: Real persistent, ordered progress; never awards a class.
]]
function Service:record_world_event(
    user_id: number, evidence: any
): any
    if not self._world then
        return result(false, "OriginalQuestWorldNotReady")
    end
    local character = self._profiles:get_character(user_id)
    if not character then return result(false, "ProfileNotLoaded") end
    local advancement = character.ClassAdvancement
    local state = advancement
        and advancement.OriginalFirstTransferQuest
    local quest = state and Source.get(state.BranchId)
    if not quest or not state then
        return result(false, "OriginalQuestNotStarted")
    end
    local allowed, refusal = Rules.can_start(character, state.BranchId)
    if not allowed then return result(false, refusal) end
    if self._world:available(quest, state.Step) ~= true then
        return result(false, "OriginalQuestWorldNotReady")
    end
    if self._world:verify(user_id, evidence, quest, state) ~= true then
        return result(false, "OriginalQuestWorldEvidenceUnverified")
    end
    local permitted, rejection = Rules.can_progress(quest, state, evidence)
    if not permitted then return result(false, rejection) end
    local progress: any? = nil
    local ok, reason = self._profiles:mutate(
        user_id, function(profile: any)
            local live = selected_character(profile)
            local eligible, why = Rules.can_start(
                live, state.BranchId
            )
            if not eligible then error(why) end
            local latest = live.ClassAdvancement.OriginalFirstTransferQuest
            if not latest or latest.QuestId ~= quest.Id then
                error("OriginalQuestStateChanged")
            end
            progress = Rules.advance(quest, latest, evidence)
            if not progress.ok then error(progress.reason) end
        end
    )
    if not ok then
        return result(false, reason or "OriginalQuestProgressRejected")
    end
    return progress
end

return table.freeze(Service)
