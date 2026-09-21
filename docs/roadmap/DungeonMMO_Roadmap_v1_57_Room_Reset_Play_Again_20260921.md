# DungeonMMO roadmap v1.57 — recoverable room reset and Play again

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Local physical-gameplay candidate:** `acb628fb99202a94f7f4cec781a15ec7f5614760`

## Completed in this backend increment

- [x] After a full party wipe with a pending automatic free revive,
  abort the currently active uncleared encounter, destroy its
  enemy instances, release boss-executor spawn guards, restore
  the encounter sequence to Pending and clear its live combat handles.
- [x] Preserve cleared earlier rooms, already consumed free revives,
  existing reward transaction IDs, checkpoints and member identity.
- [x] On automatic free revive, respawn near the active room-start
  checkpoint. Physical re-entry executes that room's factories again
  with new full-health enemies and fresh threat tables.
- [x] Authored Temple Room1 **real unpublished Play** demonstrated
  an injured enemy, a genuine player death, old-model retirement,
  a new checkpoint-respawned character and newly spawned full-health
  enemies on physical room re-entry.
- [x] On a fully exhausted failed run, keep terminal failure and
  present Return to Base **and Play again**. After a committed
  completion, present the same two choices.
- [x] Explicit party-wide opt-in to Play again; create a separate
  reserved dungeon session with the same dungeon/difficulty and
  Base destination. Clear the old consent votes after a failed
  launch; suppress automatic completed-run return while replay
  launch is underway. Unpublished Studio simulates the teleport.
- [x] Real-client completed and failed end-state UI Play both
  show Play again; replay backend tests **17 assertions** passed.
- [x] Six Rojo compositions, Dungeon backend **30/30** and
  one-shot recovery **40 assertions** passed on the local
  candidate/testing heads.

Receipt: [Room reset and Play again](../testing/dungeon-room-reset-play-again-2026-09-21.md).

## Remaining testing and backend release gates

- [ ] Two-/four-client actual-room all-dead and checkpoint recovery,
  including disconnect and a partially cleared room.
- [ ] Real boss, optional boss and dynamic difficulty encounter
  wipe/re-entry, spawn claim cleanup and enemy reward idempotence
  during a full physical fight.
- [ ] Actual multi-client Play again command/consent interaction
  through the full Dungeon Runtime (not just server service
  contracts plus client UI presentation).
- [ ] Published TEST reserved teleport, cross-server continuity
  and cloud reward persistence need explicit authorization.
- [ ] Production paid-revive refund/recovery policy following a
  persisted purchase whose subsequent character spawn fails.

No modelling, Roblox publication, main merge or force-push was
performed. Script and document edits stay in GitHub; the local
computer was used only for pull/build/test/diagnosis.
