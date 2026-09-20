# Phase 4 — Depth 2–4 optional side rooms: physical Play-mode acceptance

Date: 20 September 2026. Integration branch:
`wip/phase-4-test-hud-integration-v1`.
Source checkpoint before this work:
`924bcbe15802bcafe56c938564f2210dc28f466c`.

## GitHub-first implementation and release boundaries

The existing optional encounter definitions and the Depth 2–4 required
room sequences were reused. Changes were committed to GitHub first,
fast-forward pulled into the existing Windows integration worktree and
tested on unpublished local Rojo/Studio places. No published Roblox
place, account DataStore, main branch, existing authored art or
production difficulty release switch was modified.

Only an explicitly opted-in, unpublished local Studio placeholder can
register the new high-depth EventArena/SecretArena slots. The generated
Depth 2–4 blockouts now include walkable, level side bridges, proper
main-room wall openings, enclosed optional rooms, depth-specific boss,
checkpoint and trigger anchors, and an EntranceGate on each bridge.
The Event bridge joins Room 1; the Secret bridge joins the penultimate
required room (Depth 2: Room 3; Depth 3: Room 4; Depth 4: Room 5).
Legacy Depth 1 geometry and both unreleased physical previews remain
unchanged unless a selected depth is explicitly opted in.

`DungeonOptionalEntranceGates` selects gates belonging to the active
higher-depth blockout. The unused Depth 1 bridges remain sealed, even
after a higher-depth Event/Secret boss becomes eligible. If a high-depth
run has not opted into its optional layout, synchronization reports
no active optional side gates instead of opening the old Depth 1
entrances. Original Temple and Mine Depth 1 gate behaviour remains.

## Fresh structural and backend verification

`DungeonOptionalDepthPhysicalLayoutTest` verifies both dungeons at
all three higher depths. Its **139 assertions passed** for room/bridge
floor alignment, main-room side openings, three unique optional anchors
per room, active depth gate selection, opening only after required
prerequisites, keeping unused Depth 1 bridges sealed and independently
locking ineligible Secret routes. Fresh Studio log:
`0.739.0.7390687_20260920T173658Z_Studio_C5F89_last.log`.
All **18/18 focused optional-boss suites passed** on that build.

The broader gameplay backend matrix passed **30/30 suites**:
`0.739.0.7390687_20260920T174606Z_Studio_532E7_last.log`.
Four local Rojo compositions built: Dungeon, Base, published-style
Dungeon and published-style Base. These are local files, not releases.

## Six independent physical Play-mode results — PASS

Fixture:
`scripts/studio/phase4_placeholder_depth_optional_physical_play.luau`.
Each scenario ran in an independent disposable Studio Play-mode session
against the same source-controlled test fixture. It enabled Event/Secret
eligibility and the selected dungeon rollout **only in that local loaded
DataModel**; the unchanged Depth 2–4 release flags remained false.

The Studio character used Humanoid:MoveTo to walk through each side
opening, across the physical gate/bridge and into its boss trigger,
then back into the main route. The server's actual encounter runtime
spawned and cleared each boss. Required-room enemy packs and the boss
health defeats were test-assisted. This is NOT a human-controlled
manual combat/balance test, and no real player DataStore was accessed.

| Dungeon | Depth | Encounters | Parent Studio log | Result |
|---|---|---:|---|---|
| Temple | 2 | 6 | `0.739.0.7390687_20260920T173853Z_Studio_89320_last.log` | PASS |
| Temple | 3 | 7 | `0.739.0.7390687_20260920T174043Z_Studio_26D34_last.log` | PASS |
| Temple | 4 | 8 | `0.739.0.7390687_20260920T174151Z_Studio_D895F_last.log` | PASS |
| Abandoned Mine | 2 | 6 | `0.739.0.7390687_20260920T174242Z_Studio_EEE23_last.log` | PASS |
| Abandoned Mine | 3 | 7 | `0.739.0.7390687_20260920T174328Z_Studio_242C2_last.log` | PASS |
| Abandoned Mine | 4 | 8 | `0.739.0.7390687_20260920T174415Z_Studio_F7302_last.log` | PASS |

Every listed log contains `VERIFIED_PLAY_MODE_PASS <dungeon> <depth>`
and separate `WALKED_Event_BRIDGE_IN/OUT`,
`WALKED_Secret_BRIDGE_IN/OUT`, optional-boss spawn identity and
`PLAY_PASS` markers. Depth 4 also verified its three returning
minibosses on the normal required route.

## Higher-depth deferred Secret backtracking — PASS

A separate new TEMP fixture,
`scripts/studio/phase4_placeholder_depth_optional_backtrack_play.luau`,
ran Mine Depth 4. After clearing Room 5, the Studio character physically
approached the final-room trigger, which persisted Secret as Skipped.
Only in this disposable fixture, the normal Final spawn was deferred
AFTER the skip was recorded so the character could return to the
Secret side bridge before ending the run. The character walked back,
started and cleared the deferred Secret, then returned to clear the
Depth 4 final boss without resetting Room 5 or the main route.

Studio log:
`0.739.0.7390687_20260920T174752Z_Studio_E1615_last.log`.
Markers: `SECRET_SKIPPED_FINAL_PENDING`,
`BACKTRACK_SECRET_CLEARED_MAIN_ROUTE_INTACT`,
`PLAY_PASS AbandonedMine Depth4 rooms=8` and
`VERIFIED_BACKTRACK_PLAY_PASS AbandonedMine Depth4`.
This test did not change the released Final encounter implementation.
It is not a same-account Roblox server reconnect/crash test.

## Non-optional regression — PASS

The original optional-disabled Temple Depth 2 physical fixture was
rerun after the geometry and gate changes. It completed the original
four-room route and retained both optional release locks:
`0.739.0.7390687_20260920T174532Z_Studio_B14D5_last.log`,
`VERIFIED_PLAY_MODE_PASS TestDungeon Depth2`.

## Remaining release gates

The extra optional routes are TEMP placeholders only. No higher-depth
optional content was published or exposed in production, and no
finished modelling was attempted. Additional future checks, if the
content is released, include real non-assisted combat, user-facing
visual navigation and true same-account cross-server reconnect.
The user's previously confirmed manual optional-boss solo test
is separate and was not repeated.
