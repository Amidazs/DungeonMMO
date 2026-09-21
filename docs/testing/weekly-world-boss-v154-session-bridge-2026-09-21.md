# v1.54 weekly world boss — durable session bridge, local verification

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Last source/test commit verified:** `af90299bebc6ae41c6c7736f63153bc5b53f7bc6`

## Scope and actual state

This increment connects the **default-off server-only** weekly
world-boss contract to the project's existing
`DungeonSessionService` and its `InstanceState` snapshot. The bridge
is composed in both the Base and Dungeon `RuntimeServices`, but the
normal Base portal/teleport handler does **not** call it. No live
event is enabled or published.

`WeeklyWorldBossSessionBridge.issue` starts from an existing,
authoritative Creating/Active dungeon-session record. It requires
a pre-initialized `InstanceState`, validates an open server-owned
weekly window and uses actual stored member IDs rather than
caller-provided participants. It saves one frozen guardian ID,
entry window, UTC week and member list into
`InstanceState.WeeklyWorldBoss`. Reissuing the same session cannot
replace that snapshot or reroll its week.

`record_defeat` requires the matching tagged, dead server guardian
and writes defeat state through the existing session's atomic map
update. `resume` rehydrates a new local world-boss service from
the persisted session record without reopening closed entry.
`grant_reward` requires a member who has **actually been certified
eligible by the existing server-side session eligibility API**.
A merely invited party member cannot claim. Weekly gold and
the once-per-week receipt remain atomically linked within the
existing player-profile mutation, including after an in-memory
same-UserId save/release/reload.

The existing server's Studio in-memory map and profiles were
shared across newly constructed service objects in the tests,
simulating a server handoff. This does **not** prove Roblox
MemoryStore/DataStore behavior or authenticated cross-server
network reconnection. Sessions still use existing finite TTLs;
a reward for a lost/expired session is not guaranteed.

## Reproducible local Studio results

The local output directory is
`%TEMP%\DungeonMMO_weekly_world_boss_session\`.

| Validation | Observed result |
| --- | --- |
| Four Rojo builds before the latest service composition | 4/4 PASS |
| Session bridge contract in Base | `final_durable_session_base.log`: 30 assertions PASS |
| Session bridge contract in Dungeon | `final_durable_session_dungeon.log`: 30 assertions PASS |
| Original weekly policy in Base | `final_worldboss_base.log`: 40 assertions PASS |
| Weekly policy + guardian factory in Dungeon | `final_worldboss_dungeon.log`: 40 + 8 assertions PASS |
| Existing profession suite in Base | `final_professions_base.log`: 14/14 PASS |
| Existing gameplay suite in Dungeon | `final_dungeon_backend.log`: 30/30 PASS |

The dedicated session test exercised real `DungeonSessionService`
create, snapshot initialization, issue and rejection of repeated/
future admission. It checked outsider and non-contributor rejections,
live-boss and wrong-instance rejection through the existing weekly
service, server-owned defeat persistence, first-member payout and
independent second-member eligibility. A fresh pair of service
objects restored the same session map and the previously saved
first player's profile without a second grant. It also verified
the session's reward grace deadline.

**Important boundary:** The test uses a disposable TestDungeon
session as a transport for the future world-boss instance
snapshot. This does not make a regular TestDungeon run a
world-boss encounter. Its normal encounter state, portal and
teleport behavior remain untouched.

## Next backend integration gate

Create an explicitly dedicated, disabled-by-default server-issued
weekly boss entry route in Base, carrying this frozen snapshot
*before* reserving/teleporting to a dedicated boss place.
Destination admission must use the existing trusted
session/lease handoff rules, refuse ordinary dungeon/forged entry
and reconstruct the recorded member/event/defeat state.
The current ordinary Dungeon runtime cannot be treated as a
dedicated world-boss place by just redirecting its teleport.
Two-client participation and real cross-server claim/retry still
need TEST-environment verification, with no production-player
DataStore writes.

All source, tests, roadmap and handoff edits were done through
GitHub. The Windows environment only fast-forward-pulled a clean
tree, built locally and executed read-only Studio tests. No
production publish, main merge, force-push or live event rollout.
