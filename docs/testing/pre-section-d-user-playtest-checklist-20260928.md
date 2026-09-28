# DungeonMMO Pre-Section-D User Playtest Checklist
**Date:** 28 September 2026

## Friend test setup

The TEST experience is published and intentionally non-public.

- TEST Base/start place: `134132328219009`;
- TEST Dungeon place: `117293035754309`;
- audience: **Limited**;
- **Friends**: enabled;
- **Playtesters**: enabled;
- **Public**: disabled.

Start-place link:

`https://www.roblox.com/games/134132328219009`

For the cleanest two-player test:

1. make sure both Roblox accounts are friends with the TEST experience owner;
2. both players open the TEST Base;
3. if Roblox places you in different Base servers, one player should use the
   normal Roblox **Join Friend** flow;
4. at the Temple entrance, one player chooses **Create Party**;
5. the leader invites the other player;
6. the second player accepts;
7. both players set **Ready**;
8. the leader selects **Depth 1** and starts the dungeon;
9. confirm both players arrive in the same reserved Dungeon session;
10. after completion or wipe, confirm both can return to Base.

A fresh account should also exercise the guided tutorial from the beginning.
The owner may already have test progression that causes some first-time
tutorial gates to be skipped.

This is the manual hold point before world-boss/raid/PvP work.

The purpose is not to re-prove every backend unit test. It is to confirm that
the current game slice feels understandable and playable from a real player's
view.

## 1. Base / quest presentation

Check the Adventure Board:

- open and close it normally;
- Start Quest opens dialogue before acceptance;
- active quest Review shows useful context;
- ready quest shows turn-in dialogue before reward;
- successful turn-in shows completion dialogue;
- walking away closes the contextual window.

Check physical quest givers:

- each has a Talk prompt;
- speaker role is understandable;
- talking opens the same conversation UI;
- the correct quest/story is offered for current character state;
- walking away closes the NPC conversation rather than measuring from the
  Adventure Board.

Expected placeholder debt:

- quest-giver bodies are blockout placeholders;
- final NPC models/names/animations are not required for this test.

## 2. Temple Depth 1

### Hidden-room tutorial

With Whispers Behind the Stone active:

1. clear Room 1;
2. confirm the faded-panel feedback appears;
3. activate the panel;
4. confirm the hidden passage opens;
5. enter the alcove;
6. collect the Hidden Ward Fragment;
7. return and complete the Adventure.

Pay attention to whether this successfully teaches:
**some dungeon walls/rooms can be hidden**.

### Resonant Seal

With The Resonant Seal active:

1. recover the Resonance Shard after Room 1;
2. clear Room 2;
3. inspect the rune feedback;
4. intentionally press a wrong rune once and confirm the sequence resets;
5. enter Moon -> Root -> Flame;
6. confirm completion/turn-in behaves normally.

### Hold the Resonance

With Hold the Resonance active:

1. clear Room 1;
2. activate the ward;
3. remain inside the ward and confirm the HOLD feedback;
4. briefly leave and return before 3 seconds;
5. leave for longer than 3 seconds and confirm reset;
6. restart;
7. complete Room 2 while holding the ward;
8. confirm the quest becomes ready.

### Combat / Skinning spot check

- Forest Wolf and Marauder remain distinct Room-1 enemies;
- only the beast is skinnable;
- no duplicate Skinning reward;
- combat/aggro/Taunt still feels normal.

## 3. Abandoned Mine Depth 1

### Lost Surveyor

With Guide the Lost Surveyor active:

1. clear Room 1;
2. talk to the Lost Surveyor;
3. check that the escort moves at a sensible running pace;
4. move away and confirm it does not blindly disappear ahead;
5. reach the Room-2 safe pause;
6. confirm feedback says Room 2 must be secured;
7. clear Room 2;
8. confirm the Surveyor resumes and reaches safety;
9. confirm the Adventure completes.

Also confirm the Corrupted Foreman encounter and ordinary Mine clear still
behave normally.

## 4. Advancement

Using any convenient first-transfer test character:

- choose a branch;
- confirm progression is presented as Quest 1/3, Quest 2/3, Quest 3/3;
- confirm the branch-specific objectives still drive progress;
- confirm it does not collapse into one generic dungeon-clear trial.

You do not need to manually exhaust all 18 branches in this playtest unless you
want to; automated coverage already validates the 18 x three-quest mapping.

## 5. Profession/economy spot check

The pre-D boundary relies on the already-green Section-C launch loop.

Spot-check whichever professions are convenient:

- 1 gathering + 1 crafting restriction for ordinary characters;
- market listing/buying;
- cross-profession material use;
- blueprint learning if convenient;
- profession-aware quest materials remain tradeable.

Gearwright/Deepclaimer specialist capacity and the complete four-player market
chain already have automated acceptance; this manual pass is about UX
regressions, not re-proving every transaction.

## 6. UI / presentation regressions

Watch for:

- overlapping windows;
- windows that cannot close;
- dialogue reopening unexpectedly;
- prompts remaining enabled after an objective completes;
- incorrect quest text for the NPC being spoken to;
- stale feedback after reset/completion;
- obvious movement/animation regressions;
- rewards granted twice;
- quests becoming ready too early.

## Known non-blocking placeholder debt

Do not treat these alone as Section-D blockers:

- final quest-giver NPC art;
- final Forest Wolf presentation;
- final Dwarf cavern/NPC art;
- final crafting minigames;
- final VFX/audio/cinematics;
- final Depths 2-4 physical content.

Report actual gameplay failures separately from presentation that is knowingly
placeholder.

## Section D hold rule

After this checklist, report what worked and what failed.

**Do not begin world-boss, raid, guild-competition or castle/PvP work until the
user explicitly releases this hold.**
