--!strict
-- Retires defeated enemies. Explicitly registered beast corpses remain
-- harvestable briefly after their encounter rewards have been processed.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local SkinningEligibility = require(
    ServerScriptService.Core.Services:WaitForChild("SkinningEligibility")
)

local DungeonEnemyCleanup = {}

local RETIRED_ATTRIBUTE = "DungeonEnemyRetired"
local DEFAULT_DESTROY_DELAY_SECONDS = 0.15
local BEAST_CORPSE_LIFETIME_SECONDS = 45
local BEAST_TAG = "DungeonMMOSkinnableBeast"

-- Args:
--   instance: Instance; part or effect to disable on a defeated enemy.
--   preserve_visuals: boolean; keep an eligible beast corpse visible.
-- Returns:
--   nil: removes combat collisions and effects without re-enabling them.
local function disable_visual_or_collision(
    instance: Instance,
    preserve_visuals: boolean
)
    if instance:IsA("BasePart") then
        if not preserve_visuals then
            instance.Transparency = 1
        end
        instance.CanCollide = false
        instance.CanTouch = false
        instance.CanQuery = false
    elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail")
        or instance:IsA("Beam")
    then
        instance.Enabled = false
    elseif instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
        instance.Enabled = false
    end
end

-- Args:
--   model: Model; an enemy that just completed its server reward path.
-- Returns:
--   boolean: whether this enemy is a registered animal-like corpse.
local function should_preserve_corpse(model: Model): boolean
    if not CollectionService:HasTag(model, BEAST_TAG)
        or Players:GetPlayerFromCharacter(model) ~= nil
    then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health <= 0
        and SkinningEligibility.is_species_allowed(
            model:GetAttribute("CreatureSpeciesId"),
            model:GetAttribute("CreatureFamily")
        )
end

-- Args:
--   model: Model; defeated enemy to retire from combat.
--   destroy_delay_seconds: number?; optional explicit test delay.
-- Returns:
--   boolean: true for the first retirement, false for repeated calls.
function DungeonEnemyCleanup.retire(
    model: Model,
    destroy_delay_seconds: number?
): boolean
    if not model:IsA("Model")
        or model:GetAttribute(RETIRED_ATTRIBUTE) == true
    then
        return false
    end

    local preserve_corpse = should_preserve_corpse(model)
    model:SetAttribute(RETIRED_ATTRIBUTE, true)
    for _, descendant in ipairs(model:GetDescendants()) do
        disable_visual_or_collision(descendant, preserve_corpse)
    end

    if preserve_corpse then
        -- retire() is called only after encounter rewards succeed. A beast
        -- can be skinned after this existing server-owned loot boundary.
        model:SetAttribute("LootComplete", true)
    end

    local default_delay = if preserve_corpse
        then BEAST_CORPSE_LIFETIME_SECONDS
        else DEFAULT_DESTROY_DELAY_SECONDS
    local delay_seconds = if type(destroy_delay_seconds) == "number"
        then destroy_delay_seconds
        else default_delay
    delay_seconds = math.max(0, delay_seconds)

    task.delay(delay_seconds, function()
        if model.Parent then
            model:Destroy()
        end
    end)

    return true
end

return table.freeze(DungeonEnemyCleanup)
