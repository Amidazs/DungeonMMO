--!strict
-- Two independent in-memory player profiles contest one server-owned corpse.
-- This is an atomic service test, not a two-client network Play test.
local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")

local Core = SSS:WaitForChild("Core")
local Runtime = require(Core.Services.CorpseSkinningRuntime)
local InMemoryAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)

local assertions = 0

-- Args:
--   condition: boolean; required concurrent-claim rule.
--   message: string; explanation of the invariant.
-- Returns:
--   nil: increments the assertion count or raises on failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Skinning Two User] " .. message)
end

-- Args:
--   user_id: number; unique disposable account identifier.
--   position: Vector3; server-owned player position near the corpse.
-- Returns:
--   any: disposable Player-like object with a living character.
local function create_player(user_id: number, position: Vector3): any
    local character = Instance.new("Model")
    character.Name = "SkinningTwoUserCharacter_TEMP"
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.Position = position
    root.Parent = character

    local humanoid = Instance.new("Humanoid")
    humanoid.Health = 100
    humanoid.Parent = character
    character.Parent = workspace
    return {UserId = user_id, Character = character}
end

-- Args:
--   position: Vector3; location of a registered dead and looted wolf.
-- Returns:
--   Model: independent harvestable animal corpse for one contest.
local function create_corpse(position: Vector3): Model
    local model = Instance.new("Model")
    model.Name = "SkinningTwoUserWolf_TEMP"
    model:SetAttribute("CreatureSpeciesId", "forest_wolf")
    model:SetAttribute("CreatureFamily", "Beast")
    model:SetAttribute("LootComplete", true)
    model:SetAttribute("SkinningClaimed", false)

    local part = Instance.new("Part")
    part.Name = "HumanoidRootPart"
    part.Anchored = true
    part.Position = position
    part.Parent = model
    model.PrimaryPart = part

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model
    model.Parent = workspace
    humanoid.Health = 0
    CollectionService:AddTag(model, "DungeonMMOSkinnableBeast")
    return model
end

local profiles = Profiles.new(InMemoryAdapter.new())
local first = create_player(68311, Vector3.new(4, 5, 0))
local second = create_player(68312, Vector3.new(-4, 5, 0))
check(profiles:load(first.UserId) ~= nil,
    "first player must receive an independent in-memory profile")
check(profiles:load(second.UserId) ~= nil,
    "second player must receive an independent in-memory profile")
local inventory = Inventory.new(profiles)
local professions = Professions.new(profiles, inventory)
local corpse = create_corpse(Vector3.new(0, 5, 0))

local first_result: any = nil
local second_result: any = nil
task.spawn(function()
    first_result = Runtime.try_skin(first, corpse, professions)
end)
task.spawn(function()
    second_result = Runtime.try_skin(second, corpse, professions)
end)

local deadline = os.clock() + 6
while (first_result == nil or second_result == nil)
    and os.clock() < deadline
do
    task.wait(0.05)
end
check(first_result ~= nil and second_result ~= nil,
    "both concurrent server harvest calls must complete")

local successes = (if first_result.ok then 1 else 0)
    + (if second_result.ok then 1 else 0)
check(successes == 1,
    "two users contesting one corpse must award exactly one hide")
check((not first_result.ok
    and first_result.reason == "CreatureNotSkinnable")
    or (not second_result.ok
        and second_result.reason == "CreatureNotSkinnable"),
    "a losing concurrent claimant must be rejected by server authority")
check(corpse:GetAttribute("SkinningClaimed") == true,
    "the contested corpse must stay claimed after its first grant")

local first_character = assert(profiles:get_character(first.UserId, 1))
local second_character = assert(profiles:get_character(second.UserId, 1))
local first_hides = Inventory.count_item(first_character, "raw_hide")
local second_hides = Inventory.count_item(second_character, "raw_hide")
check(first_hides + second_hides == 1,
    "independent inventories must contain one hide total after race")

local loser = if first_result.ok then second else first
local fresh_corpse = create_corpse(Vector3.new(0, 5, 0))
local retry = Runtime.try_skin(loser, fresh_corpse, professions)
check(retry.ok == true,
    "losing player can skin another eligible corpse independently")
local loser_character = assert(profiles:get_character(loser.UserId, 1))
check(Inventory.count_item(loser_character, "raw_hide") == 1,
    "independent second corpse yields exactly one hide to other user")

corpse:Destroy()
fresh_corpse:Destroy()
first.Character:Destroy()
second.Character:Destroy()

print(string.format(
    "[Skinning Two User] PASS: %d assertions.", assertions))
