# DungeonMMO Roadmap v3.46
## SECTION D READY — USER PLAYTEST HOLD
**Date:** 28 September 2026

This is the formal boundary requested by the user.

**Do not begin Section D implementation until the user completes their manual
playtest and explicitly says to continue.**

## Current roadmap position

The consolidated roadmap sequence is:

- A — close the core Dungeon slice;
- B — expand player progression and launch content;
- C — expand gathering/crafting/economy into a game loop;
- **D — complete weekly-boss/raid gameplay, then guild competition**;
- E — retention, tuning and release readiness.

DungeonMMO is now parked immediately before **D**.

## A status

The ordinary Dungeon/session/combat/reward foundation is accepted and is no
longer an open framework-building programme.

## B status

The initial launch progression/content slice now includes:

- level-30 first-transfer class/skill backend;
- all 18 first-transfer branches;
- three player-facing advancement quests per branch;
- varied Adventure objective families;
- level 1-20 launch Adventure pacing;
- dialogue/narrative continuity;
- physical quest-giver presentation;
- visible Dungeon quest feedback.

Final art is not required to enter D.

## C status

The launch profession/economy loop is sufficiently accepted to move to D
without inventing another economy framework.

Accepted evidence already includes:

- exclusive ordinary and Dwarf specialist profession capacity;
- gathering level gates;
- level 3-5 cross-profession component ladder;
- real four-player market dependency through Masterwork Frame;
- Gearwright premium economy;
- Deepclaimer salvage supply;
- blueprint drop -> trade -> learn -> craft;
- live animal-only Dungeon Skinning;
- quest reward -> market -> profession use.

Still open but non-blocking for the D boundary:

- final profession station/resource art;
- final crafting minigames;
- final economy tuning/drop percentages;
- wider recipe/content breadth.

Those remain presentation/tuning/content backlog rather than missing authority.

## Final pre-D presentation gates

### v3.44 Physical Quest Givers — GREEN

Eight physical quest-giver roles cover all 13 current Adventures and reuse the
same trusted dialogue/quest backend.

### v3.45 Dungeon Quest Feedback — GREEN

The hidden-room tutorial, Mine escort, Resonant Seal puzzle and Resonance Ward
defense now expose readable in-world state feedback.

## Final automated acceptance at the hold

Source head before this documentation:

`d6b40941395bd52b379e8a68ef46ce0da0c7c8de`

Accepted markers:

- BaseRuntime compile: PASS;
- DungeonRuntime compile: PASS;
- `VERIFIED_QUEST_VARIETY_FOCUS_PASS 10`;
- `VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 11`;
- `VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 6`;
- `VERIFIED_PHYSICAL_QUEST_GIVER_DIALOGUE_PASS 1`;
- `VERIFIED_LIVE_TEMPLE_QUEST_FEEDBACK_PASS 3`;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- git diff check: PASS.

## Manual gate

Use:

`docs/testing/pre-section-d-user-playtest-checklist-20260928.md`

The user should test the current slice and report blockers before Section D
starts.

## What Section D will be when released

The first D milestone is **not** castle PvP.

It will resume the existing default-off weekly world-boss foundation and close
the representative real four-player encounter gate:

1. real party roles;
2. boss mechanics/skills;
3. four-player normal-combat completion;
4. wipe/recovery/reward confidence.

Only after that should raid rooms/puzzles become the next bounded content
system. Guild competition/castle PvP follows after explicit rules for
eligibility, ownership, scoring, cooldowns, reconnect and duplicate rewards.

## HOLD

**STOP HERE.**

No new world-boss, raid, guild-competition, territory or castle/PvP source work
is authorized until the user says the manual pre-D test is complete.
