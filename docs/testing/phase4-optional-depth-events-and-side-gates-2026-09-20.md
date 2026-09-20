# Phase 4 — depth-specific optional events and side entrances

Date: 20 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Starting source: `7f1abf2fe79fe96f763dec86746a335bf004df31`.

## Scope

Continue the existing Event/Secret boss framework rather than adding a
second event scheduler or changing the accepted Depth1–4 progression.
All source changes were authored in GitHub, fast-forward pulled into the
existing Windows integration worktree and tested with local Rojo/Studio.
Models, textures, player DataStores, TEST/PROD cloud places and existing
release switches were untouched.

The existing optional encounter catalogue already defines separate
EventArena/SecretArena insertion anchors for Temple and Mine at Depth1–4.
Depth2–4 remain unreleased and their physical optional arenas are NOT
registered or connected to the deeper placeholder routes. New
higher-depth tests use explicitly synthetic optional binding capabilities,
not a release-enabled authored map.

## Defect 1: Secret entrance prerequisite fixed

Original `DungeonOptionalEntranceGates.status` always used Room2 as
the Secret prerequisite. At higher difficulties, Secret is scheduled
immediately before the final room: Depth2 follows Room3, Depth3 follows
Room4, and Depth4 follows Room5. The fixed Room2 gate could open too
early. The new gate logic reads the immediately preceding required room
from the saved ordered binding plan and fails closed if that binding
is invalid. Existing detached Depth1 tests retain their legacy
Room1/Room2 fallback when no binding order was supplied. No encounter
sequence is moved or rerolled.

The new regression was run RED before this change:
`0.739.0.7390687_20260920T172312Z_Studio_AF3EE_last.log`
recorded a failure that the higher-depth Secret gate opened at Room2.

## Defect 2: Mine placeholder gate lifecycle fixed

The physical placeholder builder produces EventBridge and SecretBridge
for both dungeons, but `DungeonOptionalEntranceGates.get/sync`
previously only recognized the Temple root. Thus Mine's entrances
remained sealed even when the encounter was eligible and the prerequisite
room was cleared. The existing gate controller now accepts the same
explicit, replaceable placeholder structure for `AbandonedMine` and
`TestDungeon`; unknown/authored roots remain untouched. Mine also
receives the existing short entrance-unavailable objective from
DungeonRuntime, without modifying its Event/Secret selection.

The new Mine regression was run RED before this change:
`0.739.0.7390687_20260920T172707Z_Studio_A19C6_last.log`
recorded the missing Mine gate resolution.

## New backend acceptance coverage

`DungeonOptionalDepthEventIntegrationTest` runs two dungeons × four
difficulties × four independent Event/Secret eligibility combinations.
It verifies that optional encounters extend rather than replace the
3/4/5/6 required-room plans, Event remains required, Secret remains
skippable, no second boss can start, and each side gate opens after its
actual required predecessor. It uses synthetic bindings for higher
depths, not their unreleased physical maps.

`DungeonOptionalTimedEventRecoveryTest` creates eight disposable
per-depth sessions backed by the real session/encounter controllers and
shared in-memory storage. It verifies that a new run arriving after an
event window does not inherit the expired Event, while an eligible
saved run retains its entry-time Event and separate Secret eligibility
after the global window expires. Mine's existing DeepEchoes modifier
stays independent of the MineEchoSurge optional-boss event. Rebuilding
the controller does not duplicate the frozen encounter plan or spawn
another active Event.

The final focused Studio log:
`0.739.0.7390687_20260920T172758Z_Studio_5A67B_last.log`
records 712 optional depth/eligibility assertions, 116 timed-event
recovery assertions, 32 gate assertions and 17/17 focused suites PASS.

## Fresh physical and broader regressions

- Temple Depth1 deferred Secret backtracking and final-room completion
  passed in the assisted physical fixture after the prerequisite fix:
  `0.739.0.7390687_20260920T172606Z_Studio_F9AEE_last.log`;
  markers `BACKTRACK_SECRET_CLEARED_MAIN_ROUTE_INTACT` and
  `TEMPLE_FIGHT_PLACEHOLDER_PLAY_PASS`.
- Mine Depth1 Event, Secret, rewards and final-room progression passed
  in the existing assisted placeholder gameplay fixture after enabling
  the shared gate controller:
  `0.739.0.7390687_20260920T172820Z_Studio_42CB1_last.log`;
  marker `MINE_FIGHT_PLACEHOLDER_PLAY_PASS`. That fixture positions the
  player near triggers and assists boss defeats. Physical bridge
  traversability is not independently demonstrated by this fixture.
- All four local Rojo compositions completed: Dungeon, Base,
  published-style Dungeon and published-style Base. These are local
  builds only, not cloud publishing. The normal gameplay backend matrix
  passed 30/30 selected suites:
  `0.739.0.7390687_20260920T172908Z_Studio_84F61_last.log`.

## Remaining scope

Higher-depth optional bosses are backend-plan ready but their physical
side rooms, bridges, and depth-specific side-room gate positions are not
integrated into the Depth2–4 placeholder layouts. Do not remove release
locks or interpret these synthetic policy tests as higher-depth physical
playtest acceptance. Normal player combat at higher depths, actual
same-account server rejoin, dynamic event art, cloud TEST verification
and PROD release all remain separate. The user's previously confirmed
manual solo optional-boss playtest is not being repeated.
