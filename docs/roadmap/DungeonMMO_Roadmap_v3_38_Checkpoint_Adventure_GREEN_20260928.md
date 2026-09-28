# DungeonMMO Roadmap v3.38
## Trusted Checkpoint Adventure GREEN
**Date:** 28 September 2026

This checkpoint is the first accepted launch Adventure that progresses from
server-owned dungeon checkpoint state rather than DungeonClear or EnemyDefeat.

It follows the v3.37 direction to stop adding repetitive Gold-only bounties and
build richer launch content only on trusted server event boundaries.

## New trusted event boundary

Dungeon runtime now publishes:

`CheckpointReached`

only after `CheckpointService:activate()` succeeds.

The bridge:

- scopes targets by dungeon and checkpoint ID;
- emits one event per unique connected party member;
- uses stable session/checkpoint/user event IDs;
- remains idempotent through QuestService replay protection;
- fails closed on invalid context/member data;
- never accepts a client-authored checkpoint event.

Example released target:

`TestDungeon:EncounterStart:CombatRoom2`

## New optional Adventure

**Survey the Broken Ways**

- quest ID: `RuinSurvey`;
- kind: Adventure;
- minimum level: **8**;
- prerequisite: **Mine Echoes**;
- optional;
- available to the same currently creation-enabled Adventure races/classes.

Objectives:

1. reach the Temple inner approach:
   `TestDungeon:EncounterStart:CombatRoom2`;
2. reach the Mine lower works:
   `AbandonedMine:EncounterStart:CombatRoom2`.

Both use `CheckpointReached` and require one fresh server-authorized event.

## Reward

The Adventure grants atomically:

- **60 Gold**;
- 1 Deep Iron Bar;
- 1 Moonpetal Extract;
- 1 Reinforced Leather;
- 1 Resonant Rune.

The reward is profession-optional. It gives one small sample of each level-3
crafted component and keeps the items tradeable, so a character with no
profession selection can still participate in the player economy.

The quest does not grant or require a profession blueprint and therefore does
not undermine the v3.29 optional blueprint drop/trade loop.

## Quest Board presentation

Checkpoint objectives have readable player-facing labels instead of exposing
raw internal IDs:

- Reach the Temple's inner approach;
- Reach the Mine's lower works.

The existing Adventure Board contract remains green.

## Fresh validation

Pre-documentation source head:

`d4952580a3d616393a797c1c9bdcc54fe33f660d`

Fresh checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Base package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Notable Base results:

- Quest Definition Tests: **42 assertions**;
- Adventure Eligibility: **47 assertions**;
- Dark Elf Adventure: **23 assertions**;
- Quest Service: **59 assertions**;
- Profession Quest Integration: **27 assertions**;
- Base Adventure Board: **6 assertions**.

Dungeon package:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 4`

Focused results:

- Checkpoint Service: **7 assertions**;
- Completion Quest Bridge: **8 assertions**;
- Checkpoint Quest Bridge: **9 assertions**;
- Ruin Survey Integration: **19 assertions**.

## What is GREEN

- trusted server checkpoint event publishing;
- stable checkpoint target IDs;
- per-party-member checkpoint quest progress;
- duplicate member/event replay protection;
- level-8 Ruin Survey eligibility;
- two released Depth-1 checkpoint objectives;
- one-time multi-item reward;
- save/reload persistence;
- creation-enabled race coverage;
- existing story/profession/blueprint content underneath.

## Placeholder / presentation status

This checkpoint makes the quest logic real; it does not claim all world
presentation is final.

Still placeholder or presentation-pending in the wider project:

- several final NPC/monster meshes and animations;
- final quest dialogue/cinematics;
- some current Dungeon enemy presentation;
- Forest Wolf final mesh/animation/AI presentation;
- Dwarf hub final cavern/NPC art;
- final crafting station presentation/minigames.

These are presentation replacements over accepted server contracts, not fake
quest/progression logic.

## Next development gate

Continue richer launch content using trusted existing events and the new
checkpoint boundary.

Priority:

1. combine checkpoint exploration with existing enemy/clear events where it
   creates a meaningful side/story objective;
2. add presentation/dialogue around accepted Adventures rather than only
   increasing quest count;
3. use profession/blueprint rewards sparingly where they create trade pressure;
4. introduce any new objective type only after a server-owned publisher and
   focused test exist;
5. keep Depths 2-4 release-disabled until their physical layouts are ready.

Do not return to repetitive Gold-only kill bounties as the default content
pattern.
