--!strict
-- Motor world conversion uses Part0/C0/C1, not Bone parent rest frames.
local Adapter={};Adapter.__index=Adapter
function Adapter.new(rig)
    local self=setmetatable({motors={},neutral={}},Adapter)
    for _,x in rig:GetDescendants() do
        if x:IsA("Motor6D") then assert(not self.motors[x.Name],"Ambiguous motor");assert(x.Part0 and x.Part1,"Disconnected motor");self.motors[x.Name]=x;self.neutral[x.Name]=x.Transform end
    end
    return self
end
function Adapter:captureNeutral() for n,m in self.motors do self.neutral[n]=m.Transform end end
function Adapter:apply(channels)
    for n in channels do assert(self.motors[n],"Missing motor "..n) end
    for n,cf in channels do self.motors[n].Transform=cf end
end
function Adapter:applyWorld(name,desiredPart1)
    local m=assert(self.motors[name],"Missing motor")
    m.Transform=(m.Part0.CFrame*m.C0):ToObjectSpace(desiredPart1*m.C1)
end
function Adapter:reset() for n,m in self.motors do m.Transform=self.neutral[n] end end
function Adapter:destroy() self:reset();self.motors={};self.neutral={} end
return Adapter
