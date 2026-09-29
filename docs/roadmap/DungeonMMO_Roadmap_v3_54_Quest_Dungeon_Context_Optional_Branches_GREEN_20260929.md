# DungeonMMO Roadmap v3.54 — Quest Dungeon Context + Optional Branches GREEN

**Date:** 29 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Feature source checkpoint:** `7cfb19a64aa6680de318827b54791c015a0794cf`  
**Status:** GREEN / published TEST cloud acceptance complete

## Goal

Resolve two friend-test issues without entering consolidated roadmap Section D:

1. tell players which dungeon and difficulty can progress their accepted
   Adventure quests before they launch;
2. ensure Event and Secret side rooms are genuinely optional and never block
   the required dungeon route.

## Dungeon entrance quest context

The Base dungeon entrance panel now includes a **QUEST OBJECTIVES HERE** card.

For the currently opened physical dungeon entrance it shows active,
incomplete Adventure objectives that can be progressed there. The tracked
quest is ordered first and marked with `◆`.

Each line includes:

- quest name;
- current objective text and progress;
- eligible depth or `Any unlocked depth`.

Example accepted output from the Temple entrance:

`◆ The Captain's Price — Defeat the Marauder Captain  0/1 — Depth 1 or Depth 4`

`• A Relic Beneath the World Tree — Clear the Temple  0/1 — Any unlocked depth`

The picker warns when the selected depth cannot progress every displayed quest:

`! Selected depth will not progress every quest shown.`

The quest/dungeon resolver understands:

- dungeon-clear objectives;
- known Depth-1 dungeon item/creature targets;
- checkpoint targets expressed as
  `<DungeonId>:EncounterStart:<RuntimeEncounterId>`;
- boss quest aliases such as `marauder_captain` and
  `corrupted_foreman`;
- dungeon-prefixed world-object objectives.

## Optional dungeon branches

Event and Secret side encounters now both use
`CompletionRequired = false`.

When a required successor room is entered while an optional side encounter is
still pending, the authoritative encounter flow persists that side encounter as
`Skipped` and starts the required room.

This applies to Event boss, Event combat and Secret boss side content.

Secret-specific deferred/backtracking behavior remains distinct: a skipped
Secret can still use the existing Secret backtracking contract where
applicable. A skipped timed Event is forfeited for that run instead of
remaining restartable.

The optional entrance-gate runtime also recognises `Skipped` state so a
forfeited Event branch does not remain presented as an active progression
requirement.

## Authoritative acceptance

A disposable unpublished Temple fixture materialised:

`Room1, EventArena, Room2, SecretArena, Room3`

The final fixture used an unpublished-only bridge to the exact
`start_executed_slot()` server function called by the production room trigger,
because Studio automation did not reliably synthesize `Touched` contact. It
proved:

- Room 1 started and cleared;
- EventArena remained pending and was not entered;
- starting Room 2 persisted the Event as `Skipped` and started Room 2;
- Room 2 cleared;
- SecretArena remained pending and was not entered;
- starting Room 3 persisted the Secret as `Skipped` and started the final
  required boss;
- the run completed successfully;
- skipped Secret content did not count as discovered.

## Base UI acceptance

A disposable local Base run used the actual `BaseUi.DungeonEntryPanel` at the
real Temple entrance anchor. Because synthetic prompt keyboard input was
unreliable, an unpublished-only bridge called the existing
`open_from_entrance()` function; the player remained within the normal
entrance-distance guard.

At Depth 1 the quest card rendered the tracked Hidden Ward objective as
`Depth 1` and the Worldroot dungeon-clear objective as `Any unlocked depth`.
Switching the same live panel to Depth 2 changed the incompatible quest marker
to `!` and displayed the selected-depth mismatch warning.

Direct mapping checks also verified Captain and Foreman bounties as
`Depth 1 or Depth 4`. No saved player quest state was modified and no temporary
bridge was published.

## Build and regression status

Fresh Rojo builds pass for:

- `base.project.json`;
- `default.project.json`;
- `published-base.project.json`;
- `published-dungeon.project.json`.

The initial full Dungeon regression identified two old assertions that still
encoded the previous rule that a triggered Event was mandatory. Those tests
were updated to the new optional contract. The rerun completed without those
failures, including the new optional-flow coverage.

## Published TEST acceptance

TEST universe: `10765241947`

- Dungeon: `117293035754309`
- Base: `134132328219009`

Studio terminal publish states:

- Dungeon: `PublishSuccessful` at 10:59:14Z;
- Base: `PublishSuccessful` at 10:59:59Z.

Fresh cloud copies were reopened after publication.

Fresh cloud verification confirmed the v3.54 source markers, quest/depth
mapping and absence of unpublished test hooks in the correct place IDs.

Fresh published Dungeon Play:

- Synthetic TestDungeon runtime started;
- player admitted normally;
- no v3.54 runtime/script error.

Fresh published Base Play:

- authored Base environment started;
- profile lifecycle loaded normally;
- no v3.54 runtime/script error.

## Release boundary

This remains pre-Section-D friend-test work.

**HOLD remains active:** do not begin Section D until the user completes the
two-player friend test and explicitly releases the hold.
