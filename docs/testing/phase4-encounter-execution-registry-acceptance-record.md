# Phase 4 Encounter Execution Registry Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Generic Encounter Execution / Spawn Registry
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `c6e181c`
**Implementation checkpoint:** `fe1856e`
**Branch:** `wip/phase-4-encounter-execution-registry-v1`

This backend-only gate removes concrete enemy/boss creation knowledge from the
live Dungeon controller. Encounter descriptors now select server-owned execution
strategies and content IDs.

No modelling, meshes, terrain, authored rooms, UI art, boss art or environment
presentation work was performed.

## Accepted architecture

The execution layer now provides:

- stable executor IDs selected by encounter descriptor;
- `CombatPack` execution through a server-owned spawn catalogue;
- `Boss` execution through a stable BossId -> factory registry;
- current registered boss content:
  - `MarauderCaptain`;
  - `CorruptedForeman`;
- fail-closed validation for missing packs, executors, boss content, boss
  factories, physical room bindings and execution context;
- data-driven combat-pack count/reward/health/spawn configuration;
- server-owned rare/event pack-count bonuses;
- generic execution startup transaction:
  1. validate descriptor/content;
  2. start/persist generic sequence state;
  3. execute/spawn;
  4. register spawned enemies with existing EncounterService;
- rollback from Active to Pending when execution fails;
- cleanup + rollback if EncounterService rejects a successfully spawned
  encounter;
- partial combat-pack cleanup if an enemy factory fails mid-pack;
- boss factory exception / missing-Humanoid cleanup;
- encounter-scoped boss spawn claims rather than one-boss-per-session claims.

## Boss/miniboss/event/secret extension contract

Boss-family encounter kinds continue to include:

- `MiniBoss`;
- `Boss`;
- `FinalBoss`;
- `EventBoss`;
- `SecretBoss`.

All boss-family kinds route through the generic `Boss` executor when their
descriptor selects that executor.

A future boss becomes executable only when:

1. its stable `BossId` is present in the encounter descriptor;
2. the spawn catalogue registers that BossId;
3. a matching server-owned factory is registered;
4. the encounter has a valid physical binding;
5. normal sequencer ordering permits it.

Missing future content therefore fails closed instead of falling back to an
existing boss.

The upgraded boss spawn guard is scoped by stable encounter ID and session.
This permits multiple distinct boss-family encounters in one run, including
several Depth4 minibosses plus a final boss and later optional Event/Secret
bosses, while still blocking duplicate execution of the same encounter.

Failed boss execution releases its claim so the same encounter can be retried
safely.

## Live Dungeon controller boundary

`DungeonRuntime.server.luau` no longer directly imports or invokes:

- `DungeonMarauderFactory`;
- `MarauderCaptainFactory`;
- `MineForemanFactory`;
- `DungeonBossSpawnGuard`.

It also no longer owns the old room-pack count or concrete spawn helpers.

The live controller supplies only generic run context:

- Dungeon definition;
- authoritative difficulty/modifier tuning;
- immutable session InstanceState;
- environment adapter;
- enemies folder;
- runtime root;
- session ID.

Room1, Room2 and boss startup all route through
`DungeonEncounterExecutionController`.

Existing reward, death, clear, checkpoint and completion callbacks remain the
accepted compatibility layer.

## Implementation checkpoints

- `8c51b4d` - encounter execution registry foundation;
- `f006739` - execution descriptors exposed in difficulty/binding data;
- `fe1856e` - live Dungeon spawning routed through the execution registry,
  including rollback/cleanup and encounter-scoped boss guarding.

## Focused Studio evidence

Committed clean Dungeon composition reported:

- Dungeon Encounter Execution Registry: **16 assertions PASS**;
- Dungeon Encounter Spawn Catalog: **10 assertions PASS**;
- Dungeon Boss Factory Registry: **8 assertions PASS**;
- Dungeon Encounter Execution Bootstrap: **4 assertions PASS**;
- Dungeon Encounter Execution Controller: **17 assertions PASS**;
- Dungeon Encounter Executors: **20 assertions PASS**;
- Boss Spawn Guard: **10 assertions PASS**;
- Dungeon Encounter Sequencer: **25 assertions PASS**;
- Dungeon Encounter Runtime Controller: **22 assertions PASS**;
- Depth1 Encounter Flow: **18 assertions PASS**;
- Depth1 Encounter Bindings: **18 assertions PASS**.

## Real Temple live acceptance

A temporary Studio-only inspector/driver was added to a validation build and
removed immediately afterward.

The driver used the actual Temple trigger volumes and registry-spawned enemies.

Verified:

