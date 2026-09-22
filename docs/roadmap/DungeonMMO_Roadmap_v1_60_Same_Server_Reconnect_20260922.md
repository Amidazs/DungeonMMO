# DungeonMMO roadmap v1.60 — same-server reconnect (LOCAL VERIFIED)

Date: 22 September 2026
GitHub branch: `wip/phase-4-test-hud-integration-v1`
Latest implementation/test source:
`7d684f583020df64e2591a00acef14c90f35ecb1`

## Implemented on the feature branch and locally verified

- [x] Add narrowly gated existing-server reconnect admission
  for the authenticated UserId of a previously connected,
  now-disconnected, non-abandoned member of **this**
  active SessionId. First admissions continue to use the
  existing single-use profile handoff nonce.
- [x] Keep the independent profile writer-lease check;
  a returning player must reacquire their own profile
  before being marked connected.
- [x] Reject abandoned users during ordinary Dungeon
  admission, including stale routing-data attempts.
- [x] Re-send the server-owned revive/spectator state on
  admission. Dungeon client requests a fresh snapshot
  after listeners are registered so an early push is
  not silently lost. Reconnection does not refund
  consumed revives or issue monster rewards.
- [x] Add a service-level simulated same-UserId return
  regression, including checkpoint/party preservation,
  session/dungeon mismatch rejection, exclusive leases,
  unchanged spectator state and consumed free revive.
- [x] Add a focused unpublished Studio runner and
  extra death-service state-sync assertions.
- [x] Device reconnected. At tested gameplay head
  `87a19ba6ac112f8fd3850d01f271538067286d72`, all six
  Rojo builds, same-user reconnect 30 assertions,
  Dungeon backend 30/30, death/revive 46 assertions,
  actual-client failed-run UI, focused threat 51,
  Base professions 14/14 and real four-client Room1
  recovery passed in unpublished Studio.

[Local test acceptance](../testing/dungeon-same-server-reconnect-local-acceptance-2026-09-22.md)

[Original staged implementation note](../testing/dungeon-same-server-reconnect-stage-2026-09-22.md)

## Remaining reconnect and release gates

- [x] Clean fast-forward; six Rojo builds; Dungeon 30/30;
  focused same-user admission 30 assertions;
  death/revive 46 assertions; real-client failed-run UI;
  threat 51; Base professions 14/14; real four-client
  Room1 wipe/re-entry all passed at the same source head.
- [ ] Add a disposable Studio simulation of the normal
  Dungeon admission pipeline after a released profile
  and server-recorded disconnect; check spectator
  restrictions and unchanged live encounter health.
- [ ] Verify that actual Roblox same-account return to
  a published reserved server supplies valid join
  routing, reacquires the profile lease and resumes
  the same session/checkpoint. Direct joins without
  platform routing must fail closed; no invented
  client-supplied session ID fallback.
- [ ] Normal-combat and boss-reward continuity after
  reconnect, including duplicates and late completion.
- [ ] Higher-depth completion / Play again and real
  cross-place TEST/cloud travel; publishing still
  requires explicit user authorization.

The previous v1.59 secret, Depth4 and peer-departure results
are independent, historical tests. The v1.60 source now
passes the focused reconnect service tests, but a real
same-account Roblox network reconnect remains untested.
No `main` merge, Roblox publish or production data
operations were performed.
