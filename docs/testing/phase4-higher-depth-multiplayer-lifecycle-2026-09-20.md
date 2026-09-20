# Phase 4 — higher-depth optional-boss multiplayer lifecycle acceptance

**Date:** 20 September 2026.  
**Branch:** `wip/phase-4-test-hud-integration-v1`.  
**Starting checkpoint:** `cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.

## Implementation and safety

Two source-controlled Studio fixtures were authored through GitHub first and
fast-forward pulled to the existing Windows integration worktree:
`scripts/studio/phase4_depth_optional_multiplayer_lifecycle.luau` and
`scripts/studio/phase4_depth_optional_secret_disconnect_lifecycle.luau`.
They run only in unpublished local places with `PlaceId=0` and
`GameId=0`. They temporarily enable the selected dungeon's optional boss
switch, the selected higher-depth placeholder, the frozen Event/Secret
eligibility and shared Studio-only party admission in the disposable loaded
DataModel. All ordinary source-controlled higher-depth and optional release
locks remain disabled.

The fixtures use **real simulated Studio client processes** and invoke
real `PlayerRemoving` with a TEMP-only Kick. Other members continue in the
same server-owned party/session. They move characters to the relevant
physical encounter triggers but use test-assisted enemy defeats and inflated
test player health. These are multiplayer backend/play-mode tests, not
manual combat or full physical bridge-walking tests; all six independent
single-client bridge-walking tests are already documented separately.

## Fresh two- and four-client gameplay — PASS

The Event fixture was exercised on the following independent local Studio
runs. Two players approached the same Event trigger, and exactly one boss
spawned. One member was disconnected mid-Event; the peer/remaining three
kept the same session, checkpoint and Active encounter, finished the route,
and earned the eligible Event/Secret rewards. A detached sequencer verified
interrupted Event would reconstruct as Pending without replaying Room1.

| Dungeon | Depth | Initial/remaining | Parent log | Child server log |
|---|---|---|---|---|
| Temple | 2 | 2 → 1 | `20260920T185325Z_Studio_5A292_last.log` | `20260920T185333Z_Studio_F0279_last.log` |
| Abandoned Mine | 4 | 4 → 3 | `20260920T185431Z_Studio_1634F_last.log` | `20260920T185439Z_Studio_3AB35_last.log` |
| Temple | 4 | 4 → 3 | `20260920T185558Z_Studio_E77E4_last.log` | `20260920T185606Z_Studio_67C47_last.log` |
| Abandoned Mine | 2 | 2 → 1 | `20260920T185655Z_Studio_86721_last.log` | `20260920T185703Z_Studio_A6D12_last.log` |

The first three parent logs contain
`VERIFIED_MULTIPLAYER_DEPTH_PASS`; the fourth child server log contains
`MULTIPLAYER_DEPTH_PASS AbandonedMine Depth2 initial=2 remaining=1`.
Its parent did not provide a separate verified pass marker, so the child
server assertion is the evidence cited for that case.

The independent Secret-disconnect variant kept the entire party connected
through Event, paid each connected member's Event reward once, then kicked
one member **while Secret was Active**. The remaining members completed
Secret and the final encounter without checkpoint rollback. A detached
recovery snapshot confirmed an interrupted Secret returns Pending while
the previously cleared Event remains Cleared.

| Dungeon | Depth | Initial/remaining | Parent pass log | Child server log |
|---|---|---|---|---|
| Temple | 4 | 2 → 1 | `20260920T185910Z_Studio_AAF45_last.log` | `20260920T185917Z_Studio_16ADB_last.log` |
| Abandoned Mine | 2 | 4 → 3 | `20260920T190006Z_Studio_B9462_last.log` | `20260920T190014Z_Studio_6B363_last.log` |

Each Secret test recorded a real
`DISCONNECT_ACTIVE_SECRET_PASS` and one Secret boss for concurrent
trigger arrivals. For the 2→1 Event test, the parent additionally
recorded `VERIFIED_MULTIPLAYER_DEPTH_PASS TestDungeon Depth2 party=2`;
for 4→3 Mine Depth4, the parent recorded the equivalent Mine marker.

## Per-member completion reward replay — PASS after correcting the TEMP fixture

The first stricter completion-reward rerun **failed**: entering Depth2 with
brand-new test profiles that had never cleared Depth1 caused the *real*
`CompletionService` save barrier to reject the higher-depth clear with
`DifficultyProgressionFailed`. The server retried the barrier and the test
timed out. This was correct progression enforcement, not a bug to remove:
`20260920T190150Z_Studio_61289_last.log`.

Both Studio fixtures now use the **real**
`DungeonDifficultyProgressionService.record_clear` to give each
disposable member their required preceding-depth clears before simulating
higher-depth entry. They do not disable readiness rules or alter real
profiles. The corrected reruns exercised the actual persisted completion
commit and then constructed a fresh `CompletionService` for a replay
attempt. They compared every surviving member's Gold and completion
reward-history count before and after replay:

- Temple Depth2, Event disconnect, 2→1: parent
  `20260920T190400Z_Studio_6822E_last.log` passed;
  child `20260920T190407Z_Studio_D5574_last.log` records
  `PER_MEMBER_COMPLETION_REPLAY_PASS 1`.
- Abandoned Mine Depth4, Secret disconnect, 4→3: parent
  `20260920T190452Z_Studio_FEFE9_last.log` records
  `VERIFIED_MULTIPLAYER_SECRET_PASS`; child
  `20260920T190459Z_Studio_985BF_last.log` records
  `PER_MEMBER_COMPLETION_REPLAY_PASS 3`.

In both reruns, completion recipients were exactly the surviving connected
members; replay was `already_applied` and did not change their balances or
completion histories. The disconnected member was not a completion
recipient in this scenario. Per-member Event reward replay was also
blocked. Separate accepted optional-boss reward suites cover saved
monster transaction replay more generally.

## Higher-depth party wipe and checkpoint recovery — PASS, service-level

New `DungeonOptionalDepthPartyWipeTest` exercises both dungeons,
Depth2/Depth4 and parties of 1/2/4 using disposable real
`DungeonSessionService`, `DungeonEncounterRuntimeController` and
`DungeonDeathService` instances. A selected Event is Active and its
checkpoint persisted. Each member receives one automatic revive at the
same checkpoint; one living or reviving party member prevents a premature
wipe. After every member consumes that revive and becomes Spectating,
the wipe deadline starts. The run only enters Failed at deadline expiry;
checkpoint and Event audit state persist, and the failed session cannot
be re-admitted as an active run. The initial test lacked
`RunEnteredAtUnix` and was corrected to use the proper frozen event
entry-time snapshot rather than weakening the trigger policy.

Fresh Studio log:
`20260920T190851Z_Studio_D8292_last.log` records
`[Optional Depth Party Wipe Tests] PASS: 392 assertions.`
and `[Optional Boss Studio Focus] PASS: 19 edit-mode suites.`

The broader gameplay backend matrix passed 30/30 suites in
`20260920T190947Z_Studio_F2D0C_last.log`. All four local Rojo
compositions (Dungeon, Base, published-style Dungeon and Base) built
successfully. None was published.

## Explicitly unproven

The 1-player wipe scenario was tested at service level and the earlier
solo physical optional routes passed locally, but 1-player multiplayer
admission is not a meaningful network scenario. True same-account
reconnection into a newly recreated Roblox reserved server, live network
re-admission into a still-running higher-depth party, in-Play-mode
all-player death/revive and normal-combat balance remain untested.
Recreating service objects or reading a detached encounter snapshot
does not prove a real server restart. Event/Secret eligibility is forced
to both selected for the local multiplayer fixtures; independently
selected eligibility combinations already passed separate depth-specific
backend matrix tests, not the simultaneous-touch Play-mode scenarios.

No cloud test, TEST/PROD publish, player DataStore modification,
force-push, main merge or model/mesh work was carried out.
