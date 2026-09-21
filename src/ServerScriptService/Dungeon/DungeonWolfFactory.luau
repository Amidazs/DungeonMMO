--!strict
-- Temporary quadruped wolf archetype, reusing the existing server combat
-- skeleton until authored animal rigs and dedicated animal AI are available.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Marauder = require(SSS.Dungeon:WaitForChild(
    "DungeonMarauderFactory"))
local CombatConfig = require(
    ReplicatedStorage.Combat.Shared:WaitForChild("CombatConfig")
)

local DungeonWolfFactory = {}

local WOLF_SPECIES_ID = "forest_wolf"
local WOLF_TAG = "DungeonMMOSkinnableBeast"

-- Args:
--   body: BasePart; existing shared combat rig's physical torso.
--   offset: Vector3; rear-leg offset from the torso centre.
-- Returns:
--   nil: welds one simple quadruped placeholder leg to the rig.
local function add_rear_leg(body: BasePart, offset: Vector3)
    local leg = Instance.new("Part")
    leg.Name = "WolfRearLeg"
    leg.Size = Vector3.new(0.6, 1.7, 0.6)
    leg.Color = body.Color
    leg.Material = body.Material
    leg.CanCollide = false
    leg.Massless = true
    leg.CFrame = body.CFrame * CFrame.new(offset)
    leg.Parent = body.Parent

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = leg
    weld.Parent = leg
end

-- Args:
--   model: Model; temporary combat rig with required Marauder motors.
-- Returns:
--   nil: provides an animal-like placeholder silhouette, not final art.
local function use_wolf_placeholder(model: Model)
    local body = assert(model:FindFirstChild("Body"))
    local head = assert(model:FindFirstChild("Head"))
    local blade = assert(model:FindFirstChild("TrainingBlade"))
    local right_leg = assert(model:FindFirstChild("RightArm"))
    local left_leg = assert(model:FindFirstChild("LeftArm"))
    assert(body:IsA("BasePart") and head:IsA("BasePart")
        and blade:IsA("BasePart")
        and right_leg:IsA("BasePart")
        and left_leg:IsA("BasePart"))

    body.Size = Vector3.new(3.8, 2.1, 2)
    body.Color = Color3.fromRGB(93, 87, 79)
    head.Size = Vector3.new(1.4, 1.3, 1.7)
    head.Color = body.Color
    right_leg.Size = Vector3.new(0.6, 1.7, 0.6)
    left_leg.Size = right_leg.Size
    right_leg.Color = body.Color
    left_leg.Color = body.Color
    blade.Transparency = 1
    blade.CanQuery = false
    blade.CanCollide = false

    add_rear_leg(body, Vector3.new(1.15, -1.2, 0.65))
    add_rear_leg(body, Vector3.new(-1.15, -1.2, 0.65))
end

-- Args:
--   options: any; standard server-owned dungeon enemy spawn settings.
-- Returns:
--   Model: a registered animal-like combat enemy, eligible after loot.
function DungeonWolfFactory.create(options: any): Model
    local combat_options = table.clone(options)
    combat_options.ControllerEnabled = false
    combat_options.BestiaryCreatureId = ""
    local wolf = Marauder.create(combat_options)
    use_wolf_placeholder(wolf)

    wolf:SetAttribute("CreatureSpeciesId", WOLF_SPECIES_ID)
    wolf:SetAttribute("CreatureFamily", "Beast")
    wolf:SetAttribute("LootComplete", false)
    wolf:SetAttribute("SkinningClaimed", false)
    wolf:SetAttribute("BestiaryCreatureId", nil)

    -- Register the fully constructed server entity before enabling AI.
    CollectionService:AddTag(wolf, WOLF_TAG)
    if options.ControllerEnabled ~= false then
        CollectionService:AddTag(
            wolf, CombatConfig.TRAINING_MARAUDER.CONTROLLER_TAG)
    end
    return wolf
end

return table.freeze(DungeonWolfFactory)
