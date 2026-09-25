--!strict
-- Human Wizard source cast-time planning and fail-closed reuse regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local CastContract = require(
    ServerScriptService.Core.Services.C4SourceCastContractService
)
local TimingService = require(
    ServerScriptService.Core.Services.C4SourceCastTimingService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local USER_ID = 938193
local checks = 0

local shot_state = {
    Spiritshot = false,
    BlessedSpiritshot = false,
}
local snapshot_calls = 0
local boundary_state = {
    ScopeId = "HumanWizard",
    SourceStatCandidateReady = true,
    SourceStatCandidate = {
        MAGICAL_ATTACK_SPEED = 333,
    },
}

local FakeShots = {}

--[[
Returns detached source shot state without consuming either charge.

Args:
    user_id (number): Expected Human Wizard owner.

Returns:
    any: Current disposable source magical-shot snapshot.
]]
function FakeShots:snapshot(user_id: number): any
    assert(user_id == USER_ID)
    snapshot_calls += 1
    return table.clone(shot_state)
end

--[[
Returns the disposable authenticated source stat boundary.

Args:
    user_id (number): Expected Human Wizard owner.

Returns:
    (any?, string?): Current boundary state or a stable owner denial.
]]
local function boundary_provider(
    user_id: number
): (any?, string?)
    if user_id ~= USER_ID then
        return nil, "OriginalCharacterIdentityNotVerified"
    end

    return boundary_state, nil
end

--[[
Counts one Human Wizard timing-planner assertion.

Args:
    condition (boolean): Observed source-only timing state.
    label (string): Failure description for focused Studio diagnostics.

Returns:
    nil: Raises on failure and increments the check count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Cast Timing] " .. label)
end

--[[
Builds an authentic level-30 Emberweaver with direct and slowed magic.

Args:
    None.

Returns:
    any: Profile-shaped authenticated first-transfer owner.
]]
local function wizard_character(): any
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
        OriginalFirstTransferReceiptId = "TEMP_SourceTimingReceipt",
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
        PurchasedRank = 6,
        Proficiency = 0,
    }
    character.Progression.Skills.EmberweaverFrostLance = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 2,
        Proficiency = 0,
    }

    return character
end

--[[
Creates the timing service around real cast mapping and isolated read state.

Args:
    None.

Returns:
    any: Source-only timing planner.
]]
local function service(): any
    return TimingService.new(FakeShots, {
        CastContract = CastContract,
        BoundaryProvider = boundary_provider,
    })
end

--[[
Checks uncharged and accelerated Ember Bolt timing at source attack speed.

Args:
    None.

Returns:
    nil: Confirms exact hit/interrupt timing and read-only shot semantics.
]]
local function check_ember_bolt_timing()
    local timing = service()
    boundary_state.ScopeId = "HumanWizard"
    boundary_state.SourceStatCandidateReady = true
    boundary_state.SourceStatCandidate.MAGICAL_ATTACK_SPEED = 333
    shot_state.Spiritshot = false
    shot_state.BlessedSpiritshot = false
    snapshot_calls = 0

    local normal = assert(timing:resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    ))
    check(
        normal.SourceMagicAttackSpeed == 333
            and normal.SourceAuthoredHitTimeMs == 4000
            and normal.FinalHitTimeMs == 4000
            and normal.CastInterruptTimeMs == 2000,
        "uncharged rank-six Ember Bolt preserves source cast time"
    )
    check(
        normal.SourceAuthoredReuseDelayMs == 6000
            and normal.UnmodifiedReuseDelayMs == 6000
            and not normal.FinalReuseDelayReady
            and normal.ReuseBlocker
                == "OriginalSkillReuseRateNotIntegrated",
        "reuse stays fail-closed while exposing neutral diagnostic scaling"
    )
    check(
        snapshot_calls == 1
            and not shot_state.Spiritshot
            and not shot_state.BlessedSpiritshot
            and not normal.ShotStateConsumed,
        "uncharged timing reads shot state without consuming it"
    )

    shot_state.Spiritshot = true
    local spiritshot = assert(timing:resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    ))
    check(
        spiritshot.FinalHitTimeMs == 2800
            and spiritshot.CastInterruptTimeMs == 1400
            and spiritshot.SpiritshotCharged
            and not spiritshot.BlessedSpiritshotCharged,
        "Spiritshot applies exact seventy-percent cast acceleration"
    )
    check(
        shot_state.Spiritshot
            and not spiritshot.ShotStateConsumed,
        "timing preview never consumes the charged Spiritshot"
    )

    shot_state.Spiritshot = false
    shot_state.BlessedSpiritshot = true
    local blessed = assert(timing:resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    ))
    check(
        blessed.FinalHitTimeMs == 2800
            and blessed.BlessedSpiritshotCharged
            and shot_state.BlessedSpiritshot,
        "Blessed Spiritshot accelerates timing without early consumption"
    )
