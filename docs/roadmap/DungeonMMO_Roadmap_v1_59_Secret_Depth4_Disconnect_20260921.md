# DungeonMMO roadmap v1.59 — secret, Depth4 and disconnect

Date: 21 September 2026  
Feature branch: `wip/phase-4-test-hud-integration-v1`  
Latest focused tested head:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`

## Completed local backend acceptance

- [x] Four live Studio clients enter eligible TEMP-only
  Temple SecretArena. On a genuine full-party character
  wipe, its boss retires and four automatic checkpoint
  revives allow one new full-health boss on re-entry.
  Room1, EventArena and Room2 retain their cleared state.
- [x] Four real Studio clients enter the correct Depth4
  placeholder physical layout, clear Room1 and wipe at
  Room2's prior-difficulty mini-boss. The six-encounter
  plan stays intact. Only the interrupted mini-boss goes
  Pending; the new boss model spawns at full health after
  four checkpoint revives.
- [x] Actual Studio peer leaves during a live Depth1
  Room3 boss fight. The server records disconnection,
  keeps the boss active for three remaining members,
  recovers from their full-party wipe and never consumes
  the absent player's free revive.
- [x] Updated the stale optional Depth2/Depth4
  service regression to require **one** terminal failure
  notification, matching the already-fixed runtime
  behavior. All **392 assertions** pass for both
  dungeons and solo/two-/four-player parties.
- [x] Six Rojo builds, Dungeon backend 30/30 and
  death/revive 41 assertions at the latest gameplay
  test head. Secret, mini-boss and disconnect fixtures
  each produced independent `VERIFIED_MULTIPLAYER_PASS`.

[Local acceptance report](../testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md)

## Next backend gates

- [ ] Actual **same-account** disconnect and rejoin to
  an interrupted encounter across real reserved-server
  admission, with stable identity, checkpoint and
  member reward eligibility. Unpublished Studio tests
  so far only verify the departure/peer recovery side.
- [ ] Full normal-client multi-player combat and
  monster/boss reward idempotence across one wipe,
  including higher-depth mini-boss and secret boss.
- [ ] Multi-party higher-depth progression unlock,
  physical completion and fresh-run replay of the
  same difficulty following a **completed** dungeon.
- [ ] Permanent paid-revive grant recovery/refund
  policy for a successful purchase followed by a
  failed player character spawn.
- [ ] Published TEST cross-place reserved replay,
  cloud persistence, durable recovery, and production
  purchase flows require separate user approval.

All work remains on the GitHub feature branch;
no `main` merge, Roblox publish, force-push or
production DataStore operation.
