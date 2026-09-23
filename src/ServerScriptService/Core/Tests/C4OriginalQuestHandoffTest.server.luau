--!strict
-- Shared-store cross-server source loot handoff; no published places used.
local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Coordinator = require(Core.Services.TeleportCoordinator)
local Quest = require(Core.Services.C4OriginalFirstTransferQuestService)
local Stages = require(
    game:GetService("ReplicatedStorage")
        .Core.Shared.C4OriginalFirstTransferQuestStages
)

local assertions = 0
local OWNERS = table.freeze({
    {UserId = 94611, RaceId = "Human", BranchId = "HumanRogue"},
    {UserId = 94612, RaceId = "Elf", BranchId = "ElvenScout"},
})

--[[
Checks one source-quest handoff and persistence contract.

Args:
    condition (boolean): Condition observed from authoritative services.
    label (string): Specific expected source/return ownership invariant.

Returns:
    nil: Raises a targeted error rather than claiming a false acceptance.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[C4 Quest Handoff] " .. label)
end

--[[
Creates server-only mock proof; this checks persistence, not physical kills.

Args:
    None.

Returns:
    any: Mock stage-three world binder unavailable to client remotes.
]]
local function test_world(): any
    return {
        available = function(
            _self: any, _quest: any, step: number
        ): boolean
            return step == 3 or step == 6
        end,
        verify = function(
            _self: any, user_id: number, event: any,
            quest: any, state: any
        ): boolean
            return event.ServerVerified == true
                and event.ActorUserId == user_id
                and quest.BranchId == state.BranchId
        end,
    }
end

--[[
Prepares two distinct level-18 source owners in the disposable store.

Args:
    profiles (any): Actual Dungeon ProfileService under test.
    owner (any): Fixed identity and selected branch for test isolation.

Returns:
    nil: Seeds the starting stage only, never an earned item or proof.
]]
local function seed_owner(profiles: any, owner: any)
    check(profiles:load(owner.UserId) ~= nil, "Owner profile loads")
    local quest = assert(Stages.get(owner.BranchId))
    check(profiles:mutate(owner.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = owner.RaceId,
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Level = 18
        character.ClassAdvancement.OriginalFirstTransferChoiceId =
            owner.BranchId
        character.ClassAdvancement.OriginalFirstTransferQuest = {
            QuestId = quest.Id, BranchId = owner.BranchId,
            Step = 3, Count = 0, Ready = false,
            AppliedEvents = {}, Proofs = {},
        }
        if owner.BranchId == "HumanRogue" then
            for _, item_id in ipairs({
                "neti_trial_dagger", "neti_trial_bow",
            }) do
                assert(Inventory.apply_item_to_character(
                    character, item_id, 1
                ).ok)
            end
            character.Equipment.Weapon = "neti_trial_dagger"
        end
    end), "Isolated source character prepared")
end

--[[
Produces unique, authenticated server fixture kills for one owner.

Args:
    profiles (any): Actual loaded Dungeon profile service.
    service (any): Server-only quest service; no public remote authority.
    owner (any): Chosen character and original quest branch.

Returns:
    nil: Completes stage three using one distinct proof per monster life.
]]
local function earn_stage_three(
    profiles: any, service: any, owner: any
)
    local count = if owner.BranchId == "HumanRogue" then 10 else 4
    for index = 1, count do
        local proofs = if owner.BranchId == "HumanRogue"
            then {SpartoiBone = true}
            else {["PriasLetter" .. tostring(index)] = true}
        local event = {
            ServerVerified = true, ActorUserId = owner.UserId,
            EventId = owner.BranchId .. ":Kill:" .. tostring(index),
            MonsterReceiptId = owner.BranchId .. ":Life:"
                .. tostring(index),
            Kind = "QuestMonsterDefeat",
            TargetId = if owner.BranchId == "HumanRogue"
                then "CryptSentinel" else "BrackenRaider",
            TrialWeaponVerified = owner.BranchId == "HumanRogue",
            VerifiedProofIds = proofs,
        }
        check(service:record_world_event(owner.UserId, event).ok,
            "Distinct source kill earns one owner-specific quest item")
        if index < count then
            check(service:record_world_event(
                owner.UserId, event
            ).reason == "OriginalQuestEventAlreadyApplied",
                "Replaying an old source kill grants no extra item")
        end
    end
    local character = assert(profiles:get_character(owner.UserId))
    local state = character.ClassAdvancement.OriginalFirstTransferQuest
    check(state.Step == 4 and state.Count == 0,
        "Owner progresses to physical mentor return, without class award")
end

--[[
Creates a routing-only fake teleport and real coordinator profile save.

Args:
    profiles (any): Loaded Dungeon profiles backed by the shared store.

Returns:
    (any, any): Real coordinator and inspected mock transport.
]]
local function create_return_coordinator(
    profiles: any
): (any, any)
    local teleport = {}
    function teleport:teleport(
        _place: number, _players: {any},
        _code: string?, routing: any
    ): (boolean, string?)
        self.routing = routing
        return true, nil
    end
    local leases = {}
    function leases:begin_handoff(
        _user: number, _nonce: string, _destination: string
    ): any
        return {ok = true}
    end
    function leases:cancel_handoff(
        _user: number, _nonce: string
    ): any
        return {ok = true}
    end
    local sessions = {}
    function sessions:set_handoff_nonce(
        _session: string, _user: number, _nonce: string
    ): any
        return {ok = true}
    end
    return Coordinator.new(teleport, profiles, leases, sessions),
        teleport
end

--[[
Checks stored quest state from an entirely new Base ProfileService cache.

Args:
    base (any): Destination ProfileService, reading shared saved adapter.
    owner (any): Human Rogue or Elven Scout saved in source Dungeon.

Returns:
    nil: Confirms personal loot, immutable class and saved proof survive.
]]
local function verify_destination(base: any, owner: any)
    check(base:load(owner.UserId) ~= nil,
        "New Base service loads the actual saved source profile")
    local character = assert(base:get_character(owner.UserId))
    local quest = character.ClassAdvancement.OriginalFirstTransferQuest
    check(quest.Step == 4 and quest.BranchId == owner.BranchId
        and quest.Ready == false and character.Identity.ClassId == "Fighter",
        "Return does not skip stages or grant an unfinished advanced class")
    if owner.BranchId == "HumanRogue" then
        check(Inventory.count_item(character, "spartoi_bone") == 10
            and quest.Proofs.SpartoiBone10 == true,
            "Ten owned fragments and earned aggregate proof reach Base")
        check(Inventory.count_item(character, "prias_letter_1") == 0,
            "Rogue cannot acquire Scout's personal quest materials")
    else
        for index = 1, 4 do
            local id = "prias_letter_" .. tostring(index)
            check(Inventory.count_item(character, id) == 1
                and quest.Proofs["PriasLetter" .. tostring(index)] == true,
                "Every separate earned Scout fragment reaches Base")
        end
        check(Inventory.count_item(character, "spartoi_bone") == 0,
            "Scout cannot acquire Rogue's personal quest materials")
    end
end

--[[
Verifies all four later Cinder items survive a second save/handoff/reload.

Args:
    shared_store (any): Same real in-memory persisted profile adapter.
    source (any): Loaded first destination's original ProfileService.

Returns:
    nil: No duplicate cached loot or advanced-class award after transfer.
]]
local function verify_cinder_handoff(shared_store: any, source: any)
    local user_id = OWNERS[1].UserId
    check(source:mutate(user_id, function(profile: any)
        local owner = profile.Characters.Slot1
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        assert(state.Step == 4 and state.Proofs.SpartoiBone10)
        assert(Inventory.apply_remove_from_character(
            owner, "spartoi_bone", 10
        ).ok)
        -- The future stage-four/five NPC interactions are tested in a
        -- separate live Base fixture, not bypassed in production here.
        state.Step = 6
    end), "Test-only later-stage setup uses the actual source profile")

    local cinder = Quest.new(source, "Dungeon", test_world())
    local earned = cinder:record_world_event(user_id, {
        ServerVerified = true,
        EventId = "CinderHandoff:Kill1",
        MonsterReceiptId = "CinderHandoff:Life1",
        ActorUserId = user_id,
        Kind = "QuestMonsterDefeat",
        TargetId = "CinderBrigand",
        TrialWeaponVerified = true,
        VerifiedProofIds = {
            StolenJewelry = true, StolenTomes = true,
            StolenRing = true, StolenNecklace = true,
        },
    })
    check(earned.ok and earned.Step == 7,
        "Authenticated fixture Cinder defeat earns distinct source items")

    local coordinator, transport = create_return_coordinator(source)
    check(coordinator:return_to_base(
        {{UserId = user_id}}, {
            SessionId = "LaterCinderHandoff",
            DungeonId = "TestDungeon",
            ReturnPlaceId = 42,
        }
    ).ok, "Actual return coordinator saves later source loot")
    check(transport.routing.Inventory == nil
        and transport.routing.Proofs == nil,
        "Second transport never trusts client-supplied quest inventory")
    check(source:forget_for_handoff(user_id),
        "Second source cache closes after the saved coordinator handoff")

    local destination = Profiles.new(shared_store)
    check(destination:load(user_id) ~= nil,
        "Fresh post-Cinder destination reloads shared persisted profile")
    local owner = assert(destination:get_character(user_id))
    local quest = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(quest.Step == 7 and owner.Identity.ClassId == "Fighter"
        and owner.ClassAdvancement.ActiveClassId == nil,
        "Later-stage saved Cinder proof cannot grant an advanced class")
    for _, item_id in ipairs({
        "cinder_cipher", "cinder_route_map",
        "cinder_ward_seal", "cinder_tideglass_lens",
    }) do
        check(Inventory.count_item(owner, item_id) == 1,
            "Each separately earned Cinder item survives destination load")
    end
end

--[[
Tests both actual source profile save/handoff and fresh destination loads.

Args:
    None.

Returns:
    nil: Prints asserted owner-specific persistence after fake transport.
]]
local function main()
    local shared_store = Adapter.new()
    local dungeon = Profiles.new(shared_store)
    local source_quest = Quest.new(dungeon, "Dungeon", test_world())
    for _, owner in ipairs(OWNERS) do
        seed_owner(dungeon, owner)
        earn_stage_three(dungeon, source_quest, owner)
    end

    local coordinator, teleport = create_return_coordinator(dungeon)
    local session = {
        SessionId = "SourceQuestHandoffOne",
        DungeonId = "TestDungeon",
        ReturnPlaceId = 42,
    }
    local result = coordinator:return_to_base({
        {UserId = OWNERS[1].UserId},
        {UserId = OWNERS[2].UserId},
    }, session)
    check(result.ok, "Real return coordinator saves both source owners")
    check(teleport.routing.SessionId == session.SessionId
        and teleport.routing.Inventory == nil
        and teleport.routing.Proofs == nil,
        "Teleport routing cannot replace saved quest or loot authority")
    for _, owner in ipairs(OWNERS) do
        check(dungeon:forget_for_handoff(owner.UserId),
            "Only clean saved source profile may release writer cache")
    end

    local base = Profiles.new(shared_store)
    for _, owner in ipairs(OWNERS) do
        verify_destination(base, owner)
    end
    verify_cinder_handoff(shared_store, base)
    print(("[C4 Quest Handoff] PASS: %d assertions")
        :format(assertions))
end

main()
