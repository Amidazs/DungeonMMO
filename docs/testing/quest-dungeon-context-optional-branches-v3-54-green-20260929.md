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

Relevant Dungeon tests were updated/extended, and a dedicated physical optional
bypass fixture was added.

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

## Physical Temple bypass proof

A disposable local Temple fixture forced both optional branches into the plan.

Materialised order:

`Room1,EventArena,Room2,SecretArena,Room3`

Observed runtime sequence:

1. Room 1 activated and cleared.
2. Event remained pending.
3. Player physically entered Room 2 without entering EventArena.
4. Runtime logged `ROOM2_STARTED_EVENT_SKIPPED`.
5. Event state persisted as `Skipped`.
6. Room 2 cleared.
7. Secret remained pending.
8. Player physically entered Room 3 without entering SecretArena.
9. Runtime logged `FINAL_STARTED_SECRET_SKIPPED`.
10. Secret state persisted as `Skipped`.
11. Final boss cleared and the session completed.
12. Fixture logged
    `PASS required route ignores side rooms` and
    `PLAY_MODE_PASS`.

## Dungeon entrance UI proof

The live local Base test used the actual
`Workspace.DungeonMMOEnvironmentAnchors.Base_TemplePortal.DungeonEntryPrompt`.

Prompt properties:

- enabled;
- keyboard key **E**;
- 0.15-second hold;
- 12-stud activation distance.

A held-E input opened the real `BaseUi.DungeonEntryPanel`.

With presentation-only active quests:

- tracked `MarauderCaptainBounty`;
- active `WorldrootRelic`;

the Depth-1 entrance displayed:

`◆ The Captain's Price — Defeat the Marauder Captain  0/1 — Depth 1 or Depth 4`

`• A Relic Beneath the World Tree — Clear the Temple  0/1 — Any unlocked depth`

The current build correctly displays unreleased Depth 2 as `Locked`.

For mismatch validation, a disposable quest targeting
`TestDungeon:EncounterStart:Depth2Combat1` was sent while Depth 1 remained
selected. The panel displayed:

`! Deeper into the Temple — Reach the Temple's inner approach  0/1 — Depth 2`

and:

`! Selected depth will not progress every quest shown.`

The normal Quest Journal polling LocalScript was disabled only in that
disposable local test copy to prevent the authoritative one-second snapshot
refresh from overwriting synthetic presentation data. Source-controlled and
published scripts were not altered for that isolation step.

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
   `PublishSuccessful` at 09:53:12Z.
2. Base `134132328219009`:
   `PublishSuccessful` at 09:53:49Z.

Studio also reported for each place:

`Place published. Friends and playtesters can now play this place in Roblox.`

## Fresh published-cloud verification

Fresh copies were opened after both publishes.

Normalised source equality against the current worktree returned true for:

Dungeon:

- `QuestPresentation`;
- `DungeonEncounterFlow`;
- `DungeonOptionalBossContent`;
- `DungeonOptionalEntranceGates`;
- `DungeonRuntime`.

Base:

- `QuestPresentation`;
- `BaseUi`.

Fresh Dungeon Play started normally and admitted the player with no v3.54
runtime/script failure.

A clean Base reopen was used after removing disposable local Studio sessions.
Fresh Base Play then started normally in Authored mode and loaded the player
profile with no v3.54 runtime/script failure.

## Result

**GREEN.**

The player can now see which accepted quests belong to the dungeon they are
about to enter and which depth can progress them. Optional Event and Secret
branches no longer block required room progression when skipped.

Section D remains held for the user's two-player friend test.
