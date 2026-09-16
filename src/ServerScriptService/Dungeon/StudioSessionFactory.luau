--!strict
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local DungeonDefinitions=require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("DungeonDefinitions"))
local Director=require(ServerScriptService:WaitForChild("Core"):WaitForChild("Services"):WaitForChild("DungeonInstanceDirector"))
local M={}
function M.create_for_players(players:{any},sessions:any,dungeon_id:string?):any
 if not RunService:IsStudio() then return {ok=false,reason="StudioOnly"} end
 local def=DungeonDefinitions.get(dungeon_id or DungeonDefinitions.TEST_DUNGEON.Id)
 if not def then return {ok=false,reason="UnknownDungeon"} end
 if #players<def.MinPlayers or #players>def.MaxPlayers then return {ok=false,reason="PlayerCountOutOfRange"} end
 local ids={}
 for _,p in ipairs(players) do
  local old=sessions:get_for_user(p.UserId)
  if old and (old.State=="Creating" or old.State=="Active") then return {ok=true,session=old,teleport_data={SessionId=old.SessionId,DungeonId=old.DungeonId},reused=true} end
  table.insert(ids,p.UserId)
 end
 local s,e=sessions:create(def.Id,ids,0,"StudioReservedServer")
 if not s then return {ok=false,reason=e} end
 local r=sessions:set_instance_state(s.SessionId,Director.resolve(def.Id,s.SessionId,os.time(),Director.runtime_options()))
 if not r.ok then return {ok=false,reason=r.reason} end
 s=r.session
 return {ok=true,session=s,teleport_data={SessionId=s.SessionId,DungeonId=s.DungeonId},reused=false}
end
return table.freeze(M)