- Room1 real trigger activated logical `CombatRoom1`;
- StandardRoom1 catalogue spawned exactly **2** live enemies;
- Room1 names came from the registered pack specification;
- Room1 clear persisted and advanced the stable Room2 checkpoint;
- Room2 real trigger activated logical `CombatRoom2`;
- StandardRoom2 catalogue spawned exactly **3** live enemies;
- Room2 clear persisted and advanced the stable boss checkpoint;
- Room3 real trigger activated logical `Depth1Boss`;
- boss registry/executor produced the Marauder Captain;
- `DungeonBossRole = Boss` was forwarded from logical encounter kind;
- existing compatibility runtime encounter ID `MarauderCaptain` was retained;
- logical `Depth1Boss` persisted Cleared;
- generic flow completed;
- session completion and normal save barrier completed.

Result:

**Execution Registry Live Acceptance: PASS - 15 assertions.**

No project CreatorErrors occurred in that validation run.

## Real Abandoned Mine live acceptance

A separate temporary validation build deterministically forced:

- dungeon: `AbandonedMine`;
- event: `DeepEchoes`;
- rare state: `CrystalBloom`.

The driver used real Mine triggers and registry-spawned live enemies.

Verified:

- InstanceState selected Abandoned Mine;
- Deep Echoes was active;
- Crystal Bloom was active;
- Room1 catalogue spawned exactly **3** enemies
  (base 2 + Deep Echoes bonus 1);
- Room2 catalogue spawned exactly **4** enemies
  (base 3 + Crystal Bloom bonus 1);
- boss registry resolved the real `CorruptedForeman` factory;
- Foreman Humanoid display identity remained `Corrupted Foreman`;
- logical boss role remained `Boss`;
- logical Depth1Boss persisted Cleared;
- completion/save barrier succeeded.

Result:

**Mine Execution Registry Live Acceptance: PASS - 16 assertions.**

The temporary forced-mine build naturally caused Temple-only environment tests
to fail because the place intentionally contained the Mine environment rather
than Temple. Those validation-only errors disappeared after all temporary
selection hooks were reverted. They are not production regressions.

## Repository-wide static evidence

Final committed checkpoint `fe1856e`:

- repository Lua/Luau parse: **494 files, 0 failures**;
- `git diff --check`: PASS;
- non-published Dungeon Rojo build: PASS;
- non-published Base Rojo build: PASS;
- published Dungeon Rojo build: PASS;
- published Base Rojo build: PASS.

Source-boundary review against `c6e181c`:

- changed code/test files: **26**;
- art/model/mesh/terrain/image files changed: **0**;
- no art worktree merge or modification.

## Final committed Dungeon regression

Final committed Dungeon composition reported, among other families:

- Dungeon Difficulty Definitions: **114 assertions PASS**;
- Dungeon Difficulty v13 Migration: **14 assertions PASS**;
- Dungeon Difficulty Progression: **17 assertions PASS**;
- Dungeon Difficulty Session: **7 assertions PASS**;
- Dungeon Difficulty Instance Director: **7 assertions PASS**;
- Dungeon Difficulty Teleport: **7 assertions PASS**;
- Dungeon Difficulty Tuning: **10 assertions PASS**;
- Dungeon Enemy Difficulty Scaling: **5 assertions PASS**;
- Enemy Damage Multiplier Rules: **3 assertions PASS**;
- Dungeon Difficulty Completion Unlock: **9 assertions PASS**;
- Dungeon Modifier Definitions: **6 assertions PASS**;
- Teleport Coordinator: **16 assertions PASS**;
- Completion Service: **14 assertions PASS**;
- Reward Service: **27 assertions PASS**;
- Dungeon Session: PASS;
- Phase 3 Systems Stress: PASS.

One first final run hit the known nondeterministic TrainingDummy startup fixture
race. The exact same committed `Dungeon.rbxl` was reopened and rerun without
source changes; the repeat reported:

- Training Dummy: **9 assertions PASS**;
- execution-registry families PASS;
- Phase 3 Systems Stress PASS;
- player admitted normally;
- **no project CreatorErrors**.

The repeated clean run is the final Dungeon regression evidence.

## Final committed Base regression

Final committed Base composition reported:

- Dungeon Difficulty v13 Migration: **14 assertions PASS**;
- Dungeon Difficulty Progression: **17 assertions PASS**;
- Dungeon Entry Selection Rules: **9 assertions PASS**;
- Party Difficulty: **22 assertions PASS**;
- Party Difficulty Entry: **32 assertions PASS**;
- Party Entry Coordinator: PASS;
- Party Service: PASS;
- Phase 3 Systems Stress: PASS;
- **no project CreatorErrors**.

## Safety / deferred content

- Depth2-Depth4 remain `RuntimeReady = false`.
- Existing Depth1 remains the physical compatibility baseline.
- No new Event Boss or Secret Boss content is enabled.
- Unregistered future boss IDs fail closed.
- No modelling, mesh, terrain or authored-room work occurred.
- No TEST/PROD Roblox publish occurred during this gate.
- No PROD DataStore, Robux or monetisation action occurred.

## Release state

This gate has **not** been pushed, merged or published.

The canonical long-form roadmap remains v1.43 until a deliberate project-owner
release/closeout action.
