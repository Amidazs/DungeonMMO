# DungeonMMO Roadmap v3.36
## Level-ten Corrupted Foreman bounty GREEN
**Date:** 28 September 2026

This checkpoint adds the second level-paced optional boss Adventure on top of
the corrected v3.35 Abandoned Mine boss identity.

## New optional Adventure

**The Foreman's Reckoning**

- quest ID: `CorruptedForemanBounty`;
- kind: Adventure;
- minimum level: **10**;
- prerequisite: **Mine Echoes**;
- objective: defeat **1** `corrupted_foreman`;
- reward: **80 Gold only**.

The quest is optional. Expedition Provisioning continues to require only
Mine Echoes, so the Foreman bounty cannot block the launch story/content path.

## Trusted released boss identity

The Adventure uses the v3.35 accepted Mine identity:

- `BossId = "CorruptedForeman"`;
- `BestiaryCreatureId = "corrupted_foreman"`.

The real BossEncounterExecutor is part of the integration, so the test does not
bypass the identity override that separates the Foreman from the Temple Captain.

No new client-authored quest signal was introduced. EncounterService emits the
existing trusted `EnemyDefeat / corrupted_foreman` event only after the
monster reward path succeeds.

## Level pacing

Eligibility coverage proves:

- level 9 + Mine Echoes complete -> Foreman bounty unavailable;
- level 10 without Mine Echoes -> unavailable;
- level 10 + Mine Echoes complete -> eligible;
- Human, Elf and Dark Elf remain the creation-enabled Adventure races;
- creation-disabled Orc and Dwarf remain excluded.

The Adventure Board renders:
**"Defeat the Corrupted Foreman"**.

## Real Dungeon integration

The focused integration uses:

- real `BossEncounterExecutor`;
- real `MineForemanFactory`;
- real `EncounterService`;
- real `QuestService`;
- the real Abandoned Mine Dungeon definition;
- a launch-valid level-10 Dark Elf Fighter.

The real executor-spawned Foreman death:

1. commits one monster reward transaction;
2. carries `BestiaryCreatureId = corrupted_foreman`;
3. emits trusted `EnemyDefeat / corrupted_foreman`;
4. readies the Foreman bounty;
5. allows exactly one **80 Gold** claim;
6. rejects duplicate reward/quest credit;
7. leaves Expedition Provisioning independently startable.

## Fresh acceptance

Pre-documentation head:

`cc32bc0f4f1bb88314948e491a35f4e7c8da50ae`

Fresh local checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Base package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Dungeon package:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 6`

The Dungeon package now covers:

- Forest Wolf factory;
- Marauder Captain contract;
- EncounterService;
- Forest Wolf bounty;
- Marauder Captain bounty;
- Corrupted Foreman bounty.

## What is GREEN

- corrected Foreman identity from v3.35;
- level-10 eligibility and Mine Echoes prerequisite;
- real executor-spawned Foreman -> trusted EnemyDefeat;
- Gold-only 80-Gold reward;
- duplicate death idempotence;
- optional-story independence;
- existing profession-aware Adventure content underneath.

## Next development gate

Continue launch-level quest/content expansion through the gap between the
level-10 Foreman bounty and level-20 first-transfer progression.

Prefer released Depth-1 content and existing trusted event types. Do not make
Depths 2-4 visible quest requirements while those physical layouts remain
release-disabled.
