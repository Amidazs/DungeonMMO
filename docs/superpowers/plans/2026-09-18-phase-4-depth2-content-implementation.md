# Phase 4 Depth2 Backend Content - Implementation Plan

**Baseline:** `468cf76`
**Branch:** `wip/phase-4-depth2-content-v1`

## Task 1 - RED content contract

Add focused Depth2 content tests and update readiness expectations.

Require registered Depth2Room1/2/3 packs, stable boss specs/factories and
layout-only Depth2 readiness failure.

Capture RED before implementation.

## Task 2 - Combat packs

Register Depth2Room1/2/3 for TestDungeon and AbandonedMine.

Use Marauder entries with base counts 3/4/5. Preserve Mine Deep Echoes and
Crystal Bloom bonus rules on the first two rooms.

## Task 3 - Boss content

Add TempleDepth2BossFactory and AbandonedMineDepth2BossFactory as identity
wrappers around the accepted Captain/Foreman combat factories.

Register both factory IDs in DungeonEncounterExecutionBootstrap and both boss
specs in DungeonRuntimeContentCatalog.

## Task 4 - Acceptance

Run focused Studio tests, repository parse, all four Rojo builds, Base/Dungeon
regressions and source-boundary audit.

Depth2 must remain release-disabled and physically unregistered.

Update continuity docs and close locally. Do not push, merge or publish.
