--!strict
-- Isolated profile test; physical Base/NPC Play is still required.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Services = SSS.Core.Services
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Selection = require(Services.C4FirstTransferSelectionService)
local QuestService = require(Services.C4OriginalFirstTransferQuestService)
local Transfers = require(Shared.OriginalFirstTransferDefinitions)
local Quests = require(Shared.C4OriginalFirstTransferQuestStages)
local Classes = require(Shared.ClassProgressionDefinitions)
local Trainers = require(Shared.TrainerCatalogues)
local Coverage = require(Shared.C4Level30LaunchCoverage)

local OWNER_ID = 848801
local QUEST = assert(Quests.get("ElvenKnight"))
local assertions = 0

--[[
Checks one authoritative branch, rank or quest security condition.

Args:
    valid (boolean): Exact condition that must be true.
    label (string): Diagnostic for a failing isolated test.

Returns:
    nil: Counts a verified assertion or raises an error.
]]
local function check(valid: boolean, label: string)
    assertions += 1
    assert(valid, "[Greenward Warden Foundation] " .. label)
end

--[[
Provides a deliberately limited mock world for profile transaction tests.

Args:
    None.

Returns:
    any: Test-only verifier that exposes only two NPC interactions.
]]
local function first_two_npcs(): any
    local world = {}
    function world:available(quest: any, index: number?): boolean
        local step = quest.Steps[index or 1]
        return quest.BranchId == "ElvenKnight"
            and (index or 1) <= 2 and step ~= nil
            and step.Kind == "NpcTalk"
    end
    function world:verify(
        user_id: number, event: any, quest: any, state: any
    ): boolean
        local step = quest.Steps[state.Step]
        return user_id == OWNER_ID and event.ServerVerified == true
            and event.ActorUserId == user_id
            and step ~= nil and event.Kind == step.Kind
            and event.TargetId == step.TargetId
    end
    return world
end

--[[
Creates a real isolated profile with Elf Fighter starting identity.

Args:
    profiles (any): In-memory exclusive profile service.

Returns:
    nil: Persists only legitimate original level-18 starting data.
]]
local function seed_elf(profiles: any)
    check(profiles:load(OWNER_ID) ~= nil, "Profile must load")
    check(profiles:mutate(OWNER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Identity = {
            Version = 1, RaceId = "Elf",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Elf Fighter starter must persist")
end

--[[
Verifies ordered NPC progress without granting incomplete Knight abilities.

Args:
    profiles (any): Same exclusive owner profile.
    service (any): Server-only limited quest service.

Returns:
    nil: Ensures future monster stage is closed and class remains Fighter.
]]
local function verify_quest(profiles: any, service: any)
    check(service:start(OWNER_ID).ok, "Chosen owner starts Knight quest")
    for index = 1, 2 do
        local step = QUEST.Steps[index]
        local forged = {
            EventId = "ElvenKnight:forged:" .. index,
            Kind = step.Kind, TargetId = step.TargetId,
            ActorUserId = OWNER_ID,
        }
        check(service:record_world_event(OWNER_ID, forged).reason
            == "OriginalQuestWorldEvidenceUnverified",
            "A client-like NPC claim cannot progress the quest")
        forged.EventId = "ElvenKnight:verified:" .. index
        forged.ServerVerified = true
        check(service:record_world_event(OWNER_ID, forged).ok,
            "Test-only authenticated NPC step progresses in order")
    end
    local owner = assert(profiles:get_character(OWNER_ID))
    local state = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(state.Step == 3 and not state.Ready,
        "Unimplemented monster proof must remain locked")
    check(service:build_snapshot(OWNER_ID).WorldReady == false,
        "Incomplete physical monster encounter cannot advertise ready")
    check(service:record_world_event(OWNER_ID, {
        EventId = "ElvenKnight:forged:kill", Kind = "QuestMonsterDefeat",
        TargetId = "RootboundMarauder", ActorUserId = OWNER_ID,
        ServerVerified = true,
        MonsterReceiptId = "nonexistent-monster",
    }).reason == "OriginalQuestWorldNotReady",
        "No synthetic enemy kill can advance an unbuilt world stage")
    check(profiles:mutate(OWNER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Owner reaches actual first-transfer eligibility level")
    owner = assert(profiles:get_character(OWNER_ID))
    check(not Transfers.can_transfer(owner, "ElvenKnight")
        and Transfers.awarded(owner) == nil
        and owner.Identity.ClassId == "Fighter",
        "Choosing a class and two NPCs never awards an unfinished Knight")
end

--[[
Runs only new Elven Knight race, quest, training and release-gate checks.

Args:
    None.

Returns:
    nil: Prints a pass count only after real profile operations succeed.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    seed_elf(profiles)
    local selected = Selection.new(profiles, "Base")
    check(selected:choose(OWNER_ID, "HumanKnight").ok == false,
        "Elf cannot select Human Knight")
    check(selected:choose(OWNER_ID, "ElvenKnight").ok,
        "Elf can choose its own original Knight branch")
    check(Transfers.for_branch("ElvenKnight").Id == "GreenwardWarden",
        "Independent saved class identity is registered")
    check(Classes.get("GreenwardWarden") ~= nil
        and not Classes.can_teach(
            "GreenwardWarden", "OathguardShieldImpact"
        ), "Human Knight abilities cannot leak into the Elven career")
    local trainer = assert(Trainers.get("GreenwardWardenTrainer"))
    check(#trainer.Skills == 6
        and trainer.AllowedClasses[1] == "GreenwardWarden"
        and trainer.AllowedRaces[1] == "Elf",
        "Warden trainer offers three passives and three active lines")
    local service = QuestService.new(profiles, "Base", first_two_npcs())
    verify_quest(profiles, service)
    local audit = assert(Coverage.for_branch("ElvenKnight"))
    check(audit.CurrentCareerId == "GreenwardWarden"
        and audit.TrainerMappedRankEntries == 45
        and audit.MissingRankScheduleEntries == 11
        and not audit.LaunchSkillCatalogueReady,
        "Source inventory and class identity do not imply ready skills")
    print(("[Greenward Warden Foundation] PASS: %d assertions")
        :format(assertions))
end

main()
