--!strict
-- Explicitly opt-in temporary world boss; reuse the established captain
-- combat rig until dedicated guardian art and combat patterns are authored.
local CollectionService = game:GetService("CollectionService")

local CaptainFactory = require(
    script.Parent:WaitForChild("MarauderCaptainFactory")
)

local DungeonWeeklyWorldBossFactory = {}

local BOSS_ID = "AncientGuardian"
local BOSS_TAG = "DungeonMMOWeeklyWorldBoss"

-- Args:
--   options: any; server-owned Parent, SpawnCFrame and InstanceId.
-- Returns:
--   Model: distinct server-tagged world boss, with no ordinary gold reward.
function DungeonWeeklyWorldBossFactory.create(options: any): Model
    assert(type(options) == "table"
        and typeof(options.Parent) == "Instance"
        and typeof(options.SpawnCFrame) == "CFrame"
        and type(options.InstanceId) == "string"
        and options.InstanceId ~= "",
        "World boss factory requires an authorized server instance")

    local boss = CaptainFactory.create({
        Parent = options.Parent,
        SpawnCFrame = options.SpawnCFrame,
        EncounterId = "WeeklyBoss:" .. options.InstanceId,
        RewardXP = 0,
        RewardGoldMin = 0,
        RewardGoldMax = 0,
        HealthMultiplier = options.HealthMultiplier or 2,
        DamageMultiplier = options.DamageMultiplier or 1,
        BossRole = "WorldBoss",
    })
    boss.Name = "AncientGuardianPlaceholder"
    boss:SetAttribute("BossId", BOSS_ID)
    boss:SetAttribute("WorldBossId", BOSS_ID)
    boss:SetAttribute("WorldBossInstanceId", options.InstanceId)
    boss:SetAttribute("DungeonEnemyId",
        "WeeklyBoss:" .. options.InstanceId)
    boss:SetAttribute("BestiaryCreatureId", nil)
    local humanoid = assert(
        boss:FindFirstChildOfClass("Humanoid"),
        "World boss requires a server-owned humanoid"
    )
    humanoid.DisplayName = "Ancient Guardian (Prototype)"

    -- Apply this tag only after constructing the authoritative model.
    CollectionService:AddTag(boss, BOSS_TAG)
    return boss
end

return table.freeze(DungeonWeeklyWorldBossFactory)
