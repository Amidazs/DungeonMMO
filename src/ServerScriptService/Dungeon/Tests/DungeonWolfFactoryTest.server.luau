--!strict
-- Dungeon wolf factory contract plus the accepted Temple Room 1 binding.
-- Only the explicit Forest Wolf archetype is enrolled for skinning.
local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Dungeon = SSS:WaitForChild("Dungeon")
local WolfFactory = require(Dungeon:WaitForChild("DungeonWolfFactory"))
local MarauderFactory = require(
    Dungeon:WaitForChild("DungeonMarauderFactory"))
local SpawnCatalog = require(
    Dungeon:WaitForChild("DungeonEncounterSpawnCatalog"))
local Skinning = require(SSS.Core.Services.SkinningEligibility)

local assertions = 0

-- Args:
--   condition: boolean; the factory rule being verified.
--   message: string; explains the expected rule.
-- Returns:
--   nil: counts the assertion or raises with useful context.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Wolf Factory] " .. message)
end

local registered = SpawnCatalog.get_enemy_archetype("Wolf")
check(registered ~= nil and registered.FactoryId == "ForestWolf",
    "wolf must have its own registered enemy factory")
local room1_pack = SpawnCatalog.get_pack(
    "TestDungeon",
    "StandardRoom1"
)
local room1_entries = assert(room1_pack)
check(
    SpawnCatalog.resolve_pack_count(room1_entries, {}) == 2,
    "Temple Room1 total enemy count must remain two"
)
check(
    #room1_entries.Entries == 2
        and room1_entries.Entries[1].EnemyArchetypeId
            == "Marauder"
        and room1_entries.Entries[1].BaseCount == 1
        and room1_entries.Entries[2].EnemyArchetypeId
            == "Wolf"
        and room1_entries.Entries[2].BaseCount == 1,
    "Temple Room1 must bind one Marauder and one Forest Wolf"
)

local holder = Instance.new("Folder")
holder.Name = "WolfFactoryTest_TEMP"
holder.Parent = workspace

local options = {
    Parent = holder,
    Name = "TestWolf",
    SpawnCFrame = CFrame.new(0, 12, 0),
    RespawnEnabled = false,
    ControllerEnabled = false,
    BaseMaxHealth = 80,
    HealthMultiplier = 1,
    DamageMultiplier = 1,
}
local wolf = WolfFactory.create(options)
local humanoid = assert(wolf:FindFirstChildOfClass("Humanoid"))
check(wolf:GetAttribute("CreatureSpeciesId") == "forest_wolf"
    and wolf:GetAttribute("CreatureFamily") == "Beast",
    "server factory must assign exact animal identity")
check(CollectionService:HasTag(wolf, "DungeonMMOSkinnableBeast"),
    "the wolf must be intentionally enrolled for skinning")
check(wolf:GetAttribute("LootComplete") == false
    and wolf:GetAttribute("SkinningClaimed") == false,
    "a freshly spawned wolf must not be harvested")
check(humanoid.Health > 0
    and not Skinning.can_skin(
        wolf:GetAttribute("CreatureSpeciesId"),
        wolf:GetAttribute("CreatureFamily"),
        humanoid.Health <= 0,
        wolf:GetAttribute("LootComplete"),
        wolf:GetAttribute("SkinningClaimed")),
    "a living wolf cannot provide hide")
check(wolf:FindFirstChild("WolfRearLeg") ~= nil
    and wolf:FindFirstChild("TrainingBlade").Transparency == 1,
    "wolf has a quadruped placeholder silhouette, not a visible sword")
check(wolf:GetAttribute("BestiaryCreatureId") == nil,
    "temporary animal must not grant Marauder bestiary progress")

local marauder_options = table.clone(options)
marauder_options.Name = "TestMarauder"
local marauder = MarauderFactory.create(marauder_options)
check(not CollectionService:HasTag(marauder,
    "DungeonMMOSkinnableBeast"),
    "existing Marauder factory must never enroll its enemies")
check(marauder:GetAttribute("CreatureSpeciesId") == nil,
    "humanoid enemies must not inherit animal identity")

holder:Destroy()
print(string.format(
    "[Wolf Factory] PASS: %d assertions.", assertions))
