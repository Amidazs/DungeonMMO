# Phase 4 — server-owned dynamic Event/Secret boss variants

Date: 20 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Source checkpoint at start: `2c7ff212a783ead9f467621c3ecb4763a06071f0`.

## Scope, implementation and rollout

The accepted Event/Secret issuance, encounter catalogue, ordered encounter
plan, physical triggers, dungeon session storage, boss executor, discovery
service and reward service were reused. No second scheduler, party system,
event planner, new boss animation, mesh or authored arena was added.
The existing `DungeonMMOOptionalBossVariantsEnabled` **server-only**
attribute is newly read by `DungeonInstanceDirector.runtime_options`;
the opt-in defaults to false. Existing `OptionalBossRuntimeEnabled`
and Depth2–4 `RuntimeReleaseEnabled` flags remain OFF in source.

The shared `DungeonOptionalBossVariantCatalog` registers one legacy and
one alternate Event/Secret identity per dungeon. Server-issued, eligible
runs choose their optional variant deterministically from the existing
run seed only when the variant opt-in is true. A selected run persists its
exact Event ID/window, Secret unlock ID and materialized encounter plan;
a reconnect/controller restart does not reroll it. Ineligible runs receive
neither a bonus encounter nor a spurious unlock. An invalid saved ID
fails closed instead of substituting another boss. Existing older
callers with no saved variant state continue to receive the original
Event/Secret descriptors.

| Dungeon | Kind | Original ID / boss | Opt-in alternate ID / boss |
|---|---|---|---|
| Temple | Event | TempleEclipse / TempleEventBoss | TempleEchoHunt / TempleDepth2Boss |
| Temple | Secret | TempleHiddenSanctum / TempleSecretBoss | TempleForgottenVault / TempleDepth3Boss |
| Abandoned Mine | Event | MineEchoSurge / AbandonedMineEventBoss | MineFaultSurge / AbandonedMineDepth2Boss |
| Abandoned Mine | Secret | MineSealedGallery / AbandonedMineSecretBoss | MineDeepCache / AbandonedMineDepth3Boss |

Alternate bosses deliberately reuse existing implemented Depth2/3 factories
as backend placeholders. Their IDs describe server-owned run variants,
not new final visual assets. The Event is still required after Room1;
Secret remains skippable after the selected depth's penultimate required
room. At most one Event and one Secret can enter a run. The original
Mine DeepEchoes dungeon modifier is distinct from the optional event.

## Two RED discoveries and minimal production fixes

**Secret variant discovery:** A first Temple Depth2 alternate Play-mode
run selected both variants and walked across the Event bridge, but Secret
never started. Log:
`0.739.0.7390687_20260920T192436Z_Studio_917A8_last.log`,
`TIMEOUT SecretArena server encounter activated`. The existing
`DungeonSecretDiscoveryService` had hard-coded checks for the two
original Secret boss IDs. It now checks the already persisted boss ID
and matching server-frozen unlock against the same dungeon's catalogued
Secret variants, both on discovery and on replay. It preserves the
existing proximity, membership, sequence, deferred-Secret and failed
storage guards. It does not accept a client-selected unlock.

**Reward collision from factory reuse:** An initial stricter reward
fixture failed because the alternate Event boss used an inherited
`MarauderCaptain` enemy reward ID rather than an
encounter-scoped transaction ID. Log:
`0.739.0.7390687_20260920T193108Z_Studio_4572E_last.log`.
That inherited ID would also be shared by a Depth4 returning miniboss
using the same factory. `BossEncounterExecutor` now sets
`DungeonEnemyId = BossId:RuntimeEncounterId` for EventBoss, SecretBoss,
MiniBoss and FinalBoss encounter kinds. The original Depth1 legacy
`Boss` reward identity is unchanged. Reward-service idempotence and
session-based transaction IDs are reused; no new currency or reward
grant service was introduced.

## Studio backend acceptance — PASS

The new `DungeonOptionalDynamicVariantTest` covers two dungeons,
four depths, four independent Event/Secret eligibility combinations
and four deterministic variant selection seeds. It confirms
content-factory registration, exact persisted identities, one
Event/Secret per run, insertion positions, skippability, old behaviour
with opt-in disabled, fail-closed corrupted IDs and frozen-plan
reconstruction after an expired event window.

The new `DungeonOptionalDynamicSecretDiscoveryTest` exercises
original and alternate Secret discovery at all four depths in both
dungeons, including original saved unlock, duplicate discovery,
expired window, deferred Secret and rejecting other encounter IDs.
The new `DungeonOptionalVariantRewardIdentityTest` spawns identical
implemented factories first as optional bosses and again as returning
minibosses, then verifies separate persisted reward transactions
and no new Gold/history from reward replay.

