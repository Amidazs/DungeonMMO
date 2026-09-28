# DungeonMMO Roadmap v3.39
## Mixed-Objective Adventure GREEN
**Date:** 28 September 2026

This checkpoint implements the first accepted launch Adventure that deliberately
combines two different trusted server objective types in one quest.

It follows v3.38's priority to make launch content richer without inventing a
new objective type when existing trusted publishers are sufficient.

## New optional Adventure

**Follow the Fracture**

- quest ID: `FractureTrail`;
- kind: Adventure;
- minimum level: **12**;
- prerequisite: **Survey the Broken Ways / RuinSurvey**;
- optional;
- available to the same creation-enabled Adventure races/classes.

Objectives:

1. trace the disturbance through the Temple inner approach:
   `TestDungeon:EncounterStart:CombatRoom2`;
2. purge the source by completing a fresh Abandoned Mine run:
   `AbandonedMine`.

The first objective uses trusted `CheckpointReached`.
The second uses trusted `DungeonClear`.

No new client-authored or unvalidated quest event was introduced.

## Reward

The Adventure grants atomically:

- **90 Gold**;
- 2 Warding Essence.

The reward remains profession-optional and trade-compatible without introducing
another profession blueprint or another Gold-only boss bounty.

## Why this content exists

The quest is intended to feel more like a small investigation than a bounty:

- first follow a physical dungeon trail;
- then complete the second dungeon as the payoff;
- require two different kinds of play;
- reuse only released Depth-1 content;
- keep Depths 2-4 hidden until their physical layouts exist.

It also creates a level-12 content beat between the level-10 Foreman bounty and
the level-15 Break the Chain Adventure.

## Fresh validation

Source head before documentation:

`8481e6639019c1fb7e2cfb8ad4d5c8b999ba9fb1`

Fresh checks:

- `git diff --check 9210c29a..HEAD`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Base package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

This covers:

- quest definitions;
- launch Adventure eligibility;
- Dark Elf launch Adventure integration;
- QuestService;
- profession-aware quest rewards;
- profession economy topology;
- blueprint acquisition;
- gathering tiers;
- Base environment contract;
- Adventure Board contract.

Dungeon package:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

Focused Dungeon results include:

- Checkpoint Service;
- Completion Quest Bridge;
- Dungeon Checkpoint Quest Bridge;
- Ruin Survey integration;
- Fracture Trail mixed-objective integration.

The new Fracture Trail integration proves:

- level/prerequisite eligibility;
- Mine clear alone cannot finish the quest;
- Temple checkpoint plus Mine clear completes it;
- checkpoint replay remains idempotent;
- completion retry remains idempotent;
- one-time reward claiming;
- exact Warding Essence quantity;
- profession-optional completion;
- save/reload persistence.

## Launch pacing after v3.39

Current optional/story-adjacent launch beats include roughly:

- level 1: Worldroot / Forest Wolf content;
- level 5: Marauder Captain bounty;
- level 8: Survey the Broken Ways;
- level 10: Corrupted Foreman bounty;
- level 12: **Follow the Fracture**;
- level 15: Break the Chain;
- level 20: first class-transfer milestone.

## What is GREEN

- mixed `CheckpointReached` + `DungeonClear` Adventure progress;
- level-12 eligibility and Ruin Survey prerequisite;
- current creation-enabled race coverage;
- one-time Gold/item reward;
- replay/idempotency protection;
- persistence;
- existing profession/market/quest regressions underneath;
- existing Adventure Board contract.

## Placeholder / presentation status

The quest logic is real server-owned content. Final presentation is still
pending.

Presentation work remains for:

- NPC quest-giver identity and dialogue;
- story text explaining the fracture;
- final Temple/Mine environmental storytelling;
- final NPC/monster meshes and animations;
- Forest Wolf final presentation;
- Dwarf cavern/NPC art;
- crafting presentation/minigames;
- broader VFX/audio polish.

## Next development gate

The project should now start pairing accepted gameplay content with stronger
presentation instead of only increasing quest count.

Priority:

1. add reusable quest dialogue/presentation around the accepted Adventure
   catalogue;
2. give Worldroot, Mine Echoes, Ruin Survey and Fracture Trail clearer narrative
   continuity;
3. keep expanding content only where it adds a genuinely different play pattern;
4. begin replacing high-impact presentation placeholders, especially Forest
   Wolf/NPC/quest presentation;
5. keep Depths 2-4 release-disabled until physical content exists.

Do not add another simple Gold-only kill bounty as the next default step.
