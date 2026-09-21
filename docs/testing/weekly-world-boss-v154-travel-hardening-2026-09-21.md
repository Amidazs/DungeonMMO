# v1.54 weekly boss — travel hardening and reward-contract correction

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Source tested through commit:** `90046cd754427d7e0ddfe0b790b888050aea63da`  
**Scope:** GitHub-only source/fixture edits; unpublished local Studio
builds and tests. No live weekly event, cloud publish or TEST/PROD
DataStore change.

## Critical reward-contract correction

`WorldBossRuntime.grant_if_eligible` previously read
`contribution:get_player_snapshot(...).snapshot`. The actual
`ContributionService.get_player_snapshot` returns `ok` and the
server-recorded `Damage`, `Tank`, `Support`, `Breakdown`
**at the top level**. Therefore the original dedicated runtime
would return early and **never authorize a normal weekly payout**,
even when the real contribution service had stored qualifying work.

A small shared `WorldBossContributionRules.is_eligible` now
validates the actual authoritative response, rejects missing,
nonfinite and zero contribution, and accepts positive recorded
damage, tank or support. The dedicated boss runtime calls that
function; it does not accept client-provided success metadata.

The independent real-service contract test exercised actual
`ContributionService` and `DungeonSessionService` with a
shared Studio map adapter. An invited non-contributor remained
ineligible, while persisted damage and healing each qualified.
A newly created service still read the previously persisted
contribution. This **does not connect player attacks to the
dedicated boss place's combat runtime yet**.

## Return and admission hardening

- The dedicated reserved runtime now binds the first validated
  stored encounter session before its next yielding lease/profile
  admission operation. A second session cannot take over the same
  server while the first member is loading. A failed first admission
  fails closed on that server rather than admitting another party.
- A malformed persisted world-boss party list is rejected by
  `WeeklyWorldBossSessionBridge.resume` before computing its length.
- `TeleportCoordinator` records the destination kind of each
  pending handoff. If a world-boss member's Base return teleport
  fails, the coordinator cancels the lease handoff and clears only
  that member's persisted `WorldBossReturnPending` flag. Their
  original boss-session index remains, so a reconnect can return
  them to the boss instead of stranding them in Base's
  return-in-progress branch. A successful Base arrival still clears
  only that member's index after their profile loads.
- No changes to normal dungeon entry, skill/crafting system,
  final boss art, real-player DataStore or public event enable flags.

## Verified local evidence

- `%TEMP%\DungeonMMO_weekly_boss_contribution_fix\`:
  Base and Dungeon each built, and the actual contribution-service
  contract printed `[World Boss Contribution] PASS: 14 assertions.`
  in **both** compositions; Studio exit code 0 both times.
  The isolated world-boss place also built.
- `%TEMP%\DungeonMMO_weekly_boss_return_rollback\`:
  Base, Dungeon and isolated world-boss Rojo compositions built.
  The Base return test printed `PASS: 22 assertions`, including
  the simulated synchronous failed-teleport rollback;
  the reserved-travel contract printed `PASS: 18 assertions`
  in Base; the existing durable world-boss session contract
  printed `PASS: 30 assertions` in Dungeon.
  All these Studio tests exited with code 0.
- The earlier independent isolated travel receipt covers six
  composition builds, the separate destination and ordinary
  dungeon guard suites, default-off destination Play,
  unchanged profession 14/14, Dungeon gameplay 30/30, and
  the real-client material-chain Play regression.
  See `weekly-world-boss-v154-isolated-travel-2026-09-21.md`.

## Release status

The world-boss event is **OFF by default**, the dedicated place
lacks an authored `WorldBossArenaSpawn`, and its independent
player combat/guardian AI and recording pipeline is not yet
integrated. No real cross-place Base → reserved boss → Base
teleport, new-server handoff, multi-client boss kill or published
TEST DataStore/MemoryStore persistence has been verified. These
are required before describing this milestone as playable.
