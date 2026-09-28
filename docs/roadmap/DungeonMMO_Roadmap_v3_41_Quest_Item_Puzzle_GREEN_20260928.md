# DungeonMMO Roadmap v3.41
## Quest-Item Puzzle Adventure GREEN
**Date:** 28 September 2026

This checkpoint adds a real ordered dungeon puzzle on top of the v3.40 quest
variety foundation.

The goal is not to add another button-click counter. The server owns the rune
order, room prerequisites, quest-item requirement, shared puzzle state and the
completion event.

## New Adventure: The Resonant Seal

Quest ID: `TempleResonancePuzzle`.

- minimum level: **11**;
- prerequisite: **Survey the Broken Ways / RuinSurvey**;
- optional;
- released Temple Depth 1 only;
- collect one personal bound **Temple Resonance Shard** after Room 1 is safe;
- clear Room 2;
- use the shard while attuning the ordered rune lock;
- solve **Moon -> Root -> Flame**;
- turn the shard in;
- reward: **75 Gold + 1 Resonant Rune**.

This creates a level-11 non-combat-content beat between the level-10 Foreman
bounty and level-12 Follow the Fracture.

## New trusted puzzle boundary

New server-owned objective type:

`PuzzleCompleted`

The client cannot report puzzle completion.

`DungeonPuzzleService` validates:

- known puzzle ID;
- correct dungeon and difficulty;
- active connected session member;
- server-computed distance to the physical rune;
- required encounter state;
- active matching quest objective;
- possession of the required bound quest item;
- exact next rune in the server-owned sequence.

Wrong rune input resets the saved sequence to the first rune and increments the
server-owned reset counter.

Correct input advances one step.

Only the final correct input publishes `PuzzleCompleted`.

## Quest-item use

The puzzle requires the player to own:

`temple_resonance_shard`

The item is:

- personally collected;
- bound;
- non-tradeable;
- non-stackable;
- required by the puzzle;
- retained until Base quest turn-in;
- atomically consumed when the quest reward is claimed.

This avoids a cross-service partial-consumption problem inside the Dungeon
session while still making the item a genuine gameplay requirement rather than
a cosmetic counter.

## Party behavior

The rune lock itself is shared dungeon state.

One eligible party member with a shard may solve it.

Every connected party member with the matching active puzzle objective receives
the trusted `PuzzleCompleted` event.

However, personal item collection remains independent.

A party member who did not collect their own shard receives puzzle completion
but **does not become quest-ready** until they collect their personal shard.

This preserves shared-world cooperation without duplicating personal quest
items.

## Physical presentation contract

The current synthetic Temple now contains:

- `TempleResonanceShard`;
- `MoonRune`;
- `RootRune`;
- `FlameRune`.

The shard prompt remains disabled until CombatRoom1 is Cleared.

Rune prompts remain disabled until CombatRoom2 is Cleared.

The same stable names/attributes are mirrored in the replaceable placeholder
Temple path so final art can replace these parts without rewriting quest
authority.

## Existing quest-object generalization

`DungeonQuestObjectService` now supports both:

- interaction-gated collectibles, such as Hidden Ward Fragment;
- encounter-gated collectibles, such as Temple Resonance Shard.

The existing hidden-room denial reason and behavior remain unchanged.

## Fresh validation

Source head before documentation:

`b3a8ca09f7c7455795cbd40feae144210cfa44f9`

Static/build:

- `git diff --check aaf26b3c..HEAD`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Fresh Base Play:

`VERIFIED_QUEST_VARIETY_FOCUS_PASS 7`

The package now covers:

1. QuestDefinitionsTest;
2. AdventureEligibilityTest;
3. HiddenRoomQuestIntegrationTest;
4. LostSurveyorEscortIntegrationTest;
5. TempleResonancePuzzleIntegrationTest;
6. C4OriginalFirstTransferQuestArcsTest;
7. C4OriginalFirstTransferQuestStagesTest.

Broader Base regression:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Fresh live Temple presentation:

`VERIFIED_TEMPLE_RESONANCE_PRESENTATION_PASS 1`

Existing Dungeon checkpoint/adventure regression:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

## Puzzle integration coverage

The dedicated integration proves:

- shard collection fails before Room 1 clears;
- out-of-range collection fails;
- personal shard grant and ItemCollected progress are authoritative;
- rune interaction fails before Room 2 clears;
- a party member without the quest item cannot drive puzzle state;
- out-of-range rune interaction fails;
- wrong first rune resets;
- wrong later rune resets;
- reset count and next step persist in session state;
- Moon -> Root -> Flame completes;
- puzzle completion is shared to eligible quest owners;
- personal item objective remains personal;
- completed puzzle replay is idempotent;
- a second player may collect their shard after shared puzzle completion;
- turn-in consumes the shard;
- exact Gold + Resonant Rune reward is granted;
- completion and reward survive save/reload.

## Launch variety after v3.41

The launch catalogue now has real examples of:

- dungeon clear;
- enemy defeat;
- checkpoint exploration;
- mixed checkpoint + clear;
- world interaction;
- hidden-room discovery;
- personal quest-item collection;
- item turn-in;
- escort progression;
- ordered puzzle progression;
- required quest-item use;
- profession-aware rewards;
- multi-quest class advancement.

## Presentation status

The puzzle authority is real.

Still replaceable/pending:

- final rune models;
- final shard model;
- activation/reset/completion VFX;
- audio feedback;
- lore text explaining the sequence;
- quest-giver dialogue;
- journal presentation;
- broader environmental storytelling.

## Next development gate

The next genuinely different gameplay family is **Defend/Survive**.

That gate should:

1. use a server-owned defense target or survival timer;
2. use explicit success/failure rules;
3. reuse normal encounter authority rather than spawning untracked enemies;
4. persist/recover its state safely;
5. avoid frustrating escort-style instant failure;
6. add clear UI/audio feedback.

In parallel, begin stronger dialogue and narrative continuity around the accepted
Worldroot -> Mine -> Ruin Survey -> Resonant Seal / Fracture quest cluster.

Depths 2-4 remain release-disabled until their physical content is ready.
