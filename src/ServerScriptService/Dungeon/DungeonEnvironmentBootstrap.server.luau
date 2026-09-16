--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local ServerScriptService=game:GetService("ServerScriptService")
local Workspace=game:GetService("Workspace")
local Shared=ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local D=require(Shared:WaitForChild("DungeonDefinitions"))
local A=require(Shared:WaitForChild("EnvironmentAnchorDefinitions"))
local E=ServerScriptService:WaitForChild("Core"):WaitForChild("Environment")
local Mode=require(E:WaitForChild("EnvironmentRuntimeMode"))
local Factory=require(E:WaitForChild("EnvironmentAnchorFactory"))
local Resolver=require(E:WaitForChild("EnvironmentAnchorResolver"))
local Temple=require(script.Parent:WaitForChild("TempleSyntheticEnvironment"))
local Mine=require(script.Parent:WaitForChild("AbandonedMineSyntheticEnvironment"))
local Select=require(script.Parent:WaitForChild("DungeonRuntimeSelection"))
local id,err=Select.resolve(Players,Workspace,RunService,D,15); assert(id,err)
local mode,merr=Mode.resolve(RunService:IsStudio(),Workspace:GetAttribute("DungeonMMOEnvironmentMode")); assert(mode,merr)
Workspace:SetAttribute("DungeonMMODungeonEnvironmentReady",false)
Workspace:SetAttribute("DungeonMMODungeonEnvironmentError",nil)
if mode=="Synthetic" then Factory.clear_generated(Workspace); if id==D.TEST_DUNGEON.Id then Temple.create(Workspace) else Mine.create(Workspace) end end
if mode=="Candidate" and id~=D.TEST_DUNGEON.Id then error("MineCandidateEnvironmentNotAuthoredYet") end
local def=if id==D.TEST_DUNGEON.Id then A.TEMPLE else A.ABANDONED_MINE
local r=Resolver.resolve(Workspace,def); assert(r.ok,tostring(r.reason)..":"..tostring(r.anchor_id))
local triggers=if id==D.TEST_DUNGEON.Id then {"Temple.Room1.Trigger","Temple.Room2.Trigger","Temple.Room3.Trigger"} else {"Mine.Room1.Trigger","Mine.Room2.Trigger","Mine.Room3.Trigger"}
for _,x in ipairs(triggers) do local p=r.by_id[x]; p.CanTouch=true;p.CanCollide=false;p.Transparency=1 end
local barriers=if id==D.TEST_DUNGEON.Id then {"Temple.Room1.ExitBarrier","Temple.Room2.ExitBarrier"} else {"Mine.Room1.ExitBarrier","Mine.Room2.ExitBarrier"}
for _,x in ipairs(barriers) do local p=r.by_id[x];if p then p.CanCollide=true;p.CanTouch=false;p.Transparency=1 end end
Workspace:SetAttribute("DungeonMMOResolvedDungeonId",id)
Workspace:SetAttribute("DungeonMMOResolvedEnvironmentMode",mode)
Workspace:SetAttribute("DungeonMMODungeonEnvironmentReady",true)
if id==D.TEST_DUNGEON.Id then Workspace:SetAttribute("DungeonMMOTempleEnvironmentReady",true) end
print("[Dungeon Environment] "..id.." ready in "..mode.." mode.")
