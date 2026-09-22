# DungeonMMO roadmap v1.61 — party unlock, spectator and replay

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Last full multiplayer/backend gameplay test: `c6925c0`
Final source including Base UI explanation: `b6fe3be`

## Complete in unpublished local testing

- [x] No higher-difficulty party entry unless **every** selected
  character has independently unlocked the requested depth
  in the selected dungeon. Existing Base member validation and
  the additional TeleportCoordinator reservation-boundary
  validation both reject a locked leader or any locked member.
- [x] Depth3 requires each member's own Depth2 clear;
  Temple progress does not unlock Abandoned Mine.
- [x] A locked party never reserves a server, creates a new
  session or starts a profile handoff/teleport. The entry
  failure identifies the member; the Base UI explains it.
- [x] Play again must recheck **each connected member** against
  their present profile-backed difficulty unlock before a
  new-run vote/Studio simulation/published teleport. Failed
  validation clears any previous votes. The transport
  checks again before reservation.
- [x] A reconnecting or newly respawned spectator cannot
  attack, cast, defend, deliver delayed damage/contribution
  or be targeted as an active dungeon member. Active peers
  retain combat access.
- [x] Correct real-client Play again UI race: a late revive
  snapshot cannot dismiss ReplayWaiting/ReplaySimulated.
  Both real clients demonstrated successful vote and visible
  replay result in unpublished Studio.
- [x] Six Rojo compositions, Base unlock, coordinator
  **23 assertions**, replay **28 assertions**, backend
  **30/30**, real two-client spectator fixture and real
  two-client Play again fixture passed at `c6925c0`.
  All six compositions and Base unlock passed again at
  the final Base UI-only source `b6fe3be`.

[Detailed acceptance report](../testing/dungeon-party-unlock-spectator-replay-2026-09-22.md)

## Next backend work

- [ ] Integrate a real full-party difficulty gate into a
  multi-client Base UI/portal test, beyond the already
  passing production-service four-member fixture.
- [ ] Normal player-attack monster and boss completion,
  reward idempotence and durable difficulty unlocks
  across a legitimate reconnect and Play again.
- [ ] Real same-account reconnection into the original
  published TEST reserved server; confirm authoritative
  routing data and profile lease reacquisition.
- [ ] Higher-depth boss/mini-boss/secret/event progression
  and real new-run replay after a completed difficulty.
- [ ] Published TEST cross-place travel, cloud continuity,
  purchase receipt recovery and release readiness require
  separate explicit user authorization.

All code, tests and documents were edited in GitHub.
No Roblox publish, `main` merge, force-push or production
profile/receipt operation occurred.
