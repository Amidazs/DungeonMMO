# DungeonMMO Roadmap v2.79 — C4 Live Combat Executor Foundation

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.78](
DungeonMMO_Roadmap_v2_78_C4_Spatial_Combat_20260925.md).

## Goal

Introduce the first separately gated live C4 combat executor without replacing
the current DungeonMMO combat path or enabling source combat by default.

This milestone applies one accepted C4 ordinary player-versus-player attack
through authoritative CP and HP only after every independent source gate is
explicitly ready.

## GitHub implementation

New service:

`C4SourceCombatExecutor`.

The executor is an instance service rather than another process-wide toggle.
It is composed by `RuntimeServices`, starts disabled, and exposes no remote or
client entry point.

One live normal attack now requires all of the following:

1. executor gate explicitly enabled;
2. explicit Roblox-stud to C4 source-unit conversion configured;
3. server-owned night-state provider configured;
4. source calculation provider enabled;
5. source resource cutover globally enabled;
6. attacker source resource cutover active;
7. defender source resource cutover active;
8. distinct authenticated server participant IDs;
9. living server-owned character/root/humanoid state.

The executor then:

1. reads attacker and defender root transforms on the server;
2. converts only the vertical delta using the explicitly configured source
   scale;
3. obtains source-equivalent night state from a server callback;
4. invokes the accepted source normal-attack calculation;
5. performs no mutation on a miss;
6. routes a successful player hit through C4 CP first;
7. applies only the remaining damage to server-owned Humanoid Health;
8. returns detached calculation/application evidence.

Clients cannot submit damage, hit, critical, shield, shot, condition or CP
outcomes.

## Deliberate fail-closed configuration

There is still **no guessed Roblox-to-C4 elevation conversion**.

`configure_spatial_rules(source_units_per_stud, night_provider)` must be
called by trusted server bootstrap before the executor can be enabled.

The branch does not yet choose a production conversion factor or production
night mapping. This prevents a source-parity claim from being created by an
arbitrary unit assumption.

## Runtime composition

Dungeon runtime composes the executor with the existing
`C4ResourceCutoverService`, but it remains disabled and spatially
unconfigured.

Base runtime also composes the executor object, but deliberately has no live
resource authority because the current C4 resource cutover depends on the
Dungeon combat/ManaService composition. The Base executor therefore cannot be
enabled.

This is a useful explicit boundary for later castle/PvP work: source resource
authority must be made place-independent before live C4 combat is enabled in a
future PvP/castle place.

## Fresh acceptance

Source/runtime candidate:

`d7dd81b32f3580ad9db20cb9cbe7411d7a25c57e`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Fresh focused Studio:

- Base: **17/17 PASS**;
- Dungeon: **19/19 PASS**;
- live executor: **10 assertions PASS**;
- existing source combat: **30 assertions PASS**;
- spatial reference: **11 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Runtime composition probes:

- Base: executor available, resource authority false, enabled false;
- Dungeon: executor available, resource authority true, enabled false.

## Safety boundary

This milestone does **not**:

- enable the source calculation provider;
- enable source resource cutover;
- enable the live executor;
- install a production elevation scale;
- install a production night mapping;
- replace current CombatService attacks;
- expose a client remote;
- apply PDAM/MDAM/HEAL through the live executor;
- merge to `main`;
- publish Roblox places;
- mutate production DataStores.

## Next backend implementation

Extend the executor across source PDAM, MDAM and HEAL while preserving the same
independent gates and server-owned spatial/resource authority.

After those action families are accepted, add a controlled adapter from the
existing combat entry points into the disabled source executor, then run
targeted multiplayer cutover tests before any default activation.
