# Phase 4 — persisted optional dungeon session recovery

Date: 20 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Scope

GitHub-first test-only changes on the existing integration branch.
No new recovery implementation, production runtime modification, authored
asset change, TEST/PROD cloud publish or player DataStore mutation.
The existing Temple placeholder and in-memory test adapters were reused.

Added
`src/ServerScriptService/Dungeon/Tests/DungeonOptionalFullSessionRecoveryTest.server.luau`
and registered it with
`scripts/studio/optional_boss_focused_tests.luau`.

## Persisted-session re-creation — PASS

The new test exercises the real DungeonSessionService,
DungeonEncounterRuntimeController, DungeonEncounterFlow,
DungeonOptionalEntranceGates and RewardService with two members,
separately instantiated session/controller services and a shared
in-memory persistence adapter. It verifies:

- An Active Event becomes Pending after a newly constructed controller
  recovers an interrupted server, while Room1 remains Cleared.
- The last checkpoint, both party members' independent Connected states,
  the original frozen Event/Secret eligibility and Event window survive.
- Event's entrance is open but Secret's stays physically closed before
  the restored Room2 prerequisite; double Event start is rejected.
- The same saved member is marked reconnected without disconnecting the
  still-connected peer, and recovered Event/Room2 can be cleared once.
- Room2 opens the eligible Secret entrance. Skipping Secret and
  interrupting Final preserves previously cleared rooms, Final Pending
  and deferred Secret's backtracking eligibility.
- Interrupting the deferred Secret itself resets it to Skipped without
  rewinding the main route; one Secret replay and clear succeeds, a
  duplicate replay fails, and Final then completes.
- Two member profiles and their boss-reward history survive reconstruction
  of an independent ProfileService and RewardService; the same Event
  reward transaction is not granted twice.

The fresh unpublished Dungeon composition built successfully with
`rojo build default.project.json`. Studio log:
`0.739.0.7390687_20260920T165335Z_Studio_7F703_last.log`
reports `[Optional Full Recovery Tests] PASS: 42 assertions.`
and `[Optional Boss Studio Focus] PASS: 15 edit-mode suites.`

## Physical placeholder regression — PASS

The existing assisted Temple playable-route fixture was rerun on the
same new Dungeon build. Studio log:
`0.739.0.7390687_20260920T165423Z_Studio_31E77_last.log`
records `BACKTRACK_SECRET_CLEARED_MAIN_ROUTE_INTACT` and
`TEMPLE_FIGHT_PLACEHOLDER_PLAY_PASS`. The test fixture assists combat.
It verifies the local placeholder route still works after the test-only
changes; it does not recreate a live server process.

## Limits and next gate

A new service/controller instance backed by the same persisted test
adapter is not a Roblox server crash/restart, a real same-account
network rejoin or a published cross-server handoff. Existing Roblox
Studio multiplayer fixtures use distinct synthetic UserIds; replacing
one test client does not prove same-user network re-admission.

Cloud verification remains deferred as instructed. For future acceptance,
exercise actual reconnect on the isolated TEST Dungeon, preserving the
current cloud version first; or use an authorized same-user test harness
without modifying real player DataStores.

The user separately confirmed a successful manual solo optional-boss
playtest. The earlier automated injured-solo no-recovery fixture's failure
remains a distinct historical test result, not evidence that the user's
manual solo run failed.
