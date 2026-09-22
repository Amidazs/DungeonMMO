-- Create an isolated lasso performer from the existing, tested R15 mannequin.
assert(game.PlaceId == 0 and game:GetService("RunService"):IsStudio(),
    "Lasso development is restricted to unpublished Studio Place1")
local source = workspace:FindFirstChild("DMMO_Astra_Guardian_Test")
assert(source and source:GetAttribute("DMMO_TestOnly"),
    "The existing approved test-only humanoid is required")
local previous = workspace:FindFirstChild("DMMO_Lasso_Character_Test")
if previous then
    return "EXISTS: " .. previous:GetFullName()
end
local character = source:Clone()
character.Name = "DMMO_Lasso_Character_Test"
for _, child in ipairs(character:GetDescendants()) do
    if child:IsA("BaseScript") or child:IsA("KeyframeSequence") then
        child:Destroy()
    end
end
local hammer = character:FindFirstChild("Guardian_Hammer")
if hammer then hammer:Destroy() end
local grip = character:FindFirstChild("GuardianHammerGrip", true)
if grip then grip:Destroy() end
character:SetAttribute("DMMO_TestOnly", true)
character:SetAttribute("DMMO_Action", "Looping overhead lasso")
character.Parent = workspace
character:PivotTo(CFrame.new(-22, 0, 0) * source:GetPivot())
local root = character:FindFirstChild("HumanoidRootPart")
local rightHand = character:FindFirstChild("RightHand")
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
assert(root and rightHand and humanoid and
    humanoid.RigType == Enum.HumanoidRigType.R15)
root.Anchored = true
local ropeGrip = Instance.new("Part")
ropeGrip.Name = "LassoGrip"
ropeGrip.Size = Vector3.new(.14, .3, .14)
ropeGrip.Material = Enum.Material.Wood
ropeGrip.Color = Color3.fromRGB(111, 79, 48)
ropeGrip.CanCollide = false
ropeGrip.Massless = true
ropeGrip.Parent = character
local holder = Instance.new("Motor6D")
holder.Name = "LassoGripMotor"
holder.Part0 = rightHand
holder.Part1 = ropeGrip
holder.C0 = CFrame.new(0, -.20, -.15)
holder.C1 = CFrame.identity
holder.Parent = rightHand
ropeGrip.CFrame = rightHand.CFrame * holder.C0
local motorNames = {}
for _, obj in ipairs(character:GetDescendants()) do
    if obj:IsA("Motor6D") then table.insert(motorNames, obj.Name) end
end
return game:GetService("HttpService"):JSONEncode({
    rig = character:GetFullName(),
    motorNames = motorNames,
    head = {character.Head.Position.X, character.Head.Position.Y,
        character.Head.Position.Z},
    hand = {rightHand.Position.X, rightHand.Position.Y,
        rightHand.Position.Z},
    originalExists = workspace:FindFirstChild(
        "DMMO_Astra_Guardian_Test") ~= nil,
    originalOverheadExists = source:FindFirstChild(
        "DMMO_Astra_CrushingStrike_v1") ~= nil
})
