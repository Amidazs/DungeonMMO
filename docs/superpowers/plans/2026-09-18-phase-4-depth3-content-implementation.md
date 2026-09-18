# Phase 4 Depth3 Backend Content - Implementation Plan

**Baseline:** `3d978af`
**Branch:** `wip/phase-4-depth3-content-v1`

## Task 1 - RED content contract

Add focused Depth3 content/factory tests and update readiness expectations.

Require registered Depth3Room1/2/3/4 packs, stable Depth3 boss specs/factories,
and layout-only Depth3 readiness failure.

Capture RED before implementation.

## Task 2 - Combat packs

Register Depth3Room1/2/3/4 for TestDungeon and AbandonedMine.

Use Marauder entries with base counts 4/5/6/7. Preserve Mine Deep Echoes and
Crystal Bloom bonus rules on the first two rooms.

## Task 3 - Boss content

Add TempleDepth3BossFactory and AbandonedMineDepth3BossFactory as identity
wrappers around the accepted Captain/Foreman combat factories.

Register both factory IDs in DungeonEncounterExecutionBootstrap and both boss
specs in DungeonRuntimeContentCatalog.

## Task 4 - Acceptance

Run focused Studio tests, repository parse, all four Rojo builds, Base/Dungeon
regressions and source-boundary audit.

Depth3 must remain release-disabled and physically unregistered.
Depth4 must remain content-incomplete.

Update continuity docs and close locally. Do not push, merge or publish.
