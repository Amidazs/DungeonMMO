--!strict
local S = game:GetService("ServerScriptService").Core.Services
local module = S:FindFirstChild("DungeonOptionalBossRules")
assert(module, "[Optional Boss Schedule Tests] RED: rules module missing")
local Rules = require(module)
local Issuer = require(S.DungeonOptionalBossRunState)
local n=0
local function check(ok: boolean, why: string) n+=1; assert(ok, "[Optional Boss Schedule Tests] "..why) end
local enabled={optional_boss_schedule_enabled=true,optional_boss_secret_routes_enabled=true}
check(Rules.resolve("TestDungeon",3600,{}).optional_boss_event_start==nil,"schedule requires server opt-in")
local t=Rules.resolve("TestDungeon",3600,enabled)
check(t.optional_boss_event_start==3600 and t.optional_boss_event_end==4800,"Temple hourly window")
local m=Rules.resolve("AbandonedMine",5400,enabled)
check(m.optional_boss_event_start==5400 and m.optional_boss_event_end==6600,"Mine offset window")
check(t.optional_boss_secret_chance_basis_points==500,"explicit opt-in route proof chance")
check(Rules.resolve("TestDungeon",3600,{}).optional_boss_secret_chance_basis_points==nil,"routes require opt-in")
for _,case in ipairs({{3599,false},{3600,true},{4799,true},{4800,false},{7199,false},{7200,true}}) do
 local state=Issuer.issue("TestDungeon",case[1],9999,enabled,true)
 check(state.OptionalBossEventActive==case[2],"window boundary "..case[1])
end
check(not Issuer.issue("TestDungeon",3600,0,enabled,false).OptionalBossEnabled,"release lock dominates schedule")
check(not Issuer.issue("Unknown",3600,0,enabled,true).OptionalBossEnabled,"unknown dungeon disabled")
local override=Rules.resolve("TestDungeon",3700,{optional_boss_schedule_enabled=true,optional_boss_event_start=3650,optional_boss_event_end=3750})
check(override.optional_boss_event_start==3650 and override.optional_boss_event_end==3750,"explicit window wins")
local bad=Issuer.issue("TestDungeon",3700,0,{optional_boss_schedule_enabled=true,optional_boss_event_start=0/0},true)
check(not bad.OptionalBossEventActive,"bad partial override cannot fall back")
local snap=Issuer.issue("TestDungeon",3700,9999,enabled,true)
check(snap.OptionalBossEventWindows.TempleEclipse.EndUnix==4800,"snapshot window frozen")
local later=Issuer.issue("TestDungeon",7300,9999,enabled,true)
check(later.OptionalBossEventWindows.TempleEclipse.StartUnix==7200 and snap.OptionalBossEventWindows.TempleEclipse.StartUnix==3600,"new run cannot mutate old window")
check(not Issuer.issue("TestDungeon",3600,500,enabled,true).OptionalBossSecretUnlocked,"route upper bound exclusive")
check(Issuer.issue("TestDungeon",3600,499,enabled,true).OptionalBossSecretUnlocked,"route lower bound eligible")
for _,now in ipairs({-1,0,math.huge,0/0}) do
 check(not Issuer.issue("TestDungeon",now,0,enabled,true).OptionalBossEnabled,"invalid entry time")
end
print(string.format("[Optional Boss Schedule Tests] PASS: %d assertions.",n))
