--!strict
local Core=game:GetService("ServerScriptService").Core
local S=Core.Services
local module=S:FindFirstChild("DungeonSecretDiscoveryService")
assert(module,"[Secret Discovery Tests] RED: discovery service missing")
local Discovery=require(module)
local Sessions=require(S.DungeonSessionService)
local Map=require(Core.Adapters.InMemoryMapAdapter)
local n=0
local function check(ok: boolean,why: string) n+=1;assert(ok,"[Secret Discovery Tests] "..why) end
local map=Map.new(function() return 100 end)
local sessions=Sessions.new(map,function() return 100 end)
local session=assert(sessions:create("TestDungeon",{99001},0,"secret-test","Depth1"))
assert(sessions:mark_connected(session.SessionId,99001,"test-job").ok)
local id=session.SessionId
local eid="TempleSecretBossEncounter"
assert(sessions:set_instance_state(id,{
 OptionalBossEnabled=true,OptionalBossSecretUnlocked=true,
 OptionalBossSecretUnlocks={TempleHiddenSanctum=true},
 EncounterPlan={{Id="First",Kind="Combat"},{Id=eid,Kind="SecretBoss",BossId="TempleSecretBoss",RoomSlotId="SecretArena"},{Id="Final",Kind="Boss"}},
 EncounterRuntime={EncounterStates={First="Pending",[eid]="Pending",Final="Pending"}}
}).ok)
local service=Discovery.new(sessions)
check(not service:discover(id,99999,eid,0).ok,"nonmember rejected")
check(not service:discover(id,99001,eid,13).ok,"distant member rejected")
check(not service:discover(id,99001,eid,0/0).ok,"NaN distance rejected")
check(not service:discover(id,99001,eid,-1).ok,"negative distance rejected")
check(not service:discover(id,99001,eid,0).ok,"preceding combat required")
assert(sessions:update_instance_state(id,function(s) s.EncounterRuntime.EncounterStates.First="Cleared";return s end).ok)
check(not service:discover(id,99001,"Final",0).ok,"only matching secret descriptor")
local result=service:discover(id,99001,eid,12)
check(result.ok and not result.already_discovered,"eligible nearby member discovers route")
check(sessions:get(id).InstanceState.OptionalBossSecretDiscoveries.TempleHiddenSanctum==true,"discovery saved")
check(service:discover(id,99001,eid,1).already_discovered==true,"discovery replay idempotent")
local restored=Discovery.new(Sessions.new(map,function() return 100 end))
check(restored:discover(id,99001,eid,0).already_discovered==true,"new service recovers discovery")
assert(sessions:update_instance_state(id,function(s) s.EncounterRuntime.EncounterStates[eid]="Skipped";return s end).ok)
check(not service:discover(id,99001,eid,0).ok,"skipped route cannot be reopened")
assert(sessions:update_instance_state(id,function(s) s.EncounterRuntime.EncounterStates[eid]="Pending";s.OptionalBossSecretUnlocks={};return s end).ok)
check(not service:discover(id,99001,eid,0).ok,"discovery requires run eligibility even on replay")
local failSessions={get=function() return sessions:get(id) end,update_instance_state=function() return {ok=false,reason="StoreFailed"} end}
assert(sessions:update_instance_state(id,function(s) s.OptionalBossSecretUnlocks.TempleHiddenSanctum=true;return s end).ok)
check(not Discovery.new(failSessions):discover(id,99001,eid,0).ok,"failed write not accepted")
print(string.format("[Secret Discovery Tests] PASS: %d assertions.",n))
