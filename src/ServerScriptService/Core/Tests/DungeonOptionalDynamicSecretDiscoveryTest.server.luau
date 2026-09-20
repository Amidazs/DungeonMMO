--!strict
-- Discover both original and alternate Secret bosses from their actual
-- server-frozen plan; no client-chosen unlock or second discovery service.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Core = SSS.Core
local Dungeon = SSS.Dungeon
local Shared = RS.Core.Shared
local Map = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Issuer = require(Core.Services.DungeonOptionalBossRunState)
local Discovery = require(Core.Services.DungeonSecretDiscoveryService)
local Content = require(Dungeon.DungeonOptionalBossContent)
local Policy = require(Dungeon.DungeonOptionalBossPolicy)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)
local Variants = require(Shared.DungeonOptionalBossVariantCatalog)
local Difficulty = require(Shared.DungeonDifficultyDefinitions)
local checks = 0
local function check(ok: boolean, label: string)
    checks += 1
    assert(ok, "[Dynamic Secret Discovery] " .. label)
end
local slots = {
    EventArena = {SupportsBoss = true, BossSpawnAnchor = "Temp.Event"},
    SecretArena = {SupportsBoss = true, BossSpawnAnchor = "Temp.Secret"},
}
for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    for _, depth_id in ipairs({"Depth1", "Depth2", "Depth3", "Depth4"}) do
        for _, seed in ipairs({0, 7}) do
            local now = 150
            local clock = function() return now end
            local map = Map.new(clock)
            local sessions = Sessions.new(map, clock)
            local user_id = 85000 + seed
            local session = assert(sessions:create(
                dungeon_id, {user_id}, 0, "secret-variant", depth_id))
            check(sessions:mark_connected(session.SessionId, user_id).ok,
                "member admitted into disposable run")
            local state = Issuer.issue(dungeon_id, now, seed, {
                optional_boss_event_start = 100,
                optional_boss_event_end = 200,
                optional_boss_secret_chance_basis_points = 10000,
                optional_boss_variants_enabled = true,
            }, true)
            state.RunEnteredAtUnix = now
            state.DungeonId = dungeon_id
            check(sessions:set_instance_state(session.SessionId, state).ok,
                "server-frozen run saved")
            local descriptors = assert(Content.for_difficulty(
                dungeon_id, depth_id, state))
            local selected = Policy.evaluate({
                OptionalEncounters = descriptors,
            }, depth_id, slots, true, state)
            check(selected.ok and #selected.encounters == 2,
                "variant Event and Secret issued independently")
            local difficulty = assert(Difficulty.get(
                dungeon_id, depth_id))
            local controller = assert(Controller.new({
                session_service = sessions,
                session_id = session.SessionId,
                base_sequence = difficulty.EncounterSequence,
                optional_encounters = selected.encounters,
            }))
            local plan = controller:encounters()
            local secret = plan[#plan - 1]
            local variant = assert(Variants.get(
                dungeon_id, "Secret",
                (math.floor(seed / 7) % 2) + 1))
            check(secret.Kind == "SecretBoss"
                and secret.BossId == variant.BossId,
                "server plan must bind the selected Secret boss")
            for index = 1, #plan - 2 do
                check(controller:start(plan[index].Id).ok
                    and controller:clear(plan[index].Id).ok,
                    "required precursor and Event clear exactly once")
            end
            local discovery = Discovery.new(sessions)
            local found = discovery:discover(
                session.SessionId, user_id, secret.Id, 2)
            check(found.ok and not found.already_discovered,
                "new Secret boss can be physically discovered once")
            check(sessions:get(session.SessionId).InstanceState
                .OptionalBossSecretDiscoveries[variant.Id] == true,
                "discovery persists selected Secret ID, not legacy fallback")
            now = 250
            local recovered = Discovery.new(Sessions.new(map, clock))
            check(recovered:discover(
                session.SessionId, user_id, secret.Id, 2
            ).already_discovered == true,
                "discovery remains idempotent after window expiry")
            check(controller:skip(secret.Id).ok,
                "one optional Secret may be skipped before final")
            check(recovered:discover(
                session.SessionId, user_id, secret.Id, 2
            ).ok, "same Secret remains discoverable after bypass")
            check(not recovered:discover(
                session.SessionId, user_id, plan[#plan].Id, 2
            ).ok, "final boss cannot impersonate Secret discovery")
        end
    end
end
print(string.format(
    "[Dynamic Secret Discovery Tests] PASS: %d assertions.", checks
))
