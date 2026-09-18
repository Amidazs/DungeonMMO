# Phase 4 Depth2 Backend Content - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Depth2 Backend Combat + Boss Content
**Baseline:** `468cf76`
**Scope:** backend content only

## Goal

Give both current dungeons complete registered Depth2 encounter content without
enabling Depth2 entry or creating physical rooms.

The existing difficulty ladder already defines:

- three Depth2 combat encounters in Room1-Room3;
- one new Depth2 boss in Room4;
- stronger health/damage/reward tuning;
- RuntimeReleaseEnabled = false.

This gate fills the combat-pack and boss-content registrations behind those
existing descriptors.

## Combat packs

Depth2 uses the existing Marauder archetype and enemy factory. Difficulty
strength comes from the existing Depth2 tuning multipliers, while pack size
increases encounter pressure.

For both dungeons:

- Depth2Room1: 3 Marauders;
- Depth2Room2: 4 Marauders;
- Depth2Room3: 5 Marauders.

Abandoned Mine retains its current instance-state flavour:

- Deep Echoes adds one Marauder to Depth2Room1;
- Crystal Bloom adds one Marauder to Depth2Room2.

## Depth2 bosses

Register the existing stable IDs already referenced by the difficulty ladder:

- TestDungeon: `TempleDepth2Boss`;
- AbandonedMine: `AbandonedMineDepth2Boss`.

Working display identities:

- Temple Warden;
- Deep Overseer.

Both reuse the accepted Captain/Foreman server combat controller for this backend
content slice. Their factories must still set distinct BossId/model/display
identity so Depth4 can later reuse these exact boss IDs as minibosses.

Boss reward keys reuse the current dungeon boss reward definitions for now.
Difficulty reward scaling remains authoritative.

## Readiness boundary

After this gate, Depth2 content readiness for each current dungeon must:

- still be Ready = false;
- still be ContentComplete = false;
- still be ReleaseEnabled = false;
- report DungeonLayoutNotRegistered;
- no longer report EncounterContentNotRegistered;
- contain no other readiness issue.

Depth3 and Depth4 remain unchanged and continue reporting missing content.

## Scope exclusions

This gate does not:

- register a Depth2 physical layout;
- create Room4 geometry or anchors;
- enable RuntimeReleaseEnabled;
- add a new enemy AI archetype;
- add EventBoss or SecretBoss content;
- change difficulty multipliers;
- publish, push or merge.

## Acceptance

Require RED -> GREEN proving:

- all six Depth2 combat packs are registered;
- expected base counts resolve as 3/4/5;
- Mine event/rare bonuses still target explicit entries;
- both Depth2 boss specs are registered;
- both Depth2 boss factories create distinct boss identities while retaining the
  accepted Captain controller tag;
- Depth2 readiness has only the missing-layout issue;
- Depth3/Depth4 remain fail closed for missing content;
- all existing Depth1 regressions remain green.
