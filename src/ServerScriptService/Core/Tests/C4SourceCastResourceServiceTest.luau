--!strict
-- Human Wizard split-MP source cast lifecycle transaction regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local CastContract = require(
    ServerScriptService.Core.Services.C4SourceCastContractService
)
local CastResources = require(
    ServerScriptService.Core.Services.C4SourceCastResourceService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local USER_ID = 938192
local checks = 0
local player = {
    UserId = USER_ID,
}

local source_active = true
local mana_current = 30

local FakeResources = {}

--[[
Reports disposable source-cutover authority for the current test owner.

Args:
    subject (any): Candidate cast owner.

Returns:
    boolean: Test-controlled active state for only the expected owner.
]]
function FakeResources.is_active(subject: any): boolean
    return subject == player and source_active
end

local FakeMana = {}

--[[
Applies the same total-affordability/initial-spend shape as ManaService.

Args:
    subject (any): Expected disposable cast owner.
    initial_amount (number): Exact source initial MP charge.
    completion_amount (number): Exact source launch MP charge.

Returns:
    boolean: True when total cost is affordable and initial MP is spent.
]]
function FakeMana.try_begin_split_spend(
    subject: any,
    initial_amount: number,
    completion_amount: number
): boolean
    if subject ~= player
        or mana_current < initial_amount + completion_amount
    then
        return false
    end

    mana_current -= initial_amount
    return true
end

--[[
Applies the source launch-time MP charge with zero-floor semantics.

Args:
    subject (any): Expected disposable cast owner.
    completion_amount (number): Exact source launch MP charge.

Returns:
    number: Actual MP removed.
]]
function FakeMana.finish_split_spend(
    subject: any,
    completion_amount: number
): number
    if subject ~= player then
        return 0
    end

    local before = mana_current
    mana_current = math.max(0, mana_current - completion_amount)
    return before - mana_current
end

--[[
Counts one split-MP source lifecycle assertion.

Args:
    condition (boolean): Observed transaction state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Cast Resource] " .. label)
end

--[[
Builds an authentic level-30 Emberweaver owning one direct spell rank.

Args:
    rank (number): Purchased Emberweaver Ember Bolt rank.

Returns:
    any: Server-owned profile-shaped source identity.
]]
local function wizard_character(rank: number): any
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
        OriginalFirstTransferReceiptId = "TEMP_SourceCastResourceReceipt",
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
        PurchasedRank = rank,
        Proficiency = 0,
    }

    return character
end

--[[
Creates a fresh isolated source cast resource lifecycle.

Args:
    None.

Returns:
    any: Service using real source contract and disposable resource authorities.
]]
local function service(): any
    return CastResources.new({
        CastContract = CastContract,
        Resources = FakeResources,
        Mana = FakeMana,
    })
end

--[[
Checks exact rank-six initial and launch MP phases.

Args:
    None.

Returns:
    nil: Confirms 6 MP at start and 21 MP at commit.
]]
local function check_complete_cast()
    Runtime.set_character(USER_ID, wizard_character(6))
    source_active = true
    mana_current = 30

    local lifecycle = service()
    local begun, begin_reason = lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    )
    check(
        begun ~= nil
            and begin_reason == nil
            and mana_current == 24
            and begun.InitialMpSpent == 6
            and begun.LaunchMpPending == 21,
        "rank-six cast start spends only exact initial MP"
    )
    check(
        lifecycle:snapshot(player).Pending,
        "successful cast start owns one private pending receipt"
    )

    local committed, commit_reason = lifecycle:commit_cast(
        player,
        begun.CastId
    )
    check(
        committed ~= nil
            and commit_reason == nil
            and committed.LaunchMpRequested == 21
            and committed.LaunchMpSpent == 21
            and mana_current == 3,
        "rank-six launch spends exact source ongoing MP"
    )
    check(
        not lifecycle:snapshot(player).Pending,
        "completed source cast clears its private receipt"
    )
end

