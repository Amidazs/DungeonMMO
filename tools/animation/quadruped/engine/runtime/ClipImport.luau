--!strict
-- Convert baked local channels to editable native Roblox animation.
local ClipImport={}
function ClipImport.build(rig,manifest,mask)
    assert(type(manifest.frames)=="table" and #manifest.frames>=2,"At least two frames")
    local root=assert(rig:FindFirstChild("RootPart"),"RootPart missing")
    local mapped={}
    for _,x in root:GetDescendants() do if x:IsA("Bone") then assert(not mapped[x.Name],"Ambiguous bone");mapped[x.Name]=x end end
    for _,b in manifest.bones do assert(mapped[b.name],"Missing bone: "..b.name) end
    local sequence=Instance.new("KeyframeSequence");sequence.Name=manifest.id;sequence.Loop=manifest.loop==true
    sequence.Priority=Enum.AnimationPriority.Movement
    local previous=-1
    for _,frame in manifest.frames do
        assert(type(frame.time)=="number" and frame.time>previous,"Frames must be ordered");previous=frame.time
        local key=Instance.new("Keyframe");key.Time=frame.time;key.Name="Frame"
        local top=Instance.new("Pose");top.Name=root.Name;top.Weight=0;top.Parent=key
        local poses={}
        for _,b in manifest.bones do
            local p=Instance.new("Pose");p.Name=b.name
            p.Weight=if mask and not mask[b.name] then 0 else 1
            local values=assert(frame.poses[b.name],"Missing channel "..b.name)
            assert(#values==12,"Invalid CFrame channel")
            for _,n in values do assert(type(n)=="number" and n==n and math.abs(n)<math.huge,"Nonfinite channel") end
            p.CFrame=CFrame.new(table.unpack(values));p.EasingStyle=Enum.PoseEasingStyle.Linear
            poses[b.name]=p
        end
        for _,b in manifest.bones do poses[b.name].Parent=if b.parent then assert(poses[b.parent],"Missing parent") else top end
        sequence:AddKeyframe(key)
    end
    return sequence
end
return ClipImport
