--!strict
local Adapter={};Adapter.__index=Adapter
function Adapter.new(rig)
    local self=setmetatable({bones={},neutral={}},Adapter)
    for _,x in rig:GetDescendants() do
        if x:IsA("Bone") then assert(not self.bones[x.Name],"Ambiguous bone "..x.Name);self.bones[x.Name]=x;self.neutral[x.Name]=x.Transform end
    end
    return self
end
function Adapter:captureNeutral() for n,b in self.bones do self.neutral[n]=b.Transform end end
function Adapter:apply(channels)
    for name in channels do assert(self.bones[name],"Missing bone "..name) end
    for name,cf in channels do self.bones[name].Transform=cf end
end
function Adapter:applyWorld(name,desired)
    local b=assert(self.bones[name],"Missing bone")
    local parent=b.Parent
    local parentWorld=if parent:IsA("Bone") then parent.TransformedWorldCFrame else parent.CFrame
    b.Transform=(parentWorld*b.CFrame):ToObjectSpace(desired)
end
function Adapter:reset() for name,b in self.bones do b.Transform=self.neutral[name] end end
function Adapter:destroy() self:reset();self.bones={};self.neutral={} end
return Adapter
