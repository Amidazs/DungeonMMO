# DungeonMMO roadmap v1.58 — four-party dungeon recovery

Date: 21 September 2026  
Branch: `wip/phase-4-test-hud-integration-v1`  
Local verified gameplay/test head:
`a5c0637888f8400703d07290f790a24d3b8406bf`

## Completed backend and unpublished Play gates

- [x] Physical four-client Temple Room1 run: partial enemy kill
  with real per-player monster reward receipts, full-party death,
  consumed automatic revives, old-enemy cleanup and four fresh
  checkpoint characters.
- [x] Physically re-enter the interrupted room and respawn a
  separate full-health pack. Re-killing the previously rewarded
  monster cannot duplicate Gold, XP, Level or bestiary reward
  for any of the four clients.
- [x] Physical four-client Room3 boss wipe: preserve completed
  Room1/Room2, retire the old injured boss and its spawn claim,
  respawn four players at the boss checkpoint and permit a
  single full-health boss on re-entry.
- [x] Physical four-client optional Temple event-boss wipe
  with event eligibility opened **only in the disposable
  Studio test**. Previous room clears persist; event encounter
  returns to Pending and respawns a new full-health boss.
  Production optional release gates remain unchanged.
- [x] Fix repeated Failed-state broadcasts that replaced the
  replay waiting screen every server tick. DungeonDeathService
  now announces terminal wipe once.
- [x] Real two-client Play again request flow: first party
  member sees Waiting for party; when the second consents,
  both see the Studio-simulated new run. Existing separate
  real-client UI tests cover both victory and defeat buttons.
- [x] Six Rojo compositions; Dungeon backend 30/30 and
  death/revive 41 assertions at the latest gameplay head.
  Focused threat 51, Base professions 14/14 and paid-retry
  integration 15 assertions at the preceding gameplay fix head.

[Full four-party gameplay and replay evidence](../testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md)

## Next locally testable backend gates

- [ ] Optional SecretArena boss, multiple difficulty depths and
  guardian miniboss room wipe/re-entry, including progression
  and spawn-claim isolation.
- [ ] Real player disconnect/reconnect during an active physical
  room/boss wipe, with unchanged party checkpoint and
  no duplicate reward on a repeated monster life.
- [ ] Full normal-client combat and boss-reward completion across
  a wipe; current tests use injected prerequisite kills and
  injury and do not verify damage balance.
- [ ] In-universe Play again with a real completed run through
  multi-client UI and a new session; unpublished Studio
  currently simulates its reserved teleport by design.
- [ ] Explicit approval before any TEST publication,
  cross-place reserved-server journey, cloud persistence
  or production purchase/reward handling.

Release and branch boundary: GitHub feature branch only.
No main merge, place publishing, force-push or production
DataStore operations were performed.
