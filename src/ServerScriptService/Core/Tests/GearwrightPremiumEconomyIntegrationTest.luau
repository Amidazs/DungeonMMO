--!strict
-- Real-service Gearwright premium blueprint and market-dependency regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local QuestStages = require(
    Shared.C4OriginalFirstTransferQuestStages
)
local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local EntityAdapter = require(Core.Adapters.InMemoryEntityAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Market = require(Core.Services.MarketService)

local GEARWRIGHT_ID = 964201
local FRAME_SELLER_ID = 964202
local CATALYST_SELLER_ID = 964203
local SALVAGE_SELLER_ID = 964204
local MAX_PROFESSION_XP = 340
local checks = 0

--[[
Counts one premium-economy assertion.

Args:
    condition (boolean): Expected class, market, or crafting result.
    label (string): Failure context for focused Studio validation.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Gearwright Premium Economy] " .. label)
end

--[[
Installs the complete server-authored proof state for an earned Gearwright.

Args:
    character (any): Disposable character profile to advance.

Returns:
    nil: Mutates only the in-memory test character.
]]
local function award_gearwright(character: any)
    local quest = assert(QuestStages.get("DwarfArtisan"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 28
    character.Identity = {
        Version = 1,
        CreationStage = "Complete",
        RaceId = "Dwarf",
        BaseClassId = "Fighter",
        ClassId = "Gearwright",
    }
    character.Progression = character.Progression or {}
    character.Progression.Skills =
        character.Progression.Skills or {}
    character.Progression.Skills.DwarfWorkshopCraft = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.DwarfBlueprintFoundation = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.DwarfCommonCraft = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.GearwrightBlueprintTraining = {
        Known = true,
        PurchasedRank = 2,
    }
    character.ClassAdvancement = {
        Version = 1,
        CompletedByRace = {},
        ActiveClassId = nil,
        OriginalFirstTransferChoiceId = "DwarfArtisan",
        OriginalFirstTransferClassId = "Gearwright",
        OriginalFirstTransferReceiptId =
            "gearwright-premium-test-receipt",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = "DwarfArtisan",
            Ready = true,
            Step = #quest.Steps + 1,
            Count = 0,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }
end

--[[
Raises one selected crafting career to profession level five.

Args:
    profiles (any): Loaded authoritative profile service.
    user_id (number): Disposable profile owner.
    profession_ids ({string}): Selected careers to advance.

Returns:
    nil: Mutates only the disposable profile.
]]
local function set_level_five(
    profiles: any,
    user_id: number,
    profession_ids: {string}
)
    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            for _, profession_id in ipairs(profession_ids) do
                local state = character.Professions[profession_id]
                state.XP = MAX_PROFESSION_XP
                state.Level = 5
            end
        end),
        "selected Gearwright careers reach level five"
    )
end

--[[
Transfers one tradeable premium input through real market escrow.

Args:
    market (any): Existing authoritative market service.
    seller_id (number): Current material owner.
    item_id (string): Tradeable input.
    request_suffix (string): Stable request identifier.

Returns:
    nil: Raises when listing or purchase fails.
]]
local function buy_input(
    market: any,
    seller_id: number,
    item_id: string,
    request_suffix: string
)
    local listing = market:create_listing(
        seller_id,
        item_id,
        1,
        25,
        "gearwright-sell-" .. request_suffix
    )
    check(listing.ok == true, item_id .. " lists")

    local bought = market:buy(
        GEARWRIGHT_ID,
        listing.listing.ListingId,
        "gearwright-buy-" .. request_suffix
    )
    check(bought.ok == true, item_id .. " is purchased")
end

--[[
Runs the class-owned premium recipe through real inventory and market services.

Args:
    None.

Returns:
    nil: Prints a stable marker after the premium craft succeeds.
]]
local function main()
    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)

    for _, user_id in {
        GEARWRIGHT_ID,
        FRAME_SELLER_ID,
        CATALYST_SELLER_ID,
        SALVAGE_SELLER_ID,
    } do
        check(profiles:load(user_id), "disposable profile loads")
    end

    check(
        profiles:mutate(GEARWRIGHT_ID, function(profile: any)
            local character = profile.Characters.Slot1
            award_gearwright(character)
            character.Gold = 1000
        end),
        "earned Gearwright proof state is installed"
    )

    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)

    check(
        professions:choose_profession(
            GEARWRIGHT_ID,
            "Mining"
        ).ok,
        "Gearwright selects one gathering career"
    )
    check(
        professions:choose_profession(
            GEARWRIGHT_ID,
            "Blacksmithing"
        ).ok,
        "Gearwright selects first crafting career"
    )
    check(
        professions:choose_profession(
            GEARWRIGHT_ID,
            "Enchanting"
        ).ok,
        "Gearwright selects second crafting career"
    )
    set_level_five(
        profiles,
        GEARWRIGHT_ID,
        {"Blacksmithing", "Enchanting"}
    )

    local missing = professions:prepare_craft(
        GEARWRIGHT_ID,
        "gearwright_precision_assembly"
    )
    check(
        not missing.ok and missing.reason == "MissingMaterials",
        "earned premium recipe still requires real materials"
    )

    check(
        inventory:add_item(
            FRAME_SELLER_ID,
            "masterwork_frame",
            1
        ).ok,
        "normal profession component enters seller inventory"
    )
    check(
        inventory:add_item(
            CATALYST_SELLER_ID,
            "aetheric_catalyst",
            1
        ).ok,
        "cross-profession catalyst enters seller inventory"
    )
    check(
        inventory:add_item(
            SALVAGE_SELLER_ID,
            "salvaged_mechanism_fragment",
            1
        ).ok,
        "Deepclaimer-style salvage enters seller inventory"
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
            return "gearwright-premium-"
                .. tostring(listing_counter)
        end
    )

    buy_input(
        market,
        FRAME_SELLER_ID,
        "masterwork_frame",
        "frame"
    )
    buy_input(
        market,
        CATALYST_SELLER_ID,
        "aetheric_catalyst",
        "catalyst"
    )
    buy_input(
        market,
        SALVAGE_SELLER_ID,
        "salvaged_mechanism_fragment",
        "salvage"
    )

    local prepared = professions:prepare_craft(
        GEARWRIGHT_ID,
        "gearwright_precision_assembly"
    )
    check(
        prepared.ok == true
            and prepared.minigame_id == "BlacksmithingForge",
        "premium assembly prepares only after three market inputs arrive"
    )

    local crafted = professions:complete_craft(
        GEARWRIGHT_ID,
        "gearwright_precision_assembly",
        Professions.foundation_success_outcome(
            prepared.minigame_id
        )
    )
    check(
        crafted.ok == true
            and crafted.output_item_id
                == "gearwright_precision_assembly",
        "earned Gearwright crafts the premium assembly"
    )

    local character = assert(
        profiles:get_character(GEARWRIGHT_ID, 1)
    )
    check(
        Inventory.count_item(
            character,
            "gearwright_precision_assembly"
        ) == 1,
        "premium output is granted exactly once"
    )
    check(
        Inventory.count_item(character, "masterwork_frame") == 0
            and Inventory.count_item(
                character,
                "aetheric_catalyst"
            ) == 0
            and Inventory.count_item(
                character,
                "salvaged_mechanism_fragment"
            ) == 0,
        "premium craft consumes every traded dependency exactly once"
    )

    local unselected = professions:prepare_craft(
        GEARWRIGHT_ID,
        "gearwright_stabilizing_compound"
    )
    check(
        not unselected.ok
            and unselected.reason == "ProfessionNotSelected",
        "second craft slot does not authorize a third crafting profession"
    )

    print(
        ("[Gearwright Premium Economy] PASS: %d assertions")
            :format(checks)
    )
end

main()
