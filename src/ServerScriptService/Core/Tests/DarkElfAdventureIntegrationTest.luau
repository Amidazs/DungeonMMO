--!strict
-- Real QuestService acceptance for the creation-enabled Dark Elf race.

local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Quests = require(Core.Services.QuestService)

local USER_ID = 967201
local checks = 0

--[[
Counts one Dark Elf Adventure assertion.

Args:
    condition (boolean): Expected authoritative quest result.
    label (string): Diagnostic failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Dark Elf Adventure] " .. label)
end

--[[
Installs one normal creation-valid Dark Elf Fighter identity.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates only the disposable in-memory profile.
]]
local function install_dark_elf(
    profiles: any
)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 1
            character.Identity = {
                Version = 1,
                RaceId = "DarkElf",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
        end),
        "Dark Elf Fighter identity persists"
    )
end

--[[
Records one trusted DungeonClear event.

Args:
    quests (any): Authoritative quest service.
    event_id (string): Stable dedupe identifier.
    dungeon_id (string): Server-known dungeon identifier.

Returns:
    nil: Raises when progress is rejected.
]]
local function record_clear(
    quests: any,
    event_id: string,
    dungeon_id: string
)
    local result = quests:record_event(USER_ID, {
        EventId = event_id,
        Type = "DungeonClear",
        TargetId = dungeon_id,
        Amount = 1,
    })
    check(result.ok == true, event_id .. " progresses")
end

--[[
Returns one inventory quantity from the current character.

Args:
    profiles (any): Loaded authoritative profile service.
    item_id (string): Registered item identifier.

Returns:
    number: Current authoritative quantity.
]]
local function quantity(
    profiles: any,
    item_id: string
): number
    local character = assert(
        profiles:get_character(USER_ID, 1)
    )
    return Inventory.count_item(character, item_id)
end

--[[
Runs the core Dark Elf story/provisioning path plus the wolf side quest.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after save/reload succeeds.
]]
local function main()
    local adapter = Adapter.new()
    local profiles = Profiles.new(adapter)

    check(profiles:load(USER_ID), "profile loads")
    install_dark_elf(profiles)

    local quests = Quests.new(profiles)

    check(
        quests:start(USER_ID, "WorldrootRelic").ok,
        "Dark Elf starts Worldroot Relic"
    )
    record_clear(
        quests,
        "dark-elf:worldroot",
        "TestDungeon"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "WorldrootRelic"
        ).ok,
        "Dark Elf claims Worldroot Relic"
    )

    check(
        quests:start(USER_ID, "ForestWolfBounty").ok,
        "Dark Elf starts optional Forest Wolf bounty"
    )
    check(
        quests:record_event(USER_ID, {
            EventId = "dark-elf:wolf-1",
            Type = "EnemyDefeat",
            TargetId = "forest_wolf",
            Amount = 1,
        }).ok,
        "Dark Elf receives first trusted wolf defeat"
    )
    check(
        quests:record_event(USER_ID, {
            EventId = "dark-elf:wolf-2",
            Type = "EnemyDefeat",
            TargetId = "forest_wolf",
            Amount = 1,
        }).ok,
        "Dark Elf receives second trusted wolf defeat"
    )
    local wolf_claim = quests:claim_reward(
        USER_ID,
        "ForestWolfBounty"
    )
    check(
        wolf_claim.ok
            and wolf_claim.gold_granted == 40
            and #wolf_claim.items_granted == 0,
        "Dark Elf claims optional Gold-only wolf bounty"
    )

    local captain_too_early = quests:start(
        USER_ID,
        "MarauderCaptainBounty"
    )
    check(
        not captain_too_early.ok
            and captain_too_early.reason == "QuestUnavailable",
        "level-one Dark Elf cannot start level-five Captain bounty"
    )

    check(
        quests:start(USER_ID, "MineEchoes").ok,
        "Dark Elf starts Mine Echoes"
    )
    record_clear(
        quests,
        "dark-elf:mine",
        "AbandonedMine"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "MineEchoes"
        ).ok,
        "Dark Elf claims Mine Echoes"
    )

    check(
        quests:start(
            USER_ID,
            "ExpeditionProvisioning"
        ).ok,
        "Dark Elf starts Provisioning"
    )
    record_clear(
        quests,
        "dark-elf:provision-temple",
        "TestDungeon"
    )
    record_clear(
        quests,
        "dark-elf:provision-mine",
        "AbandonedMine"
    )

    local provision = quests:claim_reward(
        USER_ID,
        "ExpeditionProvisioning"
    )
    check(
        provision.ok == true
            and provision.gold_granted == 75
            and #provision.items_granted == 3,
        "Dark Elf claims the complete Provisioning bundle"
    )

    check(
        quantity(profiles, "deep_iron_ore") == 2
            and quantity(profiles, "moonpetal") == 2
            and quantity(profiles, "thick_hide") == 2,
        "Dark Elf receives all advanced trade materials"
    )

    local character = assert(
        profiles:get_character(USER_ID, 1)
    )
    check(
        character.ProfessionSlots.Gathering == ""
            and character.ProfessionSlots.Creation == "",
        "Adventure chain still requires no profession selection"
    )
    check(
        character.Quests.Completed.WorldrootRelic == true
            and character.Quests.Completed.ForestWolfBounty == true
            and character.Quests.Completed.MineEchoes == true
            and character.Quests.Completed.ExpeditionProvisioning == true,
        "core Dark Elf story/provisioning Adventures complete once"
    )

    check(
        profiles:save(
            USER_ID,
            "DarkElfAdventureIntegration"
        ),
        "completed Dark Elf Adventure chain saves"
    )

    local restored = Profiles.new(adapter)
    check(restored:load(USER_ID), "Dark Elf profile reloads")
    local restored_character = assert(
        restored:get_character(USER_ID, 1)
    )
    check(
        restored_character.Quests.Completed.ForestWolfBounty == true
            and restored_character.Quests.Completed
                .ExpeditionProvisioning == true
            and Inventory.count_item(
                restored_character,
                "deep_iron_ore"
            ) == 2
            and Inventory.count_item(
                restored_character,
                "moonpetal"
            ) == 2
            and Inventory.count_item(
                restored_character,
                "thick_hide"
            ) == 2,
        "Dark Elf quest completion and reward bundle survive reload"
    )

    print(
        ("[Dark Elf Adventure] PASS: %d assertions")
            :format(checks)
    )
end

main()
