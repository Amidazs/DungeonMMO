# Phase 4 Depth3 Backend Content Acceptance Record

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Depth3 Backend Combat + Boss Content
**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `3d978af`
**RED checkpoint:** `b205914`
**Implementation checkpoint:** `092bd99`

## Purpose

This gate registers complete backend encounter content for Depth3 in both
current dungeons while deliberately leaving Depth3 physically unimplemented and
release-disabled.

The existing difficulty ladder already defined four combat encounters plus a
new boss in Room5. This gate fills those PackId and BossId registrations.

## Test-first RED evidence

The permanent Depth3 content, boss-factory and readiness contracts were written
before implementation.

The RED Dungeon run failed for the intended reasons:

- Depth3 combat packs were missing;
- TempleDepth3BossFactory was missing;
- Depth3 readiness still reported EncounterContentNotRegistered.

## Depth3 combat packs

Both TestDungeon and AbandonedMine now register:

- Depth3Room1: 4 Marauders;
- Depth3Room2: 5 Marauders;
- Depth3Room3: 6 Marauders;
- Depth3Room4: 7 Marauders.

Strength continues to come from the authoritative Depth3 difficulty multipliers
in addition to the increased pack sizes.

Abandoned Mine preserves its current instance-state rules:

- Deep Echoes adds one Marauder to Depth3Room1;
- Crystal Bloom adds one Marauder to Depth3Room2.

No new production enemy archetype or enemy AI factory was required.

## Depth3 bosses

Registered stable boss IDs:

- TestDungeon: TempleDepth3Boss / display name Relic Guardian;
- AbandonedMine: AbandonedMineDepth3Boss / display name Hollow Taskmaster.

Both use thin identity wrappers around the accepted Captain/Foreman combat
factories and retain the DungeonMarauderCaptain controller tag.

These stable IDs are now available for the intended Depth4 miniboss chain.

## Readiness boundary

After this gate, Depth2 and Depth3 readiness for both current dungeons is
intentionally:

- Ready = false;
- ContentComplete = false;
- ReleaseEnabled = false;
- Issues = exactly one DungeonLayoutNotRegistered issue.

Depth3 no longer reports EncounterContentNotRegistered.

Depth4 remains content-incomplete and fail-closed.

No Depth3 physical layout, Room4/Room5 anchor set or release switch was added.

## Focused acceptance

- Dungeon Depth3 Content: **36 assertions PASS**.
- Dungeon Depth3 Boss Factory: **8 assertions PASS**.
- Dungeon Encounter Spawn Catalog: **19 assertions PASS**.
- Dungeon Runtime Content Readiness: **68 assertions PASS**.
- Dungeon Encounter Execution Bootstrap: **4 assertions PASS**.

## Final committed static/build acceptance

Acceptance was rerun from clean committed checkpoint `092bd99`.

- `git diff --check`: PASS.
- repository Lua/Luau parse: **522 files, 0 failures**.
- Dungeon Rojo build: PASS.
- Base Rojo build: PASS.
- published Dungeon Rojo build: PASS.
- published Base Rojo build: PASS.

## Final committed Base regression

- Runtime Content Readiness: **68 assertions PASS**.
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

- Depth3 Content: **36 assertions PASS**.
- Depth3 Boss Factory: **8 assertions PASS**.
- Depth2 Content: **32 assertions PASS**.
- Depth2 Boss Factory: **8 assertions PASS**.
- Encounter Spawn Catalog: **19 assertions PASS**.
- Encounter Execution Bootstrap: **4 assertions PASS**.
- Studio Session Factory: **7 assertions PASS**.
- Layout Environment Contract: **14 assertions PASS**.
- Encounter Bindings: **34 assertions PASS**.
- Combat Pack Encounter Executor: **15 assertions PASS**.
- Phase2A Failure Path: **24 assertions PASS**.
- Teleport Coordinator: **19 assertions PASS**.
- Dungeon Difficulty Teleport: **7 assertions PASS**.
- Dungeon Difficulty Progression: **19 assertions PASS**.
- Runtime Content Readiness: **68 assertions PASS**.
- Training Dummy: **9 assertions PASS**.
- Combat Target Rules: **9 assertions PASS**.
- Phase 3 Systems Stress: PASS.
- live Studio player admission succeeded.

## Source-boundary audit

Compared with baseline `3d978af` before documentation closeout:

- 10 files changed;
- 8 are source/test files;
- 2 are design/implementation-plan documents;
- 0 art/model/mesh/terrain/image files changed.

## Release qualification

- Depth3 remains release-disabled.
- Depth3 remains physically unregistered.
- Depth2 remains release-disabled and physically unregistered.
- Depth4 remains content-incomplete and release-disabled.
- no Event/Secret boss content was enabled.
- no modelling, meshes, terrain or authored-room work occurred.
- no Roblox TEST/PROD publish occurred.
- no PROD DataStore, Robux or monetisation action occurred.
- no push or merge is part of this local engineering closeout.
