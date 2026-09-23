--!strict
-- One-use, original DungeonMMO level-20 first-class award authority.
-- This service cannot be invoked by a client RemoteEvent.
local RS = game:GetService("ReplicatedStorage")
local FirstTransfers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)

local Service = {}
Service.__index = Service

--[[
Looks up the same selected character slot used by ProfileService.

Args:
    profile (any): Exclusive server-writer-owned player profile.

Returns:
    any?: Currently selected personal character or nil if missing.
]]
local function selected_character(profile: any): any?
    local account = profile and profile.Account
    local slot = account and account.SelectedCharacterSlot
    local characters = profile and profile.Characters
    return slot and characters
        and characters["Slot" .. tostring(slot)] or nil
end

--[[
Initialises the Base-only source-quest and physical-mentor service.

Args:
    profiles (any): Current real ProfileService and transaction authority.
    place_kind (string): Only Base may grant first-transfer identities.
    world (any): Server-only real physical mentor receipt verifier.

Returns:
    any: Private first-transfer claim service with no client event path.
]]
function Service.new(
    profiles: any, place_kind: string, world: any
): any
    assert(profiles and world and place_kind == "Base")
    assert(type(world.available) == "function"
        and type(world.verify) == "function")
    return setmetatable({
        _profiles = profiles,
        _world = world,
    }, Service)
end

--[[
Reports the actual selected owner's readiness and persistent class award.

Args:
    user_id (number): Server-resolved current profile owner UserId.

Returns:
    any: Safe snapshot with eligibility and earned original class details.
]]
function Service:build_snapshot(user_id: number): any
    local owner = self._profiles:get_character(user_id)
    if not owner then return {ok = false, reason = "ProfileNotLoaded"} end
    local advancement = owner.ClassAdvancement
    local choice = advancement
        and advancement.OriginalFirstTransferChoiceId
    local definition = if type(choice) == "string"
        then FirstTransfers.for_branch(choice) else nil
    if not definition then
        return {ok = false, reason = "OriginalTransferBranchUnavailable"}
    end
    local valid, reason = FirstTransfers.can_transfer(owner, choice)
    local awarded = FirstTransfers.awarded(owner)
    return {
        ok = true,
        ClassId = definition.Id,
        DisplayName = definition.DisplayName,
        MentorId = definition.MentorId,
        MentorName = definition.MentorName,
        TrainerId = definition.TrainerId,
        RequiredLevel = 20,
        ClassAwarded = awarded ~= nil,
        Eligible = valid and self._world:available(definition),
        LockedReason = if valid or awarded then nil else reason,
    }
end

--[[
Awards the exact source branch only after a genuine nearby mentor receipt.

Args:
    user_id (number): Verified physical prompt's actual player UserId.
    evidence (any): Exact one-use server-minted mentor event table.

Returns:
    any: Atomic saved class award, or explicit non-mutating denial.
]]
function Service:claim(user_id: number, evidence: any): any
    local character = self._profiles:get_character(user_id)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end
    local advancement = character.ClassAdvancement
    local branch = advancement
        and advancement.OriginalFirstTransferChoiceId
    local eligible, refusal, definition =
        FirstTransfers.can_transfer(character, branch)
    if not eligible then return {ok = false, reason = refusal} end
    if not self._world:available(definition)
        or not self._world:verify(user_id, evidence, definition)
    then
        return {ok = false, reason = "TransferMentorProofRequired"}
    end
    local mutated, reason = self._profiles:mutate(
        user_id, function(profile: any)
            local live = selected_character(profile)
            local allowed, why = FirstTransfers.can_transfer(
                live, definition.BranchId
            )
            if not allowed then error(why) end
            local original = live.ClassAdvancement
            original.OriginalFirstTransferClassId = definition.Id
            original.OriginalFirstTransferReceiptId = evidence.EventId
            live.Identity.ClassId = definition.Id
            assert(FirstTransfers.awarded(live) ~= nil,
                "OriginalTransferAwardInvariantFailed")
        end
    )
    if not mutated then
        return {
            ok = false,
            reason = reason or "OriginalTransferMutationFailed",
        }
    end
    return {
        ok = true,
        class_id = definition.Id,
        display_name = definition.DisplayName,
        trainer_id = definition.TrainerId,
    }
end

return table.freeze(Service)
