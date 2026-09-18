# Phase 4 Depth3 Backend Content - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Depth3 Backend Combat + Boss Content
**Baseline:** `3d978af`
**Scope:** backend content only

## Goal

Give both current dungeons complete registered Depth3 encounter content while
keeping Depth3 physically unavailable and release-disabled.

The existing difficulty ladder already defines:

- four Depth3 combat encounters in Room1-Room4;
- one new Depth3 boss in Room5;
- stronger Depth3 health/damage/reward tuning;
- RuntimeReleaseEnabled = false.

This gate fills the combat-pack and boss registrations behind those descriptors.

## Combat packs

Depth3 continues to use the accepted Marauder archetype/factory. Difficulty
strength comes from the existing Depth3 tuning multipliers plus larger packs.

For both current dungeons:

- Depth3Room1: 4 Marauders;
- Depth3Room2: 5 Marauders;
- Depth3Room3: 6 Marauders;
- Depth3Room4: 7 Marauders.

Abandoned Mine preserves its instance-state flavour:

- Deep Echoes adds one Marauder to Depth3Room1;
- Crystal Bloom adds one Marauder to Depth3Room2.

## Depth3 bosses

Register the stable IDs already referenced by the difficulty ladder:

- TestDungeon: `TempleDepth3Boss`;
- AbandonedMine: `AbandonedMineDepth3Boss`.

Working display identities:

- Temple: **Relic Guardian**;
- Abandoned Mine: **Hollow Taskmaster**.

Both reuse the accepted Captain/Foreman server combat behavior for this backend
slice while setting distinct stable BossId/model/display identity. These IDs are
then available for Depth4 miniboss reuse exactly as defined by the ladder.

Boss rewards continue to use each dungeon's existing boss reward definition;
difficulty reward scaling remains authoritative.

## Readiness boundary

After this gate, Depth3 readiness for each current dungeon must:

- remain Ready = false;
- remain ContentComplete = false;
- remain ReleaseEnabled = false;
- report DungeonLayoutNotRegistered;
- no longer report EncounterContentNotRegistered;
- contain no other readiness issue.

Depth2 keeps the same layout-only failure.
Depth4 remains content-incomplete.

## Scope exclusions

This gate does not:

- register a Depth3 physical layout;
- create Room4/Room5 geometry or anchors;
- enable RuntimeReleaseEnabled;
- add a new enemy AI archetype;
- enable EventBoss or SecretBoss content;
- change difficulty multipliers;
- publish, push or merge.

## Acceptance

Require RED -> GREEN proving:

- all eight Depth3 combat packs are registered;
- expected base counts resolve as 4/5/6/7;
- Mine event/rare bonuses still target explicit entries;
- both Depth3 boss specs are registered;
- both Depth3 boss factories create distinct stable identities while retaining
  the accepted Captain controller tag;
- Depth2 and Depth3 readiness each fail only on missing physical layout;
- Depth4 remains fail-closed for missing content;
- all existing Depth1/Depth2 regressions remain green.
