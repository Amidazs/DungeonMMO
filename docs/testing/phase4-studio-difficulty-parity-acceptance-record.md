# Phase 4 Studio Difficulty Parity Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Studio Difficulty / Session Parity
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `5fb3491`
**RED checkpoint:** `efc6a47`
**Implementation checkpoint:** `d9297f8`

## Purpose

This gate removes the final demonstrated framework mismatch between production
difficulty routing and Studio-only dungeon session creation.

Production already preserved the selected DifficultyId through teleport,
session creation and DungeonInstanceDirector. StudioSessionFactory did not.

## Test-first RED evidence

The permanent Studio Session Factory test was extended before implementation.

The RED Dungeon run failed for the intended reason:

- explicit Studio Depth2 did not reach DungeonSessionService:create.

The failure message was:

`Studio session creation must receive Depth2.`

## Studio session propagation

StudioSessionFactory now accepts an optional difficulty_id and propagates it to:

- DungeonSessionService:create;
- DungeonInstanceDirector.resolve;
- returned Studio teleport_data.

When difficulty is omitted, the existing dungeon default remains Depth1.

Reused Studio sessions derive routing difficulty from the authoritative session
record when available.

## DungeonRuntime integration

DungeonRuntime now reads the difficulty already resolved by
DungeonEnvironmentBootstrap from:

`DungeonMMOResolvedDifficultyId`

That resolved difficulty is passed into StudioSessionFactory.

Production TeleportCoordinator routing was not changed.

## Focused acceptance

Studio Session Factory:
**7 assertions PASS**.

The focused proof includes:

- existing default Studio session creation remains valid;
- supplied player UserIds remain authoritative;
- explicit Depth2 reaches session creation;
- explicit Depth2 reaches DungeonInstanceDirector InstanceState;
- returned Studio routing data preserves DifficultyId = Depth2.

The live Studio dungeon remains Depth1 because higher-depth physical/content
registrations are intentionally not enabled yet.

## Final committed static/build acceptance

Acceptance was rerun from clean committed checkpoint `d9297f8`.

- `git diff --check`: PASS.
- repository Lua/Luau parse: **514 files, 0 failures**.
- Dungeon Rojo build: PASS.
- Base Rojo build: PASS.
- published Dungeon Rojo build: PASS.
- published Base Rojo build: PASS.

## Final committed Base regression

- Runtime Content Readiness: **64 assertions PASS**.
- Difficulty Definitions: **114 assertions PASS**.
- Difficulty Progression: **19 assertions PASS**.
- Teleport Coordinator: **19 assertions PASS**.
- Dungeon Entry Selection Rules: **9 assertions PASS**.
- Party Difficulty: **22 assertions PASS**.
- Party Difficulty Entry: **32 assertions PASS**.
- Party Entry Coordinator: PASS.
- Party Service: PASS.
- Phase 3 Systems Stress: PASS.

## Final committed Dungeon regression

Clean-repeat Dungeon acceptance recorded:

- Studio Session Factory: **7 assertions PASS**.
- Dungeon Layout Environment Contract: **14 assertions PASS**.
- Dungeon Encounter Bindings: **34 assertions PASS**.
- Combat Pack Encounter Executor: **15 assertions PASS**.
- Phase2A Failure Path: **24 assertions PASS**.
- Teleport Coordinator: **19 assertions PASS**.
- Dungeon Difficulty Teleport: **7 assertions PASS**.
- Dungeon Difficulty Progression: **19 assertions PASS**.
- Runtime Content Readiness: **64 assertions PASS**.
- Training Dummy: **9 assertions PASS**.
- Combat Target Rules: **9 assertions PASS**.
- Phase 3 Systems Stress: PASS.
- live Studio player admission succeeded.

## Source-boundary audit

Compared with baseline `5fb3491` before documentation closeout:

- 5 files changed;
- 3 are source/test files;
- 2 are design/implementation-plan documents;
- 0 art/model/mesh/terrain/image files changed.

Implementation-only checkpoint `d9297f8` changes only:

- DungeonRuntime.server.luau;
- StudioSessionFactory.luau.

## Release qualification

- Depth2-Depth4 remain release-disabled/content-incomplete.
- No higher-depth layout was registered.
- No new enemy/boss content was enabled.
- No Event/Secret boss content was enabled.
- No modelling, meshes, terrain or authored-room work occurred.
- No Roblox TEST/PROD publish occurred.
- No PROD DataStore, Robux or monetisation action occurred.
- No push or merge is part of this local engineering closeout.
