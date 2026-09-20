# Phase 4 — after-Room2 Event physical route and multiplayer lifecycle

Date: 20 September 2026. Source branch:
`wip/phase-4-test-hud-integration-v1`.
Pre-implementation rollback commit:
`a7e6b2ccd033a651b5b980f6749ee64079c34527`.

## Changes (GitHub first; disposable, unpublished Studio only)

The existing saved `EventAfterRoom2` template from roadmap v1.50 now has
a separate temporary physical route in both Temple and Abandoned Mine,
Depth2–4, **only** when an unpublished local Studio place explicitly
sets `DungeonMMOPlaceholderOptionalPlayEnabled` and the new independent
`DungeonMMOPlaceholderLateEventPlayEnabled` workspace opt-in.
The existing independent server-only
`DungeonMMOOptionalBossTemplatesEnabled` opt-in must additionally be
enabled in that disposable test to issue a late Event. None of these
switches is enabled in ordinary source or a production place.

The existing replaceable Depth2–4 blockout now includes a dedicated
`EventArenaLate` side room opening from required **Room2**, with its
own bridge, closed server-owned `EventBridgeLate.EntranceGate`,
encounter trigger, checkpoint, boss-spawn anchor and distinct layout
slot. The slot declares `OptionalPlacementVerified=true` and its
exact, difficulty-specific `OptionalInsertAfterId`:
`Depth2Combat2`, `Depth3Combat2` or `Depth4MiniBoss1`. The latter
is a real returning miniboss on Depth4; Room2 is not assumed to
always contain ordinary enemies.

The existing gate controller now reconciles **three independently
selectable** higher-depth side entrances: old EventArena, new
EventArenaLate and SecretArena, driven by the saved encounter plan
and the immediately preceding required room's Cleared state.
The unused early-Event bridge stays sealed when a late Event is issued,
even after Room1/Room2 clear. An ineligible late route stays sealed.
The existing Depth1 side bridges remain sealed during higher-depth
runs. The runtime's existing gate-status UI also recognizes the new
entrance without adding a second trigger/scheduler/controller.

The new room is temporary geometry, not finished authored models.
There is still at most **one Event and one Secret boss per run**.
The late Event's stable `BossId .. "LateEncounter"` encounter identity,
checkpoint and encounter-scoped reward transaction survive interruption.

## Physical geometry and gate acceptance — PASS

New `DungeonLateEventPhysicalLayoutTest` (85 assertions) exercises
Temple/Mine at **all three** higher depths (Depth2, Depth3 and Depth4).
It checks independent late slot/bridge/gate registration, exact depth
prerequisite, Room2 east-side entrance, level walkable floor/bridge,
unique trigger/checkpoint/boss anchors, the gate remaining closed
after Room1, opening only after Room2, closing on a recovered uncleared
Room2, sealing both Events when neither was issued, and the existing
early Event and Secret slots still being present.

Fresh initial Studio log:
`0.739.0.7390687_20260920T203109Z_Studio_3A584_last.log`,
`[Late Event Physical Tests] PASS: 85 assertions.`
and `[Optional Boss Studio Focus] PASS: 24 edit-mode suites.`

## Fresh local *walking* Play-mode acceptance — PASS

Fixture: `scripts/studio/phase4_late_event_physical_play.luau`.
Only the loaded TEMP DataModel overrides the selected dungeon's
optional release switch, seeds the run at 7, opts into alternate
already-implemented bosses and the late physical route, and uses
assisted enemy defeats/elevated temporary player HP. The character
uses Humanoid:MoveTo through the actual Room2 east opening and
across the bridge, triggers the late boss in its own room, then
walks back into the required-room route and clears Secret/final.

| Dungeon/depth | Total encounters | Parent Studio log | Result |
|---|---:|---|---|
| Temple Depth2 | 6 | `20260920T203138Z_Studio_9124E_last.log` | `VERIFIED_LATE_PLAY_PASS TestDungeon Depth2` |
| Abandoned Mine Depth4 | 8 | `20260920T203249Z_Studio_308E5_last.log` | `VERIFIED_LATE_PLAY_PASS AbandonedMine Depth4` |