--[[
Checks pre-cast total affordability and duplicate pending-cast rejection.

Args:
    None.

Returns:
    nil: Prevents partial initial spends and overlapping owner receipts.
]]
local function check_begin_denials()
    Runtime.set_character(USER_ID, wizard_character(6))
    source_active = true
    mana_current = 26

    local lifecycle = service()
    local denied, denied_reason = lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    )
    check(
        denied == nil
            and denied_reason == "C4SourceCastManaInsufficient"
            and mana_current == 26,
        "26 MP cannot begin the exact 27-MP rank-six source cast"
    )

    mana_current = 30
    local begun = assert(lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    ))
    local duplicate, duplicate_reason = lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    )
    check(
        duplicate == nil
            and duplicate_reason == "C4SourceCastAlreadyPending"
            and mana_current == 24,
        "pending owner cannot spend another source initial charge"
    )
    lifecycle:cancel_cast(player, begun.CastId)
end

--[[
Checks interruption preserves initial MP and never spends launch MP.

Args:
    None.

Returns:
    nil: Confirms source interruption semantics and receipt invalidation.
]]
local function check_cancel()
    Runtime.set_character(USER_ID, wizard_character(6))
    source_active = true
    mana_current = 30

    local lifecycle = service()
    local begun = assert(lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    ))
    local cancelled, reason = lifecycle:cancel_cast(
        player,
        begun.CastId
    )

    check(
        cancelled
            and reason == nil
            and mana_current == 24
            and not lifecycle:snapshot(player).Pending,
        "interrupted cast keeps 6 initial MP spent and skips 21 launch MP"
    )
    local replay, replay_reason = lifecycle:commit_cast(
        player,
        begun.CastId
    )
    check(
        replay == nil
            and replay_reason == "C4SourceCastReceiptInvalid"
            and mana_current == 24,
        "cancelled receipt cannot be replayed for a launch spend"
    )
end

--[[
Checks class/rank/cutover authority is revalidated before launch.

Args:
    None.

Returns:
    nil: Prevents stale source receipts from surviving authority changes.
]]
local function check_authority_changes()
    Runtime.set_character(USER_ID, wizard_character(6))
    source_active = true
    mana_current = 30

    local lifecycle = service()
    local begun = assert(lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    ))
    Runtime.set_character(USER_ID, wizard_character(5))

    local changed, changed_reason = lifecycle:commit_cast(
        player,
        begun.CastId
    )
    check(
        changed == nil
            and changed_reason == "C4SourceCastAuthorityChanged"
            and mana_current == 24,
        "rank change invalidates launch without refunding initial MP"
    )

    Runtime.set_character(USER_ID, wizard_character(6))
    mana_current = 30
    source_active = true
    lifecycle = service()
    begun = assert(lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    ))
    source_active = false

    local inactive, inactive_reason = lifecycle:commit_cast(
        player,
        begun.CastId
    )
    check(
        inactive == nil
            and inactive_reason
                == "C4SourceCastResourceCutoverInactive"
            and mana_current == 24,
        "cutover withdrawal cancels pending launch without refund"
    )

    mana_current = 30
    local no_start, no_start_reason = lifecycle:begin_cast(
        player,
        "EmberweaverEmberBolt"
    )
    check(
        no_start == nil
            and no_start_reason
                == "C4SourceCastResourceCutoverInactive"
            and mana_current == 30,
        "non-cutover owner cannot begin source MP lifecycle"
    )
end

--[[
Runs Human Wizard split-MP source lifecycle acceptance.

Args:
    None.

Returns:
    nil: Prints bounded source-only evidence when every transaction passes.
]]
local function main()
    local capability = CastResources.new({
        CastContract = CastContract,
        Resources = FakeResources,
        Mana = FakeMana,
    }):capability()
    check(
        capability.Available
            and capability.RequiresSourceResourceCutover
            and capability.ServerOwnedPurchasedRank
            and capability.TotalManaAffordabilityAtStart
            and capability.InitialManaSpentAtCastStart
            and capability.LaunchManaSpentAtCommit
            and capability.InterruptedInitialManaNotRefunded
            and capability.RevalidatesRankAtCommit
            and capability.OnePendingCastPerOwner
            and not capability.LiveDamageIntegrated
            and not capability.ClientAuthority,
        "capability preserves source split-MP authority without live damage"
    )

    check_complete_cast()
    check_begin_denials()
    check_cancel()
    check_authority_changes()

    Runtime.clear_character(USER_ID)

    print((
        "[C4 Source Cast Resource] SOURCE_ONLY_PASS: %d assertions "
        .. "split=true cancel=true revalidate=true live=false"
    ):format(checks))
end

main()
