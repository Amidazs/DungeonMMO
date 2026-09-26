--!strict
-- Server-owned Human Wizard source cast-cost/timing contract regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local CastContract = require(
    ServerScriptService.Core.Services.C4SourceCastContractService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local USER_ID = 938191
local checks = 0

--[[
Counts one source cast-contract assertion.

Args:
    condition (boolean): Observed server contract state.
    label (string): Failure description for focused Studio output.

Returns:
    nil: Raises on failure and increments the check count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Cast] " .. label)
end

--[[
Builds an authentically represented Human Wizard transfer owner.

Args:
    creative_rank (number): Purchased Emberweaver Ember Bolt rank.

Returns:
    any: Profile-shaped level-30 server-owned Emberweaver state.
]]
local function wizard_character(creative_rank: number): any
    local character =
        ProfileSchema.create_default(USER_ID).Characters.Slot1
    local quest = assert(QuestStages.get("HumanWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Mage",
        ClassId = "Emberweaver",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "HumanWizard",
        OriginalFirstTransferClassId = "Emberweaver",
        OriginalFirstTransferReceiptId = "TEMP_SourceCastReceipt",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = quest.BranchId,
            Step = #quest.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }
    character.Progression.Skills.EmberweaverEmberBolt = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = creative_rank,
        Proficiency = 0,
    }

    return character
end

--[[
Checks exact Blaze rank-six source cost, timing and range metadata.

Args:
    None.

Returns:
    nil: Verifies the contract preserves raw source fields without live use.
]]
local function check_rank_six()
    Runtime.set_character(USER_ID, wizard_character(6))

    local contract, reason = CastContract.resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    )
    check(
        contract ~= nil and reason == nil,
        "owned Emberweaver rank resolves one source cast contract"
    )
    local resolved = assert(contract)

    check(
        resolved.CreativeRank == 6
            and resolved.SourceScopeId == "HumanWizard"
            and resolved.SourceSkillId == 1220
            and resolved.SourceRank == 6
            and resolved.SourceSkillType == "MDAM"
            and resolved.SourceOperateType == "ACTIVE"
            and resolved.SourceTarget == "TARGET_ONE"
            and resolved.SourceIsMagic,
        "rank six resolves exact Human Wizard Blaze identity"
    )
    check(
        resolved.SourceMpInitialConsume == 6
            and resolved.SourceMpConsume == 21
            and resolved.SourceMpTotal == 27,
        "rank six preserves exact split source MP fields"
    )
    check(
        resolved.SourceHitTimeMs == 4000
            and resolved.SourceCoolTimeMs == nil
            and resolved.SourceReuseDelayMs == 6000,
        "rank six preserves exact source timing metadata"
    )
    check(
        resolved.SourceCastRange == 750
            and resolved.SourceEffectRange == 1250,
        "rank six preserves source range metadata without stud conversion"
    )
    check(
        resolved.SourceOnly
            and not resolved.LiveResourceSpendIntegrated
            and not resolved.LiveTimingIntegrated
            and not resolved.ClientAuthority,
        "source cast metadata cannot imply live or client authority"
    )
end

--[[
Checks every currently staged Human Wizard targeted cast family.

Args:
    None.

Returns:
    nil: Verifies reviewed direct/periodic skills keep exact source metadata.
]]
local function check_staged_wizard_cast_families()
    local character = wizard_character(6)
    character.Progression.Skills.EmberweaverFlameBurst = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 6,
        Proficiency = 0,
    }
    character.Progression.Skills.EmberweaverFocusedBolt = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 3,
        Proficiency = 0,
    }
    character.Progression.Skills.EmberweaverVenomHex = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 2,
        Proficiency = 0,
    }
    Runtime.set_character(USER_ID, character)

    local cases = {
        {
            SkillId = "EmberweaverFlameBurst",
            CreativeRank = 6,
            SourceSkillId = 1172,
            SourceRank = 6,
            SkillType = "MDAM",
            InitialMp = 6,
            OngoingMp = 21,
            HitTimeMs = 1500,
            ReuseMs = 2500,
            CastRange = 150,
            EffectRange = 650,
        },
        {
            SkillId = "EmberweaverFocusedBolt",
            CreativeRank = 3,
            SourceSkillId = 1274,
            SourceRank = 3,
            SkillType = "MDAM",
            InitialMp = 3,
            OngoingMp = 11,
            HitTimeMs = 2000,
            ReuseMs = 3000,
            CastRange = 400,
            EffectRange = 900,
        },
        {
            SkillId = "EmberweaverVenomHex",
            CreativeRank = 2,
            SourceSkillId = 1168,
            SourceRank = 3,
            SkillType = "DEBUFF",
            InitialMp = 6,
            OngoingMp = 21,
            HitTimeMs = 4000,
            ReuseMs = 12000,
            CastRange = 600,
            EffectRange = 1100,
        },
    }

    for _, case in ipairs(cases) do
        local resolved = assert(CastContract.resolve(
            USER_ID,
            case.SkillId
        ))
        check(
            resolved.CreativeRank == case.CreativeRank
                and resolved.SourceSkillId == case.SourceSkillId
                and resolved.SourceRank == case.SourceRank
                and resolved.SourceSkillType == case.SkillType
                and resolved.SourceTarget == "TARGET_ONE"
                and resolved.SourceMpInitialConsume == case.InitialMp
                and resolved.SourceMpConsume == case.OngoingMp
                and resolved.SourceHitTimeMs == case.HitTimeMs
                and resolved.SourceReuseDelayMs == case.ReuseMs
                and resolved.SourceCastRange == case.CastRange
                and resolved.SourceEffectRange == case.EffectRange,
            case.SkillId .. " preserves reviewed exact source cast metadata"
        )
    end