end

--[[
Checks a Human Wizard skill with authored coolTime.

Args:
    None.

Returns:
    nil: Confirms shot acceleration affects hit/cool time with no cool floor.
]]
local function check_frost_lance_cool_time()
    boundary_state.SourceStatCandidate.MAGICAL_ATTACK_SPEED = 333
    shot_state.Spiritshot = true
    shot_state.BlessedSpiritshot = false

    local result = assert(service():resolve(
        USER_ID,
        "EmberweaverFrostLance"
    ))
    check(
        result.SourceSkillId == 1184
            and result.SourceRank == 6
            and result.SourceAuthoredHitTimeMs == 3100
            and result.FinalHitTimeMs == 2170
            and result.CastInterruptTimeMs == 1085,
        "rank-two Frost Lance maps Ice Bolt six and scales hit time"
    )
    check(
        result.SourceAuthoredCoolTimeMs == 200
            and result.FinalCoolTimeMs == 140,
        "source cool time accelerates without the 500 ms hit-time floor"
    )
    check(
        result.SourceAuthoredReuseDelayMs == 8000
            and result.UnmodifiedReuseDelayMs == 8000
            and not result.FinalReuseDelayReady,
        "Frost Lance final reuse also remains explicitly unresolved"
    )
end

--[[
Checks attack-speed scaling and strict source-boundary failures.

Args:
    None.

Returns:
    nil: Confirms M.Atk.Spd changes timing and invalid authority fails closed.
]]
local function check_boundary_rules()
    shot_state.Spiritshot = false
    shot_state.BlessedSpiritshot = false
    boundary_state.ScopeId = "HumanWizard"
    boundary_state.SourceStatCandidateReady = true
    boundary_state.SourceStatCandidate.MAGICAL_ATTACK_SPEED = 666

    local fast = assert(service():resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    ))
    check(
        fast.FinalHitTimeMs == 2000
            and fast.CastInterruptTimeMs == 1000
            and fast.UnmodifiedReuseDelayMs == 3000,
        "double source M.Atk.Spd halves hit and neutral reuse timing"
    )

    boundary_state.SourceStatCandidate.MAGICAL_ATTACK_SPEED = 0
    local invalid, invalid_reason = service():resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    )
    check(
        invalid == nil
            and invalid_reason == "OriginalMagicAttackSpeedUnavailable",
        "nonpositive source M.Atk.Spd fails closed"
    )

    boundary_state.SourceStatCandidate.MAGICAL_ATTACK_SPEED = 333
    boundary_state.ScopeId = "HumanMystic"
    local mismatched, mismatch_reason = service():resolve(
        USER_ID,
        "EmberweaverEmberBolt"
    )
    check(
        mismatched == nil
            and mismatch_reason == "OriginalCastSourceScopeMismatch",
        "cast source scope must match authenticated stat source scope"
    )

    boundary_state.ScopeId = "HumanWizard"
    local missing, missing_reason = service():resolve(
        USER_ID,
        "EmberweaverSlumberHex"
    )
    check(
        missing == nil
            and missing_reason == "CreativeCastSkillRankNotOwned",
        "unowned spell cannot request source timing"
    )
end

--[[
Runs Human Wizard source cast-time planning acceptance.

Args:
    None.

Returns:
    nil: Prints source-only pass evidence when every timing gate succeeds.
]]
local function main()
    Runtime.set_character(USER_ID, wizard_character())

    local capability = service():capability()
    check(
        capability.Available
            and capability.FinalMagicCastTimeIntegrated
            and capability.FinalMagicCoolTimeIntegrated
            and capability.ReadOnlyShotAccelerationIntegrated
            and capability.CastInterruptWindowIntegrated
            and capability.UnmodifiedReuseDiagnosticIntegrated
            and not capability.FinalReuseDelayIntegrated
            and capability.ReuseBlocker
                == "OriginalSkillReuseRateNotIntegrated"
            and not capability.LiveSchedulingIntegrated
            and not capability.ClientAuthority,
        "capability exposes exact cast timing and fail-closed final reuse"
    )

    check_ember_bolt_timing()
    check_frost_lance_cool_time()
    check_boundary_rules()

    Runtime.clear_character(USER_ID)

    print((
        "[C4 Source Cast Timing] SOURCE_ONLY_PASS: %d assertions "
        .. "hit=true cool=true shots=peek reuse=blocked live=false"
    ):format(checks))
end

main()
