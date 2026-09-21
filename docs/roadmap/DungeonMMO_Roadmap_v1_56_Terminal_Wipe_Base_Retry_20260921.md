# DungeonMMO roadmap v1.56 — terminal wipe and Base retry

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** Staged local backend increment; publication and in-place
room/encounter reset remain deferred.

## Implemented and locally verified

- [x] Preserve the existing terminal `Failed` state after the
  revive-decision deadline; do not revive that failed session.
- [x] Connected failed-run members can request the existing
  Return-to-Base route without trying to abandon a terminal
  session. Active abandonment and committed-completion return
  retain their separate server-owned guards.
- [x] Real Dungeon client shows a failed-run Return-to-Base panel
  and sends `Abandon`, which the server routes to failed-session
  return when appropriate. Unpublished UI Play PASS.
- [x] New Base-issued dungeon sessions use fresh SessionId,
  Entrance checkpoint and per-run free-revive allowance; the
  failed predecessor and its reward identity remain terminal.
- [x] Paid-revive spawn callbacks reject failed/departed members
  and repeat grants. Legitimate callbacks handle the actual
  purchase-service order, which marks a member Active before
  the server-owned spawn; the two-service integration passed.
- [x] Six local Rojo builds, Dungeon backend 30/30,
  standalone failed-return contract, fresh-session contract,
  real client UI state and paid-revive integration tests.

Receipt:
[Terminal wipe return and fresh retry](../testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md).

## Still required for the full wipe/retry milestone

- [ ] True **in-instance** encounter wipe/retry: restore current
  enemies to full health/spawn, retire their old executor handles,
  reset an interrupted room to Pending without revisiting cleared
  room reward boundaries and respawn party at the current checkpoint.
  The current three-second no-target reset is **threat-only**.
- [ ] Establish dungeon-specific retry limits/timing and how
  already-used free revives and paid purchases apply across
  in-instance retries. Do not silently reset paid/revive receipts.
- [ ] Two-/four-client physical dungeon Play covering full wipe,
  checkpoint respawn, boss/optional room re-entry, completion
  idempotence and disconnect during recovery.
- [ ] Published TEST travel and cross-server/cloud state only
  after renewed user authorization.

This phase is an independently accepted **terminal failure ->
Base -> new run** path, not the complete in-place dungeon
encounter reset. No `main` merge or Roblox place publish.
