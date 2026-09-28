# DungeonMMO Roadmap v3.45
## Visible Dungeon Quest Feedback GREEN
**Date:** 28 September 2026

This checkpoint closes the final presentation gate immediately before roadmap
Section D.

No new objective family is introduced. The existing trusted mechanics now
surface readable world-state feedback during play.

## Hidden-room tutorial feedback

Temple Depth 1 now explains the deterministic tutorial secret in-world.

After Room 1 is safe, the faded panel displays that it can reveal a hidden
passage.

After activation, the same surface reports:

**Hidden passage revealed**

The hidden-room authority remains the accepted `WorldInteraction` and
`ItemCollected` server path.

## Resonant Seal feedback

The Temple puzzle now displays context over the real Moon Rune.

Before Room 2 is clear it explains that:

- a Resonance Shard can be recovered;
- Room 2 must be secured before rune attunement.

Once usable it displays:

- the reviewed Moon -> Root -> Flame order;
- the next expected rune.

Completion displays that the Resonant Seal has been restored.

A live inspection caught and fixed one presentation-only mismatch:
the real physical IDs are `MoonRune`, `RootRune`, and `FlameRune`.
The feedback runtime and its focused test now use those real IDs.

## Defend/survive feedback

The Resonance Ward now reports:

- ready state;
- active HOLD THE RESONANCE WARD state;
- 18-stud stay-near instruction;
- RETURN TO THE WARD warning during the 3-second grace period;
- reset/restart state;
- stabilised completion state.

The defense service remains authoritative.

## Escort feedback

The Lost Surveyor now reports:

- Talk to begin escort;
- escort active / stay nearby;
- waiting for Room 2 to be secured;
- route clear / stay nearby;
- Surveyor safe.

The existing escort service and safe-pause movement remain authoritative.

## Fresh validation

Final pre-documentation source head:

`d6b40941395bd52b379e8a68ef46ce0da0c7c8de`

Fresh current-head checks:

- `git diff --check 62df8aa0..HEAD`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- BaseRuntime compile probe: PASS;
- DungeonRuntime compile probe: PASS;
- `VERIFIED_QUEST_VARIETY_FOCUS_PASS 10`;
- `VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 11`;
- `VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 6`;
- `VERIFIED_PHYSICAL_QUEST_GIVER_DIALOGUE_PASS 1`;
- `VERIFIED_LIVE_TEMPLE_QUEST_FEEDBACK_PASS 3`.

## Focused feedback contract

`DungeonQuestFeedbackRuntimeTest` independently proves state transitions for:

- hidden-panel tutorial;
- Resonance Shard prerequisite message;
- next ordered puzzle rune;
- defense ready state;
- defense grace danger;
- Mine escort safe pause.

## What is GREEN

- hidden-room in-world guidance;
- puzzle prerequisite/order/next-step guidance;
- defense ready/hold/grace/reset/completion guidance;
- escort start/movement/wait/completion guidance;
- existing gameplay authority untouched;
- synthetic and replaceable presentation layering.

## Next gate

**STOP before Section D.**

The project is ready for the user's manual pre-D playtest. World boss, raid and
PvP/castle implementation must not advance until that playtest is reviewed.
