# Phase 4 Depth4 Backend Content - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Depth4 Final-Difficulty Backend Content
**Baseline:** `230f7f5`
**Scope:** backend content only

## Goal

Complete the backend content registrations for the locked final difficulty while
keeping Depth4 physically unavailable and release-disabled.

The authored Depth4 encounter sequence already contains six logical encounters:

1. Room1 combat;
2. Depth1 boss reused as MiniBoss;
3. Room3 combat;
4. Depth2 boss reused as MiniBoss;
5. Depth3 boss reused as MiniBoss;
6. a new true final boss.

This gate supplies only the missing combat-pack and final-boss content. It does
not replace the locked miniboss chain with new bosses.

## Combat packs

Depth4 continues to use the accepted Marauder archetype/factory.

For both current dungeons:

- Depth4Room1: 5 Marauders;
- Depth4Room3: 7 Marauders.

Difficulty strength also comes from the existing Depth4 health/damage/reward
tuning and the three miniboss encounters.

Abandoned Mine preserves its instance-state flavour:

- Deep Echoes adds one Marauder to Depth4Room1;
- Crystal Bloom adds one Marauder to Depth4Room3.

## Miniboss chain

No new factory is created for the first three Depth4 bosses.

The authored difficulty ladder must continue to reuse:

- DifficultyBossIds[1] in Room2 as MiniBoss;
- DifficultyBossIds[2] in Room4 as MiniBoss;
- DifficultyBossIds[3] in Room5 as MiniBoss.

For TestDungeon this means:

- MarauderCaptain;
- TempleDepth2Boss;
- TempleDepth3Boss.

For AbandonedMine this means:

- CorruptedForeman;
- AbandonedMineDepth2Boss;
- AbandonedMineDepth3Boss.

Their existing stable boss specs/factories remain authoritative.

## New final bosses

Register the stable IDs already referenced by the difficulty ladder:

- TestDungeon: `TempleDepth4Boss`;
- AbandonedMine: `AbandonedMineDepth4Boss`.

Working display identities:

- Temple: **Sanctum Ascendant**;
- Abandoned Mine: **Buried Tyrant**.

Both reuse the accepted Captain/Foreman server combat behavior for this backend
slice while setting distinct stable BossId/model/display identity.

BossRole = FinalBoss must remain preserved by the wrapper.

Boss rewards continue to use the existing dungeon boss reward definition;
Depth4 reward scaling remains authoritative.

## Readiness boundary

After this gate, Depth2, Depth3 and Depth4 readiness for both current dungeons
must each:

- remain Ready = false;
- remain ContentComplete = false;
- remain ReleaseEnabled = false;
- report exactly one DungeonLayoutNotRegistered issue;
- report no EncounterContentNotRegistered issue.

No higher-depth physical layout is registered by this gate.

## Scope exclusions

This gate does not:

- register a Depth4 physical layout;
- create Room1-Room6 geometry or anchors;
- enable RuntimeReleaseEnabled;
- introduce a new enemy AI archetype;
- introduce a new boss AI stack;
- enable EventBoss or SecretBoss content;
- change difficulty multipliers;
- publish, push or merge.

## Acceptance

Require RED -> GREEN proving:

- both Depth4 combat packs are registered for both dungeons;
- expected base counts resolve as 5 and 7;
- Mine event/rare bonuses target the two Depth4 combat packs;
- the authored three-miniboss chain still references Depth1/2/3 boss IDs;
- both new Depth4 final-boss specs are registered;
- both final-boss factories create distinct stable identities while preserving
  FinalBoss role and the accepted Captain controller tag;
- Depth2/Depth3/Depth4 readiness each fail only on missing physical layout;
- all existing Depth1-Depth3 regressions remain green.
