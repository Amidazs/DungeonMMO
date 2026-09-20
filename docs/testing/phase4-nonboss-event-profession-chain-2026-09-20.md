# Phase 4 — non-boss Event variations and cross-profession backend

Date: 20 September 2026. Integration branch:
`wip/phase-4-test-hud-integration-v1`.
Previous accepted v1.51 checkpoint:
`adbc700b17cf79a0990b8e92c6c459de2e58315a`.

## Scope and safety

All implementation and fixture source files were authored in GitHub
**first**, then fast-forward pulled into the existing Windows
integration worktree for disposable local Rojo and Studio testing.
The ordinary Roblox game retains its original after-Room1 optional
boss, disabled higher-depth/optional release switches, disabled
late-Event template switch and disabled new
`DungeonMMOOptionalEventCombatEnabled` server switch.
No cloud place was published; no actual player's DataStore or
authored map/mesh was changed.

The new content is **two non-boss combat variations**, not a
cave-in, environmental hazard, genuinely staggered/time-limited
enemy wave, or a second event scheduler. The server selects one
eligible, already-established `EventAfterRoom2` side-room
encounter for a run. A separate independent opt-in chooses
either `Ambush` (four enemies) or `Surge` (eight enemies)
from a deterministic server seed and persists the exact
mechanic/pack identity in the run snapshot. Existing Event
window, late-room entrance gate, required Room2 prerequisite,
Secret route, controller, execution registry, checkpoint,
per-enemy rewards, session recovery and per-run frequency
limit are reused unchanged. Both variants use the already
implemented Marauder enemy factory with unique event-specific
enemy/reward identities, and do not spawn an optional boss
in the same slot.

The Temple and Mine Depth2–4 late-room placeholder layouts
register eight independent enemy-spawn anchors and an explicit
CombatPack-capable, boss-capable physical slot. The optional
policy refuses unregistered/mismatched executor kinds, unknown
mechanics, unavailable packs, insufficient spawn capacity,
an unverified late-room placement or a second Event.
The original early Event boss and the old late Event boss
remain the defaults when the new mechanic switch is OFF.

## Local backend and physical Play-mode acceptance — PASS

**Fresh final deterministic focused Studio tests:**
`0.739.0.7390687_20260920T211057Z_Studio_511F9_last.log`:
`[Optional Combat Variations] PASS: 144 assertions.`
`[Optional Boss Studio Focus] PASS: 25 edit-mode suites.`
Tests cover the independent on/off switches, seeded 4/8
variant selection at both dungeons Depth2–4, one Event plus
one Secret, stable required-room order, saved recovery of
the original pack, exact capacity requirement and rejection
of mismatched boss-vs-combat executor combinations.

**Assisted physical walking Play mode:**

| Dungeon/depth | Selected event | Parent Studio log | Result |
|---|---|---|---|
| Temple Depth2 | Four-enemy `TempleRelicAmbush` | `20260920T210016Z_Studio_66742_last.log` | `VERIFIED_COMBAT_PLAY_PASS TestDungeon Depth2` |
| Abandoned Mine Depth4 | Eight-enemy `MineDeepSurge` | `20260920T210151Z_Studio_FE166_last.log` | `VERIFIED_COMBAT_PLAY_PASS AbandonedMine Depth4` |

The simulated character walked across the actual after-Room2
bridge into the chosen encounter trigger, defeated spawned
enemies with test assistance, returned to the main path,
cleared Secret and all required rooms, and completed the
dungeon. Both logs record exact `SPAWN_COUNT_PASS` (4 or
8), a non-boss event reward-replay denial and an independent
Secret reward-replay denial. The two early disposable
Temple fixture attempts did not complete: one wrongly
assumed the previous seed's Secret variant, and the second
printed a nonexistent EventCombat `BossId`. Both fixture
errors were corrected **through GitHub**, and the two
fresh passing runs above are the acceptance evidence.

**Real simulated Studio party lifecycle:**

| Dungeon/depth | Initial → remaining | Parent Studio log | Child server log |
|---|---|---|---|
| Temple Depth2 ambush | 2 → 1 | `20260920T210400Z_Studio_2D57A_last.log` | `20260920T210407Z_Studio_A2008_last.log` |
| Mine Depth4 surge | 4 → 3 | `20260920T210526Z_Studio_13139_last.log` | `20260920T210533Z_Studio_0E671_last.log` |

Both parent logs record `VERIFIED_MULTIPLAYER_COMBAT_PASS`.
Each child confirms one pack despite simultaneous entrance,
a real mid-combat Studio PlayerRemoving, unchanged surviving
checkpoint/Active encounter, saved next-room progression,
distinct per-enemy reward receipts and replay denial,
and persisted per-member completion reward replay rejection
for exactly one/three connected surviving recipients.
The detached interrupted-event snapshot reconstructs as
Pending without resetting earlier cleared Rooms1/2.
The 4-player Mine test also completes its existing returning
miniboss/Secret/final route after the eight-enemy pack.

This is an assisted backend/physical trigger playtest, not a
genuine same-account reconnect to a new reserved server,
unassisted combat balance, or a staggered-wave implementation.

## First broader backend milestone: professions — PASS

A separate new **bidirectional** crafting chain now uses the
existing Blacksmithing, Alchemy, gathering, inventory, minigame
hand-off and atomic profile mutation without a second crafting
service or station runtime.

1. Blacksmithing smelts ore into an `iron_bar` and forges the
   existing `ironbound_gloves`.
2. Alchemy combines a blacksmith-made `iron_bar` with gathered
   `silverleaf` into new `forging_flux`.
3. Blacksmithing consumes `ironbound_gloves`, one `iron_bar`
   and Alchemy's `forging_flux` to forge new equippable
   `runic_ironbound_gloves`.

The new items and two recipe IDs are registered in the
existing shared item/recipe catalogues with the existing
Blacksmithing and Alchemy station IDs and minigame identities.
No new authored station, interface or fully finished
Leatherworking/Enchanting profession was claimed.

**Fresh local craft acceptance:**
`0.739.0.7390687_20260920T211224Z_Studio_C2AE5_last.log`:
`[Profession Cross Dependency] PASS: 46 assertions.`
`[Profession Backend Focus] RESULT passed=7 total=7 failed=0`.
The real services gather materials, smelt five bars,
forge base gloves, enforce missing flux/ingredient checks,
require the correct minigame, protect equipped ingredients,
consume all items exactly once in one profile mutation,
refuse a duplicate craft without materials, and persist
exactly one finished runic glove item across a freshly
constructed ProfileService reload.

## Cross-system final regression

Fresh final broad backend matrix:
`0.739.0.7390687_20260920T211147Z_Studio_5DBC0_last.log`,
`RESULT passed=30 total=30 failed=0`.
All four local Rojo compositions (Dungeon, Base, published-
style Dungeon, published-style Base) built successfully,
with no cloud publish.

The original optional-boss/default after-Room1 route remains
unchanged in source; see its final Play-mode regression
receipt in the latest roadmap/test-matrix closeout.

## Next *larger backend* increment

Continue actual cross-profession content rather than
adding further boss/event aliases: add Leatherworking and
Enchanting to the existing definition/recipe/inventory and
server-validated station pipeline, define gathering inputs,
and make at least one recipe depend on products of two other
professions. Accept anti-dupe, migration, incompatible
equipment, persistence and one real station interaction
before presenting those professions as fully playable.
Raids/weekly boss and guild castle PvP remain later,
separately scoped backend milestones. Historical same-user
network rejoin/cloud publishing/unassisted party combat
remain independent deferred gates.
