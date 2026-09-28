--!strict
-- Server-only profession gathering tier authority regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)

local USER_ID = 963201
local checks = 0

--[[
Counts one gathering-tier assertion.

Args:
    condition (boolean): Expected authoritative result.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Gather Tier] " .. label)
end

--[[
Runs high-tier gathering progression and denial checks.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    check(profiles:load(USER_ID), "disposable profile loads")

    local inventory = Inventory.new(profiles)
    local professions = Professions.new(profiles, inventory)
    check(
        professions:choose_profession(USER_ID, "Mining").ok,
        "test character selects Mining"
    )

    local advanced_node = {
        ProfessionId = "Mining",
        ItemId = "deep_iron_ore",
        Quantity = 1,
        XP = 18,
        RequiredLevel = 3,
    }

    local denied = professions:gather(USER_ID, advanced_node)
    check(
        not denied.ok
            and denied.reason == "ProfessionLevelTooLow",
        "level-one Miner cannot harvest level-three ore"
    )

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        Inventory.count_item(character, "deep_iron_ore") == 0,
        "denied gather grants no high-tier material"
    )

    local level, level_reason =
        professions:get_profession_level(USER_ID, "Mining")
    check(
        level == 1 and level_reason == nil,
        "profession level reader starts at level one"
    )

    for _ = 1, 12 do
        local gathered = professions:gather(USER_ID, {
            ProfessionId = "Mining",
            ItemId = "iron_ore",
            Quantity = 1,
            XP = 8,
            RequiredLevel = 1,
        })
        check(gathered.ok, "foundation ore advances Mining XP")
    end

    level, level_reason =
        professions:get_profession_level(USER_ID, "Mining")
    check(
        level == 3 and level_reason == nil,
        "ninety-plus Mining XP reaches profession level three"
    )

    local advanced = professions:gather(USER_ID, advanced_node)
    check(
        advanced.ok
            and advanced.item_id == "deep_iron_ore"
            and advanced.required_level == 3,
        "level-three Miner harvests advanced ore"
    )

    character = assert(profiles:get_character(USER_ID, 1))
    check(
        Inventory.count_item(character, "deep_iron_ore") == 1,
        "successful advanced gather grants exactly one ore"
    )

    local invalid = professions:gather(USER_ID, {
        ProfessionId = "Mining",
        ItemId = "deep_iron_ore",
        Quantity = 1,
        XP = 18,
        RequiredLevel = 99,
    })
    check(
        not invalid.ok
            and invalid.reason == "InvalidNodeDefinition",
        "out-of-range gathering tier fails closed"
    )

    print(
        ("[Profession Gather Tier] PASS: %d assertions")
            :format(checks)
    )
end

main()
