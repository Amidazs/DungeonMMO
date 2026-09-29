# DungeonMMO Roadmap v3.53 — Quest Journal + Persistent Tracker GREEN

**Date:** 29 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Feature source checkpoint:** `888018cb33ce7e5314a5b1cd3b8f66a68a67830d`  
**Status:** GREEN / published TEST cloud acceptance complete

## Goal

Keep accepted Adventure quests visible across Base and Dungeon travel, provide
a normal MMORPG-style quest journal, and let the player select exactly one
Adventure quest for Base navigation.

This replaces the temporary behavior where the first tutorial quest appeared
to vanish in the Dungeon and where Base navigation did not reliably resume
after returning or accepting a later quest.

## Accepted player behavior

- Active Adventure quests persist through Base/Dungeon handoff.
- A compact right-side tracker is available in both Base and Dungeon.
- Every active quest row shows its current objective lines and counts.
- Completed objective lines use a check mark.
- Ready quests show a return-to-giver instruction.
- The Quest Journal opens from **QUESTS** in the command menu or **L**.
- The journal shows accepted quests, objectives and configured rewards.
- Exactly one Adventure quest is selected as the tracked quest.
- Accepting a new Adventure automatically selects it for tracking.
- The player may select a different active Adventure in the journal/tracker.
- Class-advancement trials never steal the Adventure tracked slot.
- Completing the tracked quest clears its selection.
- A later accepted Adventure becomes the tracked quest automatically.

## Base navigation

The tracked quest alone controls the Base floor-flow guide.

- Incomplete Temple-oriented objectives guide toward the Temple route.
- Incomplete Mine-oriented objectives guide toward the Dwarf/Mine route.
- A ready quest guides back to its real physical quest giver.
- The first-time tutorial and persistent quest tracker use independent guide
  instances.
- The persistent guide is created lazily because Core client scripts may start
  before the sibling Base folder reaches `PlayerScripts`.

No floor guide is created in Dungeon.

## Architecture

### Persistent state

`QuestService` now owns `TrackedQuestId` inside the existing character
`Quests` state. The server validates that tracked ids are active Adventure
quests.

### Shared presentation

`QuestPresentation` owns readable objective labels, reward summaries, giver
lookup and Base navigation-target rules.

`QuestJournal.client.luau` lives in shared Core client code so the same
tracker/journal is available in Base and Dungeon.

### Dungeon access

`DungeonQuestRuntime` exposes only safe presentation actions:

- `Snapshot`
- `Track`

Dungeon still cannot start or claim Adventure quests through this runtime.

## Important regression fixes

During acceptance, adding a top-level `DungeonQuestRuntime` local pushed the
large Dungeon runtime beyond Luau's 200-local-register limit. The runtime was
changed to require/attach the module inline, restoring normal compilation.

A second issue was found in Base: the shared Core journal could initialize
before the sibling Base folder existed in `PlayerScripts`. Base guide creation
is now lazy, eliminating that race.

## Published TEST acceptance

TEST universe: `10765241947`

- Dungeon: `117293035754309`
- Base: `134132328219009`

Studio terminal publish states:

- Dungeon: `PublishSuccessful` at 00:16:31Z
- Base: `PublishSuccessful` at 00:18:26Z

Fresh cloud copies were opened after both successful publishes and contained
the final source markers.

Published Dungeon UI acceptance:

- tracker visible;
- multi-objective quest rendered both objective rows;
- completed row displayed a check mark;
- journal opened through the real **QUESTS** HUD button;
- no Base floor-guide object existed in Dungeon.

Published Base UI acceptance for ready `WorldrootRelic`:

- tracker visible;
- goal text: `Return to Worldroot Keeper`;
- physical giver found;
- quest guide existed with 48 visible route pieces;
- nearest route piece ended 1.80 studs from the giver.

## Release boundary

This is friend-test presentation/persistence work only. It does not begin
consolidated roadmap Section D.

**HOLD remains active:** do not begin Section D until the user completes the
two-player friend test and explicitly releases the hold.
