# Phase 4 Layout-Derived Environment Contract - Implementation Plan

**Baseline:** `87a88c1`
**Branch:** `wip/phase-4-layout-environment-contract-v1`

## Task 1 - RED contract

Add a focused selected-layout environment-contract test.

The test must require a synthetic Room4 trigger/checkpoint/barrier and Room4
enemy-spawn group to become visible through EnvironmentAnchorResolver.

Capture intended RED before implementation.

## Task 2 - Physical spawn-group metadata

Extend combat-capable layout slots with EnemySpawnPrefix and
EnemySpawnMinCount.

Extend readiness validation for those fields.

## Task 3 - Contract builder

Add `DungeonLayoutEnvironmentContract`.

Build one runtime resolver contract from the dungeon-wide base contract plus
selected physical layout metadata.

Add Temple/Mine runtime base contracts while preserving existing full contracts.

## Task 4 - Production integration

Use the builder in DungeonEnvironmentBootstrap.

Use the same builder in DungeonEnvironmentRouter and pass the built contract to
the selected environment adapter.

Allow Temple/Mine adapter resolve functions to accept an optional contract while
preserving the existing default behavior.

## Task 5 - Acceptance

Run focused Studio tests, repository parse, four Rojo builds, committed Base and
Dungeon regressions, and source-boundary audit.

Update continuity docs and create a local closeout checkpoint.

Do not enable higher depths, add authored rooms, push, merge or publish.
