-- Test-only authoring and preview utility. No published assets or gameplay hooks.
local M={}
local rig=script.Parent
assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0,"Isolated Studio Place1 only")
local motors,base,parts={},{},{}
for _,v in rig:GetDescendants() do
 if v:IsA("Motor6D") then motors[v.Name]=v end
 if v:IsA("BasePart") then base[v.Name]=v.CFrame; parts[v.Name]=v end
end
local headRelative=base.Handle:ToObjectSpace(base.HammerHead)
-- Derive bind pose from the preserved joints, even if loaded during a paused preview.
for _=1,6 do for _,j in motors do base[j.Part1.Name]=base[j.Part0.Name]*j.C0*j.C1:Inverse() end end
base.HammerHead=base.Handle*headRelative
local root=base.HumanoidRootPart
local function R(x,y,z) return CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0)) end
local function fk(name,p,t)
 local j=motors[name]; return p*j.C0*(t or CFrame.identity)*j.C1:Inverse()
end
local function minimumY(cf,size)
 return cf.Position.Y-(math.abs(cf.RightVector.Y)*size.X+math.abs(cf.UpVector.Y)*size.Y+math.abs(cf.LookVector.Y)*size.Z)/2
end
function M.Pose(t)
 local keys=game:GetService("HttpService"):JSONDecode(script:GetAttribute("Controls"))
 local a,b=keys[1],keys[#keys]
 for i=1,#keys-1 do if t>=keys[i][1] and t<=keys[i+1][1] then a=keys[i];b=keys[i+1];break end end
 local u=math.clamp((t-a[1])/math.max(.00001,b[1]-a[1]),0,1)
 if a[1]==.9 then u=u*u end
 if a[1]~=.9 then u=u*u*(3-2*u) end
 local v={}
 for i=2,#a do v[i]=a[i]+(b[i]-a[i])*u end
 local tr={}
 for n in motors do tr[n]=CFrame.identity end
 tr.Root=CFrame.new(0,v[2],v[3])*R(v[4],v[5],0)
 tr.Waist=R(v[6],v[7],0)
 tr.Neck=R(v[8],-v[7]*.45,0)
 tr.RightShoulder=R(v[9],v[10],v[11])
 tr.RightElbow=R(v[12],0,0)
 tr.RightWrist=R(v[13],0,v[14])
 tr.LeftShoulder=R(v[15],v[16],v[17])
 tr.LeftElbow=R(v[18],0,0)
 tr.LeftWrist=R(-v[18]*.2,0,0)
 local cf={HumanoidRootPart=root}
 cf.LowerTorso=fk("Root",root,tr.Root)
 cf.UpperTorso=fk("Waist",cf.LowerTorso,tr.Waist)
 cf.Head=fk("Neck",cf.UpperTorso,tr.Neck)
 for _,s in {"Left","Right"} do
  cf[s.."UpperArm"]=fk(s.."Shoulder",cf.UpperTorso,tr[s.."Shoulder"])
  cf[s.."LowerArm"]=fk(s.."Elbow",cf[s.."UpperArm"],tr[s.."Elbow"])
  cf[s.."Hand"]=fk(s.."Wrist",cf[s.."LowerArm"],tr[s.."Wrist"])
  local hip,knee,ankle=motors[s.."Hip"],motors[s.."Knee"],motors[s.."Ankle"]
  local h=(cf.LowerTorso*hip.C0).Position
  local target=base[s.."Foot"]*ankle.C1
  local d=target.Position-h
  local l1=(hip.C1.Position-knee.C0.Position).Magnitude
  local l2=(knee.C1.Position-ankle.C0.Position).Magnitude
  local len=math.clamp(d.Magnitude,.001,l1+l2-.000001)
  local dir=d.Unit
  local pole=root.LookVector-dir*root.LookVector:Dot(dir);pole=pole.Unit
  local along=(l1*l1-l2*l2+len*len)/(2*len)
  local k=h+dir*along+pole*math.sqrt(math.max(0,l1*l1-along*along))
  local function limb(from,to,localUpper,localLower)
   local up=(from-to).Unit
   local right=pole:Cross(up).Unit
   local rot=CFrame.fromMatrix(Vector3.zero,right,up,right:Cross(up))
   return CFrame.new(from)*rot*CFrame.new(-localUpper)
  end
  cf[s.."UpperLeg"]=limb(h,k,hip.C1.Position,knee.C0.Position)
  cf[s.."LowerLeg"]=limb(k,target.Position,knee.C1.Position,ankle.C0.Position)
  cf[s.."Foot"]=base[s.."Foot"]
  tr[s.."Hip"]=(cf.LowerTorso*hip.C0):ToObjectSpace(cf[s.."UpperLeg"]*hip.C1)
  tr[s.."Knee"]=(cf[s.."UpperLeg"]*knee.C0):ToObjectSpace(cf[s.."LowerLeg"]*knee.C1)
  tr[s.."Ankle"]=(cf[s.."LowerLeg"]*ankle.C0):ToObjectSpace(target)
 end
 if t<=0 or t>=2.4 then for n in tr do tr[n]=CFrame.identity end; for n,c in base do cf[n]=c end end
 cf.Handle=fk("GuardianHammerGrip",cf.RightHand)
 cf.HammerHead=cf.Handle*headRelative
 return tr,cf,{hammerBottom=minimumY(cf.HammerHead,parts.HammerHead.Size),headPosition=cf.HammerHead.Position}
end
function M.Show(t)
 local tr,cf,info=M.Pose(t)
 for n,c in tr do motors[n].Transform=c end
 for n,c in cf do if parts[n] then parts[n].CFrame=c end end
 return info
end
function M.Reset()
 if M.track then
  M.track:AdjustSpeed(0);M.track.TimePosition=0
  if not game:GetService("RunService"):IsRunning() then rig.Humanoid.Animator:StepAnimations(0) end
  task.wait(.05)
  M.track:Stop(0);M.track=nil
 end
 if M.connection then M.connection:Disconnect();M.connection=nil end
 if not game:GetService("RunService"):IsRunning() then rig.Humanoid.Animator:StepAnimations(0) end
 for _,v in rig:GetDescendants() do if v:IsA("AnimationConstraint") then v.Transform=CFrame.identity end end
 for n,j in motors do j.Transform=CFrame.identity end
 for n,c in base do parts[n].CFrame=c end
end
function M.Build()
 M.Reset()
 local old=rig:FindFirstChild("DMMO_Astra_CrushingStrike_v1")
 if old then old:Destroy() end
 local seq=Instance.new("KeyframeSequence")
 seq.Name="DMMO_Astra_CrushingStrike_v1";seq.Loop=false;seq.Priority=Enum.AnimationPriority.Action
 for i=0,144 do
  local t=i/60;local tr=M.Pose(t)
  local key=Instance.new("Keyframe");key.Time=t;key.Name=string.format("Frame_%03d",i);key.Parent=seq
  if i==72 then key.Name="Impact";local mark=Instance.new("KeyframeMarker");mark.Name="Impact";mark.Value="HammerGroundContact";mark.Parent=key end
  local poseMap={}
  local rootPose=Instance.new("Pose");rootPose.Name="HumanoidRootPart";rootPose.Weight=1;rootPose.Parent=key;poseMap.HumanoidRootPart=rootPose
  local remaining={}
  for n,j in motors do if n~="GuardianHammerGrip" then remaining[n]=j end end
  for _=1,6 do for n,j in remaining do
   if poseMap[j.Part0.Name] then local p=Instance.new("Pose");p.Name=j.Part1.Name;p.CFrame=tr[n];p.Weight=1;p.EasingStyle=Enum.PoseEasingStyle.Linear;p.Parent=poseMap[j.Part0.Name];poseMap[j.Part1.Name]=p;remaining[n]=nil end
  end end
 end
 seq:SetAttribute("Duration",2.4);seq:SetAttribute("ImpactTime",1.2);seq:SetAttribute("Authoring","Original stationary overhead strike; planted-foot IK baked at 60 Hz")
 seq.Parent=rig
 return seq
end
function M.Play(speed)
 M.Reset()
 local seq=rig:FindFirstChild("DMMO_Astra_CrushingStrike_v1");assert(seq,"Build first")
 local anim=Instance.new("Animation")
 anim.AnimationId=game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(seq)
 local animator=rig.Humanoid:FindFirstChildOfClass("Animator")
 local track=animator:LoadAnimation(anim);M.track=track
 M.impacts=0
 track:GetMarkerReachedSignal("Impact"):Connect(function() M.impacts+=1;rig:SetAttribute("CrushingStrikeImpactCount",M.impacts) end)
 rig:SetAttribute("CrushingStrikeImpactCount",0)
 track.Looped=false;track:Play(0,1,speed or 1)
 if not game:GetService("RunService"):IsRunning() then
  M.connection=game:GetService("RunService").Heartbeat:Connect(function(dt) animator:StepAnimations(dt) end)
 end
 return track
end
return M
