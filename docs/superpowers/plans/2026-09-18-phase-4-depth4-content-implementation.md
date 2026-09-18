# Phase 4 Depth4 Backend Content - Implementation Plan

**Baseline:** `230f7f5`
**Branch:** `wip/phase-4-depth4-content-v1`

## Task 1 - RED content contract

Add focused Depth4 content/factory tests and update readiness expectations.

Require Depth4Room1/Room3 packs, the locked Depth1/2/3 miniboss chain, stable
Depth4 final-boss specs/factories and layout-only Depth4 readiness failure.

Capture RED before implementation.

## Task 2 - Combat packs

Register Depth4Room1 and Depth4Room3 for TestDungeon and AbandonedMine.

Use Marauder entries with base counts 5 and 7. Preserve Mine Deep Echoes on
Room1 and Crystal Bloom on Room3.

## Task 3 - Final boss content

Add TempleDepth4BossFactory and AbandonedMineDepth4BossFactory as identity
wrappers around the accepted Captain/Foreman combat factories.

Register both factory IDs in DungeonEncounterExecutionBootstrap and both boss
specs in DungeonRuntimeContentCatalog.

Do not create replacement factories for the three miniboss encounters.

## Task 4 - Acceptance

Run focused Studio tests, repository parse, all four Rojo builds, Base/Dungeon
regressions and source-boundary audit.

Depth2-Depth4 must remain release-disabled and physically unregistered.

Update continuity docs and close locally. Do not push, merge or publish.
