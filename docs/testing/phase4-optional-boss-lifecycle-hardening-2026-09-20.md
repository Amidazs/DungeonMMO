# Phase 4 optional-boss lifecycle hardening (20 September 2026)

## Scope and source
Worktree: DungeonMMO_Phase4_HUD_Integration_v1.
Branch: wip/phase-4-test-hud-integration-v1.
Starting source: 92b31be4b1f5c5cf7507a38d65d6c6e00f40851a.

This is a backend-and-placeholder test gate. Existing Event/Secret
eligibility, Secret backtracking, rewards, main-route checkpoints,
published places, authored artwork and DataStores remain unchanged.

## Defects reproduced and repaired
1. Normal encounter startup, including the required Event boss, left
   its sequencer Active if persisting the start failed. That could
   strand progression without spawning the boss. The shared controller
   now cancels the unsaved Active state to Pending before returning
   the original save error. RED Studio log:
   20260920T153817Z_Studio_FE16C_last.log.
2. A failed persisted Secret skip left an unsaved Skipped state in
   memory and could advance the main encounter cursor. The controller
   now restores the pre-skip sequencer snapshot when persistence fails.
   RED Studio log: 20260920T154150Z_Studio_D134A_last.log.

Neither fix issues eligibility, spawns a boss, grants rewards or
modifies a stored run after a failed save.

## Fresh local verification
- 14/14 optional-focused Studio suites PASS on the repaired source.
  11 startup/skip failure assertions, 24 saved two-member recovery
  assertions and 28 physical-gate eligibility/recovery assertions.
  GREEN log: 20260920T154229Z_Studio_532FE_last.log.
- Both TEMPLE placeholder entrances were initially shut; Room1 opened
  only eligible Event, Room2 opened eligible Secret; the Secret boss
  was bypassed, backtracked into and cleared, then Room3 completed.
  This combat-assisted disposable Studio fixture passed in
  20260920T154320Z_Studio_25B52_last.log.
- Unpublished normal Dungeon Play-mode baseline with optional
  rollout disabled passed in 20260920T154529Z_Studio_01A19_last.log.
- Five Rojo compositions built: Dungeon, Base, both published-style
  compositions and the isolated TEST Temple placeholder candidate.
  Builds were local and never uploaded.

## Evidence limits
The two-member saved-state test exercises the real session and
encounter services using a disposable in-memory map. It is not proof
of same-account network rejoin or a two-client optional-boss fight.
All live placeholder play fixtures assist combat. No Roblox cloud
deployment, DataStore modification, PROD action or art changes.

## Real local Studio two-client regression
The first pre-existing multiplayer fixture attempt admitted two real
Studio clients but timed out waiting for StudioTestService:LeaveTest
to remove the departing client. Its log was
20260920T154356Z_Studio_76850_last.log; this was a genuine failed
fixture run, not a successful disconnect test. A TEMP-only fallback
server kick was added for Studio test-runner flakiness. A fresh retry
passed and the fallback was not needed: client departure persisted,
the remaining party member stayed connected, and the encounter plan
and checkpoint were preserved. Parent Studio log:
20260920T154713Z_Studio_F7EB9_last.log; child server log:
20260920T154722Z_Studio_B6B4E_last.log.
The two-client fixture uses the normal optional-content release lock.
It proves an actual Studio PlayerRemoving path, not an optional-boss
fight in a two-client session or a same-account rejoin.
