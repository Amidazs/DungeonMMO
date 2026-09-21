# Dungeon room reset and Play again — local acceptance

Date: 21 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Latest focused gameplay/test head:
`341c84da73b9c1246414a51e171cc363d4e71c1b`

## Gameplay behavior

A dungeon with an interrupted **active** encounter can recover
after all connected living party members die **if at least one
automatic free revive is still pending**. The death service invokes
the encounter reset once for that wipe, then allows the existing
free-revive callback to respawn at the current checkpoint.

The runtime uses the active executor to clean up old enemy models
and release boss spawn guards, rolls the active encounter's generic
sequence back to Pending, retires EncounterService's current enemy
handles, clears character combat-encounter identity and preserves
the saved room-start checkpoint. Re-entering the room executes
its existing content factories again: full-health enemies at
authored spawns with a fresh active threat ledger.

No previously cleared encounter is rolled back. Already granted
monster reward transaction identifiers remain scoped to the
original session/enemy/life and retain RewardService's duplicate
protection. The room reset does not reset free-revive consumption,
paid purchase receipts, the old session ID or a cleared-run
completion receipt.

If every member has exhausted available revival, the existing
revive-decision timeout still fails the run. A terminal completed
run is replayable only after completion rewards have committed;
a failed run is replayable only after the terminal failure is
recorded. Both cases show **Play again** alongside **Return to Base**.

The server-owned replay service gathers explicit consent from all
still-connected, non-abandoned members. When everyone opts in, a
fresh reserved dungeon session is requested with the same dungeon,
difficulty and original Base return destination. A failed launch
clears collected votes so a retry again needs all-party consent.
Studio deliberately simulates the new-session teleport; it does
not assert a published cross-place success.

## Exact testing boundaries

At `c1d7f83`: all six Rojo compositions built; Dungeon backend
matrix **30/30**; replay service **17 assertions** including
post-failure renewed party consent; real-client UI Play printed
`COMPLETION_BUTTON_PASS`, `WIPE_BUTTON_PASS` and
`VERIFIED_PLAY_MODE_PASS`; paid retry service regression PASS.

At `341c84d`: the one-shot recoverable wipe, return from checkpoint,
subsequent exhausted revive and terminal timer contract passed
within DungeonDeathService's **40 assertions**. The same-head
Dungeon backend matrix passed **30/30** in unpublished Studio.

**Not yet verified end-to-end:** a real multiplayer run entering an
authored room, damaging its enemies, wiping, rejoining and
physically observing respawned enemy models; publisher-backed
new reserved server teleport; or cloud datastore persistence
across the replay. The server and pure service boundaries are
locally verified, but do not claim these live gates passed.

All edits were made directly in GitHub. Remote Desktop was
used only for a clean fast-forward pull, temporary Rojo builds,
unpublished Studio tests and read-only diagnosis. No publish,
main merge, force-push or production DataStore purchase was done.
