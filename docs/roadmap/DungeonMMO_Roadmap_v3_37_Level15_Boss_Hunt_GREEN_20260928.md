# DungeonMMO Roadmap v3.37
## Level-fifteen dual-boss Adventure GREEN
**Date:** 28 September 2026

This checkpoint fills the launch content gap between the level-10 Corrupted
Foreman bounty and the level-20 first-transfer milestone.

## New optional Adventure

**Break the Chain**

- quest ID: `DungeonBossHunt`;
- kind: Adventure;
- minimum level: **15**;
- prerequisite: **Mine Echoes**;
- objectives:
  - defeat **1** `marauder_captain`;
  - defeat **1** `corrupted_foreman`;
- reward: **120 Gold only**.

The Adventure is optional. It does not gate Expedition Provisioning or any
first-transfer/class progression.

## Trusted objective path

Both objectives use already-reviewed server-owned `EnemyDefeat` events.

Temple path:

- real `MarauderCaptainFactory`;
- `BestiaryCreatureId = marauder_captain`;
- real EncounterService event.

Mine path:

- real `BossEncounterExecutor`;
- real `MineForemanFactory`;
- `BestiaryCreatureId = corrupted_foreman`;
- real EncounterService event.

No new client-authored quest signal was introduced.

## Level pacing

Fresh eligibility coverage proves:

- level 14 + Mine Echoes -> unavailable;
- level 15 + Mine Echoes -> eligible;
- existing creation-enabled Human, Elf and Dark Elf remain covered;
- creation-disabled Orc and Dwarf remain excluded.

The launch Adventure spine now has optional content at levels 1, 5, 10 and 15,
leading naturally into the existing level-20 first-transfer milestone.

## Real two-dungeon integration

The focused Dungeon integration:

1. starts Break the Chain for a level-15 Dark Elf Fighter;
2. executes a real Captain encounter;
3. proves one boss alone cannot complete the Adventure;
4. executes a real Foreman through the corrected Mine boss executor;
5. proves the second trusted boss defeat completes the objective set;
6. grants exactly **120 Gold** and no items;
7. records exactly one monster reward transaction per boss;
8. leaves Expedition Provisioning independently available.

## Fresh acceptance

Pre-documentation head:

`b404fb12194aae2e2ff330d1ce0df0a46379f1da`

Fresh checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Base package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Dungeon package:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 7`

The Dungeon package now covers both released boss bounties plus the combined
dual-boss Adventure.

## What is GREEN

- level-15 Adventure eligibility;
- two-objective trusted EnemyDefeat progress;
- real Temple Captain integration;
- real Mine Foreman executor/factory integration;
- exact one-time 120-Gold reward;
- optional-story independence;
- existing profession-aware content and level-1-to-10 Adventures underneath.

## Next development gate

The launch progression spine now reaches the level-20 first-transfer milestone.

Next work should shift from adding another repetitive Gold bounty to improving
**quest/content density and presentation**:

1. add richer side/story objectives using released Depth-1 gameplay;
2. add new trusted server event boundaries before introducing objective types
   beyond DungeonClear/EnemyDefeat;
3. continue replacing temporary monster/boss presentation with final launch
   creatures, animations and VFX;
4. add profession/blueprint reward sources where they create trade pressure
   without making professions mandatory;
5. keep Depths 2-4 release-disabled until their physical rooms are ready.
