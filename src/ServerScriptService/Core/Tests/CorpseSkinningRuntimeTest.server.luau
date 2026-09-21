--!strict
-- Server-only acceptance: no generic enemy can grant hides, while an
-- explicitly tagged/registered beast needs death, loot and one-time claim.
local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")

local Runtime = require(SSS.Core.Services.CorpseSkinningRuntime)

local assertions = 0

-- Args:
--   ok: boolean; whether the contract is satisfied.
--   message: string; identifies a failed contract.
-- Returns:
--   nil: records an assertion and raises if it fails.
local function check(ok: boolean, message: string)
    assertions += 1
    assert(ok, "[Corpse Skinning] " .. message)
end

-- Args:
--   identity: string; authoritative creature species.
--   family: string; authoritative server creature family.
--   tagged: boolean; whether the factory opted the creature into skinning.
-- Returns:
--   Model: a disposable server-owned animal or monster model.
local function create_creature(
    identity: string,
    family: string,
    tagged: boolean
): Model
    local model = Instance.new("Model")
    model.Name = identity
    model:SetAttribute("CreatureSpeciesId", identity)
    model:SetAttribute("CreatureFamily", family)
    model:SetAttribute("LootComplete", false)
    model:SetAttribute("SkinningClaimed", false)

    local part = Instance.new("Part")
    part.Name = "HumanoidRootPart"
    part.Anchored = true
    part.CFrame = CFrame.new(0, 0, 0)
    part.Parent = model
    model.PrimaryPart = part

    local humanoid = Instance.new("Humanoid")
    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = model
    model.Parent = workspace
    if tagged then
        CollectionService:AddTag(model, "DungeonMMOSkinnableBeast")
    end
    return model
end

local character = Instance.new("Model")
local player_root = Instance.new("Part")
player_root.Name = "HumanoidRootPart"
player_root.Anchored = true
player_root.Position = Vector3.new(0, 0, 5)
player_root.Parent = character
local player_humanoid = Instance.new("Humanoid")
player_humanoid.Parent = character
character.Parent = workspace

local fake_player = ({
    UserId = 987651,
    Character = character,
} :: any)
local grant_calls = 0
local professions = {
    gather = function(_self: any, user_id: number, node: any): any
        grant_calls += 1
        check(user_id == fake_player.UserId
            and node.ProfessionId == "Skinning"
            and node.ItemId == "raw_hide"
            and node.Quantity == 1,
            "skin grant must use existing service and fixed server resource")
        return {ok = true, item_id = "raw_hide", quantity = 1}
    end,
}

local marauder = create_creature("TrainingMarauder", "Beast", true)
local wolf = create_creature("forest_wolf", "Beast", true)
local untagged = create_creature("wild_boar", "Beast", false)

local wolf_humanoid = assert(wolf:FindFirstChildOfClass("Humanoid"))
local marauder_humanoid = assert(
    marauder:FindFirstChildOfClass("Humanoid"))
local boar_humanoid = assert(untagged:FindFirstChildOfClass("Humanoid"))

wolf_humanoid.Health = 0
marauder_humanoid.Health = 0
boar_humanoid.Health = 0
wolf:SetAttribute("LootComplete", true)
marauder:SetAttribute("LootComplete", true)
untagged:SetAttribute("LootComplete", true)

check(not Runtime.can_skin_model(marauder),
    "a Marauder cannot become skinnable by claiming Beast family/tag")
check(not Runtime.can_skin_model(untagged),
    "untagged animal cannot grant hides without server factory opt-in")
check(Runtime.can_skin_model(wolf),
    "registered tagged dead and looted wolf should be skinnable")

player_root.Position = Vector3.new(0, 0, 40)
local far = Runtime.try_skin(fake_player, wolf, professions)
check(not far.ok and far.reason == "NotAtSkinnableCreature",
    "too-far server skinning request must fail")
check(wolf:GetAttribute("SkinningClaimed") == false
    and grant_calls == 0,
    "out-of-range request cannot mark or grant the corpse")

player_root.Position = Vector3.new(0, 0, 5)
local successful = Runtime.try_skin(fake_player, wolf, professions)
check(successful.ok and grant_calls == 1,
    "nearby eligible wolf gives exactly one server-owned hide")
check(wolf:GetAttribute("SkinningClaimed") == true,
    "success must mark the exact corpse claimed")
local duplicate = Runtime.try_skin(fake_player, wolf, professions)
check(not duplicate.ok and grant_calls == 1,
    "repeat attempt cannot grant a second hide")

local bear = create_creature("cave_bear", "Beast", true)
local bear_humanoid = assert(bear:FindFirstChildOfClass("Humanoid"))
bear_humanoid.Health = 0
bear:SetAttribute("LootComplete", true)

local missing_profile = {
    gather = function(): any
        return {ok = false, reason = "ProfileNotLoaded"}
    end,
}
local rejected = Runtime.try_skin(fake_player, bear, missing_profile)
check(not rejected.ok and rejected.reason == "ProfileNotLoaded",
    "failed profile grant returns the actual service rejection")
check(bear:GetAttribute("SkinningClaimed") == false,
    "failed grant releases the pending corpse claim for retry")
local retried = Runtime.try_skin(fake_player, bear, professions)
check(retried.ok and grant_calls == 2,
    "successful retry grants one hide after profile recovery")

local root = Instance.new("Folder")
root.Parent = workspace
Runtime.attach({
    root = root,
    professions = professions,
    action_result = function(): ()
    end,
})
local boar = create_creature("wild_boar", "Beast", true)
local boar_humanoid2 = assert(boar:FindFirstChildOfClass("Humanoid"))
boar_humanoid2.Health = 0
check(boar.PrimaryPart:FindFirstChild("BeastSkinningPrompt") == nil,
    "unlooted animal must not expose a skinning prompt")
boar:SetAttribute("LootComplete", true)
task.wait(0.1)
local prompt = boar.PrimaryPart:FindFirstChild("BeastSkinningPrompt")
check(prompt ~= nil and prompt:IsA("ProximityPrompt")
    and prompt.Enabled,
    "dead looted and registered animal gets a skinning prompt")
check(marauder.PrimaryPart:FindFirstChild("BeastSkinningPrompt") == nil,
    "registered Marauder never gets a beast-skinning prompt")

root:Destroy()
marauder:Destroy()
wolf:Destroy()
untagged:Destroy()
bear:Destroy()
boar:Destroy()
character:Destroy()
print(string.format(
    "[Corpse Skinning] PASS: %d assertions.", assertions))
