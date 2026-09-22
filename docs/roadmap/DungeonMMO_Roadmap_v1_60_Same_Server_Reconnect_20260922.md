# DungeonMMO roadmap v1.60 — same-server reconnect (STAGED)

Date: 22 September 2026
GitHub branch: `wip/phase-4-test-hud-integration-v1`
Latest implementation/test source:
`7d684f583020df64e2591a00acef14c90f35ecb1`

## Implemented on the feature branch, NOT YET LOCALLY VERIFIED

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
- [ ] **Test gate blocked**: local device was offline
  when Rojo/Studio tests were attempted. Source at
  this head is not yet accepted as built or passing.

[Implementation and pending-verification report](../testing/dungeon-same-server-reconnect-stage-2026-09-22.md)

## Next work once a test device is online

- [ ] Clean fast-forward the feature branch; build all
  six Rojo projects, run the Dungeon 30/30 backend
  matrix, focused same-user service regression, normal
  death/revive and client UI regressions.
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

The previously verified v1.59 four-player secret,
Depth4 and peer-departure fixtures are not a proof of
the new v1.60 same-account reconnection path.
No `main` merge, Roblox publish or production data
operations were performed.
