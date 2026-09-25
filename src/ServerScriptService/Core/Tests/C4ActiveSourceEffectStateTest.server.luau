--!strict
-- Server-only C4 active-source-effect resolver and registry regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Careers = require(Shared.OriginalFirstTransferDefinitions)
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local ActiveState = require(
    ServerScriptService.Core.Services.C4ActiveSourceEffectState
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local TEST_OWNER = 938179
local checks = 0

--[[
Counts one active-source-state assertion.

Args:
    valid (boolean): Expected authoritative registry condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Active Source State] " .. label)
end

--[[
Builds a complete original first-transfer test character.

Args:
    race_id (string): Human or Elf original race.
    class_id (string): Current creative first-transfer class ID.
    level (number): Current launch-level character level.

Returns:
    any: Profile-shaped authenticated character fixture.
]]
local function original_character(
    race_id: string,
    class_id: string,
    level: number
): any
    local character = ProfileSchema
        .create_default(TEST_OWNER).Characters.Slot1
    local career = assert(Careers.for_class(class_id))
    local stage = assert(QuestStages.get(career.BranchId))
    local proofs = {}

    for _, proof_id in ipairs(stage.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = level
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = career.BaseClassId,
        ClassId = class_id,
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = career.BranchId,
        OriginalFirstTransferClassId = career.Id,
        OriginalFirstTransferReceiptId =
            "TEMP_C4ActiveSourceStateMentor",
        OriginalFirstTransferQuest = {
            QuestId = stage.Id,
            BranchId = career.BranchId,
            Step = #stage.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }

    return character
end

--[[
Stores one actually owned creative skill rank in the fixture.

Args:
    character (any): Mutable server-owned test character.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Mutates only the disposable fixture progression state.
]]
local function own_skill(
    character: any,
    skill_id: string,
    rank: number
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Builds a disposable owner compatible with the server-only registry contract.

Args:
    user_id (number): Seeded ProgressionRuntimeState user ID.

Returns:
    any: Table-shaped owner with a stable current-character identity.
]]
local function owner_fixture(user_id: number): any
    return {
        UserId = user_id,
        Character = {
            Parent = true,
        },
    }
end

--[[
Checks learned toggles remain absent until a server executor activates them.

Args:
    None.

Returns:
    nil: Confirms attributes/ownership alone cannot mint active C4 state.
]]
local function check_activation_authority()
    local character = original_character("Human", "Ironvow", 30)
    own_skill(character, "IronvowAccuracyStance", 1)
    own_skill(character, "IronvowCriticalStance", 3)
    Runtime.set_character(TEST_OWNER, character)

    local owner = owner_fixture(TEST_OWNER)
    owner.Character.C4IronvowAccuracyActive = true

    local initial = ActiveState.snapshot(owner)
    check(
        initial.Authoritative and initial.ActiveCount == 0,
        "learned skills and forged display fields are not active effects"
    )

    local accuracy_ok, accuracy_reason = ActiveState.activate(
        owner,
        "IronvowAccuracyStance",
        1
    )
    check(
        accuracy_ok and accuracy_reason == nil,
        "server activation resolves Warrior Accuracy"
    )

    local accuracy = ActiveState.snapshot(owner)
    check(
        accuracy.ActiveCount == 1
            and accuracy.SourceRanks[1].SkillId == 256
            and accuracy.SourceRanks[1].Rank == 1
            and accuracy.SourceRanks[1].OperateType == "TOGGLE",
        "Warrior Accuracy records exact source 256 rank 1"
    )

    local critical_ok, critical_reason = ActiveState.activate(
        owner,
        "IronvowCriticalStance",
        3
    )
    check(
        critical_ok and critical_reason == nil,
        "server activation resolves Warrior critical stance"
    )

    local both = ActiveState.snapshot(owner)
    check(
        both.ActiveCount == 2
            and both.SourceRanks[1].SkillId == 256
            and both.SourceRanks[2].SkillId == 312
            and both.SourceRanks[2].Rank == 3,
        "multiple genuine toggles coexist as detached source ranks"
    )

    local bad_rank, bad_reason = ActiveState.activate(
        owner,
        "IronvowCriticalStance",
        4
    )
    check(
        not bad_rank
            and bad_reason == "CreativeActiveSkillRankNotOwned",
        "unowned creative rank cannot enter active source state"
    )

    ActiveState.deactivate(owner, "IronvowAccuracyStance")
    local after_off = ActiveState.snapshot(owner)
    check(
        after_off.ActiveCount == 1
            and after_off.SourceRanks[1].SkillId == 312,
        "explicit deactivation removes only the ended source effect"
    )

    owner.Character = {
        Parent = true,
    }
    local respawned = ActiveState.snapshot(owner)
    check(
        respawned.ActiveCount == 0,
        "character replacement invalidates all old active source state"
    )

    ActiveState.clear(owner)
    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks first-transfer characters can activate genuinely inherited starter buffs.

Args:
    None.

Returns:
    nil: Confirms the resolver searches the inherited starter source scope.
]]
local function check_inherited_active_source()
    local character = original_character(
        "Elf",
        "GreenwardWarden",
        30
    )
    own_skill(character, "ElvenFighterBattleCry", 1)
    Runtime.set_character(TEST_OWNER, character)

    local owner = owner_fixture(TEST_OWNER)
    local activated, reason = ActiveState.activate(
        owner,
        "ElvenFighterBattleCry",
        1
    )
    check(
        activated and reason == nil,
        "Warden can resolve an actually owned inherited Fighter buff"
    )

    local snapshot = ActiveState.snapshot(owner)
    check(
        snapshot.ActiveCount == 1
            and snapshot.SourceRanks[1].SkillId == 77
            and snapshot.SourceRanks[1].Rank == 1
            and snapshot.SourceRanks[1].OperateType == "ACTIVE",
        "inherited Fighter Battle Cry records source Attack Aura rank 1"
    )

    ActiveState.clear(owner)
    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks non-active source candidates and missing ownership fail closed.

Args:
    None.

Returns:
    nil: Confirms passives and absent purchases cannot masquerade as effects.
]]
local function check_denials()
    local character = original_character("Human", "Ironvow", 30)
    own_skill(character, "IronvowHeavyArmorTraining", 1)
    Runtime.set_character(TEST_OWNER, character)

    local owner = owner_fixture(TEST_OWNER)
    local passive_ok, passive_reason = ActiveState.activate(
        owner,
        "IronvowHeavyArmorTraining",
        1
    )
    check(
        not passive_ok
            and passive_reason
                == "CreativeSkillNotActiveSourceCandidate",
        "owned passive cannot enter the active-effect registry"
    )

    local missing_ok, missing_reason = ActiveState.activate(
        owner,
        "IronvowAccuracyStance",
        1
    )
    check(
        not missing_ok
            and missing_reason == "CreativeActiveSkillRankNotOwned",
        "learnable but unowned toggle cannot be registered"
    )

    ActiveState.clear(owner)
    Runtime.clear_character(TEST_OWNER)
end

--[[
Runs server-only active C4 source-effect state acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_activation_authority()
    check_inherited_active_source()
    check_denials()

    print((
        "[C4 Active Source State] SOURCE_ONLY_PASS: %d assertions "
        .. "authoritative=true attributes_ignored=true live_registry=true"
    ):format(checks))
end

main()
