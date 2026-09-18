# Phase 4 Depth4 Final-Difficulty Backend Content Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Depth4 Final-Difficulty Backend Content
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `230f7f5`
**RED checkpoint:** `8c3b8c2`
**Implementation checkpoint:** `8bcb58b`

## Purpose

This gate completes backend encounter content for the locked final difficulty in
both current dungeons while deliberately leaving Depth4 physically unimplemented
and release-disabled.

The authored Depth4 sequence remains:

1. Room1 combat;
2. Depth1 boss reused as MiniBoss;
3. Room3 combat;
4. Depth2 boss reused as MiniBoss;
5. Depth3 boss reused as MiniBoss;
6. new true final boss.

No replacement miniboss factories were added.

## Test-first RED evidence

The permanent Depth4 content, boss-factory and readiness contracts were written
before implementation.

The RED Dungeon run failed for the intended reasons:

- Depth4Room1 was missing;
- TempleDepth4BossFactory was missing;
- Depth4 readiness still reported EncounterContentNotRegistered.

## Depth4 combat packs

Both TestDungeon and AbandonedMine now register:

- Depth4Room1: 5 Marauders;
- Depth4Room3: 7 Marauders.

Abandoned Mine preserves its current instance-state rules:

- Deep Echoes adds one Marauder to Depth4Room1;
- Crystal Bloom adds one Marauder to Depth4Room3.

Depth4 combat strength also comes from the authoritative Depth4 health/damage
and reward multipliers plus the three miniboss encounters.

## Locked miniboss chain

The accepted difficulty ladder remains unchanged.

TestDungeon reuses:

- MarauderCaptain in Room2;
- TempleDepth2Boss in Room4;
- TempleDepth3Boss in Room5.

AbandonedMine reuses:

- CorruptedForeman in Room2;
- AbandonedMineDepth2Boss in Room4;
- AbandonedMineDepth3Boss in Room5.

The focused Depth4 content test permanently asserts these references.

## New final bosses

Registered stable final-boss IDs:

- TestDungeon: TempleDepth4Boss / display name Sanctum Ascendant;
- AbandonedMine: AbandonedMineDepth4Boss / display name Buried Tyrant.

Both are thin identity wrappers around the accepted Captain/Foreman combat
factories. They preserve BossRole = FinalBoss and retain the accepted
DungeonMarauderCaptain controller tag.

No new boss AI stack was introduced.

## Readiness boundary

After this gate, Depth2, Depth3 and Depth4 readiness for both current dungeons
is intentionally:

- Ready = false;
- ContentComplete = false;
- ReleaseEnabled = false;
- Issues = exactly one DungeonLayoutNotRegistered issue.

All higher-depth encounter content is now registered.

No Depth2, Depth3 or Depth4 physical layout or release switch was added.

## Focused acceptance

- Dungeon Depth4 Content: **38 assertions PASS**.
- Dungeon Depth4 Boss Factory: **10 assertions PASS**.
- Dungeon Encounter Spawn Catalog: **20 assertions PASS**.
- Dungeon Encounter Executors: **21 assertions PASS**.
- Dungeon Encounter Execution Bootstrap: **4 assertions PASS**.
- Dungeon Runtime Content Readiness: **70 assertions PASS**.
- Depth3 Content: **36 assertions PASS**.
- Depth3 Boss Factory: **8 assertions PASS**.
- Depth2 Content: **32 assertions PASS**.
- Depth2 Boss Factory: **8 assertions PASS**.

## Final committed static/build acceptance

Acceptance was rerun from clean committed checkpoint `8bcb58b`.

- `git diff --check`: PASS.
- repository Lua/Luau parse: **526 files, 0 failures**.
- Dungeon Rojo build: PASS.
- Base Rojo build: PASS.
- published Dungeon Rojo build: PASS.
- published Base Rojo build: PASS.

## Final committed Base regression

A verified PlayServer/PlayClient run from committed `8bcb58b` passed:

- Runtime Content Readiness: **70 assertions PASS**.
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

A verified PlayServer/PlayClient run from committed `8bcb58b` passed:

- Depth4 Content: **38 assertions PASS**.
- Depth4 Boss Factory: **10 assertions PASS**.
- Depth3 Content: **36 assertions PASS**.
- Depth3 Boss Factory: **8 assertions PASS**.
- Depth2 Content: **32 assertions PASS**.
- Depth2 Boss Factory: **8 assertions PASS**.
- Encounter Spawn Catalog: **20 assertions PASS**.
- Encounter Executors: **21 assertions PASS**.
- Encounter Execution Bootstrap: **4 assertions PASS**.
- Layout Environment Contract: **14 assertions PASS**.
- Encounter Bindings: **34 assertions PASS**.
- Combat Pack Encounter Executor: **15 assertions PASS**.
- Phase2A Failure Path: **24 assertions PASS**.
- Dungeon Difficulty Teleport: **7 assertions PASS**.
- Dungeon Difficulty Progression: **19 assertions PASS**.
- Runtime Content Readiness: **70 assertions PASS**.
- Training Dummy: **9 assertions PASS**.
- Combat Target Rules: **9 assertions PASS**.
- Phase 3 Systems Stress: PASS.
- live Studio player admission succeeded.

## Source-boundary audit

Compared with baseline `230f7f5` before documentation closeout:

- 12 files changed;
- 10 are source/test files;
- 2 are design/implementation-plan documents;
- 0 art/model/mesh/terrain/image files changed.

## Backend milestone reached

Depth1-Depth4 backend encounter content is now registered for both current
dungeons.

Depth2-Depth4 remain deliberately unusable in production because their physical
layouts are absent and RuntimeReleaseEnabled remains false.

This means later authored-room work can register physical layouts without
requiring another difficulty-content architecture rewrite.

## Release qualification

- Depth2-Depth4 remain release-disabled.
- Depth2-Depth4 remain physically unregistered.
- no Event/Secret boss content was enabled.
- no modelling, meshes, terrain or authored-room work occurred.
- no Roblox TEST/PROD publish occurred.
- no PROD DataStore, Robux or monetisation action occurred.
- no push or merge is part of this local engineering closeout.
