--!strict
-- Real-service Adventure reward -> market -> profession crafting integration.

local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Adapters = Core.Adapters
local Services = Core.Services

local ProfileAdapter = require(Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Adapters.InMemoryEntityAdapter)
local Profiles = require(Services.ProfileService)
local Inventory = require(Services.InventoryService)
local Quests = require(Services.QuestService)
local Professions = require(Services.ProfessionService)
local Market = require(Services.MarketService)

local QUEST_PLAYER_ID = 966101
local BLACKSMITH_ID = 966102
local checks = 0

--[[
Counts one profession-aware quest integration assertion.

Args:
    condition (boolean): Expected quest, market, or crafting result.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Quest Integration] " .. label)
end

--[[
Installs a normal Human Fighter identity for Adventure quest testing.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Disposable profile owner.

Returns:
    nil: Mutates only the disposable test profile.
]]
local function set_fighter_identity(
    profiles: any,
    user_id: number
)
    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 1
            character.Identity = {
                Version = 1,
                RaceId = "Human",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
        end),
        "quest player receives a complete normal identity"
    )
end

--[[
Records one trusted DungeonClear event.

Args:
    quests (any): Authoritative QuestService.
    user_id (number): Quest owner.
    event_id (string): Stable dedupe identifier.
    dungeon_id (string): Server-known dungeon identifier.

Returns:
    nil: Raises when trusted quest progress is rejected.
]]
local function record_clear(
    quests: any,
    user_id: number,
    event_id: string,
    dungeon_id: string
)
    local result = quests:record_event(user_id, {
        EventId = event_id,
        Type = "DungeonClear",
        TargetId = dungeon_id,
        Amount = 1,
    })
    check(result.ok == true, event_id .. " is accepted")
end

--[[
Completes the existing story prerequisites and Provisioning quest.

Args:
    quests (any): Authoritative QuestService.
    user_id (number): Quest owner.

Returns:
    any: Successful Expedition Provisioning claim result.
]]
local function complete_provisioning(
    quests: any,
    user_id: number
): any
    check(
        quests:start(user_id, "WorldrootRelic").ok,
        "Worldroot Relic starts"
    )
    record_clear(
        quests,
        user_id,
        "profession-quest:worldroot",
        "TestDungeon"
    )
    check(
        quests:claim_reward(user_id, "WorldrootRelic").ok,
        "Worldroot Relic is claimed"
    )

    check(
        quests:start(user_id, "MineEchoes").ok,
        "Mine Echoes starts"
    )
    record_clear(
        quests,
        user_id,
        "profession-quest:mine",
        "AbandonedMine"
    )
    check(
        quests:claim_reward(user_id, "MineEchoes").ok,
        "Mine Echoes is claimed"
    )

    check(
        quests:start(user_id, "ExpeditionProvisioning").ok,
        "Expedition Provisioning starts without a profession"
    )
    record_clear(
        quests,
        user_id,
        "profession-quest:provision-temple",
        "TestDungeon"
    )
    record_clear(
        quests,
        user_id,
        "profession-quest:provision-mine",
        "AbandonedMine"
    )

    local claim = quests:claim_reward(
        user_id,
        "ExpeditionProvisioning"
    )
    check(claim.ok == true, "Expedition Provisioning is claimed")
    return claim
end

--[[
Returns one authoritative inventory quantity.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Inventory owner.
    item_id (string): Registered item identifier.

Returns:
    number: Current item quantity.
]]
local function quantity(
    profiles: any,
    user_id: number,
    item_id: string
): number
    local character = assert(
        profiles:get_character(user_id, 1)
    )
    return Inventory.count_item(character, item_id)
end

