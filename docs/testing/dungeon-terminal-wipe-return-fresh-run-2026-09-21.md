# Dungeon failure, Base return and fresh retry: local backend increment

Date: 21 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Gameplay fix / broad regression head:
`9862ce4f0903a242eebb93fe14b6232a94abe14f`
Integration fixture head:
`ae099046872621c569193741e4323f4a15168a9b`

## Implemented

- When the existing full-party revive window expires,
  DungeonSessionService retains its terminal `Failed` state.
- An already-failed dungeon can now process a member's ordinary
  **Return to Base** request without calling `abandon_member`,
  which correctly rejects transitions from a terminal session.
  The server validates each requester's current connected membership.
  Ordinary active-session abandonment and completed-session return
  are unchanged.
- The real Dungeon UI now presents a failed-run panel with a
  **Return to Base** button instead of hiding the return controls.
  In unpublished Studio, Base return is intentionally simulated.
- Returning does not reopen the old run, restore encounter health,
  reset its reward receipts or modify its terminal failure reason.
  Players start another run from Base using the existing new-session
  entry flow; the new run receives a different SessionId, Entrance
  checkpoint and unused free revive.
- DungeonDeathService now checks active session, connected
  membership, free-revive consumption and the **actual committed
  paid-grant count** before respawning. A duplicate callback,
  departed player or late callback after `Failed` cannot spawn.
  Its callback explicitly accounts for the existing purchase-service
  order: the server persists the purchase and marks the member
  `Active` **before** invoking the spawn callback.

## Unpublished test evidence

At `9862ce4`, all six Rojo compositions built; the Dungeon
backend matrix passed **30/30**, including DungeonDeathService's
paid-revive regression **32 assertions**. The dedicated failed
return service contract passed **15 assertions**. The separate
fresh session identity test passed, proving a failed run remains
terminal while the same player can create a distinct new run.

The real-client failed-run UI fixture passed
`FAILED_RETURN_BUTTON_PASS` and `VERIFIED_PLAY_MODE_PASS`
at `62a04cd`; its UI runtime is unchanged by the subsequent
paid-revive and test-only commits.

At `ae09904`, a new in-memory **integrated** service fixture
passed **15 assertions** using the real DungeonSessionService,
RevivePurchaseService, DungeonDeathService and
ReturnPortalService implementations. It proved free revive,
the real purchase callback's `Active` mode ordering, one paid
spawn, duplicate purchase receipt idempotence, terminal wipe
rejection, simulated Base return and a distinct fresh retry
session.

This is a local backend and UI contract, **not a published
cross-place Base teleport or a physical dungeon full-session
restart Play**.

## Remaining gates

- Actual multiplayer dungeon-room encounter reset/re-entry:
  enemy HP/spawn restoration, current-room executor teardown,
  checkpoint party respawn and locked-down completion rewards.
  The accepted three-second no-target reset still clears
  **threat only**.
- Full two-/four-client dungeon death-to-failed-return-to-fresh-run
  Play through Base admission and the real portal.
- Published TEST reserved travel, cloud persistence and
  cross-server reconnect, only after separate user approval.
- Audit paid-revive spawn failures after an already-recorded
  purchase; this increment avoids duplicate spawning but does
  not implement a purchase refund or replay mechanism.

All script/document changes were made directly in GitHub.
Remote Desktop was limited to clean fast-forward pulls, temporary
Rojo builds, unpublished Studio tests and read-only diagnostics.
No Roblox place was published, no `main` merge or force-push,
and no production DataStore/reward transaction was performed.
