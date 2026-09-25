--!strict
-- Ordered original C4 quest evidence contract; no client-sent event is proof.
local SourceQuests = require(
    script.Parent.C4OriginalFirstTransferQuestStages
)
local Branches = require(script.Parent.C4FirstTransferBranches)
local Rules = {}

local LETTER_IDS = table.freeze({
    PriasLetter1 = true, PriasLetter2 = true,
    PriasLetter3 = true, PriasLetter4 = true,
})

local STAGE_PROOFS = table.freeze({
    CryptSentinel = table.freeze({SpartoiBone = true}),
    RidgeMarauder = table.freeze({IronrootToken = true}),
    GloamStriker = table.freeze({StonewatchBadge = true}),
    GloamBulwark = table.freeze({GloamBulwarkSeal = true}),
    Ridgebreaker = table.freeze({RidgebreakerSigil = true}),
    AshveilAcolyte = table.freeze({AetherglassShard = true}),
    CinderboundConjurer = table.freeze({
        CinderboundEmberSigil = true,
    }),
    RootboundMarauder = table.freeze({VerdantPatrolReport = true}),
    ThornboundColossus = table.freeze({VerdantGuardianSeal = true}),
    BrackenRaider = LETTER_IDS,
    BrackenWarden = table.freeze({RustedKey = true}),
    CinderBrigand = table.freeze({
        StolenJewelry = true, StolenTomes = true,
        StolenRing = true, StolenNecklace = true,
    }),
})


--[[
Resolves the original race and starter family for one first-transfer branch.

Args:
    branch_id (string): Stable original first-transfer branch identifier.

Returns:
    (string?, string?): Source race and starter family, or nil values.
]]
local function branch_identity(
    branch_id: string
): (string?, string?)
    for _, race_id in ipairs(Branches.races()) do
        for _, base_class_id in ipairs({"Fighter", "Mage"}) do
            for _, branch in ipairs(
                Branches.get(race_id, base_class_id) or {}
            ) do
                if branch.Id == branch_id then
                    return race_id, base_class_id
                end
            end
        end
    end

    return nil, nil
end

--[[
Starts a source quest only for a saved original branch choice and starter.

Args:
    character (any): Authoritative character and saved class choice.
    branch_id (string): Exact requested source first-transfer ID.

Returns:
    (boolean, string?, any?): Eligibility, refusal or source quest.
]]
function Rules.can_start(
    character: any, branch_id: string
): (boolean, string?, any?)
    local definition = SourceQuests.get(branch_id)
    if not definition then return false, "OriginalQuestNotMapped", nil end
    if type(character) ~= "table"
        or type(character.Identity) ~= "table"
        or type(character.ClassAdvancement) ~= "table"
    then
        return false, "OriginalCharacterUnavailable", nil
    end
    local identity = character.Identity
    local expected_race, expected_base_class =
        branch_identity(branch_id)
    if expected_race == nil or expected_base_class == nil
        or identity.RaceId ~= expected_race
        or identity.BaseClassId ~= expected_base_class
        or identity.ClassId ~= expected_base_class
        or identity.CreationStage ~= "Complete"
        or character.ClassAdvancement.OriginalFirstTransferChoiceId
            ~= branch_id
    then
        return false, "OriginalClassChoiceRequired", nil
    end
    if (tonumber(character.Level) or 0) < definition.StartLevel then
        return false, "OriginalQuestLevelTooLow", nil
    end
    if character.ClassAdvancement.ActiveClassId ~= nil then
        return false, "LegacyClassMigrationRequired", nil
    end
    return true, nil, definition
end

