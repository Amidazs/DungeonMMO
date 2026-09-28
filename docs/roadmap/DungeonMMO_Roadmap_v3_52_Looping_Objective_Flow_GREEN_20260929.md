# DungeonMMO Roadmap v3.52
## LOOPING OBJECTIVE-WARD TUTORIAL FLOW GREEN

**Date:** 29 September 2026

This checkpoint changes tutorial navigation from a player-progressing path into
a continuous directional-flow presentation.

## Intended behaviour

The tutorial target remains fixed.

The route source follows the player, but the directional effect has its own
independent animation phase. This means:

- standing still still shows arrows flowing toward the objective;
- walking forward does not cause arrow bunching;
- strafing left/right changes only the route shape;
- walking away lengthens the live lead-in without reversing the flow;
- arrows always travel toward the objective;
- local detours do not immediately rebuild the structural path;
- genuine larger route deviations can still trigger a reroute.

## Presentation

The accepted tracker now combines:

- a stable structural pathfinding corridor;
- a softly smoothed player-relative source position;
- a smoothed corridor join point;
- a faint neutral dotted route underlay;
- pooled three-part flow arrows;
- a constant objective-ward flow clock;
- source and target fade zones that hide the loop seam;
- shared slowly shifting iridescent arrow colour;
- per-frame collision-floor locking;
- preallocated marker/arrow pools.

## Why this replaces v3.51

v3.51 correctly moved the source with the player, but the presentation still
reacted too directly to player progress. Sideways and backwards movement could
make the first metres of the route visibly shift and the effect did not read
as a persistent directional stream.

v3.52 decouples visual flow from route progress. The route shape can update
while the arrow stream continues in one direction toward the objective.

## Authored acceptance

Controlled movement tests in the authored Base returned:

- stationary arrow motion over 0.25 seconds: approximately 1.73 studs;
- 5-stud sideways strafe peak underlay step: 0.300 stud;
- 12-stud walk-away peak underlay step: 0.518 stud;
- same marker instance retained: true;
- same arrow shaft instance retained: true;
- 74 pooled guide parts survive;
- 0 replacements;
- 0 floor misses.

## Published-cloud acceptance

TEST Base/start place: `134132328219009`.

A clean cloud reload was opened after all stale BaseTest sessions were closed.
The new cloud copy verified these source features directly:

- `ARROW_SPEED = 6.5`;
- `SOURCE_SMOOTH_SPEED = 12`;
- `ARROW_EDGE_FADE_DISTANCE = 4`;
- `REROUTE_DISTANCE = 14`;
- preallocated marker pool;
- collision-grounded NPC runtime retained.

Published-cloud movement acceptance:

- stationary flow motion: approximately 1.73 studs;
- sideways strafe peak: 0.293 stud;
- 12-stud walk-away peak: 0.528 stud;
- same marker instance: true;
- same flow-arrow shaft instance: true;
- 74/74 pooled guide parts survive;
- 0 replacements;
- 0 floor misses;
- maximum measured floor gap during walk-away test: 0.238 stud.

## Publishing lesson

Roblox Studio can keep an open script editor buffer separate from the
underlying `LuaSourceContainer.Source`.

During this checkpoint, the authored runtime contained the correct v3.52
source while fresh cloud copies repeatedly contained the older tracker.
The publish path was corrected by:

1. synchronizing `TutorialPathGuide` through
   `ScriptEditorService:UpdateSourceAsync()`;
2. verifying `ScriptEditorService:GetEditorSource()`;
3. closing the script document;
4. verifying the underlying `Script.Source`;
5. publishing only after both representations matched;
6. reopening a clean cloud copy and verifying the published source.

Future Studio synchronization should use this method when a target script may
already be open in the editor.

## Source checkpoint

Gameplay source checkpoint before this documentation:

`b5e403ec9779e66dfa4b22d5e7075b8103afe3b7`

Build checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS;
- authored movement tests: PASS;
- fresh published-cloud source verification: PASS;
- fresh published-cloud movement tests: PASS.

## HOLD

**Section D remains on hold.**

World boss, raid, territory, castle and PvP work must not resume until the
owner completes the two-player friend test and explicitly releases the hold.
