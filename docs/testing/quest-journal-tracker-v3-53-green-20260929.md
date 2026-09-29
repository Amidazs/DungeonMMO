# Quest Journal + Persistent Tracker v3.53 — GREEN

**Date:** 29 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Feature source checkpoint:** `888018cb33ce7e5314a5b1cd3b8f66a68a67830d`

## Scope

This acceptance covers the user-requested Adventure quest journal, persistent
single-quest tracking, cross-place quest visibility and Base-only navigation.

No production place, production DataStore, Robux or monetisation setting was
changed.

## Source/build checks

Fresh checks passed:

- `git diff --check`;
- `base.project.json`;
- `published-base.project.json`;
- `published-dungeon.project.json`.

## Quest service contract

A disposable in-memory profile verified:

- Adventure start succeeds;
- accepted Adventure auto-tracks;
- inactive quest tracking is rejected;
- trusted Dungeon event advances the objective;
- ready state is reached;
- turn-in succeeds;
- tracked selection clears on turn-in;
- next accepted Adventure auto-tracks.

A separate level-20 Mage fixture verified that starting
`MageAdvancementTrial` does not replace the tracked
`WorldrootRelic` Adventure.

## Base presentation acceptance

Synthetic presentation-only snapshots were used; no saved player quest state
was modified.

Incomplete `WorldrootRelic`:

- tracker showed `Clear the Temple  0/1`;
- Base quest guide existed;
- 71 visible guide pieces were produced toward the Temple route.

Ready `WorldrootRelic`:

- tracker showed `Return to Worldroot Keeper`;
- floor guidance redirected to the physical giver.

The lazy Base-guide initialization fix was required because Core scripts can
start before the sibling Base folder reaches `PlayerScripts`.

## Dungeon presentation acceptance

The Dungeon runtime successfully answered a normal
`QuestActionRequest("Snapshot")` with the 13 Adventure definitions and
server-owned quest state.

A multi-objective `HiddenWardDiscovery` snapshot rendered:

- `✓  Activate the faded Temple panel  1/1`;
- `•  Collect the Hidden Ward Fragment  0/1`.

The Quest Journal contained the active quest and opened through the actual
**QUESTS** command-menu button.

No `DungeonMMOQuestTrackingGuide` or tutorial floor guide was created in
Dungeon.

## Luau register regression

Initial Dungeon integration produced:

`Out of local registers when trying to allocate player: exceeded limit 200`

The new runtime import was changed from a top-level local to an inline
require/attach. The subsequent Dungeon Play startup completed normally.

## TEST publication

The first interrupted publication attempt was not accepted. Studio logs showed
both places were killed while still in `PublishInProgress`.

The corrected sequence published Dungeon first and waited for terminal state:

- Dungeon `PublishSuccessful`: 00:16:31Z;
- Base `PublishSuccessful`: 00:18:26Z.

Studio also reported for both places:

`Place published. Friends and playtesters can now play this place in Roblox.`

Fresh cloud sessions were then opened from the published place ids.

## Fresh published-cloud verification

Dungeon `117293035754309`:

- final QuestService tracking marker present;
- `DungeonQuestRuntime` present and attached;
- Quest Journal and QUESTS button present;
- fresh Play admitted the player normally;
- published UI check showed both multi-objective rows;
- journal opened from the real button;
- no floor guide existed.

Base `134132328219009`:

- final QuestService tracking marker present;
- Base Track action present;
- Quest Journal, lazy guide and QUESTS button present;
- fresh Play started normally;
- ready quest displayed `Return to Worldroot Keeper`;
- physical giver existed;
- published route contained 48 visible pieces;
- nearest guide piece was 1.80 studs from the giver.

## Result

**GREEN.**

The quest no longer disappears conceptually when entering a Dungeon: persistent
server quest state is available there and the right-side tracker/journal remain
visible. Base navigation resumes from the selected tracked quest and switches
to the correct hand-in giver when ready.

Section D remains held for the user's two-player friend test.
