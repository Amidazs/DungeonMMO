--!strict
-- Check actual factory-built rig parts rather than waiting forever for
-- legacy arena model names in a differently laid-out Dungeon place.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CombatConfig = require(
    ReplicatedStorage.Combat.Shared.CombatConfig
)
local MarauderFactory = require(
    ServerScriptService.Combat.MarauderFactory
)

local MARAUDER_CONFIG = CombatConfig.TRAINING_MARAUDER
local MOTOR_NAMES = table.freeze({
    "MarauderBodyMotor", "MarauderHeadMotor",
    "MarauderRightArmMotor", "MarauderLeftArmMotor",
    "MarauderBladeMotor",
})
local VISUAL_NAMES = table.freeze({
    "Body", "Head", "RightArm", "LeftArm", "TrainingBlade",
})

--[[
Checks collision ownership and independently jointed visible rig parts.

Args:
    model (Model): Actual new world-spawned model from MarauderFactory.

Returns:
    nil: Raises if the genuine rig is missing a safety-critical part.
]]
local function assert_rig(model: Model)
    local root = assert(model:FindFirstChild("HumanoidRootPart"))
    local collision = assert(model:FindFirstChild("CollisionBody"))
    assert(root:IsA("BasePart") and root.Anchored,
        "Factory root must be anchored and authoritative")
    assert(collision:IsA("BasePart") and collision.CanCollide
        and not collision.Anchored,
        "Real collision hull must be part of anchored root assembly")
    for _, name in ipairs(MOTOR_NAMES) do
        local motor = model:FindFirstChild(name, true)
        assert(motor and motor:IsA("Motor6D")
            and motor:GetAttribute("BaseC0") ~= nil,
            "Factory rig missing a neutral-pose motor: " .. name)
    end
    for _, name in ipairs(VISUAL_NAMES) do
        local part = model:FindFirstChild(name)
        assert(part and part:IsA("BasePart") and not part.CanCollide,
            "Factory visuals must not drive collision: " .. name)
    end
end

--[[
Creates all four configured encounter rig variants in temporary world.

Args:
    folder (Folder): Disposable workspace container for factory models.

Returns:
    nil: All actual MarauderFactory variants satisfy physical rig rules.
]]
local function test_factory_variants(folder: Folder)
    for index, name in ipairs(MARAUDER_CONFIG.MODEL_NAMES) do
        local model = MarauderFactory.create({
            Parent = folder,
            Name = "TEMP_RigContract_" .. name,
            SpawnCFrame = CFrame.new(index * 8, 1000, 0),
            SpawnIndex = index,
            RespawnEnabled = false,
            ControllerEnabled = false,
            TargetEnabled = false,
        })
        assert(model:IsDescendantOf(Workspace)
            and model.PrimaryPart ~= nil,
            "Factory must produce a real registered world model")
        assert_rig(model)
    end
end

--[[
Runs the physical factory contract without relying on active room layout.

Args:
    None.

Returns:
    nil: Always cleans up temporary rigs, including after a test failure.
]]
local function main()
    local folder = Instance.new("Folder")
    folder.Name = "TEMP_MarauderRigContract"
    folder.Parent = Workspace
    local ok, reason = pcall(test_factory_variants, folder)
    folder:Destroy()
    assert(ok, "[Marauder Rig Contract] " .. tostring(reason))
    print("[Marauder Rig Contract Tests] PASS: four factory rigs")
end

main()
