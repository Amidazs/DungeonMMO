# Dungeon same-server reconnect — unpublished local acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Exact tested gameplay/test head:
`87a19ba6ac112f8fd3850d01f271538067286d72`

## Reconnected device and source

Desktop Commander reconnected to the authorized Windows machine.
The local feature worktree was clean, and `git fetch` followed by
`git merge --ff-only` advanced it from the earlier v1.59 source
to the exact GitHub feature head recorded above. No local files
were edited. The GitHub-only reconnect changes are now present
in the local test composition.

## Same-head unpublished verification

- All **six Rojo compositions** built: Dungeon, Base, published
  Dungeon composition, published Base composition, world boss
  and published world-boss composition.
- `git diff --check` passed with a clean feature worktree.
- `dungeon_reconnect_admission_tests.luau`: the in-memory
  production-service reconnect contract passed **30 assertions**
  and printed `RESULT passed=1 total=1 failed=0`.
  It covers same-server session identity, nonce-free readmission
  eligibility after an actual recorded departure, rejected
  strangers/abandoned/terminal members, checkpoint and spectator
  state, used free-revive preservation, exclusive profile lease
  claims and authoritative revive-state rehydration.
- `phase4_gameplay_backend_matrix.luau`: **30/30 PASS**,
  including DungeonDeathService's **46 assertions**.
- `dungeon_failed_return_ui_live.luau`: genuine unpublished
  client presentation printed `FAILED_RETURN_BUTTON_PASS`
  and `VERIFIED_PLAY_MODE_PASS`. Its output also includes
  the new reconnect admission and death/revive suites passing.
- `threat_service_tests.luau`: **51 assertions PASS**.
- `profession_cross_dependency_tests.luau`: **14/14 PASS**
  using the separate Base composition.
- `dungeon_four_client_room_wipe_live.luau`: the real
  four-client unpublished physical Room1 wipe/re-entry fixture
  printed `VERIFIED_MULTIPLAYER_PASS` at this **same** source
  head, guarding against a room-recovery regression.

The older note about Desktop Commander being offline describes
the earlier attempt only; it is superseded by the evidence
above. These results are from separate local Studio test
processes using the same source head, not a published game.

## Still not verified

The 30-assertion reconnect contract **simulates** the same
Roblox UserId's return using production server services.
It does not exercise a genuine account losing its network
connection and joining the original reserved server again.

The existing Dungeon admission path still requires valid
platform-provided join routing. A genuine return without
`GetJoinData().TeleportData` is not automatically routed
to the old server; it fails closed rather than trusting a
client-supplied session ID. A published TEST experiment is
required to establish actual Roblox routing, profile lease
reacquisition and client character/spectator restrictions
after a real same-account network reconnect.

Also pending: a complete normal-combat/boss-reward journey
through the same-account rejoin, cross-server recovery
and published Play again. None of these are implied by
the simulated contract or independent four-player wipe
fixture.

All source/document edits were performed in GitHub only.
Remote Desktop was used solely to fast-forward the clean
worktree, run temporary Rojo builds and unpublished Studio
tests, and read their results. No `main` merge, Roblox
place publish, force-push or production data/purchase
operation was performed.
