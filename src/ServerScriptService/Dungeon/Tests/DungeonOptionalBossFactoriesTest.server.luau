--!strict
local CollectionService = game:GetService("CollectionService")
local Dungeon = game:GetService("ServerScriptService")
    :WaitForChild("Dungeon")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(
    ReplicatedStorage:WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("DungeonRuntimeContentCatalog")
)

local count = 0

-- Checks one boss identity and records an actionable failure.
-- Args: condition (boolean): Expected state.
--       message (string): Failure description.
-- Returns: nil: Raises on failure.
local function check(condition: boolean, message: string)
    count += 1
    assert(condition, "[Optional Boss Factories Tests] " .. message)
end

local cases = {
    {"TempleEventBoss", "Eclipse Herald", "EventBoss"},
    {"TempleSecretBoss", "Veiled Sentinel", "SecretBoss"},
    {"AbandonedMineEventBoss", "Echo Ravager", "EventBoss"},
    {"AbandonedMineSecretBoss", "Buried Archivist", "SecretBoss"},
}
local parent = Instance.new("Folder")
parent.Name = "OptionalBossFactoryTest"

-- Spawns one boss through the registered module and checks its identity.
-- Args: boss_id (string): Stable boss-content ID.
--       display_name (string): Expected humanoid display name.
--       role (string): Expected encounter role.
-- Returns: nil: Destroys its test model before returning.
local function check_factory(
    boss_id: string,
    display_name: string,
    role: string
)
    local spec = Catalog.get_boss(boss_id)
    check(spec ~= nil and spec.FactoryId == boss_id,
        boss_id .. " content registration is missing")
    check(Catalog.is_boss_factory_implemented(boss_id),
        boss_id .. " is not marked implemented")
    local factory = require(
        Dungeon:WaitForChild(boss_id .. "Factory")
    )
    local boss = factory.create({
        Parent = parent,
        SpawnCFrame = CFrame.new(0, 5, 0),
        EncounterId = boss_id .. "Test",
        RewardXP = 10,
        RewardGoldMin = 2,
        RewardGoldMax = 4,
        BestiaryCreatureId = "marauder_captain",
        HealthMultiplier = 1,
        DamageMultiplier = 1,
        BossRole = role,
    })
    check(boss.Name == boss_id
        and boss:GetAttribute("BossId") == boss_id,
        boss_id .. " stable boss ID is incorrect")
    check(boss:GetAttribute("BossRole") == role,
        boss_id .. " lost its Event/Secret role")
    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    check(humanoid ~= nil
        and humanoid.DisplayName == display_name,
        boss_id .. " display identity is incorrect")
    check(CollectionService:HasTag(
        boss, "DungeonMarauderCaptain"
    ), boss_id .. " lost the accepted combat controller tag")
    boss:Destroy()
end

for _, item in ipairs(cases) do
    check_factory(item[1], item[2], item[3])
end
parent:Destroy()
print(string.format(
    "[Optional Boss Factories Tests] PASS: %d assertions.", count
))
