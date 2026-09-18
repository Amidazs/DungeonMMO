# Phase 4 Generic Dungeon Encounter Runtime Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Generic Dungeon Encounter Runtime
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `1e1574c`
**Implementation checkpoint:** `5ba9f4d`
**Branch:** `wip/phase-4-generic-encounter-runtime-v1`

This backend-only gate replaces the accepted Depth1 hard-coded
Room1 -> Room2 -> Boss progression authority with a reusable server-owned
encounter plan and sequencer.

No modelling, meshes, terrain, authored rooms, boss art, UI art or environment
presentation work was performed.

## Accepted runtime contract

The backend now provides:

- stable encounter kinds:
  `Combat`, `MiniBoss`, `Boss`, `FinalBoss`, `EventBoss` and
  `SecretBoss`;
- arbitrary ordered encounter counts;
- deterministic optional insertion before or after a stable encounter ID;
- server-owned activation from immutable InstanceState conditions;
- required versus optional completion semantics;
- exactly one active encounter at a time;
- stable encounter-ID-derived checkpoints;
- reconnect-safe lifecycle persistence;
- immutable materialized run-plan persistence;
- compatibility mapping from the existing physical Depth1 Room1/Room2/Boss
  layout to logical encounter IDs;
- migration from legacy `Room1Start`, `Room2Start` and
  `BossRoomStart` checkpoints;
- stable checkpoint aliases:
  `EncounterStart:CombatRoom1`,
  `EncounterStart:CombatRoom2` and
  `EncounterStart:Depth1Boss`;
- live Depth1 progression authority delegated to the generic sequencer while
  preserving the existing EncounterService IDs, spawners, rewards, doors and
  Captain/Foreman implementations.

## Event Boss / Secret Boss extension contract

Future optional content can be inserted through server-owned definitions using:

- `InsertBeforeId` or `InsertAfterId`;
- an authoritative activation condition;
- `CompletionRequired`;
- a normal encounter descriptor containing stable ID, room-slot ID, kind and
  optional BossId.

Initial activation conditions support:

- `InstanceFlag`: immutable InstanceState key/value comparison;
- `RareState`: immutable `InstanceState.RareStateId` comparison.

An Event/Secret encounter that materializes into a run becomes part of the
persisted immutable encounter plan. Reconnect therefore reconstructs the same
run instead of rerolling optional content.

A required inserted encounter cannot be bypassed by starting a later encounter.

The current physical Depth1 runtime intentionally fails closed with
`EncounterBindingMissing` if optional content becomes active without an
explicit room/spawn/checkpoint binding. Backend support does not silently
enable unfinished Event/Secret content.

## Implementation checkpoints

- `c2aae5a` - generic encounter plan and sequencer;
- `5005747` - reconnect-safe encounter runtime state;
- `2d840e2` - generic runtime controller;
- `b205e35` - accepted Depth1 physical bindings;
- `a4b6fe4` - logical/physical Depth1 flow adapter;
- `7fcfe7f` - legacy checkpoint recovery migration;
- `5ba9f4d` - live DungeonRuntime progression authority integration.

## Focused Studio evidence

Final committed Dungeon composition reported:

- Dungeon Encounter Plan: **13 assertions PASS**;
- Dungeon Encounter Sequencer: **22 assertions PASS**;
- Dungeon Encounter Runtime State: **9 assertions PASS**;
- Dungeon Encounter Runtime Controller: **19 assertions PASS**;
- Depth1 Encounter Bindings: **14 assertions PASS**;
- Depth1 Encounter Flow: **14 assertions PASS**;
- Depth1 Encounter Recovery: **11 assertions PASS**;
- Dungeon Recovery Rules: **18 assertions PASS**.

The recovery suite covers both legacy and stable generic checkpoint IDs.

## Live end-to-end acceptance

A temporary Studio-only acceptance inspector/driver was built into a validation
place and removed from source immediately afterward.

The live driver used the real synthetic Temple environment and:

1. moved the real Studio character through `Temple.Room1.Trigger`;
2. killed only the real spawned `CombatRoom1` enemies;
3. verified persisted `CombatRoom1 = Cleared`;
4. verified checkpoint `EncounterStart:CombatRoom2`;
5. moved through the real Room2 trigger and killed its real enemies;
6. verified persisted `CombatRoom2 = Cleared`;
7. verified checkpoint `EncounterStart:Depth1Boss`;
8. moved through the real boss trigger;
9. killed the real Marauder Captain;
10. verified logical `Depth1Boss = Cleared`;
11. verified the generic flow reported complete;
12. verified the session reached `Complete`;
13. verified completion rewards passed the normal save barrier.

Result:

**Generic Encounter Live Acceptance: PASS - 13 assertions.**

The temporary inspector/driver was not committed and is absent from final
source.

One temporary acceptance run observed a `TrainingDummyTest` fixture race
before the live driver started. The clean post-harness production regression
then reported **Training Dummy Tests: 9 assertions PASS** with no project
CreatorErrors, so no production defect remained.

## Repository-wide static evidence

Final committed checkpoint `5ba9f4d`:

- repository Lua/Luau parse: **481 files, 0 failures**;
- `git diff --check`: PASS;
- non-published Dungeon Rojo build: PASS;
- non-published Base Rojo build: PASS;
- published Dungeon Rojo build: PASS;
- published Base Rojo build: PASS.

Source-boundary review against `1e1574c`:

- changed files: **19**;
- art/model/mesh/terrain/image files changed: **0**;
- no `DungeonMMO_Art` merge or modification.

## Final Dungeon regression evidence

Final committed Dungeon composition additionally reported:

- Dungeon Difficulty Definitions: **78 assertions PASS**;
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
- Training Dummy: **9 assertions PASS**;
- Phase 3 Systems Stress: PASS.

No project CreatorErrors were reported in the final committed Dungeon run.

## Final Base regression evidence

Final committed Base composition reported:

- Dungeon Difficulty v13 Migration: **14 assertions PASS**;
- Dungeon Difficulty Progression: **17 assertions PASS**;
- Dungeon Entry Selection Rules: **9 assertions PASS**;
- Party Difficulty: **22 assertions PASS**;
- Party Difficulty Entry: **32 assertions PASS**;
- Party Entry Coordinator: PASS;
- Party Service: PASS;
- Phase 3 Systems Stress: PASS.

No project CreatorErrors were reported in the final committed Base run.

## Compatibility and safety

- Existing Depth1 physical triggers and enemy/reward implementations remain in
  use.
- Existing EncounterService runtime IDs remain compatible:
  `CombatRoom1`, `CombatRoom2`, `MarauderCaptain`.
- Logical boss identity is `Depth1Boss`, decoupled from its current physical
  Marauder Captain implementation.
- Depth2-Depth4 remain `RuntimeReady = false`.
- No Event Boss or Secret Boss content has been enabled.
- No client controls optional encounter activation.
- No TEST/PROD Roblox publish occurred during this gate.
- No PROD DataStore, Robux or monetisation action occurred.

## Release state

This gate has **not** been pushed, merged or published.

The canonical long-form roadmap remains v1.43 until the project owner
explicitly approves closeout/release handling for this gate.
