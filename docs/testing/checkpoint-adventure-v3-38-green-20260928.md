# Trusted checkpoint Adventure acceptance — v3.38
**Date:** 28 September 2026

## Scope

This record validates the first launch Adventure driven by server-owned
checkpoint progression.

It covers:

- Dungeon checkpoint -> QuestService event publishing;
- party-member dedupe;
- stable replay-safe event IDs;
- the new level-8 Ruin Survey;
- multi-component reward persistence;
- existing Base Adventure regressions.

## Build

Accepted source head before documentation:

`d4952580a3d616393a797c1c9bdcc54fe33f660d`

Fresh validation:

- `git diff --check`: PASS;
- `rojo build base.project.json`: PASS;
- `rojo build default.project.json`: PASS.

## Checkpoint bridge

`DungeonCheckpointQuestBridge` publishes only trusted server events with:

- type: `CheckpointReached`;
- target:
  `<DungeonId>:<CheckpointId>`;
- event ID:
  `<SessionId>:CheckpointReached:<CheckpointId>:<UserId>`.

Focused result:

`[Checkpoint Quest Bridge] PASS: 9 assertions`

The test proves:

- stable target generation;
- duplicate party members are deduped;
- each member gets an independent stable event;
- invalid context/member data fails closed;
- QuestService failures are surfaced.

## Ruin Survey integration

Adventure:

`RuinSurvey / Survey the Broken Ways`

Eligibility:

- level 8;
- Mine Echoes completed;
- existing creation-enabled Adventure identities.

Objectives:

- Temple CombatRoom2 checkpoint;
- Abandoned Mine CombatRoom2 checkpoint.

Focused result:

`[Ruin Survey Integration] PASS: 19 assertions`

The real QuestService integration proves:

- unrelated checkpoints are harmless;
- one correct checkpoint is insufficient;
- replaying the same stable checkpoint event does not double-progress;
- the second released checkpoint readies the quest;
- one claim grants exactly 60 Gold plus four level-3 components;
- no profession selection is required;
- repeat claim is rejected;
- completion/rewards survive profile save/reload.

## Base regression package

Marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Observed focused results:

- Quest Definition Tests: 42;
- Adventure Eligibility: 47;
- Dark Elf Adventure: 23;
- Quest Service: 59;
- Profession Quest Integration: 27;
- Profession Economy Topology: 113;
- Profession Blueprint Acquisition: 33;
- Profession Gather Tier: 21;
- Base Environment Contract: 10;
- Base Adventure Board: 6.

## Dungeon regression package

Marker:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 4`

Observed:

- Checkpoint Service: 7;
- Completion Quest Bridge: 8;
- Checkpoint Quest Bridge: 9;
- Ruin Survey Integration: 19.

The ordinary Dungeon Play log also remained green across the existing released
Depth-1 combat/recovery/environment test surface while the focused package ran.

## Non-claims

This checkpoint does not claim:

- final quest dialogue/cinematics;
- final NPC/monster art;
- final Forest Wolf presentation;
- final Dwarf cavern presentation;
- released Depths 2-4;
- a production publish or main-branch merge.
