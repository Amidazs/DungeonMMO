--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local DungeonEnemyCleanup = require(Dungeon:WaitForChild("DungeonEnemyCleanup"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then error("[Dungeon Enemy Cleanup Tests] " .. message, 2) end
end

local model = Instance.new("Model")
model.Name = "CleanupTestEnemy"
local root = Instance.new("Part")
root.Name = "HumanoidRootPart"
root.CanCollide = true
root.CanTouch = true
root.CanQuery = true
root.Transparency = 0
root.Parent = model
local body = Instance.new("Part")
body.Name = "Body"
body.CanCollide = true
body.Transparency = 0
body.Parent = model
local emitter = Instance.new("ParticleEmitter")
emitter.Enabled = true
emitter.Parent = body
model.Parent = workspace

local first = DungeonEnemyCleanup.retire(model, 10)
check(first == true, "First retirement must be accepted.")
check(model:GetAttribute("DungeonEnemyRetired") == true, "Retired marker must be set.")
check(root.Transparency == 1 and body.Transparency == 1, "All enemy parts must become invisible immediately.")
check(root.CanCollide == false and root.CanTouch == false and root.CanQuery == false, "Retired enemy collision/query must be disabled.")
check(emitter.Enabled == false, "Retired enemy effects must be disabled.")
check(DungeonEnemyCleanup.retire(model, 10) == false, "Retirement must be idempotent.")
model:Destroy()

-- Only explicit animal-like enemy identities remain visible for skinning.
local collection_service = game:GetService("CollectionService")
local beast = Instance.new("Model")
beast.Name = "BeastCleanupTest"
beast:SetAttribute("CreatureSpeciesId", "forest_wolf")
beast:SetAttribute("CreatureFamily", "Beast")
beast:SetAttribute("SkinningClaimed", false)
beast:SetAttribute("LootComplete", false)

local beast_root = Instance.new("Part")
beast_root.Name = "HumanoidRootPart"
beast_root.Transparency = 0
beast_root.CanCollide = true
beast_root.Parent = beast
beast.PrimaryPart = beast_root

local beast_humanoid = Instance.new("Humanoid")
beast_humanoid.BreakJointsOnDeath = false
beast_humanoid.Health = 0
beast_humanoid.Parent = beast
beast.Parent = workspace
collection_service:AddTag(beast, "DungeonMMOSkinnableBeast")

check(DungeonEnemyCleanup.retire(beast, 10),
    "registered animal should enter corpse retention after defeat")
check(beast_root.Transparency == 0 and not beast_root.CanCollide,
    "skinnable animal stays visible but stops being a combat obstacle")
check(beast:GetAttribute("LootComplete") == true,
    "successful enemy retirement releases the animal corpse for skinning")
beast:Destroy()

local disguised = Instance.new("Model")
disguised.Name = "MarauderCleanupTest"
disguised:SetAttribute("CreatureSpeciesId", "Marauder")
disguised:SetAttribute("CreatureFamily", "Beast")
local disguised_root = Instance.new("Part")
disguised_root.Name = "HumanoidRootPart"
disguised_root.Parent = disguised
local disguised_humanoid = Instance.new("Humanoid")
disguised_humanoid.Health = 0
disguised_humanoid.Parent = disguised
disguised.Parent = workspace
collection_service:AddTag(disguised, "DungeonMMOSkinnableBeast")

check(DungeonEnemyCleanup.retire(disguised, 10),
    "non-animal enemy should still retire normally")
check(disguised_root.Transparency == 1
    and disguised:GetAttribute("LootComplete") ~= true,
    "tagged Marauder cannot become an animal corpse or loot source")
disguised:Destroy()

print(string.format("[Dungeon Enemy Cleanup Tests] PASS: %d assertions.", assertions))