--[[
Runs quest-to-market-to-crafting acceptance.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after the full chain succeeds.
]]
local function main()
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)

    check(
        profiles:load(QUEST_PLAYER_ID),
        "quest player profile loads"
    )
    check(
        profiles:load(BLACKSMITH_ID),
        "blacksmith profile loads"
    )

    set_fighter_identity(profiles, QUEST_PLAYER_ID)
    set_fighter_identity(profiles, BLACKSMITH_ID)

    local inventory = Inventory.new(profiles)
    local quests = Quests.new(profiles)
    local claim = complete_provisioning(
        quests,
        QUEST_PLAYER_ID
    )

    local quest_character = assert(
        profiles:get_character(QUEST_PLAYER_ID, 1)
    )
    check(
        quest_character.ProfessionSlots.Gathering == ""
            and quest_character.ProfessionSlots.Creation == "",
        "Adventure completion requires no profession selection"
    )
    check(
        claim.gold_granted == 75
            and #claim.items_granted == 3,
        "Provisioning returns the complete server reward bundle"
    )
    check(
        quantity(
            profiles,
            QUEST_PLAYER_ID,
            "deep_iron_ore"
        ) == 2
            and quantity(
                profiles,
                QUEST_PLAYER_ID,
                "moonpetal"
            ) == 2
            and quantity(
                profiles,
                QUEST_PLAYER_ID,
                "thick_hide"
            ) == 2,
        "quest player owns all three tradeable advanced materials"
    )

    local professions = Professions.new(profiles, inventory)
    check(
        professions:choose_profession(
            BLACKSMITH_ID,
            "Herbalism"
        ).ok,
        "buyer selects Herbalism instead of Mining"
    )
    check(
        professions:choose_profession(
            BLACKSMITH_ID,
            "Blacksmithing"
        ).ok,
        "buyer selects Blacksmithing"
    )
    check(
        profiles:mutate(BLACKSMITH_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Gold = 500
            character.Professions.Blacksmithing.XP = 90
            character.Professions.Blacksmithing.Level = 3
        end),
        "buyer reaches focused Blacksmithing level three"
    )
    check(
        inventory:add_item(
            BLACKSMITH_ID,
            "forging_flux",
            1
        ).ok,
        "blacksmith receives one required flux"
    )

    local listing_counter = 0
    local market = Market.new(
        EntityAdapter.new(),
        profiles,
        function(): number
            return 1000
        end,
        function(): string
            listing_counter += 1
            return "profession-quest-"
                .. tostring(listing_counter)
        end
    )

    local listing = market:create_listing(
        QUEST_PLAYER_ID,
        "deep_iron_ore",
        2,
        40,
        "profession-quest-list"
    )
    check(
        listing.ok == true,
        "non-profession quest player lists Deep Iron"
    )

    local purchase = market:buy(
        BLACKSMITH_ID,
        listing.listing.ListingId,
        "profession-quest-buy"
    )
    check(
        purchase.ok == true,
        "non-Miner Blacksmith buys the quest material"
    )
    check(
        quantity(
            profiles,
            QUEST_PLAYER_ID,
            "deep_iron_ore"
        ) == 0
            and quantity(
                profiles,
                BLACKSMITH_ID,
                "deep_iron_ore"
            ) == 2,
        "market moves exactly the quest-awarded ore"
    )

    local prepared = professions:prepare_craft(
        BLACKSMITH_ID,
        "smelt_deep_iron_bar"
    )
    check(
        prepared.ok == true,
        "purchased quest ore prepares its normal level-three recipe"
    )

    local crafted = professions:complete_craft(
        BLACKSMITH_ID,
        "smelt_deep_iron_bar",
        Professions.foundation_success_outcome(
            prepared.minigame_id
        )
    )
    check(
        crafted.ok == true
            and crafted.output_item_id == "deep_iron_bar"
            and quantity(
                profiles,
                BLACKSMITH_ID,
                "deep_iron_bar"
            ) == 1,
        "quest-supplied market material becomes a real craft component"
    )

    check(
        quantity(
            profiles,
            QUEST_PLAYER_ID,
            "moonpetal"
        ) == 2
            and quantity(
                profiles,
                QUEST_PLAYER_ID,
                "thick_hide"
            ) == 2,
        "untraded quest materials remain available for later trade"
    )

    print(
        ("[Profession Quest Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