Final focused log:
`0.739.0.7390687_20260920T193405Z_Studio_01438_last.log`:
- Dynamic variant planning: 2,205 assertions PASS.
- Original/alternate Secret discovery: 232 assertions PASS.
- Independent variant/miniboss reward identity: 80 assertions PASS.
- Full optional focused matrix: 22/22 suites PASS.

The existing gameplay backend matrix also passed 30/30:
`0.739.0.7390687_20260920T193655Z_Studio_7A273_last.log`.
All four local Rojo compositions built: Dungeon, Base,
published-style Dungeon, published-style Base. These are local builds,
not Roblox cloud publishing.

## Physical and real simulated-client Play mode — PASS

`scripts/studio/phase4_optional_dynamic_variant_play.luau`
enables the optional variant attribute and fixes seed 7 **only in its
disposable loaded Studio DataModel** to exercise both alternates. Its
automated character walks through each optional bridge, triggers
the server-owned boss, and returns to required rooms. Enemy defeats
and player survivability are assisted, not normal-combat balance tests.

- Temple Depth2 (six encounters): final log
  `0.739.0.7390687_20260920T193436Z_Studio_B5907_last.log`
  contains `REWARD_REPLAY_PASS Event TempleDepth2Boss`,
  `REWARD_REPLAY_PASS Secret TempleDepth3Boss`,
  `ALTERNATE_PLAY_PASS TestDungeon Depth2`, and
  `VERIFIED_ALTERNATE_PLAY_PASS TestDungeon Depth2`.
- Mine Depth4 (eight encounters): final log
  `0.739.0.7390687_20260920T193531Z_Studio_5678E_last.log`
  contains `REWARD_REPLAY_PASS Event AbandonedMineDepth2Boss`,
  `REWARD_REPLAY_PASS Secret AbandonedMineDepth3Boss`,
  `ALTERNATE_PLAY_PASS AbandonedMine Depth4`, and
  `VERIFIED_ALTERNATE_PLAY_PASS AbandonedMine Depth4`.
- Original variant-disabled Temple Depth2 (six encounters) passed on
  the final source without selecting an alternate:
  `0.739.0.7390687_20260920T193726Z_Studio_34B7B_last.log`,
  `VERIFIED_PLAY_MODE_PASS TestDungeon Depth2`.

The TEMP `phase4_depth_optional_multiplayer_lifecycle.luau` fixture
also opted into both alternate identities with four real Studio client
processes in Mine Depth4. Two touched Event concurrently: only one
boss spawned. After a real client Kick during Event, three remained
in the same active party/session; they cleared Event, Secret, all
returning minibosses and Final. Each surviving member's Event reward
receipt is distinct from the later same-factory miniboss receipt, and
their Secret reward is distinct from the later same-factory miniboss
receipt. Final completion rewards were committed once to the three
survivors with a replay guard.

Parent log
`0.739.0.7390687_20260920T193934Z_Studio_93B26_last.log`
has `VERIFIED_MULTIPLAYER_DEPTH_PASS AbandonedMine Depth4 party=4`.
Child server log
`0.739.0.7390687_20260920T193941Z_Studio_00F81_last.log`
has `ALTERNATE_PARTY_PLAN_PASS MineFaultSurge/MineDeepCache`,
`EVENT_ONE_BOSS_CONCURRENT_PASS`,
`DISCONNECT_ACTIVE_EVENT_PASS`,
`RETURNING_BOSS_REWARDS_DISTINCT_PASS`,
`PER_MEMBER_COMPLETION_REPLAY_PASS 3`, and
`MULTIPLAYER_DEPTH_PASS AbandonedMine Depth4 initial=4 remaining=3`.

## Remaining boundaries

Event/Secret variants are a limited backend catalogue, not an arbitrary
number of simultaneously spawning optional bosses and not a new weekly
world-boss scheduler. All new boss visuals are placeholders/reused
factories. The saved variant-controller test reconstructs disposable
service state; actual same-account network rejoin and a newly
reserved Roblox server remain unverified. No real player DataStore,
TEST/PROD cloud place, authored art, released higher-depth map, main
merge or live release flag was changed.

The original `DungeonMMO_Roadmap_v1_47.docx` remains preserved;
roadmap updates were authored through the GitHub connection rather
than editing a Windows Word document with Remote Desktop.