end

--[[
Checks that the contract always follows the currently purchased server rank.

Args:
    None.

Returns:
    nil: Confirms no caller-supplied source/creative rank exists.
]]
local function check_server_rank_binding()
    Runtime.set_character(USER_ID, wizard_character(5))

    local contract = assert(CastContract.resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    ))
    check(
        contract.CreativeRank == 5
            and contract.SourceRank == 5
            and contract.SourceMpInitialConsume == 5
            and contract.SourceMpConsume == 20
            and contract.SourceHitTimeMs == 4000
            and contract.SourceReuseDelayMs == 6000,
        "contract follows server-owned purchased rank after state change"
    )
end

--[[
Checks unowned and forged first-transfer identities fail closed.

Args:
    None.

Returns:
    nil: Prevents source cast metadata from becoming a class/rank oracle.
]]
local function check_denials()
    local missing, missing_reason = CastContract.resolve(
        USER_ID,
        "EmberweaverSlumberHex"
    )
    check(
        missing == nil
            and missing_reason == "CreativeCastSkillRankNotOwned",
        "unowned creative spell has no source cast contract"
    )

    local forged = wizard_character(6)
    forged.Identity.ClassId = "Mage"
    forged.ClassAdvancement = {
        Version = 1,
    }
    Runtime.set_character(USER_ID, forged)

    local denied, denied_reason = CastContract.resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    )
    check(
        denied == nil
            and denied_reason
                == "CreativeSkillNotActiveSourceCandidate",
        "forged starter identity cannot resolve transfer cast metadata"
    )

    local invalid, invalid_reason = CastContract.resolve(
        USER_ID,
        ""
    )
    check(
        invalid == nil
            and invalid_reason == "InvalidOriginalCastRequest",
        "malformed cast request fails before source resolution"
    )
end

--[[
Runs the Human Wizard source cast-contract acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded success marker when all checks pass.
]]
local function main()
    local capability = CastContract.capability()
    check(
        capability.Available
            and capability.ServerOwnedPurchasedRank
            and capability.ExactSourceMpFields
            and capability.ExactSourceTimingFields
            and capability.ExactSourceRangeMetadata
            and not capability.LiveResourceSpendIntegrated
            and not capability.LiveTimingIntegrated
            and not capability.ClientAuthority,
        "capability declares source-only server authority"
    )

    check_rank_six()
    check_staged_wizard_cast_families()
    check_server_rank_binding()
    check_denials()

    Runtime.clear_character(USER_ID)

    print((
        "[C4 Source Cast] SOURCE_ONLY_PASS: %d assertions "
        .. "rank=true mp=true timing=true range=true live=false"
    ):format(checks))
end

main()