Both logs show physical
`WALKED_EventLate_BRIDGE_IN` /
`WALKED_EventLate_BRIDGE_OUT`,
server encounter completion, separate Event/Secret reward
`REWARD_REPLAY_PASS` receipts and dungeon completion.
Both unselected old Event and original Depth1 bridges remained sealed.
The Mine Depth4 run also cleared the returning minibosses in their
ordinary required-room positions. These are **assisted Studio Play
tests**, not unassisted combat/balance tests.

## Real simulated Studio clients and mid-boss disconnect — PASS

Fixture:
`scripts/studio/phase4_late_event_multiplayer_lifecycle.luau`.
It admits distinct actual simulated Studio clients into one
server-owned selected run, uses the same Room2-late Event trigger,
and asserts exactly one spawn under concurrent approaches.
One member is really kicked while the late boss is Active;
`PlayerRemoving` marks that party member disconnected without
resetting the survivors' checkpoint or Active encounter. A detached
sequencer reconstructs the late Event as Pending after interruption
with both Room1 and Room2 remaining Cleared. The survivors finish
the late boss, Secret and all required rooms. Reward transaction
replay returns `already_applied` and does not change per-member
monster reward histories. Completion persists exactly once for
connected survivors, checked via a fresh CompletionService replay.

| Dungeon/depth | Initial → remaining | Parent Studio log | Child server log |
|---|---|---|---|
| Temple Depth2 | 2 → 1 | `20260920T203609Z_Studio_7A13E_last.log` | `20260920T203617Z_Studio_7001C_last.log` |
| Abandoned Mine Depth4 | 4 → 3 | `20260920T203724Z_Studio_075F7_last.log` | `20260920T203731Z_Studio_062B2_last.log` |

Both parent logs contain `VERIFIED_MULTIPLAYER_LATE_PASS`.
The child logs include `FROZEN_ALTERNATE_LATE_PLAN_PASS`,
`LATE_ONE_BOSS_CONCURRENT_PASS`,
`DISCONNECT_ACTIVE_LATE_PASS`,
`LATE_REWARD_REPLAY_BLOCKED`,
`PER_MEMBER_COMPLETION_REPLAY_PASS` (1 or 3 respectively),
and `MULTIPLAYER_LATE_PASS`.

The first two-client attempt **failed only at a later fixture
assertion** that expected Depth4 returning miniboss reward identities
in a Depth2 dungeon. All preceding late-Event/disconnect/reward
assertions had passed. That check is now limited to Depth4, and
the separate fresh two-client rerun listed above passed.
The four-client Depth4 fixture additionally verifies that the
reused optional and returning miniboss factories earn separate
per-member rewards instead of colliding.

## Original-route and other regressions

Fresh optional-enabled **original after-Room1** Temple Depth2
physical walking playtest:
`0.739.0.7390687_20260920T203830Z_Studio_17506_last.log`,
`VERIFIED_PLAY_MODE_PASS TestDungeon Depth2`.

Fresh **optional-disabled** original four-room Temple Depth2
Play-mode run:
`0.739.0.7390687_20260920T203935Z_Studio_6EEBF_last.log`,
`VERIFIED_PLAY_MODE_PASS TestDungeon Depth2`.
The preexisting optional-enabled, after-Room1 six-encounter Temple
Depth2 route also passed in the separate log immediately above.

Fresh final local regression receipts:
- `0.739.0.7390687_20260920T204125Z_Studio_FAFEE_last.log`:
  `Late Event Physical Tests PASS: 85 assertions`,
  `Optional Boss Studio Focus PASS: 24 edit-mode suites`.
- `0.739.0.7390687_20260920T204057Z_Studio_F7283_last.log`:
  `Phase4 Gameplay Matrix RESULT passed=30 total=30 failed=0`.
- All **four local Rojo build compositions** passed:
  Dungeon, Base, published-style Dungeon and published-style Base,
  under TEMP `DungeonMMO_LateEvent_Final_*.rbxl`. These were local
  build products, not cloud publishing.
Do not treat a standalone planning test, a simulator's disconnected
member or a detached recovered sequencer as proof of same-account
network rejoin to a recreated reserved server.

## Safety and deferred acceptance

The actual user account, live player DataStores and TEST/PROD
published Roblox places were not modified. No authored modelling,
cloud validation, unassisted combat or actual same-account
cross-server network reconnect was performed. The special
server/workspace switches used by these fixtures are **local,
disposable test-only settings**; higher-depth release flags and
the default early Event placement remain unchanged in source.
