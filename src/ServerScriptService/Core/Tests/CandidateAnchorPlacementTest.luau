--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Environment = ServerScriptService:WaitForChild("Core"):WaitForChild("Environment")
local CandidateAnchorPlacement = require(Environment:WaitForChild("CandidateAnchorPlacement"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Candidate Anchor Placement Tests] " .. message, 2)
    end
end

local model = Instance.new("Model")
model.Name = "BoundsPlacementTest"

local lower = Instance.new("Part")
lower.Size = Vector3.new(4, 4, 2)
lower.CFrame = CFrame.new(20, 2, 30)
lower.Anchored = true
lower.Parent = model

local upper = Instance.new("Part")
upper.Size = Vector3.new(4, 6, 2)
upper.CFrame = CFrame.new(20, 9, 30)
upper.Anchored = true
upper.Parent = model

model.Parent = workspace

local bounds_cf, size = model:GetBoundingBox()
local resolved = CandidateAnchorPlacement.resolve(model, {
    UseBounds = true,
    HeightFraction = 0.55,
    Offset = CFrame.new(),
})
check(resolved ~= nil, "Bounds selector must resolve a Model.")
local expected_y = bounds_cf.Position.Y + ((0.55 - 0.5) * size.Y)
check(math.abs((resolved :: CFrame).Position.Y - expected_y) < 0.01, "Bounds placement must use visible bounding-box height fraction.")
check(math.abs((resolved :: CFrame).Position.X - bounds_cf.Position.X) < 0.01, "Bounds placement must preserve bounds centre X.")
check(math.abs((resolved :: CFrame).Position.Z - bounds_cf.Position.Z) < 0.01, "Bounds placement must preserve bounds centre Z.")

model:Destroy()
print(string.format("[Candidate Anchor Placement Tests] PASS: %d assertions.", assertions))
