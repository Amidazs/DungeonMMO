--!strict
-- Original C4 starting family and first-transfer choice validation.
-- Legacy specialist names must not silently select a source career.
local Shared = script.Parent
local Branches = require(Shared.C4FirstTransferBranches)
local RaceDefinitions = require(Shared.RaceDefinitions)
local QuestDefinitions = require(Shared.QuestDefinitions)

local C4ClassPathRules = {}

--[[
Returns a typed non-mutating class-choice result.

Args:
    ok (boolean): Whether the original C4 choice is valid.
    reason (string?): Why it cannot proceed, when rejected.
    branch (any?): Exact source branch when valid.

Returns:
    any: Small server-checkable choice validation result.
]]
local function result(ok: boolean, reason: string?, branch: any?): any
    return {ok = ok, reason = reason, branch = branch}
end

--[[
Resolves a real starting class without equating a legacy role to it.

Args:
    character (any): Authoritative selected original character.

Returns:
    string?: Original Fighter/Mage family, nil for old advanced role IDs.
]]
local function starting_family(character: any): string?
    local identity = character and character.Identity
    if type(identity) ~= "table"
        or identity.CreationStage ~= "Complete"
        or identity.ClassId ~= identity.BaseClassId
    then
        return nil
    end
    if identity.BaseClassId == "Fighter"
        or identity.BaseClassId == "Mage"
    then
        return identity.BaseClassId
    end
    return nil
end

--[[
Lists actual race/family first-transfer choices without enabling them.

Args:
    character (any): Current server-owned race and starting-class identity.

Returns:
    any: Exact source branches or a refusal for unsupported/legacy identity.
]]
function C4ClassPathRules.options(character: any): any
    local family = starting_family(character)
    if not family then
        return result(false, "OriginalStartingClassRequired")
    end
    local race_id = character.Identity.RaceId
    if not RaceDefinitions.get(race_id) then
        return result(false, "OriginalRaceNotYetPlayable")
    end
    local options = Branches.get(race_id, family)
    if not options then
        return result(false, "OriginalClassFamilyUnavailable")
    end
    return {ok = true, reason = nil, branches = options}
end

--[[
Validates a choice and explicitly declines unfinished original quests.

Args:
    character (any): Selected, authoritative starting-class profile.
    source_class_id (string): Exact requested original C4 branch ID.
    phase (string): QuestStart or Transfer; never a client-sent level.

Returns:
    any: Rejection, or an authorized branch once its quest is implemented.
]]
function C4ClassPathRules.validate(
    character: any, source_class_id: string, phase: string
): any
    local available = C4ClassPathRules.options(character)
    if not available.ok then
        return available
    end
    if phase ~= "QuestStart" and phase ~= "Transfer" then
        return result(false, "InvalidTransferPhase")
    end
    local identity = character.Identity
    local branch = Branches.find(
        identity.RaceId, identity.BaseClassId, source_class_id
    )
    if not branch then
        return result(false, "OriginalClassChoiceUnavailable")
    end
    local required_level = if phase == "QuestStart"
        then branch.SourceQuestStartLevel
        else branch.SourceTransferLevel
    if (tonumber(character.Level) or 0) < required_level then
        return result(false, "OriginalTransferLevelTooLow", branch)
    end

    -- SourceQuestName is historical metadata, NOT the game quest ID.
    -- Never grant a new class merely because the level or source
    -- skill inventory is complete: the dedicated branch quest must exist.
    local quest_id = branch.GameQuestId
    if type(quest_id) ~= "string"
        or not QuestDefinitions.get(quest_id)
    then
        return result(false, "OriginalQuestNotImplemented", branch)
    end
    if not Branches.is_complete(branch) then
        return result(false, "OriginalClassNotImplemented", branch)
    end
    return result(true, nil, branch)
end

return table.freeze(C4ClassPathRules)
