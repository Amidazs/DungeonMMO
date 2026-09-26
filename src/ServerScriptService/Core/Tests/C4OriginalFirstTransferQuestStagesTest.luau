--!strict
-- Two historically sourced C4 quest flows; missing world actors fail closed.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local Skills = require(Shared.C4OriginalClassSkillCoverage)
local OriginalSkillSources = require(
    Shared.C4OriginalFirstTransferSkillSources
)
local Rules = require(Shared.C4OriginalQuestProgressRules)
local SkillRules = require(Shared.SkillUnlockRules)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Selection = require(SSS.Core.Services.C4FirstTransferSelectionService)
local Service = require(SSS.Core.Services.C4OriginalFirstTransferQuestService)
local Inventory = require(SSS.Core.Services.InventoryService)
local Equipment = require(SSS.Core.Services.EquipmentService)
local EquipmentRules = require(Shared.EquipmentRules)
local ItemDefinitions = require(Shared.ItemDefinitions)
local TransferRules = require(Shared.ItemTransferRules)
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
    if step.TargetId == "CryptSentinel" then
        proofs.SpartoiBone = true
    elseif step.TargetId == "BrackenRaider" then
        proofs["PriasLetter" .. tostring(count)] = true
    elseif step.TargetId == "BrackenWarden" then
        proofs.RustedKey = true
    elseif step.TargetId == "CinderBrigand" then
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
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "session-1:encounter-" .. tostring(step_index)
                .. ":owner-" .. tostring(user_id)
                .. ":enemy-" .. tostring(count) .. ":life-1"
            else nil,
        TrialWeaponsGranted = step.TargetId == "Vela",
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
        if index == 3 and branch_id == "HumanRogue" then
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalTrialWeaponNotEquipped",
                "Owning Vela's trial items is not enough to earn bone proof")
            check(Equipment.new(profiles, "Base"):equip(
                user_id, "neti_trial_dagger", "Weapon"
            ).ok, "Actual authoritative equipment service equips trial dagger")
        end
        if index == 3 and branch_id == "ElvenScout" then
            event.VerifiedProofIds = {
                PriasLetter1 = true, PriasLetter2 = true,
                PriasLetter3 = true, PriasLetter4 = true,
            }
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalQuestDistinctLetterRequired",
                "One monster death cannot fabricate all four distinct letters")
            event.VerifiedProofIds = {PriasLetter1 = true}
        end
        if step.Kind == "QuestMonsterDefeat" then
            local receipt = event.MonsterReceiptId
            event.MonsterReceiptId = nil
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalQuestMonsterReceiptRequired",
                "A monster victory without stable life receipt cannot count")
            event.MonsterReceiptId = receipt
        end
        if step.RequiresTrialWeapon then
            event.TrialWeaponVerified = false
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalTrialWeaponRequired",
                "Original Vela weapon condition cannot be skipped")
            event.TrialWeaponVerified = true
        end
        if step.TargetId == "CinderBrigand"
            or step.TargetId == "BrackenWarden"
            or step.TargetId == "CryptSentinel"
        then
            local proofs = event.VerifiedProofIds
            event.VerifiedProofIds = {}
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalQuestLootProofRequired",
                "Monster victory alone cannot replace required original loot")
            event.VerifiedProofIds = proofs
        end
        if index == 7 and branch_id == "ElvenScout" then
            check(profiles:mutate(user_id, function(profile: any)
                local owner = profile.Characters.Slot1
                assert(Inventory.apply_remove_from_character(
                    owner, "bracken_ward_sigil", 1
                ).ok)
            end), "Prepare disposable missing ward sigil denial")
            check(service:record_world_event(
                user_id, event
            ).reason == "OriginalQuestProofOwnershipInvalid",
                "Cael cannot be rescued without the owner's actual sigil")
            check(profiles:mutate(user_id, function(profile: any)
                assert(Inventory.apply_item_to_character(
                    profile.Characters.Slot1, "bracken_ward_sigil", 1
                ).ok)
            end), "Restore disposable owner's exact rescue sigil")
        end
        check(service:record_world_event(user_id, event).ok,
            "Authoritative source stage " .. tostring(index)
                .. " must advance with verified original evidence")
        if branch_id == "HumanRogue" and index == 2 then
            local owner = assert(profiles:get_character(user_id, 1))
            for _, item_id in ipairs({
                "neti_trial_dagger", "neti_trial_bow",
            }) do
                local item = assert(ItemDefinitions.get(item_id))
                check(Inventory.count_item(owner, item_id) == 1,
                    "Only the authenticated Rogue owns Vela's real weapon")
                check(EquipmentRules.validate(
                    owner, item, "Weapon"
                ).ok, "Original Human Fighter may equip its quest-only gear")
                check(not TransferRules.can_trade(item_id)
                    and not TransferRules.can_bank(item_id),
                    "Original trial gear may not enter market or shared bank")
            end
        elseif branch_id == "ElvenScout" and index == 2 then
            local elf = assert(profiles:get_character(user_id, 1))
            check(Inventory.count_item(elf, "neti_trial_dagger") == 0
                and Inventory.count_item(elf, "neti_trial_bow") == 0,
                "Elven Thorne meeting cannot grant Human Rogue weapons")
        end
        check(service:record_world_event(
            user_id, event
        ).reason == "OriginalQuestEventAlreadyApplied",
            "Replayed server event cannot award source progress twice")
        if step.Kind == "QuestMonsterDefeat" and step.Required > 1 then
            local duplicate = evidence(user_id, quest, index, 2)
            duplicate.MonsterReceiptId = event.MonsterReceiptId
            check(service:record_world_event(
                user_id, duplicate
            ).reason == "OriginalQuestMonsterAlreadyCredited",
                "A new event ID cannot credit the same monster life twice")
        end
        for count = 2, step.Required do
            local next_event = evidence(user_id, quest, index, count)
            check(service:record_world_event(user_id, next_event).ok,
                "Each distinct source monster/drop needs its own proof")
        end
        local current = assert(profiles:get_character(user_id, 1))
        if index == 3 and branch_id == "HumanRogue" then
            local quest_state =
                current.ClassAdvancement.OriginalFirstTransferQuest
            check(Inventory.count_item(current, "spartoi_bone") == 10
                and quest_state.Proofs.SpartoiBone10 == true,
                "Ten distinct receipts must mint ten owned bones and proof")
            check(not TransferRules.can_trade("spartoi_bone")
                and not TransferRules.can_bank("spartoi_bone"),
                "Bound source bones cannot be traded or banked")
        elseif index == 3 and branch_id == "ElvenScout" then
            for fragment = 1, 4 do
                local item_id = "prias_letter_" .. tostring(fragment)
                check(Inventory.count_item(current, item_id) == 1
                    and not TransferRules.can_trade(item_id)
                    and not TransferRules.can_bank(item_id),
                    "Each letter is a separately owned, bound source drop")
            end
        elseif index == 4 and branch_id == "HumanRogue" then
            check(Inventory.count_item(current, "spartoi_bone") == 0
                and current.ClassAdvancement.OriginalFirstTransferQuest
                    .Proofs.SpartoiBone10 == true,
                "Actual mentor turn-in consumes ten bones but keeps proof")
        elseif index == 6 and branch_id == "HumanRogue" then
            for _, item_id in ipairs({
                "cinder_cipher", "cinder_route_map",
                "cinder_ward_seal", "cinder_tideglass_lens",
            }) do
                check(Inventory.count_item(current, item_id) == 1
                    and not TransferRules.can_trade(item_id)
                    and not TransferRules.can_bank(item_id),
                    "Unique Cinder kill mints each personal untradeable record")
            end
        elseif index == 7 and branch_id == "HumanRogue" then
            for _, item_id in ipairs({
                "cinder_cipher", "cinder_route_map",
                "cinder_ward_seal", "cinder_tideglass_lens",
            }) do
                check(Inventory.count_item(current, item_id) == 0,
                    "Authenticated captain consumes each recovered record")
            end
        elseif index == 4 and branch_id == "ElvenScout" then
            for fragment = 1, 4 do
                check(Inventory.count_item(
                    current, "prias_letter_" .. tostring(fragment)
                ) == 0, "Actual warden consumes each owned report fragment")
            end
        elseif index == 6 and branch_id == "ElvenScout" then
            check(Inventory.count_item(
                current, "bracken_ward_sigil"
            ) == 1
                and not TransferRules.can_trade("bracken_ward_sigil")
                and not TransferRules.can_bank("bracken_ward_sigil"),
                "Distinct Warden kill grants only a personally bound sigil")
        elseif index == 7 and branch_id == "ElvenScout" then
            check(Inventory.count_item(
                current, "bracken_ward_sigil"
            ) == 0, "Cael rescue consumes the real owned ward sigil")
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
    check(not can_train
        and locked_reason == "OriginalFirstTransferRequired",
        "Quest readiness must not grant shared Scout utility before "
            .. "the saved first-transfer mentor receipt")
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
    if branch_id == "HumanRogue" then
        local reloaded = assert(profiles:get_character(user_id, 1))
        check(Inventory.count_item(reloaded, "neti_trial_dagger") == 1
            and Inventory.count_item(reloaded, "neti_trial_bow") == 1
            and Inventory.count_item(reloaded, "spartoi_bone") == 0
            and reloaded.ClassAdvancement.OriginalFirstTransferQuest
                .Proofs.SpartoiBone10 == true,
            "Rogue trial weapons and spent bone-proof state survive "
                .. "save/reload without restoring consumed quest items")
        for _, item_id in ipairs({
            "cinder_cipher", "cinder_route_map",
            "cinder_ward_seal", "cinder_tideglass_lens",
        }) do
            check(Inventory.count_item(reloaded, item_id) == 0,
                "Spent supply-cache items must not reappear after reload")
        end
    else
        local reloaded = assert(profiles:get_character(user_id, 1))
        for fragment = 1, 4 do
            check(Inventory.count_item(
                reloaded, "prias_letter_" .. tostring(fragment)
            ) == 0, "Spent Elven report fragments cannot reappear on reload")
        end
    end
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
        and report.OriginalClassLevel20SourcesInventoried == 2
        and report.OriginalLevel20RankEntriesCatalogued == 28
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
    for _, record in ipairs({
        {Id = "HumanWarrior", Count = 12},
        {Id = "HumanKnight", Count = 16},
    }) do
        local source = assert(OriginalSkillSources.get(record.Id))
        local seen = {}
        check(source.SourceChronicle == "C4"
            and source.Coverage == "Level20Only"
            and #source.Level20 == record.Count,
            "Real Warrior/Knight level-20 C4 rank inventory is incomplete")
        for _, rank in ipairs(source.Level20) do
            local key = rank.Name .. ":" .. tostring(rank.SourceRank)
            check(rank.SourceLevel == 20 and not seen[key]
                and rank.DungeonSkillId == nil
                and rank.GameplayStatus == "NotImplemented",
                "Source rank must be distinct, source-level accurate and "
                    .. "not falsely advertised as an implemented ability")
            seen[key] = true
        end
    end
    local warrior_quest = assert(Stages.get("HumanWarrior"))
    check(warrior_quest.WorldBindingStatus == "NotImplemented"
        and warrior_quest.RequiredProofIds[1] == "IronrootToken4",
        "New original Warrior source blueprint remains distinct from "
            .. "a completed player-accepted live class journey")
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
    local rogue_quest = assert(Stages.get("HumanRogue"))
    local scout_quest = assert(Stages.get("ElvenScout"))
    check(rogue_quest.SourceTitle == "The Ashen Blade Trial"
        and rogue_quest.Steps[1].TargetId == "CaptainAshford"
        and rogue_quest.Steps[2].TargetId == "Vela"
        and rogue_quest.Steps[3].TargetId == "CryptSentinel"
        and rogue_quest.Steps[6].TargetId == "CinderBrigand",
        "Rogue player-facing quest and actor IDs use original game names")
    check(scout_quest.SourceTitle == "The Greenward Search"
        and scout_quest.Steps[1].TargetId == "PathfinderElyra"
        and scout_quest.Steps[2].TargetId == "WardenThorne"
        and scout_quest.Steps[3].TargetId == "BrackenRaider"
        and scout_quest.Steps[5].TargetId == "ScoutCael"
        and scout_quest.Steps[6].TargetId == "BrackenWarden",
        "Scout player-facing quest and actor IDs use original game names")
    check(rogue_quest.SourceUrl == nil
        and scout_quest.SourceUrl == nil,
        "Quest snapshots must not expose third-party walkthrough links")
    check(assert(ItemDefinitions.get("neti_trial_dagger")).Name
            == "Vela's Trial Dagger"
        and assert(ItemDefinitions.get("neti_trial_bow")).Name
            == "Vela's Trial Bow"
        and assert(ItemDefinitions.get("spartoi_bone")).Name
            == "Crypt Sentinel Fragment"
        and assert(ItemDefinitions.get("prias_letter_1")).Name
            == "Cael's Field Report Fragment 1",
        "Legacy save IDs remain valid while visible quest item names change")
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
