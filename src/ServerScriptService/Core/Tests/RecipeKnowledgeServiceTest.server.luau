--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Adapters = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Adapters")
local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local RecipeKnowledgeService = require(
    Services:WaitForChild("RecipeKnowledgeService")
)
local ProfessionService = require(
    Services:WaitForChild("ProfessionService")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Recipe Knowledge Service Tests] " .. message, 2)
    end
end

local function level_two_xp(): number
    local needed = ProfessionDefinitions.xp_to_next(1)
    assert(type(needed) == "number" and needed > 0)
    return needed
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(8501))
local inventory = InventoryService.new(profiles)
local knowledge = RecipeKnowledgeService.new(profiles, inventory)
local professions = ProfessionService.new(profiles, inventory)
assert(professions:choose_profession(8501, "Blacksmithing").ok)

local default_known = knowledge:knows_recipe(8501, "forge_ironbound_gloves")
check(
    default_known.ok == true and default_known.known == true,
    "Default recipe must be known without learned membership."
)

local learned_before = knowledge:knows_recipe(
    8501,
    "forge_blueprinted_ironbound_gloves"
)
check(
    learned_before.ok == true and learned_before.known == false,
    "Learned recipe must be unknown before blueprint use."
)

local unknown = knowledge:learn_from_item(8501, "missing_blueprint")
check(
    unknown.ok == false and unknown.reason == "UnknownBlueprintItem",
    "Unknown blueprint item must reject."
)

assert(inventory:add_item(8501, "recipe_blueprint_invalid_test", 1).ok)
local malformed = knowledge:learn_from_item(
    8501,
    "recipe_blueprint_invalid_test"
)
check(
    malformed.ok == false
        and malformed.reason == "InvalidRecipeLearningDefinition",
    "Malformed blueprint payload must fail closed."
)

local not_owned = knowledge:learn_from_item(
    8501,
    "blacksmith_iron_guard_blueprint"
)
check(
    not_owned.ok == false and not_owned.reason == "BlueprintNotOwned",
    "Unowned blueprint must reject."
)

assert(inventory:add_item(
    8501,
    "blacksmith_iron_guard_blueprint",
    2
).ok)

local too_low = knowledge:learn_from_item(
    8501,
    "blacksmith_iron_guard_blueprint"
)
check(
    too_low.ok == false and too_low.reason == "ProfessionLevelTooLow",
    "Level-one Blacksmithing must not learn a level-two blueprint."
)

assert(profiles:mutate(8501, function(profile: any)
    profile.Characters.Slot1.Professions.Blacksmithing.XP = level_two_xp()
end))

local before_count = InventoryService.count_item(
    assert(profiles:get_character(8501, 1)),
    "blacksmith_iron_guard_blueprint"
)
check(before_count == 2, "Fixture must own two Blacksmithing blueprints.")

local learned = knowledge:learn_from_item(
    8501,
    "blacksmith_iron_guard_blueprint"
)
check(learned.ok == true, "Valid Blacksmithing blueprint must learn.")
check(
    learned.RecipeId == "blacksmith_iron_guard_blueprint",
    "Server-resolved knowledge ID mismatch."
)
check(
    learned.CraftRecipeId == "forge_blueprinted_ironbound_gloves",
    "Server-resolved craft recipe mismatch."
)

local after_first = InventoryService.count_item(
    assert(profiles:get_character(8501, 1)),
    "blacksmith_iron_guard_blueprint"
)
check(after_first == 1, "Exactly one blueprint must be consumed.")

local duplicate = knowledge:learn_from_item(
    8501,
    "blacksmith_iron_guard_blueprint"
)
check(
    duplicate.ok == false and duplicate.reason == "RecipeAlreadyKnown",
    "Duplicate blueprint learning must reject."
)

local after_duplicate = InventoryService.count_item(
    assert(profiles:get_character(8501, 1)),
    "blacksmith_iron_guard_blueprint"
)
check(
    after_duplicate == 1,
    "Duplicate learning must not consume another blueprint."
)

local learned_after = knowledge:knows_recipe(
    8501,
    "forge_blueprinted_ironbound_gloves"
)
check(
    learned_after.ok == true and learned_after.known == true,
    "Learned recipe must be known after blueprint use."
)

