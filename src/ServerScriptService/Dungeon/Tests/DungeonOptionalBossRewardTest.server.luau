--!strict
local SSS=game:GetService("ServerScriptService")
local Shared=game:GetService("ReplicatedStorage").Core.Shared
local D=SSS.Dungeon
local Core=SSS.Core
local Executor=require(D.BossEncounterExecutor)
local Encounter=require(D.EncounterService)
local Config=require(Shared.SkillBookDropConfig)
local Definitions=require(Shared.DungeonDefinitions)
local Profiles=require(Core.Services.ProfileService)
local Adapter=require(Core.Adapters.InMemoryProfileAdapter)
local Progression=require(Core.Services.ProgressionService)
local Inventory=require(Core.Services.InventoryService)
local Rewards=require(Core.Services.RewardService)
local n=0
local function check(ok: boolean,why: string) n+=1;assert(ok,"[Optional Boss Reward Tests] "..why) end
local ids={"TempleEventBoss","TempleSecretBoss","AbandonedMineEventBoss","AbandonedMineSecretBoss"}
for _,id in ipairs(ids) do
 local def=Config.get_boss(id)
 check(def and def.Chance==0.02 and Config.first_item(def)=="arc_slash_book",id.." explicit book source")
end
local adapter=Adapter.new()
local profiles=Profiles.new(adapter);assert(profiles:load(99101))
local rng={NextNumber=function(_,lo) return lo end,NextInteger=function(_,lo) return lo end}
local function rewardService() return Rewards.new(profiles,Progression.new(profiles),Inventory.new(profiles),nil,rng,function() return 100 end) end
local rewards=rewardService()
local registry={get=function(_,id) return require(D:FindFirstChild(id.."Factory")) end}
local executor=Executor.new({boss_factory_registry=registry})
local root=Instance.new("Folder");local anchor=Instance.new("Part");local env={get=function() return anchor end}
local context={DungeonDefinition=Definitions.TEST_DUNGEON,Tuning={EnemyHealthMultiplier=1,EnemyDamageMultiplier=1,MonsterRewardMultiplier=1},Environment=env,EnemiesFolder=root,RuntimeRoot=root,SessionId="optional-reward-proof"}
local previous={}
for _,id in ipairs({"TempleEventBoss","TempleSecretBoss","MarauderCaptain"}) do
 local descriptor={Id=id.."Encounter",BossId=id,Kind=if id=="TempleSecretBoss" then "SecretBoss" elseif id=="TempleEventBoss" then "EventBoss" else "Boss"}
 local binding={RuntimeEncounterId=descriptor.Id,BossSpawnAnchor="fixture"}
 local spawned=executor:execute(descriptor,binding,context)
 check(spawned.ok,"spawn "..id)
 local boss=spawned.BossModel
 local key=boss:GetAttribute("DungeonEnemyId")
 check(not previous[key],"reward identity must not collide across optional/final bosses")
 previous[key]=true
 local encounter=Encounter.new(rewards,context.SessionId)
 assert(encounter:start(descriptor.Id,{99101},{boss}).ok)
 local grant=encounter:on_enemy_died(boss)
 check(grant.ok,"reward grant "..id)
 executor:cleanup(descriptor,binding,spawned,context)
end
local char=profiles:get_character(99101,1)
check(Inventory.count_item(char,"arc_slash_book")==3,"each boss grants independent personal bonus")
assert(profiles:save(99101,"test"))
local reloaded=Profiles.new(adapter);assert(reloaded:load(99101))
local replay=Rewards.new(reloaded,Progression.new(reloaded),Inventory.new(reloaded),nil,rng,function() return 101 end)
local history=reloaded:get_character(99101,1).RewardHistory.Monster
local count=0
for transaction in pairs(history) do
 count+=1
 check(replay:grant_monster_reward({99101},{XP=40,GoldMin=15,GoldMax=25,BossId="TempleEventBoss"},transaction).already_applied==true,"persisted reward replay")
end
check(count==3 and Inventory.count_item(reloaded:get_character(99101,1),"arc_slash_book")==3,"reload/replay cannot add rewards")
root:Destroy();anchor:Destroy()
print(string.format("[Optional Boss Reward Tests] PASS: %d assertions.",n))
