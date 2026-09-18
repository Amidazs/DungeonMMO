# Phase 4 Layout-Derived Environment Contract Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Selected-Layout Environment Contract
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `87a88c1`
**RED checkpoint:** `1729151`
**Implementation checkpoint:** `405dde5`

## Purpose

This gate removes the remaining Depth1-specific environment-resolver contract
dependency.

Production environment resolution now derives room anchors and enemy-spawn
groups from the selected physical layout rather than static Temple/Mine Room1-3
contract entries.

## Test-first RED evidence

The permanent Room4 contract test was written before implementation.

The RED Dungeon run failed for the intended reason:

- `DungeonLayoutEnvironmentContract` did not exist.

No implementation was counted before that failure was captured.

## Selected-layout contract

`DungeonLayoutEnvironmentContract` builds one resolver contract from:

- a dungeon-wide runtime base contract; and
- the selected physical layout.

The selected layout supplies:

- EntranceAnchor;
- TriggerAnchor;
- CheckpointAnchor;
- ExitBarrierAnchor when present;
- BossSpawnAnchor when present;
- combat enemy-spawn group name/prefix/minimum metadata.

Invalid layout anchors or incomplete combat group metadata fail closed.

The synthetic Room4 acceptance proves the built contract can be consumed by the
real EnvironmentAnchorResolver.

## Runtime base contracts

EnvironmentAnchorDefinitions now exposes runtime base contracts containing only
environment-wide anchors:

- completion position;
- return-to-base anchor.

The legacy full Temple/Mine contracts remain available for compatibility calls
and adapter-specific tests.

Current combat slots now own:

- EnemySpawnGroup;
- EnemySpawnPrefix;
- EnemySpawnMinCount.

Runtime readiness validates all three combat-group fields.

## Production integration

DungeonEnvironmentBootstrap builds and resolves the selected-layout contract
before activating the physical layout.

DungeonEnvironmentRouter rebuilds that same selected-layout contract after
bootstrap and passes it into the selected environment adapter.

TempleEnvironmentAdapter.resolve and
AbandonedMineEnvironmentAdapter.resolve accept an optional explicit contract;
when omitted they retain their legacy full-contract behavior.

## Focused acceptance

Dungeon Layout Environment Contract:
**14 assertions PASS**.

The focused proof includes:

- synthetic Room4 trigger/checkpoint visibility;
- synthetic Room4 exit-barrier visibility;
- synthetic Room4 boss-spawn visibility;
- synthetic Room4 spawn-group prefix/minimum generation;
- real EnvironmentAnchorResolver resolution;
- insufficient Room4 spawn anchors failing closed;
- incomplete combat group metadata failing closed.

Current TestDungeon Depth1 environment continued to boot through the derived
contract.

## Final committed static/build acceptance

Acceptance was rerun from clean committed checkpoint `405dde5`.

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

Roblox Controls Emulator plugin startup errors were observed and classified as
external to DungeonMMO project code.

## Source-boundary audit

Compared with baseline `87a88c1` before documentation closeout:

- 11 files changed;
- 9 are source/test files;
- 2 are design/implementation-plan documents;
- 0 art/model/mesh/terrain/image files changed.

Production bootstrap/router no longer use the static full Temple/Mine contracts
for runtime room resolution.

## Release qualification

- Depth2-Depth4 remain release-disabled/content-incomplete.
- No higher-depth layout was registered.
- No Room4+ model or authored anchor was created.
- No new enemy/boss content was enabled.
- No Event/Secret boss content was enabled.
- No modelling, meshes, terrain or authored-room work occurred.
- No Roblox TEST/PROD publish occurred.
- No PROD DataStore, Robux or monetisation action occurred.
- No push or merge is part of this local engineering closeout.
