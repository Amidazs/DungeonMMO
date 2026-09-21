# Real four-player wipe and threat reset acceptance

Date: 21 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Verified runtime/test source:
`739e747d88d93ff00ed30497e9473edd17b037f4`

## Backend behavior

Training Marauder and shared guardian target controllers now retain their
independent threat ledgers during a temporary loss of targets. After
three continuous seconds without any currently eligible target, a
previously engaged enemy discards its threat ledger and eligibility
snapshot. When an eligible living party member remains, the countdown
is cancelled. Enemy death/respawn and normal disconnect cleanup remain
separate paths.

The change is **threat-only**. It does not restore enemy health, move
the enemy to its spawn, wipe rewards, change boss admission or reroll
the weekly encounter. A complete dungeon-session reset/retry policy
remains a separate backend milestone.

## Real Studio acceptance

The unpublished `default.project.json` Dungeon composition ran the
four-client `four_player_room_support_aggro_live.luau` fixture.
All four real clients interacted with two real Marauder controllers
through ordinary server-owned CombatService and ThreatService.

The run verified, in order, nearest fallback, idle-enemy isolation,
real damage against the second enemy, effective healing threat on
both engaged enemies, Fighter Taunt retake, dead-healer fallback and
a **genuine DPS client departure**. The owning clients of the
remaining tank and observer then died; the healer was already dead.
The server observed both enemies lose their targets and their
previously nonzero player threat totals return to zero:

- `REAL_DISCONNECT_CLEANUP_PASS`
- `REAL_FULL_WIPE_THREAT_RESET_PASS`
- `VERIFIED_FOUR_CLIENT_PASS`

The real-client disconnect assertion was added at
`e8a2b4fb08a6fe90b1ec5cc36ba14c806212d83f` and passed before the wipe
change. The first new wipe-fixture attempt missed a **real Taunt**
because the moving enemy left the melee hit geometry; it never
reached the wipe assertion. The fixture now retries a genuine miss
only after the full skill cooldown. No gameplay validation, threat
or skill cost was bypassed. The corrected fixture passed at the
source head above.

## Same-head regression proof

- All six Rojo compositions built successfully.
- Focused ThreatService: **51 assertions PASS**.
- Dungeon gameplay backend matrix: **30/30 PASS**.
- Base profession regression: **14/14 PASS**.
- Correct `world-boss.project.json` local composition:
  two-client guardian aggro `VERIFIED_MULTIPLAYER_PASS`.
- Same correct world-boss composition:
  two-client guardian MageHeal, Ward and Mend support threat
  `VERIFIED_MULTIPLAYER_PASS`.
- Feature worktree was clean and `git diff --check` passed.

The world-boss tests were run using their actual isolated local
composition, not the ordinary Dungeon place. Earlier timeouts
associated with the wrong composition are historical and superseded.

## Not yet accepted

This is threat-only full-wipe cleanup, not a full production dungeon
wipe/retry or world-boss health/reset rule. Full-session reset,
respawn routing, restored encounter health, reward idempotence across
wipe/re-entry, same-account cloud reconnect and published TEST/PROD
remain separate gates. Support-threat balancing is provisional.

All source/test/doc changes were performed directly in GitHub.
Remote Desktop was used for safe fast-forward, TEMP Rojo builds,
unpublished Studio tests and read-only diagnostics only.
No Roblox place was published; no main merge, force-push or
production DataStore mutation occurred.
