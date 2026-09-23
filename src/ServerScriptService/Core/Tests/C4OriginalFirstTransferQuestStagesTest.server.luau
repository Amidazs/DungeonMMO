--!strict
-- Two historically sourced C4 quest flows; missing world actors fail closed.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local Skills = require(Shared.C4OriginalClassSkillCoverage)
local Rules = require(Shared.C4OriginalQuestProgressRules)
local SkillRules = require(Shared.SkillUnlockRules)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Selection = require(SSS.Core.Services.C4FirstTransferSelectionService)
local Service = require(SSS.Core.Services.C4OriginalFirstTransferQuestService)
local assertions = 0

--[[
Requires one genuine sourced stage, branch or persistent quest condition.

Args:
    condition (boolean): Verified factual source/authoritative state.
    label (string): Focused Studio assertion failure reason.

Returns:
    nil: Counts passing tests, raising on any false expectation.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[C4 Original Quest Stages] " .. label)
end

--[[
Creates a server-only, explicitly authenticated mock world event adapter.

Args:
    None.

Returns:
    any: Fixture simulating world listeners, NOT wired to client remotes.
]]
local function test_world(): any
    return {
        available = function(_self: any, quest: any): boolean
            return quest.WorldBindingStatus == "NotImplemented"
                and quest.SourceQuestId ~= nil
        end,
        verify = function(
            _self: any, user_id: number, event: any,
            quest: any, state: any
        ): boolean
            return event.ServerVerified == true
                and event.ActorUserId == user_id
                and type(state) == "table"
                and quest.BranchId == state.BranchId
        end,
    }
end

--[[
Sets up one actual original level-18 Fighter, choosing a race-specific path.

Args:
    profiles (any): Exclusive writer ProfileService.
    user_id (number): Isolated test character.
    race_id (string): Human or Elf.
    branch_id (string): Original selected C4 class.

Returns:
    nil: Persists selected branch without granting a class or quest loot.
]]
local function seed(
    profiles: any, user_id: number,
    race_id: string, branch_id: string
)
    check(profiles:load(user_id), "Original source profile loads")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Identity = {
            Version = 1, RaceId = race_id,
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Original race/Fighter identity saved")
    check(Selection.new(profiles, "Base"):choose(
        user_id, branch_id
    ).ok, "Character explicitly chooses only its original C4 class")
end

--[[
Builds one authenticated real-world-like stage event with quest loot proof.

Args:
    user_id (number): Exact profile owner.
    quest (any): Research-backed ordered original C4 source sequence.
    step_index (number): Current quest stage.
    count (number): Unique event within this source stage.

Returns:
    any: Server-verifiable world event, not an arbitrary client update.
]]
local function evidence(
    user_id: number, quest: any, step_index: number, count: number
): any
    local step = quest.Steps[step_index]
    local proofs = {}
    if step.TargetId == "RogueTrialSkeleton" then
        proofs.SpartoiBone = true
    elseif step.TargetId == "OlMahumPatrol" then
        proofs["PriasLetter" .. tostring(count)] = true
    elseif step.TargetId == "OlMahumSentry" then
        proofs.RustedKey = true
    elseif step.TargetId == "CatsEyeBandit" then
        for _, id in ipairs({
            "StolenJewelry", "StolenTomes",
            "StolenRing", "StolenNecklace",
        }) do proofs[id] = true end
    end
    return {
        EventId = "source-" .. tostring(user_id)
            .. "-" .. tostring(step_index) .. "-" .. tostring(count),
        ActorUserId = user_id, ServerVerified = true,
        Kind = step.Kind, TargetId = step.TargetId,
        TrialWeaponsGranted = step.TargetId == "Neti",
        TrialWeaponVerified = step.RequiresTrialWeapon == true,
        VerifiedProofIds = proofs,
    }
end

--[[
Tests the complete ordered original story, rejecting skipped/forged actions.

Args:
    profiles (any): Real profile and migration authority.
    service (any): Server-only mock-bound original quest progression.
    user_id (number): Chosen Human Rogue or Elven Scout.
    branch_id (string): Exact C4 class requiring independent stages.

Returns:
    nil: Verifies source-specific quest stages, persistence and no class grant.
]]
local function exercise(
    profiles: any, service: any, user_id: number, branch_id: string
)
    local quest = assert(Stages.get(branch_id))
    check(quest.BranchId == branch_id
        and quest.StartLevel == 18
        and quest.TransferLevel == 20,
        "Quest must retain authentic first-transfer level and class")
    local absent = service:record_world_event(
        user_id, evidence(user_id, quest, 1, 1)
    )
    check(not absent.ok and absent.reason == "OriginalQuestNotStarted",
        "Actual quest steps cannot progress before source quest starts")
    check(service:start(user_id).ok,
        "Selected original Fighter can start separately bound source quest")
    check(service:start(user_id).reason == "OriginalQuestAlreadyStarted",
        "Authenticated original quest start cannot be repeated")
    check(service:record_world_event(user_id, {
        EventId = "forged-client-event", ActorUserId = user_id,
        Kind = "NpcTalk", TargetId = quest.Steps[1].TargetId,
    }).reason == "OriginalQuestWorldEvidenceUnverified",
        "An event without genuine server-world proof cannot advance a step")
    check(service:record_world_event(
        user_id, evidence(user_id, quest, 2, 1)
    ).reason == "OriginalQuestWrongStage",
        "Talking to a future quest NPC cannot skip the original first NPC")

    for index, step in ipairs(quest.Steps) do
        local event = evidence(user_id, quest, index, 1)
        if step.RequiresTrialWeapon then
            event.TrialWeaponVerified = false
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalTrialWeaponRequired",
                "Original Neti weapon condition cannot be skipped")
            event.TrialWeaponVerified = true
        end
        if step.TargetId == "CatsEyeBandit"
            or step.TargetId == "OlMahumSentry"
            or step.TargetId == "RogueTrialSkeleton"
        then
            local proofs = event.VerifiedProofIds
            event.VerifiedProofIds = {}
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalQuestLootProofRequired",
                "Monster victory alone cannot replace required original loot")
            event.VerifiedProofIds = proofs
        end
        check(service:record_world_event(user_id, event).ok,
            "Authoritative source stage " .. tostring(index)
                .. " must advance with verified original evidence")
        check(service:record_world_event(
            user_id, event
        ).reason == "OriginalQuestEventAlreadyApplied",
            "Replayed server event cannot award source progress twice")
        for count = 2, step.Required do
            local next_event = evidence(user_id, quest, index, count)
            check(service:record_world_event(user_id, next_event).ok,
                "Each distinct source monster/drop needs its own proof")
        end
    end
    local state = assert(profiles:get_character(user_id, 1))
        .ClassAdvancement.OriginalFirstTransferQuest
    check(state.Ready == true and state.Step == #quest.Steps + 1,
        "Full original stage sequence, not a dungeon clear, readies quest")
    check(profiles:get_character(user_id, 1).Identity.ClassId == "Fighter"
        and profiles:get_character(user_id, 1)
            .ClassAdvancement.ActiveClassId == nil,
        "Completed backend quest stages cannot grant an unimplemented class")
    local starter = assert(profiles:get_character(user_id, 1))
    local can_train, locked_reason = SkillRules.can_train(
        starter, assert(SkillDefinitions.get("ScoutLockpicking")), 1
    )
    check(not can_train and locked_reason == "WrongClass",
        "Source choice or quest readiness cannot leak Scout skills to "
            .. "the original Fighter before a real level-20 transfer")
    check(profiles:save(user_id, "C4OriginalQuest"),
        "Source quest progress must persist to original profile adapter")
    check(profiles:release(user_id, "C4OriginalQuest"),
        "Quest ledger must release without deleting earned skills")
    check(profiles:load(user_id),
        "Original quest/skill profile must load again")
    local persisted = service:build_snapshot(user_id)
    check(persisted.ok and persisted.Ready == true
        and persisted.Step == #quest.Steps + 1
        and persisted.ClassAwarded == false,
        "Source-specific quest completion must survive genuine save/reload")
end

--[[
Checks all eighteen original C4 class skills remain separate from quests.

Args:
    None.

Returns:
    nil: Explicitly prevents calling two analogue inventories full C4.
]]
local function check_skill_scope()
    local report = Skills.report()
    check(report.OriginalFirstTransferClasses == 18
        and report.AnalogueRankInventoriesMapped == 2
        and report.OriginalInventoriesNotAudited == 16
        and report.ExactC4FirstTransferSkillCatalogueComplete == false,
        "396 analogue ranks cannot be mistaken for all eighteen C4 trees")
    local rogue = assert(Branches.find(
        "Human", "Fighter", "HumanRogue"
    ))
    local mapped = Skills.for_branch(rogue)
    check(mapped.MappedAnalogueRanks == 99
        and mapped.ExactC4RankParityCertified == false
        and mapped.OriginalTrainerSkillGateImplemented == false,
        "Mapped 99 Rogue analogues are not certified original C4 skills")
    local warrior = assert(Branches.find(
        "Human", "Fighter", "HumanWarrior"
    ))
    check(Skills.for_branch(warrior).MappedAnalogueRanks == 0,
        "The unimplemented Warrior source skills must not be invented")
    check(Stages.get("HumanWarrior") == nil,
        "A named Warrior source quest is not a completed implemented quest")
end

--[[
Runs isolated source quests, race/class choice and original skill accounting.

Args:
    None.

Returns:
    nil: Prints only completed actual server-profile assertion results.
]]
local function main()
    check_skill_scope()
    local profiles = Profiles.new(Adapter.new())
    seed(profiles, 99341, "Human", "HumanRogue")
    seed(profiles, 99342, "Elf", "ElvenScout")
    local unavailable = Service.new(profiles, "Base", nil)
    check(unavailable:start(99341).reason == "OriginalQuestWorldNotReady",
        "Production missing-world quests must fail closed, not auto-complete")
    local service = Service.new(profiles, "Base", test_world())
    exercise(profiles, service, 99341, "HumanRogue")
    exercise(profiles, service, 99342, "ElvenScout")
    check(not Service.new(profiles, "Dungeon", test_world()):start(
        99341
    ).ok, "Dungeon cannot start a new original Base transfer quest")
    print(("[C4 Original Quest Stages] PASS: %d assertions")
        :format(assertions))
end

main()
