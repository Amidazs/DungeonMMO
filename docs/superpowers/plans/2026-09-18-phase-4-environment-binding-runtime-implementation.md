# Phase 4 Environment Binding Runtime - Implementation Plan

**Baseline:** `caf56c5`
**Branch:** `wip/phase-4-environment-binding-runtime-v1`

## Task 1 - RED contract

Add focused tests that require:

- binding-owned EnemySpawnGroup;
- binding-owned ExitBarrierAnchor;
- CombatPack execution through environment:get_group only;
- generic physical barrier open/close behavior.

Capture intended RED before implementation.

## Task 2 - Layout/binding metadata

Extend current physical slots with EnemySpawnGroup for combat rooms.

Carry EnemySpawnGroup and ExitBarrierAnchor through
`DungeonEncounterBindings`.

Extend readiness validation for combat spawn-group bindings.

## Task 3 - Generic combat spawn lookup

Update `CombatPackEncounterExecutor` to:

- validate binding.EnemySpawnGroup;
- require environment.get_group;
- convert ordered group BaseParts into CFrames;
- stop depending on EnvironmentRoomId for spawn lookup.

Preserve EnvironmentRoomId for compatibility/diagnostics.

## Task 4 - Generic barrier runtime

Add `DungeonEncounterEnvironmentRuntime`.

Replace both DungeonRuntime `set_exit_open` call sites with the helper using
binding.ExitBarrierAnchor.

Keep adapter compatibility methods unchanged unless removal is proven safe.

## Task 5 - Acceptance

Run focused Studio tests, repository parse, all four Rojo builds, committed Base
and Dungeon regressions, and source-boundary audit.

Update continuity docs and create a local closeout checkpoint.

Do not enable higher depths, add authored content, push, merge or publish.