local snapshot = knowledge:get_snapshot(8501)
check(snapshot.ok == true, "Knowledge snapshot must build.")
check(
    snapshot.LearnedRecipes["blacksmith_iron_guard_blueprint"] == true,
    "Snapshot must expose learned Blacksmithing knowledge."
)

snapshot.LearnedRecipes["blacksmith_iron_guard_blueprint"] = nil
local fresh_snapshot = knowledge:get_snapshot(8501)
check(
    fresh_snapshot.LearnedRecipes["blacksmith_iron_guard_blueprint"] == true,
    "Snapshot mutation must not alter profile state."
)

-- A missing profession state must fail closed rather than inventing eligibility.
-- ProfileService:mutate sanitizes profiles after every successful mutation, so
-- deleting a default profession through that authority cannot create this
-- malformed-state fixture. Use a focused test-only profile proxy instead.
assert(inventory:add_item(8501, "alchemy_restorative_tonic_recipe", 1).ok)

local missing_profession_character = assert(
    profiles:get_character(8501, 1)
)
missing_profession_character.Professions.Alchemy = nil
-- Detached fixture explicitly selects Alchemy so the missing state,
-- rather than an absent profession choice, is the rejection under test.
missing_profession_character.ProfessionSlots.Creation = "Alchemy"

local missing_profession_profiles = {}

function missing_profession_profiles:get_character(
    user_id: number,
    slot: number?
): any?
    if user_id ~= 8501 or (slot ~= nil and slot ~= 1) then
        return nil
    end

    return missing_profession_character
end

function missing_profession_profiles:mutate(
    _user_id: number,
    _mutator: (any) -> ()
): (boolean, string?)
    error("Missing profession state must reject before mutation.")
end

local unavailable_knowledge = RecipeKnowledgeService.new(
    missing_profession_profiles,
    inventory
)
local unavailable = unavailable_knowledge:learn_from_item(
    8501,
    "alchemy_restorative_tonic_recipe"
)
check(
    unavailable.ok == false and unavailable.reason == "ProfessionUnavailable",
    "Missing profession state must reject."
)

-- Save/release/reload through the accepted profile boundary and prove
-- both knowledge and blueprint consumption persist.
assert(profiles:save(8501, "RecipeKnowledgeTest"))
assert(profiles:release(8501, "RecipeKnowledgeTest"))
assert(profiles:load(8501))

local reconstructed = RecipeKnowledgeService.new(profiles, inventory)
local persistent = reconstructed:knows_recipe(
    8501,
    "forge_blueprinted_ironbound_gloves"
)
check(
    persistent.ok == true and persistent.known == true,
    "Learned knowledge must survive save/release/reload."
)
check(
    InventoryService.count_item(
        assert(profiles:get_character(8501, 1)),
        "blacksmith_iron_guard_blueprint"
    ) == 1,
    "Consumed blueprint count must survive save/release/reload."
)

-- Repeated attempts model the serial mutation race boundary: only one can learn.
assert(profiles:load(8502))
assert(professions:choose_profession(8502, "Blacksmithing").ok)
local inventory2 = InventoryService.new(profiles)
local knowledge2 = RecipeKnowledgeService.new(profiles, inventory2)
assert(inventory2:add_item(8502, "blacksmith_iron_guard_blueprint", 1).ok)
assert(profiles:mutate(8502, function(profile: any)
    profile.Characters.Slot1.Professions.Blacksmithing.XP = level_two_xp()
end))

local first = knowledge2:learn_from_item(
    8502,
    "blacksmith_iron_guard_blueprint"
)
local second = knowledge2:learn_from_item(
    8502,
    "blacksmith_iron_guard_blueprint"
)
check(first.ok == true, "First serial learn must succeed.")
check(
    second.ok == false
        and (
            second.reason == "RecipeAlreadyKnown"
            or second.reason == "BlueprintNotOwned"
        ),
    "Second serial duplicate must reject without a second consume."
)
check(
    InventoryService.count_item(
        assert(profiles:get_character(8502, 1)),
        "blacksmith_iron_guard_blueprint"
    ) == 0,
    "Single owned blueprint must be consumed exactly once."
)

print(string.format(
    "[Recipe Knowledge Service Tests] PASS: %d assertions.",
    assertions
))
