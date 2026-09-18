# Phase 4 Runtime Layout Selection Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Authoritative Runtime Layout Selection + Environment Activation
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `0177b17`
**RED checkpoint:** `5ab0b4e`
**Implementation checkpoint:** `ccd289b`

## Purpose

This gate removes the remaining three-room assumption from
`DungeonEnvironmentBootstrap.server.luau`.

Environment startup now resolves the selected Dungeon/Difficulty/Layout and
activates physical triggers and exit barriers from registered layout data.

No higher-depth physical content was enabled.

## Test-first RED evidence

The permanent tests were written before implementation.

The RED Dungeon run failed for the intended missing capabilities:

- `DungeonRuntimeSelection.resolve_selection` did not exist;
- `DungeonEnvironmentLayoutActivation` did not exist.

The unrelated Combat Target Rules Studio-player startup race was not counted as
part of the RED proof.

## Accepted runtime selection

`DungeonRuntimeSelection.resolve_selection(...)` now resolves:

- DungeonId;
- DifficultyId;
- LayoutId.

Production selection preserves DifficultyId from TeleportData.
Studio may use `DungeonMMOStudioDifficultyId`; otherwise the selected dungeon's
default difficulty is used.

Unknown difficulty or unregistered selected layouts fail closed.

The original dungeon-only `resolve(...)` API remains intact for compatibility.

Focused selection evidence: **7 assertions PASS**.

## Accepted environment activation

Physical layout slots now declare an explicit `ExitBarrierAnchor` in addition
to the existing logical `ExitBarrierRoomId`.

`DungeonEnvironmentLayoutActivation` activates every declared:

- TriggerAnchor as touchable/non-collidable/invisible;
- ExitBarrierAnchor as collidable/non-touchable/invisible.

The module contains no Temple, Mine, Room1, Room2 or Room3 knowledge.

A synthetic four-slot layout proved arbitrary slot-count activation.

Focused activation evidence: **12 assertions PASS**.

## Bootstrap integration

`DungeonEnvironmentBootstrap.server.luau` no longer contains hard-coded
Temple/Mine trigger or barrier arrays.

The bootstrap now:

1. resolves Dungeon/Difficulty/Layout;
2. creates or locates the selected environment;
3. resolves the authored environment contract;
4. loads the selected registered layout;
5. applies generic layout activation;
6. publishes resolved Dungeon/Difficulty/Layout Workspace attributes.

Current Studio proof logged:

`[Dungeon Environment] TestDungeon / Depth1 / Depth1 ready in Synthetic mode.`

Runtime readiness also validates that any logical exit-barrier room binding has
a physical `ExitBarrierAnchor`.

## Final committed static/build acceptance

Acceptance was rerun from clean committed checkpoint `ccd289b`.

- `git diff --check`: PASS.
- repository Lua/Luau parse: **510 files, 0 failures**.
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
- no project CreatorError observed.

## Final committed Dungeon regression

- Runtime Selection: **7 assertions PASS**.
- Environment Layout Activation: **12 assertions PASS**.
- Encounter Bindings: **30 assertions PASS**.
- Encounter Executors: **21 assertions PASS**.
- Encounter Execution Bootstrap: **4 assertions PASS**.
- Runtime Content Readiness: **64 assertions PASS**.
- Training Dummy: **9 assertions PASS**.
- Combat Target Rules: **9 assertions PASS**.
- Phase 3 Systems Stress: PASS.
- live Studio player admission succeeded.

Roblox Controls Emulator plugin startup errors were observed and are unrelated to
DungeonMMO project code.

## Source-boundary audit

Compared with baseline `0177b17`:

- 9 files changed before documentation closeout;
- 7 are source/test files;
- 2 are design/implementation-plan documents;
- 0 art/model/mesh/terrain/image files changed;
- 0 newly added source lines exceeded 79 characters.

## Release qualification

- Depth2-Depth4 remain release-disabled/content-incomplete.
- No new physical rooms or anchors were created.
- No Event/Secret boss content was enabled.
- No modelling, meshes, terrain or authored-room work occurred.
- No Roblox TEST/PROD publish occurred.
- No PROD DataStore, Robux or monetisation action occurred.
- No push or merge is part of this local engineering closeout.
