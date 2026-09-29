# Quest Dungeon Context + Optional Branches v3.54 — GREEN

**Date:** 29 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Feature source checkpoint:** `7cfb19a64aa6680de318827b54791c015a0794cf`

## Scope

This acceptance covers:

- quest-to-dungeon/depth presentation at Base dungeon entrances;
- optional Event/Secret side-room progression;
- regression protection for skipping side content;
- TEST publication and fresh-cloud verification.

No production place, production DataStore, monetisation setting or Robux flow
was changed.

## Source delta from v3.53

Runtime/client changes:

- `QuestPresentation.luau`;
- `BaseUi.client.luau`;
- `DungeonEncounterFlow.luau`;
- `DungeonOptionalBossContent.luau`;
- `DungeonOptionalEntranceGates.luau`;
- `DungeonRuntime.server.luau`.

Relevant Dungeon tests were updated/extended, and a dedicated authoritative
optional-bypass fixture was added.

## Optional branch contract

Event and Secret definitions now materialise with
`CompletionRequired = false`.

`DungeonEncounterFlow:skip_optional_before()` validates that:

1. the pending encounter is optional;
2. the physical room being entered is its direct required successor;
3. the authoritative controller persists the skip.

`DungeonRuntime` uses that generic bypass for pending:

- `EventBoss`;
- `EventCombat`;
- `SecretBoss`.

Secret-specific `skip_secret_before()` remains for compatibility with
deferred Secret backtracking.

## Full Dungeon regression

The first regression run caught two stale tests:

- `DungeonOptionalBossPolicyTest` expected a triggered Event to be
  completion-required;
- `DungeonOptionalTimedEventRecoveryTest` expected recovered Event and Secret
  roles to differ by completion requirement.

Both assertions represented the old behavior and were updated to the accepted
optional-side-room contract.

Subsequent regression output included:

- Optional Boss Flow: PASS;
- Dungeon Encounter Flow: PASS;
- Dungeon Encounter Sequencer: PASS;
- Optional Depth Event: PASS;
- Optional Entrance Gates: PASS;
- Optional Dynamic Variant: PASS;
- Timed Event Recovery: corrected to optional semantics.

## Authoritative Temple bypass proof

A disposable local Temple fixture forced both optional branches into the plan.
Studio automation could not reliably synthesize Roblox `Touched` contact, so
the final fixture injected an unpublished-only bridge to the exact
`start_executed_slot(room_slot_id)` server function called by the production
room triggers. This preserves the authoritative encounter-start, skip,
checkpoint, executor and persistence path without claiming a synthetic physics
contact occurred.

Materialised order:

`Room1,EventArena,Room2,SecretArena,Room3`

Observed runtime sequence:

1. Room 1 activated and cleared.
2. Event remained pending.
3. The production Room-2 start path was invoked without entering EventArena.
4. Runtime logged `ROOM2_STARTED_EVENT_SKIPPED`.
5. Event state persisted as `Skipped`.
6. Room 2 cleared.
7. Secret remained pending.
8. The production Room-3 start path was invoked without entering SecretArena.
9. Runtime logged `FINAL_STARTED_SECRET_SKIPPED`.
10. Secret state persisted as `Skipped`.
11. Final boss cleared and the session completed.
12. Fixture logged
    `PASS required route ignores side rooms` and
    `PLAY_MODE_PASS`.

## Dungeon entrance UI proof

The final local Base UI acceptance used the real Temple entrance anchor and
the actual `BaseUi.DungeonEntryPanel`. An unpublished-only `BindableFunction`
bridge called the existing `open_from_entrance()` function because synthetic
ProximityPrompt keyboard input was unreliable in Studio automation. The test
character was positioned 3.62 studs from the real Temple entrance so the
normal 15-stud distance guard remained active.

With presentation-only active quests, Depth 1 rendered:

`◆ Whispers Behind the Stone — Activate the faded Temple panel  0/1  +1 more — Depth 1`

`• A Relic Beneath the World Tree — Clear the Temple  0/1 — Any unlocked depth`

and the tracked marker hint:

`◆ = tracked quest`

The same live panel was then switched to Depth 2. The Depth-1-only quest
changed to `!` and the panel rendered:

`! Selected depth will not progress every quest shown.`

Direct built-DataModel mapping checks also verified:

- Marauder Captain bounty: `Depth 1 or Depth 4`;
- Corrupted Foreman bounty: `Depth 1 or Depth 4`;
- Hidden-panel tutorial objective: `Depth 1`;
- Ruin Survey Temple checkpoint: `Depth 1`;
- Worldroot dungeon clear: `Any unlocked depth`.

No temporary UI bridge exists in source-controlled or published code.

## Build verification

`git diff --check` passed.

Rojo builds passed:

- `base.project.json`;
- `default.project.json`;
- `published-base.project.json`;
- `published-dungeon.project.json`.

## TEST publication

Final TEST publish order and terminal states:

1. Dungeon `117293035754309`:
   `PublishSuccessful` at 10:59:14Z.
2. Base `134132328219009`:
   `PublishSuccessful` at 10:59:59Z.

Studio also reported for each place:

`Place published. Friends and playtesters can now play this place in Roblox.`

## Fresh published-cloud verification

Fresh copies were opened after both publishes.

Fresh published source verification confirmed the new quest/depth mapping,
picker warning, optional-event flag and Event/Secret bypass markers in the
correct place IDs. The Base copy also confirmed that no `DMMOTemp` test hooks
were published.

Fresh Dungeon Play started normally in Synthetic TestDungeon mode, admitted
the player and reached `Enter Room1 to continue the dungeon` with no v3.54
runtime/script failure.

Fresh Base Play started normally in Authored mode, loaded the player profile
and reported the TestDungeon entry runtime ready with no v3.54 runtime/script
failure.

## Result

**GREEN.**

The player can now see which accepted quests belong to the dungeon they are
about to enter and which depth can progress them. Optional Event and Secret
branches no longer block required room progression when skipped.

Section D remains held for the user's two-player friend test.
