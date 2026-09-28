# DungeonMMO Roadmap v3.42
## Defend / Survive Adventure GREEN
**Date:** 28 September 2026

This checkpoint accepts the first server-owned Defend/Survive Adventure and
completes the initial quest-variety expansion requested after v3.39.

## New optional Adventure

**Hold the Resonance**

- quest ID: `TempleWardDefense`;
- minimum level: **13**;
- prerequisite: **The Resonant Seal / TempleResonancePuzzle**;
- released content only: Temple Depth 1;
- trusted objective: `DefenseCompleted`;
- target: `TestDungeon:ResonanceWard:Room2`;
- reward: **85 Gold + 1 Warding Essence**.

## Defend / Survive rules

The Temple Resonance Ward uses server-owned state and server-measured player
positions.

The accepted contract is:

1. Room 1 must already be cleared before the defense can start;
2. the player must start from the real ward prompt and be within 10 studs;
3. at least one active party member must remain inside an 18-stud ward zone;
4. a brief absence is tolerated for up to 3 seconds;
5. leaving the ward beyond that grace window resets the defense rather than
   auto-completing or permanently failing the quest;
6. the party can restart after a reset;
7. the objective completes only after the normal Room-2 encounter reaches its
   genuine cleared state while the defense is active;
8. completion is shared with active party members who actually own the quest;
9. duplicate heartbeats and completion replays remain idempotent.

This changes the player's combat priority without creating a second fake combat
system: the ordinary Room-2 encounter remains authoritative, but players now
also have a positional protection objective.

## Quest-variety foundation now available

Accepted trusted launch objective families now include:

- `DungeonClear`;
- `EnemyDefeat`;
- `CheckpointReached`;
- `WorldInteraction`;
- `ItemCollected`;
- `EscortCompleted`;
- `PuzzleCompleted`;
- `DefenseCompleted`.

The currently accepted varied Adventures include:

- **Whispers Behind the Stone** — hidden mechanism + personal quest item;
- **Guide the Lost Surveyor** — server-owned escort with safe pauses;
- **The Resonant Seal** — bound quest shard + ordered Moon/Root/Flame puzzle;
- **Hold the Resonance** — positional defend/survive objective.

## First-transfer advancement remains multi-quest

All **18** mapped first-transfer branches continue to expose exactly **three
player-facing quests** over their existing branch-specific trusted source
ledgers:

1. The Call;
2. Field Trial;
3. Final Proof.

This checkpoint does not revert to the old one-clear advancement prototype.

## Runtime compile regression found and fixed

During live defense presentation validation, `DungeonRuntime.server.luau`
crossed Luau's local-register ceiling and failed the compile probe with:

`Out of local registers ... exceeded limit 200`.

The defense runtime dependency was moved to lazy loading below the crowded
top-level local allocation area.

The exact same compile probe then returned:

`compileOk=true`.

This is part of v3.42 acceptance and should remain a regression concern as more
Dungeon systems are added.

## Fresh validation

Source head before documentation:

`1509ff65b785827670c72e42407ea9b064e1a203`

Static/build checks:

- `git diff --check 13422ba9..HEAD`: PASS;
- current Base Rojo build: PASS;
- current Dungeon Rojo build: PASS;
- DungeonRuntime compile probe: PASS.

Fresh unpublished Base Play:

`VERIFIED_QUEST_VARIETY_FOCUS_PASS 8`

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Fresh unpublished Dungeon Play:

`VERIFIED_TEMPLE_WARD_DEFENSE_PRESENTATION_PASS 1`

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

## What is GREEN

- level-13 eligibility and Resonant Seal prerequisite;
- trusted defense start distance;
- Room-1 start gate;
- server-measured holder positions;
- 18-stud defense zone;
- 3-second grace window;
- reset/restart lifecycle;
- Room-2 clear as the real completion condition;
- shared party quest completion;
- replay/idempotency protection;
- one-time quest reward;
- save/reload persistence;
- synthetic Temple ward presentation;
- replaceable blockout ward presentation;
- current DungeonRuntime compile viability;
- existing quest/profession/checkpoint regressions.

## Placeholder / presentation status

The defense logic is real. Presentation remains replaceable.

Current visible ward and quest presentation are still blockout-quality and may
later be replaced with final:

- ward model;
- VFX;
- encounter warnings;
- NPC dialogue;
- objective callouts;
- sound;
- environmental storytelling.

The server contract should remain unchanged when final art replaces the
placeholder presentation.

## Next development gate

The quest system now has enough mechanical variety for the first launch slice.

The next priority should shift toward **quest presentation and narrative
continuity**:

1. connect Worldroot, Mine Echoes, Ruin Survey, Resonant Seal, Follow the
   Fracture and Hold the Resonance with real dialogue;
2. add reusable NPC dialogue/quest-conversation presentation;
3. give quest starts, progress and turn-ins stronger player-facing feedback;
4. continue using the varied objective families where appropriate instead of
   adding mechanics only for novelty;
5. begin replacing high-impact placeholder NPC/enemy/quest presentation;
6. keep Depths 2-4 release-disabled until their physical content is ready.