--[[
Checks a single server-authored action against the one current quest step.

Args:
    quest (any): Exact original source quest blueprint.
    current (any): Current server-owned saved step and event state.
    event (any): Trusted world actor's stable event/monster/quest proof.

Returns:
    (boolean, string?): Whether this specific ordered action counts.
]]
function Rules.can_progress(
    quest: any, current: any, event: any
): (boolean, string?)
    if type(quest) ~= "table"
        or type(current) ~= "table"
        or type(event) ~= "table"
        or current.QuestId ~= quest.Id
        or current.BranchId ~= quest.BranchId
        or type(current.Step) ~= "number"
        or current.Step % 1 ~= 0
    then
        return false, "OriginalQuestStateInvalid"
    end
    if type(event.EventId) ~= "string" or event.EventId == ""
        or #event.EventId > 120
    then
        return false, "OriginalQuestEventIdInvalid"
    end
    if type(current.AppliedEvents) ~= "table"
        or current.AppliedEvents[event.EventId] == true
    then
        return false, "OriginalQuestEventAlreadyApplied"
    end
    if current.Ready == true then
        return false, "OriginalQuestAlreadyComplete"
    end
    local step = quest.Steps[current.Step]
    if not step then return false, "OriginalQuestStageUnavailable" end
    if event.Kind ~= step.Kind or event.TargetId ~= step.TargetId then
        return false, "OriginalQuestWrongStage"
    end
    -- Each actual monster life has one stable receipt, independent of
    -- EventId. Changing the event wrapper cannot credit the same kill.
    if step.Kind == "QuestMonsterDefeat" then
        local receipt_id = event.MonsterReceiptId
        if type(receipt_id) ~= "string" or #receipt_id == 0
            or #receipt_id > 108
        then
            return false, "OriginalQuestMonsterReceiptRequired"
        end
        if current.AppliedEvents["Kill:" .. receipt_id] == true then
            return false, "OriginalQuestMonsterAlreadyCredited"
        end
    end
    local permitted_proofs = STAGE_PROOFS[step.TargetId] or {}
    if event.VerifiedProofIds ~= nil
        and type(event.VerifiedProofIds) ~= "table"
    then
        return false, "OriginalQuestUnexpectedProof"
    end
    for proof_id, verified in pairs(event.VerifiedProofIds or {}) do
        if verified == true and permitted_proofs[proof_id] ~= true then
            return false, "OriginalQuestUnexpectedProof"
        end
    end
    if step.RequiresTrialWeapon and event.TrialWeaponVerified ~= true then
        return false, "OriginalTrialWeaponRequired"
    end
    if step.TargetId == "Vela" and current.Step == 2
        and event.TrialWeaponsGranted ~= true
    then
        return false, "OriginalTrialWeaponRequired"
    end
    if step.TargetId == "CryptSentinel"
        and (type(event.VerifiedProofIds) ~= "table"
            or event.VerifiedProofIds.SpartoiBone ~= true)
    then
        return false, "OriginalQuestLootProofRequired"
    end
    if step.TargetId == "Vela" and current.Step == 4
        and (type(current.Proofs) ~= "table"
            or current.Proofs.SpartoiBone10 ~= true)
    then
        return false, "OriginalQuestLootProofRequired"
    end
    if step.TargetId == "CaptainAshford" and current.Step == 5
        and (type(current.Proofs) ~= "table"
            or current.Proofs.SpartoiBone10 ~= true)
    then
        return false, "OriginalQuestLootProofRequired"
    end
    if step.TargetId == "WardenThorne" and current.Step == 4 then
        for letter_id in pairs(LETTER_IDS) do
            if type(current.Proofs) ~= "table"
                or current.Proofs[letter_id] ~= true
            then
                return false, "OriginalQuestLootProofRequired"
            end
        end
    end
    if step.TargetId == "CaptainAshford" and current.Step == 7 then
        for _, proof_id in ipairs({
            "StolenJewelry", "StolenTomes",
            "StolenRing", "StolenNecklace",
        }) do
            if type(current.Proofs) ~= "table"
                or current.Proofs[proof_id] ~= true
            then
                return false, "OriginalQuestLootProofRequired"
            end
        end
    end
    if quest.BranchId == "ElvenScout"
        and current.Step >= 7
        and (type(current.Proofs) ~= "table"
            or current.Proofs.RustedKey ~= true)
    then
        return false, "OriginalQuestLootProofRequired"
    end
    if quest.BranchId == "HumanWarrior" then
        if step.TargetId == "RidgeMarauder"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.IronrootToken ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "SmithOrla" and current.Step == 4
            and (type(current.Proofs) ~= "table"
                or current.Proofs.IronrootToken4 ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "Ridgebreaker"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.RidgebreakerSigil ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "MarshalTorren" and current.Step == 6
            and (type(current.Proofs) ~= "table"
                or current.Proofs.RidgebreakerSigil ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
    end
    if quest.BranchId == "HumanWizard" then
        if step.TargetId == "AshveilAcolyte"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.AetherglassShard ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "ArchivistNeris" and current.Step == 4
            and (type(current.Proofs) ~= "table"
                or current.Proofs.AetherglassShards3 ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "CinderboundConjurer"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.CinderboundEmberSigil ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "MagisterOrwyn" and current.Step == 6
            and (type(current.Proofs) ~= "table"
                or current.Proofs.CinderboundEmberSigil ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
    end
    if quest.BranchId == "ElvenKnight" then
        if step.TargetId == "RootboundMarauder"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.VerdantPatrolReport ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "WardenCaer" and current.Step == 4
            and (type(current.Proofs) ~= "table"
                or current.Proofs.VerdantPatrolReports3 ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "ThornboundColossus"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.VerdantGuardianSeal ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "SentinelIlyra" and current.Step == 6
            and (type(current.Proofs) ~= "table"
                or current.Proofs.VerdantGuardianSeal ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
    end
    if quest.BranchId == "HumanKnight" then
        if step.TargetId == "GloamStriker"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.StonewatchBadge ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "QuartermasterDena"
            and current.Step == 4
            and (type(current.Proofs) ~= "table"
                or current.Proofs.StonewatchBadge3 ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "GloamBulwark"
            and (type(event.VerifiedProofIds) ~= "table"
                or event.VerifiedProofIds.GloamBulwarkSeal ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
        if step.TargetId == "CaptainRowan" and current.Step == 6
            and (type(current.Proofs) ~= "table"
                or current.Proofs.GloamBulwarkSeal ~= true)
        then
            return false, "OriginalQuestLootProofRequired"
        end
    end
    if step.TargetId == "BrackenRaider" then
        local ids = {"PriasLetter1", "PriasLetter2",
            "PriasLetter3", "PriasLetter4"}
        local fresh_count = 0
        local verified = event.VerifiedProofIds or {}
        for _, id in ipairs(ids) do
            if verified[id] == true then
                if type(current.Proofs) == "table"
                    and current.Proofs[id] == true
                then
                    return false, "OriginalQuestDistinctLetterRequired"
                end
                fresh_count += 1
            end
        end
        if fresh_count ~= 1 then
            return false, "OriginalQuestDistinctLetterRequired"
        end
    end
    -- Loot proof is checked against the *actual* server-authored item
    -- set, not merely kill count. Missing item bindings cannot finish it.
    if step.TargetId == "CinderBrigand" then
        local required = {
            "StolenJewelry", "StolenTomes",
            "StolenRing", "StolenNecklace",
        }
        if type(event.VerifiedProofIds) ~= "table" then
            return false, "OriginalQuestLootProofRequired"
        end
        for _, id in ipairs(required) do
            if event.VerifiedProofIds[id] ~= true then
                return false, "OriginalQuestLootProofRequired"
            end
        end
    end
    if step.TargetId == "BrackenWarden"
        and (type(event.VerifiedProofIds) ~= "table"
            or event.VerifiedProofIds.RustedKey ~= true)
    then
        return false, "OriginalQuestLootProofRequired"
    end
    return true, nil
end

--[[
Advances one verified world action without awarding an advanced class.

Args:
    quest (any): Exact class-specific source quest.
    current (any): Exclusive profile-mutation quest state.
    event (any): Previously verified server-owned world action.

Returns:
    any: Updated quest progress with ordered action deduplication.
]]
function Rules.advance(quest: any, current: any, event: any): any
    local ok, reason = Rules.can_progress(quest, current, event)
    if not ok then return {ok = false, reason = reason} end
    local step = quest.Steps[current.Step]
    current.AppliedEvents[event.EventId] = true
    if step.Kind == "QuestMonsterDefeat" then
        current.AppliedEvents["Kill:" .. event.MonsterReceiptId] = true
    end
    if type(current.Proofs) ~= "table" then
        current.Proofs = {}
    end
    for id, verified in pairs(event.VerifiedProofIds or {}) do
        if verified == true then current.Proofs[id] = true end
    end
    current.Count = math.min(step.Required, (current.Count or 0) + 1)
    if step.TargetId == "RidgeMarauder"
        and current.Count == step.Required
    then
        current.Proofs.IronrootToken4 = true
    end
    if step.TargetId == "GloamStriker"
        and current.Count == step.Required
    then
        current.Proofs.StonewatchBadge3 = true
    end
    if step.TargetId == "AshveilAcolyte"
        and current.Count == step.Required
    then
        current.Proofs.AetherglassShards3 = true
    end
    if step.TargetId == "RootboundMarauder"
        and current.Count == step.Required
    then
        current.Proofs.VerdantPatrolReports3 = true
    end
    if step.TargetId == "CryptSentinel"
        and current.Count == step.Required
    then
        -- Never accept an aggregate ten-bone proof from an incoming event.
        current.Proofs.SpartoiBone10 = true
    end
    if current.Count >= step.Required then
        current.Step += 1
        current.Count = 0
    end
    if current.Step > #quest.Steps then
        current.Ready = true
    end
    return {
        ok = true, reason = nil, Step = current.Step,
        Count = current.Count, Ready = current.Ready,
    }
end

return table.freeze(Rules)
