-- Unpublished Place1 only. The R15 animation is authored separately;
-- this preview draws the moving lasso using segmented rope parts.
local runService = game:GetService("RunService")
if not runService:IsStudio() or game.PlaceId ~= 0 then return end
local rig = script.Parent
assert(rig.Name == "DMMO_Lasso_Character_Test"
    and rig:GetAttribute("DMMO_TestOnly"), "Wrong test mannequin")
local generator = require(rig:WaitForChild("DMMO_Lasso_Generator"))
local head = rig:WaitForChild("Head")
local grip = rig:WaitForChild("LassoGrip")
local root = rig:WaitForChild("HumanoidRootPart")
assert(root.Anchored, "Stationary lasso test requires anchored root")
local ropeFolder = workspace:FindFirstChild("DMMO_Lasso_Rope_Test")
if ropeFolder then ropeFolder:Destroy() end
ropeFolder = Instance.new("Folder")
ropeFolder.Name = "DMMO_Lasso_Rope_Test"
ropeFolder.Parent = workspace
local function ropePart(name, diameter)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(diameter, .2, diameter)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Fabric
    part.Color = Color3.fromRGB(210, 169, 103)
    part.Parent = ropeFolder
    return part
end
local rimCount, tetherCount = 32, 11
local rim, tether = {}, {}
for index = 1, rimCount do
    rim[index] = ropePart(string.format("Loop_%02d", index), .11)
end
for index = 1, tetherCount do
    tether[index] = ropePart(string.format("Tether_%02d", index), .095)
end
local knot = Instance.new("Part")
knot.Name = "LassoKnot"
knot.Shape = Enum.PartType.Ball
knot.Size = Vector3.new(.22, .22, .22)
knot.Material = Enum.Material.Wood
knot.Color = Color3.fromRGB(143, 97, 49)
knot.Anchored = true
knot.CanCollide = false
knot.CanTouch = false
knot.Parent = ropeFolder
local function placeSegment(part, from, to, diameter)
    local difference = to - from
    local length = math.max(.001, difference.Magnitude)
    local up = difference / length
    local reference = Vector3.yAxis
    if math.abs(up:Dot(reference)) > .97 then
        reference = Vector3.xAxis
    end
    local yAxis = (reference - up * reference:Dot(up)).Unit
    part.Size = Vector3.new(length + diameter*.6, diameter, diameter)
    part.CFrame = CFrame.fromMatrix(
        (from + to) / 2, up, yAxis, up:Cross(yAxis))
end
local function showRope(phase, openness)
    openness = math.clamp(openness, 0, 1)
    local right = root.CFrame.RightVector
    local forward = root.CFrame.LookVector
    local up = Vector3.yAxis
    local u = right * math.cos(phase) + forward * math.sin(phase)
    local v = (-right * math.sin(phase) + forward *
        math.cos(phase) + up * .23).Unit
    local centre = head.Position + up * (1.95 + .09 * math.sin(phase))
        + (right * math.cos(phase) +
            forward * math.sin(phase)) * .19
    local radius = math.max(.005, openness * 1.22)
    local points = {}
    for index = 1, rimCount do
        local theta = (index - 1) / rimCount * math.pi * 2
        points[index] = centre + radius *
            (u * math.cos(theta) + v * math.sin(theta))
    end
    for index = 1, rimCount do
        local nextIndex = index % rimCount + 1
        placeSegment(rim[index], points[index],
            points[nextIndex], .11)
        rim[index].Transparency = (1 - openness) * .7
    end
    knot.Position = points[1]
    knot.Transparency = (1 - openness) * .7
    local from, to = grip.Position, points[1]
    local curve = {}
    for index = 0, tetherCount do
        local alpha = index / tetherCount
        curve[index] = from:Lerp(to, alpha) -
            up * (.25 * math.sin(alpha * math.pi) * openness)
    end
    for index = 1, tetherCount do
        placeSegment(tether[index], curve[index - 1],
            curve[index], .095)
        tether[index].Transparency = 0
    end
    rig:SetAttribute("LassoLoopCentreY", centre.Y)
    rig:SetAttribute("LassoLoopBottomY",
        math.min(points[1].Y, points[8].Y,
            points[16].Y, points[24].Y))
    rig:SetAttribute("LassoHandToLoop", (from - to).Magnitude)
end
local function waitForLength(track, action)
    local deadline = os.clock() + 7
    while track.Length <= 0 and os.clock() < deadline do
        task.wait(.05)
    end
    assert(track.Length > 0, "Lasso action failed: " .. action)
end
local function preview()
    while script.Enabled and rig.Parent do
        local clips = generator.StartPreview()
        for action, track in clips do
            waitForLength(track, action)
        end
        local stage = "Raise"
        rig:SetAttribute("LassoPreviewStage", stage)
        local connection = runService.Heartbeat:Connect(function()
            local phase, openness = 0, 0
            if stage == "Raise" then
                openness = math.clamp(clips.Raise.TimePosition / .6, 0, 1)
            elseif stage == "Swing" then
                local captureTime = rig:GetAttribute("LassoCaptureTime")
                phase = ((typeof(captureTime) == "number"
                    and captureTime or clips.Swing.TimePosition)
                    / 1.5) * math.pi * 2
                openness = 1
            elseif stage == "Lower" then
                openness = 1 - math.clamp(
                    clips.Lower.TimePosition / .6, 0, 1)
            end
            showRope(phase, openness)
            rig:SetAttribute("LassoRotationPhase", phase)
        end)
        task.wait(clips.Raise.Length + .10)
        clips.Raise:Stop(.1)
        stage = "Swing"
        rig:SetAttribute("LassoPreviewStage", stage)
        clips.Swing.Looped = true
        clips.Swing:Play(.1, 1, 1)
        if rig:GetAttribute("LassoCaptureMode") then
            while rig:GetAttribute("LassoCaptureMode") and script.Enabled do
                task.wait(.1)
            end
        else
            task.wait(clips.Swing.Length * 3 + .12)
        end
        clips.Swing:Stop(.1)
        stage = "Lower"
        rig:SetAttribute("LassoPreviewStage", stage)
        clips.Lower:Play(.1, 1, 1)
        task.wait(clips.Lower.Length + .18)
        connection:Disconnect()
        clips.Lower:Stop(0)
        stage = "Idle"
        rig:SetAttribute("LassoPreviewStage", stage)
        generator.Reset()
        for _, part in ropeFolder:GetChildren() do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        task.wait(1.0)
    end
end
local ok, err = pcall(preview)
if not ok then
    rig:SetAttribute("LassoPreviewStage", "FAILED: " .. tostring(err))
    warn("DMMO isolated lasso preview failed", err)
    generator.Reset()
end
