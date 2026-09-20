# DungeonMMO Test and Acceptance Matrix

## 20 September 2026 — v1.52 combat Event variety / cross-profession backend

- [x] Independently default-OFF new combat variation
  selects exactly one frozen after-Room2 Ambush (4) or
  Surge (8), Temple/Mine Depth2–4, using the generic
  CombatPack executor, saved plan and existing timed event.
- [x] 144 variation assertions: both seeds, both dungeons,
  all higher depths, legacy defaults, one Event/one Secret,
  spawn capacity, mismatched/unknown mechanic and boss
  executor rejection, stable interrupted-run recovery.
- [x] Actual assisted physical Temple Depth2 Ambush and
  Mine Depth4 Surge runs: walk new side bridge in/out,
  correct 4/8 count, per-enemy/Secret reward replay denial,
  full dungeon completion.
- [x] Two-client Temple and four-client Mine: concurrent
  entrance starts exactly one pack, actual mid-fight Studio
  disconnect preserves survivors and checkpoint,
  detached interrupted encounter recovers Pending,
  per-member combat and completion rewards persist once.
- [x] Fresh original optional-enabled Temple Depth2 six
  encounters and optional-disabled Temple Depth2 four
  required encounters physically pass unchanged.
- [x] 25/25 optional-focused, 30/30 general backend suites,
  four local Rojo build compositions PASS.
- [x] Bidirectional Blacksmithing/Alchemy recipe chain:
  46 new assertions for real material inventory mutation,
  correct minigame, equipped-item safety, missing material/
  dupe prevention and save/reload output. 7/7 profession
  focused suites PASS independently in local Base and
  Dungeon compositions.
- [ ] New Event mechanics remain default-OFF/local only;
  truly staggered waves, cave-in, enemy AI/environment
  hazards, Leatherworking and Enchanting, real secured
  station interaction, actual user DataStore migration,
  same-account cross-server reconnect, unassisted party
  balance and cloud TEST/PROD remain unaccepted.

Evidence: docs/testing/
phase4-nonboss-event-profession-chain-2026-09-20.md.
Roadmap: docs/roadmap/
DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md.

## 20 September 2026 — physical after-Room2 Event v1.51

- [x] Explicit, local-only Temple and Mine Depth2/3/4
  EventArenaLate/bridge/gate plus independent trigger,
  checkpoint and boss-spawn anchors; first Event and
  Secret physical slots retained. 85 structural/gate
  assertions PASS across all six combinations.
- [x] Late-Event gate remains closed after Room1; opens
  after the *saved* Room2 clear; unselected first Event
  and old Depth1 entrances remain sealed; recovery closes
  late gate if Room2 not Cleared.
- [x] Assisted actual walking Play mode: Temple Depth2 and
  Mine Depth4 physically enter/exit late arena, trigger
  Event and Secret, and clear full six/eight encounters
  with alternate boss/transaction replay receipts.
- [x] Two-client Temple Depth2 and four-client Mine Depth4
  independent Studio multiplayer runs: concurrent late
  trigger = one boss; real PlayerRemoving mid-boss keeps
  survivors and checkpoint; detached reconstruction
  retains Rooms1/2 and resets interrupted late boss
  Pending; connected members receive distinct optional
  and completion rewards exactly once.
- [x] Original after-Room1 optional-enabled six-encounter
  Temple Depth2 walking route and fully optional-disabled
  original four-room Depth2 route pass unchanged.
- [x] Fresh 24/24 optional-focused suites, 30/30 broad
  gameplay backend suites and four local Rojo builds PASS.
- [ ] New gate/geometry and template switches remain OFF
  in ordinary source. True network same-account reconnect,
  cloud TEST/PROD publish, unassisted party combat and
  new non-boss environmental events are not accepted here.

Dated parent/child log receipts and strict limitations:
docs/testing/phase4-late-event-physical-multiplayer-2026-09-20.md.
Latest roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md.

## 20 September 2026 — configurable Event placement v1.50

- [x] Legacy EventAfterRoom1/SecretBeforeFinal remain the default,
  even for old run-state snapshots without the new template field.
- [x] Independently opted-in, eligible Depth2–4 runs freeze a
  deterministic EventAfterRoom2 placement with a unique encounter
  and separate EventArenaLate physical-room identity.
- [x] 274 assertions: late Event follows two required encounters;
  invalid/unsupported templates fail closed; one Event and one Secret
  per run; duplicate optional physical slots are rejected; interrupted
  late Event reconstructs Pending without changing the saved room.
- [x] Missing, mismatched or unverified late placement is refused
  with OptionalBossContentUnavailable, not silently remapped to
  the old EventArena.
- [x] 23/23 optional-focused suites and 30/30 broad gameplay backend
  suites PASS; all four local Rojo compositions built successfully.
- [x] Fresh original Temple Depth2 Event/Secret assisted walking
  Play mode PASS; fresh alternate-boss Temple Depth2 route and two
  encounter-scoped reward replay checks PASS.
- [ ] EventArenaLate still lacks a registered physical arena,
  gate/bridge, trigger and spawn. Its synthetic planner tests are
  NOT a physical/party Play-mode acceptance for the late route.
- [ ] Environmental event types, normal-health combat, true same-user
  network reconnect and TEST/PROD cloud release remain separate.

Evidence: docs/testing/
phase4-optional-event-placement-templates-2026-09-20.md.

## 20 September 2026 — dynamic optional boss variants

- [x] Server-only opt-in OFF by default; Depth2–4 and original optional
  runtime release flags untouched; old Event/Secret selected without opt-in.
- [x] 2,205 assertions for frozen variant/eligibility combinations
  in Temple and Mine, Depth1–4; invalid saved identities fail closed,
  recovered interrupted encounter retains original variant.
- [x] 232 exact Secret discovery, replay, window-expiry and deferred
  backtrack assertions for original and alternate identities.
- [x] 80 same-factory Event/Secret/returning-miniboss independent
  reward assertions, including persisted monster-history replay.
- [x] 22/22 optional-focused, 30/30 broader backend suites and four
  local Rojo compositions PASS.
- [x] Assisted physical alternate-boss route and reward replay PASS:
  Temple Depth2 (6 encounters) and Mine Depth4 (8 encounters).
- [x] Existing variant-disabled Temple Depth2 physical route PASS.
- [x] Four-client Mine Depth4 alternate-boss Play mode PASS:
  duplicate concurrent Event spawn blocked; real mid-Event disconnect
  preserves other 3; optional and later miniboss with same factory
  earn different receipts for each survivor; final completion replay
  blocked for all three recipients.
- [ ] Dynamic variants use implemented boss placeholders, not new art,
  an arbitrary number of Event slots or a new weekly scheduler.
- [ ] True same-user network reconnect, real cloud TEST/PROD release,
  unassisted higher-depth combat and actual player DataStore writes
  remain unverified and intentionally deferred.

Logs: docs/testing/
phase4-dynamic-optional-boss-variants-2026-09-20.md.

## 20 September 2026 — higher-depth multiplayer lifecycle

- [x] Two-client Temple Depth2 and four-client Mine/Temple Depth4 shared
  run, one Event boss despite simultaneous entry, actual disconnect
  mid-Event and peer/3-member continuation to completion.
- [x] Two-client Temple Depth4 and four-client Mine Depth2 mid-Secret
  disconnection: one Secret boss, preserved checkpoint/ongoing encounter,
  remaining party continues and completes.
- [x] Strict follow-up Temple Depth2 2→1 and Mine Depth4 4→3 runs:
  persisted completion recipient sets match connected surviving members;
  a reconstructed CompletionService returns already_applied and does
  not change per-member Gold or reward history.
- [x] Fixture-only previous-depth progression bootstrap uses
  DungeonDifficultyProgressionService; real higher-depth completion
  remains blocked if a profile lacks its prior clears.
- [x] Service-level 1/2/4-member party wipe/automatic revive and
  authoritative Event checkpoint tests: 392 assertions PASS.
- [x] Fresh 19/19 optional-focused and 30/30 gameplay backend suites;
  all four local Rojo compositions build successfully.
- [ ] Actual same-account network rejoin/new reserved-server recreation,
  physical in-Play whole-party death/revive and manual unassisted
  higher-depth party combat remain distinct acceptance gates.
- [ ] Cloud TEST/PROD publish and higher-depth release flags remain
  deliberately unchanged.

Receipts: docs/testing/
phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md.

## 20 September 2026 — higher-depth optional physical integration

- [x] Temple and Mine Depth2/3/4 TEMP geometry: level side bridge
  floors, open main-room wall, depth-specific checkpoint, trigger and
  boss spawn; original required rooms remain intact.
- [x] Active-depth entrance gating: 139 assertions; unused Depth1
  side bridges remain sealed while opted-in Depth2–4 routes play.
- [x] 18/18 optional-focused suites; 30/30 gameplay backend suites.
- [x] Six separate physical walking Play-mode scenarios pass both
  optional bosses and dungeon completion: Temple/Mine Depth2/3/4,
  with six/seven/eight encounters respectively.
- [x] Mine Depth4 physically bypasses Secret, backtracks to clear it,
  then completes the pending Final using TEMP-only spawn deferral.
- [x] Optional-disabled Temple Depth2 original four-room route PASS.
- [x] All four local Rojo build compositions succeed.
- [ ] Unassisted manual combat, true cross-server same-account rejoin
  and cloud release verification remain separate.
- [ ] Higher-depth production release flags remain OFF; TEMP test
  layout registration is not published.

Evidence:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.

## 20 September 2026 — per-depth Event/Secret integration

- [x] RED → GREEN: Secret gate prerequisite uses the actual preceding
  required room in the frozen encounter order, not always Room2.
- [x] RED → GREEN: both Temple and Mine placeholder side bridges are
  managed by the existing server-owned gate controller.
- [x] Two dungeons × four depths × four Event/Secret selection cases:
  712 assertions PASS using synthetic higher-depth slot bindings.
- [x] Per-depth saved entry-time Event-window expiry and Secret
  independence after new server-controller construction: 116 PASS.
- [x] Shared side-gate and recovery test: 32 assertions PASS.
- [x] 17/17 optional-focused suites; 30/30 gameplay-backend suites PASS.
- [x] Fresh assisted Temple/Mine Depth1 optional physical route PASS.
- [x] All four local Rojo compositions built successfully.
- [ ] Higher-depth optional physical routes and bridge geometry remain
  unregistered; the synthetic tests do not establish physical play.
- [ ] Cloud TEST verification, true same-user reconnect and PROD
  remain intentionally deferred.

Evidence: docs/testing/
phase4-optional-depth-events-and-side-gates-2026-09-20.md.

## 20 September 2026 — full depth-ladder progression

- [x] Temple/Mine Depth1–4 3/4/5/6 encounter plans, Depth4 previous
  bosses as minibosses and distinct final boss identity.
- [x] Fresh 454-assertion saved-profile/session ladder integration PASS;
  five focused Studio suites PASS.
- [x] Actual completion service commits one reward/unlock per depth;
  repeated commit does not duplicate rewards or progress.
- [x] Reconstructed Depth4 interrupted miniboss returns Pending with
  prior clear and persisted checkpoint intact.
- [x] Four local Rojo compositions, 30/30 gameplay backend suites and
  Base Play-mode regression PASS.
- [x] One fresh assisted Temple Depth2 physical route PASS; older six
  individual higher-depth Temple/Mine physical cases remain documented.
- [ ] Remaining five physical routes were NOT revalidated as fresh by
  the stopped multi-Play runner; the unsupported runner was removed.
- [ ] Unreleased Depth2–4 entry still fails actual content-readiness
  checks; no cloud/production enablement or unassisted combat acceptance.

Evidence:
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.

## 20 September 2026 — full saved-session recovery

- [x] Fresh 15/15 focused optional-boss Studio suites PASS.
- [x] New 42-assertion two-member, multi-restart service-level
  recovery suite PASS: frozen eligibility, checkpoint, interrupted Event,
  Final and deferred Secret, physical entrance gates, idempotent reward.
- [x] Fresh assisted Temple physical backtracking regression PASS.
- [x] User reports manually defeating both optional bosses solo;
  the earlier failed automated injured-solo case is historical.
- [ ] Actual same-account Roblox network rejoin and reserved-server
  reconstruction are not proven by service-level emulation.
- [ ] Cloud TEST release verification remains intentionally deferred.

Detailed evidence:
docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.

## 20 September 2026 — consecutive optional-boss gameplay

- [x] Two ordinary-health Studio players defeat Event followed by Secret
  using normal client combat, with surviving party members.
- [x] A separate two-player run confirms server-accepted Dodge and
  equipped healing skill (+32 total HP) between the two boss encounters.
- [x] The defensive/healing run defeats Secret and passes the assisted
  final-room completion check.
- [ ] Single injured survivor defeating Event then Secret remains
  unproven: the earlier no-recovery solo attempt FAILED.
- [ ] All-room unassisted combat, manual navigation, same-account rejoin
  and cloud TEST acceptance remain separate.

Receipts: docs/testing/
phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.

## 20 September 2026 — optional boss normal-combat acceptance

- [x] Real client combat defeats Temple Event at ordinary player HP.
- [x] Real client combat defeats Temple Secret in a separate healthy
  two-client run with no direct boss HP manipulation.
- [x] Secret normal-combat fixture completed final dungeon progression
  with assisted prerequisite/final-room combat and reward replay checks.
- [ ] Same injured survivor beating Event then Secret without recovery:
  local attempt FAILED; player died before Secret was defeated.
- [ ] Complete ordinary-health unassisted combat across every room,
  normal healing/dodge use, manual player navigation and true rejoin.

Evidence: docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.

## 20 September 2026 — optional boss real two-client local fixture

- [x] Two distinct local Studio clients in a shared eligible Temple run.
- [x] Simultaneous Event entry spawns one boss, not two.
- [x] Real mid-Event PlayerRemoving retains connected peer, active Event,
  checkpoint and frozen plan.
- [x] Detached interrupted-Event reconstruction returns Event Pending;
  prior Room1 stays Cleared.
- [x] Survivor clears Event then Room2, Secret boss and final boss.
- [x] Event reward replay returns already_applied; Secret reward recorded.
- [x] Fresh test re-run parent+child Studio logs report PASS.
- [ ] Actual same-account reconnect or reconstructed live server after
  interrupted boss remains untested.
- [ ] Unassisted combat/balance and any published-cloud acceptance deferred.

Evidence: docs/testing/
phase4-optional-boss-two-client-playtest-2026-09-20.md.

## 20 September 2026 — optional-boss lifecycle local follow-up

- [x] RED then GREEN: unsaved normal/Event startup must reset Pending.
- [x] RED then GREEN: unsaved Secret skip must not advance main route.
- [x] 14/14 focused Studio suites; 11 fault, 24 two-member recovery,
  28 four-way eligibility/physical-gate assertions PASS.
- [x] Five temporary Rojo build compositions succeed.
- [x] Local Temple: gate prerequisites, deferred Secret, final room PASS.
- [x] Optional rollout-locked normal Dungeon Play-mode baseline PASS.
- [x] Studio two-client disconnect: session, checkpoint and peer preserved.
- [ ] Two-client Event/Secret boss fight, reward replay and rejoin test.
- [ ] Same-account real network reconnect or cloud TEST release verification.

Detailed receipts: docs/testing/
phase4-optional-boss-lifecycle-hardening-2026-09-20.md.

## 20 September 2026 — optional gate recovery follow-up

- [x] Existing server-owned Event/Secret gates present on integration branch.
- [x] Fresh TEMP TEST Temple and Dungeon test Rojo builds completed.
- [x] Focused Studio optional tests: 13/13 suites PASS.
- [x] Entrance gate unit regression: 16 assertions PASS, including
  recovery reopen, incomplete Room2 fail-closed and restored Secret access.
- [x] Fresh TEMP physical Temple route rerun: both gates initially closed,
  Room1/Event and Room2/Secret prerequisites, Secret backtrack and final
  room completion PASS (assisted fixture). Log:
  20260920T151909Z_Studio_C434B_last.log.
- [ ] Cloud TEST Dungeon gate version verified after HTTP 429 attempt.
- [ ] Current cloud TEST Dungeon saved and version noted before republish.

Evidence: 20260920T151636Z_Studio_1BE9F_last.log and
phase4-test-temple-optional-entrance-gates-2026-09-20.md.

## 19 September 2026 — combined Phase 4 TEST Temple + restored HUD integration

**Active new worktree/branch:** DungeonMMO_Phase4_HUD_Integration_v1 /
wip/phase-4-test-hud-integration-v1. The isolated merge
43e175f4f2ad4fb3140a36a0ae99ccde49d11825 joins the backend parent
f00e581 and saved UI parent 7fa63fb; both original branches and worktrees
remain untouched. Pushed immutable source checkpoint tags:
phase4-before-hud-integration-backend-20260919 and
phase4-before-hud-integration-ui-20260919. All three documentation
conflicts retained BOTH historical branches' text.

The original framed profile/portrait, bottom-right menu, six-slot Dungeon
hotbar, contextual Inventory/Skills/Guild windows and redesigned dungeon
objective/boss/reward/revive HUD have been restored to the TEST candidate.
The Base intentionally has no Dungeon combat hotbar. Both TEST Temple and
sync-only Lobby build compositions contain their matching UI source.

**Fresh proof:** six Rojo compositions and 559 source+41 original Studio
runner Luau files compiled; 11/11 focused optional suites; Base live
regression 107 test-pass markers (four Roblox Controls Emulator plugin
errors); Dungeon live regression 221 test-pass markers and zero Creator
errors. The restored Dungeon HUD live-client test passed framed/menu/hotbar,
boss animated bar, rewards and revive with zero Creator errors. The Base
live-client test passed framed/profile/menu/expedition UI, exclusive
Inventory/Skills/Guild open and close (same Controls Emulator plugin
errors). The exact combined TEST Temple composition passed both local
published-ID simulations for Depth1 optional arenas and Depth4 physical
bindings; those runs logged a built-in Roblox ChatScript SetCore startup
error, not a game-code assertion failure. Final visual/playtest acceptance
is STILL OPEN.

**Cloud release boundary:** no TEST/PROD cloud publish or current cloud
place rollback backup has been verified. For the restored HUD release
candidate use scripts/powershell/Start-Phase4TestTempleHUDPublish.ps1 in the
integration worktree, NOT the old backend-only launcher. Before any TEST
publish, save/verify the currently published Temple Roblox place
117293035754309 and note its version history. The Lobby
134132328219009 is sync-only: never overwrite its authored map with
the standalone local Rojo sync file. No Mine place exists.

Detailed preserved evidence and remaining manual gates:
docs/testing/phase4-restored-hud-test-integration-2026-09-19.md.


## 19 September 2026 — TEMP playable physical layouts, both dungeons Depth1–4

This checkpoint supersedes the older **geometry-only** placeholder status
below; the separate editable `.rbxlx` remains geometry-only, while the
**source-generated, explicitly opted-in unpublished Studio** layouts now have
real runtime physical bindings. Temple/TestDungeon and AbandonedMine each
passed all three 4/5/6-room Depth2/3/4 physical encounter sequences, including
Depth4 three returning minibosses + final boss. Both dungeons' Depth1
Event/Secret fight, skip and on-foot optional-room traversal cases also
passed. Combat kills and high-depth player health were assisted in these
fixtures; these are not unassisted player combat/release acceptance.

- Source up to `e3b3022` passed four Rojo compositions, 549 source and
  30 Studio runner compilation checks, and all 11 focused edit-mode suites.
- Base fresh regression passed, 107 PASS markers and zero Creator errors.
  Two ordinary Dungeon regression attempts failed intermittent pre-existing
  combat-test startup deadlines despite live baseline success. Only those
  test waits were extended to 25 seconds. A fresh Dungeon regression at
  `37cef9b` passed the player and dummy assertions, 221 PASS markers, and
  zero Creator errors.
- Explicit unpublished Studio-only opt-in:
  `DungeonMMOEnvironmentMode=Synthetic`,
  `DungeonMMOPlaceholderPhysicalContentEnabled=true`,
  `DungeonMMOPlaceholderPlayableEnabled=true`; Depth1 optional physical
  slots require the separate `DungeonMMOPlaceholderOptionalPlayEnabled`
  opt-in. Runtime optional-boss eligibility/release is still separately
  locked; do not copy TEMP fixture overrides into live source.
- The shared production content catalogue still only registers Depth1;
  higher-depth `RuntimeReleaseEnabled` and both
  `OptionalBossRuntimeEnabled` values remain false. No main merge,
  production or TEST Roblox publish, or DataStore mutation occurred.
- Full log receipts, scenario IDs, code paths and remaining limits:
  `docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md`.
  Final authored room geometry, ordinary combat/balance/UI, same-user
  reconnect and release acceptance remain separate gates.


## 19 September 2026 — replaceable dungeon physical placeholders available

- Editor-ready **geometry-only** Studio scene:
  `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`.
  It includes separate Temple and Mine EventArena/SecretArena Models, walkable
  bridges, and unregistered Depth2/3/4 room/corridor previews (330 editable
  parts in 62 models). Studio static geometry verification passed.
- The source builder is
  `src/ServerScriptService/Dungeon/DungeonPlaceholderPhysicalContent.luau`;
  its opt-in synthetic Studio bootstrap can preview current Depth1 with
  placeholders while leaving both optional boss flags false and higher-depth
  physical layouts unregistered.
- **This is a replaceable blockout, NOT final authored release geometry or
  playable high-depth content.** The standalone editor scene has no runtime
  scripts and its visual anchor markers are not registered live bindings.
  Keep encounter/anchor identities when replacing with meshes/models.
- Usage/validation and limitations:
  `docs/testing/phase4-physical-placeholders-2026-09-19.md`.
  No merge to main, TEST/PROD publish or optional-boss rollout occurred.

## 19 September 2026 — remaining release gates: local proof, NOT release acceptance

The earlier four-step **backend** checkpoint below remains valid. New
TEMP-only Play-mode scripts have now additionally verified: real simulated
client leave and a separate client's arrival in Base, actual Dungeon
PlayerRemoving persisting a disconnected member while its peer/plan/checkpoint
remain active (the Studio party session uses a fixture-only override),
on-foot walking through all five synthetic Temple and Mine encounters without
per-room teleport, and one standard client basic attack reducing the live
Temple Event boss from 144 to 134 health. Boss combat and progression other
than that single attack still used explicit fixture assistance.

- Latest new fixture source: 0c2251633b70f92314abc4d0ec9d4fd50bb1dbe4.
- Evidence: docs/testing/phase4-remaining-release-gates-local-proof-2026-09-19.md.
- The departed Studio client's replacement has a **different UserId**; a true
  same-account rejoin, published cross-place transfer and production group
  admission have NOT been exercised. Real authored side rooms, an entire
  unassisted boss fight and visual/UI acceptance also remain unverified.
- Optional-boss rollout remains disabled; no main merge, TEST/PROD publish
  or production DataStore change is approved by these local fixture results.
- Next gated action: obtain explicit permission before using the isolated
  published TEST environment for same-account reconnect and cross-place tests.
  Do not mark Phase 4 release accepted on the basis of the local probes.

## Current checkpoint — 19 September 2026: four backend steps verified

The following supersedes the earlier Step 2-only status; historical evidence
remains below. **Gameplay/test source**: 3700dba7c6124e3401b615ce126d80cb7f1edb88.
**Final normal-regression/static source**: c86a90471cc3c36bbd9437ada685f4377d7e2ebe.
Branch: wip/phase-4-event-secret-policy-v1, isolated from main, UI and art.

- Recovery: event window, plan, discovery and cleared/skipped encounters survive
  session/controller reconstruction; interrupted boss returns to Pending;
  duplicate reward replay is blocked. Live Temple fixture simulated member
  disconnect/reconnect while the actual Studio player remained connected.
  **A real network leave/rejoin or cross-place handoff is NOT proven.**
- Mine: TEMP Play-mode fought-secret and skipped-secret paths both completed.
  Skipping persisted without secret discovery or secret reward.
- Four bosses have different server-authoritative two-phase attack patterns
  using existing Captain pose, telegraph, hit and defence systems. TEMP Temple
  and Mine combat fixtures passed with test-assisted positioning and defeats;
  natural battle balance and presentation are not proven.
- 11/11 focused Studio edit-mode suites passed on 3700dba. At c86a904, all
  four local Rojo compositions built; 547 Lua/Luau files parsed without error.
  Fresh unpublished Base/Dungeon Play baselines: respectively 108 and 222
  test PASS markers, zero Creator errors, and both release locks stayed false.
  Base Phase 3 stress passed (profiles=250, market=1000, replay=1000,
  guild=250, sessions=100, race_roundtrips=100).
- Evidence: docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md.
- Canonical working roadmap is docs/roadmap/DungeonMMO_Roadmap_v1_45.docx
  (SHA-256 349d8a568856091ec2dbdadfde4b7785f608e65d2ac8f2429c838d9a86a943ac);
  roadmap index docs/roadmap/README.md. DOCX structural validation passed;
  visual page-render QA is still pending following a stalled Word export.
  TEMP-only synthetic fixtures do not imply authored side-arena acceptance.
  OptionalBossRuntimeEnabled remains false; higher-depth physical layouts
  remain unreleased. Do not merge to main or publish based on these tests.
- Next release/content gates: genuine client/network reconnect, authored
  room traversal, unassisted combat and player-facing UI, multiplayer/cross-place
  admission and final release acceptance.

## Current checkpoint - 19 September 2026 Step 2 GitHub-first backend proof

This section supersedes the Step 1 status below; its validation details remain
historical evidence, not a statement about the current source.

- Active backend branch: wip/phase-4-event-secret-policy-v1.
- Step 2 code and test source validated at ae1ab32be03fe5c2ff9874f95df49a8c56ff069a.
  The former uncommitted work was preserved and pushed at bd83446. Later
  gameplay/test changes were committed directly using the Amidazs GitHub
  connector, then fast-forwarded into the clean isolated backend worktree.
- Server-only candidate event schedule and secret discovery, independent boss
  reward identities and optional book drops are implemented. Rollout remains
  disabled for both dungeons; no physical side arenas or higher-depth physical
  layouts have been registered.
- All four local Rojo builds passed; 544 Lua/Luau source files compiled with
  zero failures at ae1ab32. A fresh TEMP local Studio RunScript session passed
  eight optional-boss EDIT-MODE suites: RunState, Schedule, SecretDiscovery,
  Policy, Flow, Factories, ReleaseLock and Reward.
- Edit-mode tests are not a live Play-mode or physical/gameplay acceptance test.
  TEMP-only physical trigger/combat/reward/reconnect checks and broad
  Base/Dungeon Play-mode regressions remain before release consideration.
- Main, UI/art worktrees, published games and production data were not changed.
- Source-controlled runner: scripts/studio/optional_boss_focused_tests.luau.
  Detailed evidence: docs/testing/phase4-optional-boss-step2-backend-checkpoint-2026-09-19.md.
- Next: complete the live/physical acceptance gate separately; then continue
  backend-only work on distinct Event/Secret boss combat behaviour. No merge
  or publish is authorised by this checkpoint.

## Current checkpoint - 19 September 2026 step 1 validation

This section supersedes older active-branch, no-push and pending-Studio notes
below. Older gate sections are historical evidence, not current release status.

- Active worktree: C:/Users/Remko/Documents/Roblox/DungeonMMO_Phase4_EventSecretPolicy_v1.
- Branch: wip/phase-4-event-secret-policy-v1.
- Validated source: cb29a7c54637e371e1041ab68009c4951b579d00.
- GitHub feature tip independently verified at the same SHA on 19 September.
- Main and GitHub main remain a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9;
  this backend branch is not merged into main.
- v1.44 is now committed on this feature branch. Its statements about the
  uncommitted issuer/test edits and an unpushed optional-boss branch are
  superseded by this checkpoint.
- Step 1 backend regression is VERIFIED on the exact committed source.
  This is not physical-content acceptance or rollout approval.
- Fresh Dungeon Studio: issuer 34, extended instance director 23, policy 49,
  optional flow 9, factories 24, release locks 14, readiness 70 assertions PASS.
- Dungeon server captured 248 PASS markers and zero errors; live admission passed.
- Fresh Base Studio: 132 PASS markers, issuer 34, readiness 70, party difficulty
  22 and party difficulty entry 32 assertions PASS; server/client errors = zero.
- Phase 3 stress PASS in both compositions: profiles=250, market=1000,
  replay=1000, guild=250, sessions=100, race_roundtrips=100.
- 539 source Lua/Luau files parsed with zero failures; four Rojo builds PASS.
- OptionalBossRuntimeEnabled remains false for both dungeons. Depth2-Depth4
  remain physically unregistered and release-disabled.
- No gameplay source changed in this validation step. Documentation/evidence
  changes remain uncommitted; no commit, push, merge or publish was performed.
- Known diagnostics: expected audit-sink failure injection in both runs;
  source-controlled fallback-animation notice in Dungeon. Neither is a test failure.
- Evidence: docs/testing/phase4-optional-boss-step1-validation-2026-09-19.md.

### Exact next action

At the step-1 user checkpoint, report the completed backend validation.
Next ordered step is Event and Secret gameplay rules: prepare a bounded design
for actual server event schedules, secret discovery conditions and reward
configuration, reusing existing issuance/session/reward authority. Define
reconnect/idempotency tests before implementation. No concrete schedule,
secret-discovery mechanic or new reward balance is approved by this record.
Distinct enemy/boss mechanics follows as the next substantial combat gate.
Keep physical release locked and the UI/art worktrees separate.

## Historical gate record

**Current phase:** Phase 4 - Content Alpha
**Canonical roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_44.docx
**Phase 3 gameplay release:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

This file records accepted evidence and current gate status. It is not a
replacement for fresh test output when claiming a new result.

## Phase 1 - Combat prototype

**Roadmap status:** ACCEPTED

Previously accepted runtime coverage includes basic attack/swept melee,
blocking, parry, Guard Break, dodge invulnerability, Shield Bash, Mend channel
and cancellation, four-Marauder pressure, death/respawn lifecycle,
controller/mobile emulation and approximately 150 ms simulated round-trip
latency diagnostics.

Presentation remains placeholder quality and is intentionally deferred.

## Phase 2A - Core Base-to-Dungeon slice

**Roadmap status:** ACCEPTED

Accepted coverage includes separate Base/Dungeon builds, central profile/save,
DEV/TEST/PROD namespaces, leases/handoff, 1-4-player session contract,
reconnect/reconstruction, monster XP/Gold, room-start checkpoints, revive and
spectating/wipe flows, Marauder Captain, immutable completion eligibility,
exactly-once rewards, save-before-return, Base/Dungeon UI, reserved-server
teleport, Base -> Dungeon -> Base persistence, timed/manual return, abandon and
deliberate TEST teleport-failure recovery.

Live paid-revive activation remains disabled.

## Phase 2B.A - Progression Foundation

**Roadmap status:** ACCEPTED
**Accepted Git checkpoint:** `24dee751b87d831abe22cd046dd3b9934c566a56`

Accepted PASS families include profile migration, Level/AP/SP entitlement,
Attribute Config/Service, Skill Progression, Loadout, Proficiency, Progression
Damage, Mend Progression, Dungeon Progression Bridge and existing Phase 1/2A
regression families.

## Phase 2B.B - Gameplay + Base Progression

**Status:** ACCEPTED
**Accepted Git checkpoint:**
`ac9546c73d3f2f57221ae71b2f1e7a6ebcd35137`

### Base combined acceptance

- [x] Level 10 Profile HUD/trainer agreement.
- [x] Attribute preview/cancel and atomic spend flow.
- [x] proficiency/rank purchase flow.
- [x] six-slot rearrangement including intentional empty gaps.
- [x] exact later-slot placement, moves, replacement and uniqueness.
- [x] no-op slot clicks without selection and selection clearing after success.
- [x] Attribute TEST respec.
- [x] Skill TEST respec preserving proficiency/knowledge.
- [x] no red runtime errors reported.

### Dungeon combined acceptance

- [x] Arc Slash integration/PASS family.
- [x] first-clear Arc Slash reward/PASS family.
- [x] automatic-free-revive/PASS family.
- [x] first death performs forced three-second free revive.
- [x] second death uses normal defeated flow.
- [x] Captain first-clear awards the bound Arc Slash Skill Book.
- [x] fresh progression snapshot reports `BookOwned=true`.
- [x] fresh progression snapshot reports `ArcSlashFirstClear=true`.
- [x] relevant Phase 1/2A/2B.A regression families remain green.
- [x] no red runtime errors reported.

### Six-slot regression cause/fix

Sparse numeric RemoteEvent arrays lost later entries after an intentional nil
gap. Shared `LoadoutSnapshot.encode` produces six dense wire entries and uses
`false` for empty slots; persistent profile/loadout state remains sparse.

## Phase 2B.C - Persistence + Published Acceptance

**Status:** ACCEPTED
**Accepted code checkpoint:**
`4a82d7486e7455f7597a777e862393c5bbb56cfb`
**Merged accepted main:**
`8be005ff1ef87712bff8fde01d313fd2569771ac`

Published TEST acceptance confirmed:

- [x] fresh Level 1 profile = 5/5/5/5/5, 0 AP/SP, Mend R1 + Shield Bash R1;
- [x] each level gain grants exactly +1 AP/+1 SP;
- [x] Strength changes basic sword damage;
- [x] Vitality changes MaxHealth;
- [x] Spirit changes Mend;
- [x] Mend/Shield Bash proficiency caps at the next threshold;
- [x] DEV/TEST proficiency mutation changes proficiency only;
- [x] trainer rank purchase persists;
- [x] first Captain clear grants exactly one bound Arc Slash book;
- [x] return to Base preserves the book;
- [x] trainer consumes the book + 3 SP atomically and learns Arc Slash;
- [x] Arc Slash auto-fills the first free slot;
- [x] Character -> Skills swaps in Base;
- [x] active Dungeon encounter rejects swap and clear window accepts it;
- [x] Arc Slash requires one-handed sword and multi-target proficiency diminishes;
- [x] Attribute/Skill respec counters and allocation cannot mint points;
- [x] first death auto-revives after approximately three seconds at checkpoint;
- [x] later death uses paid/spectator flow;
- [x] Base -> Dungeon -> Base -> leave -> rejoin preserves the complete state;
- [x] reconnect/idempotency and duplicate protection remain correct;
- [x] fresh Base/Dungeon regressions remained green with no reported red runtime errors.

### Targeted published regression close-out

- [x] only one combat HUD/runtime presentation appears;
- [x] published sword attack presentation works;
- [x] only one Captain/boss runtime spawns;
- [x] shield presentation remains visible in published play;
- [x] shield arm remains behind the shield during Block and Shield Bash;
- [x] swept-volume dodge clearance prevents the under-monster/floor
  fall-through regression.

Detailed evidence is recorded in
`docs/testing/phase2b-gate-c-acceptance-record.md`.

**Phase 2B status:** FUNCTIONALLY COMPLETE.

## Phase 2C - Race/base-class definitions and class-specific trainer catalogues

**Status:** FUNCTIONALLY COMPLETE - PHASE 2C.E RANGER ACCEPTED / MERGED / PUSHED

Phase 2C.A is accepted, merged and pushed.

Phase 2C.C - Equipment Effects + Combat Integration is accepted, merged and pushed.

## Phase 2C.A - Race + Character Identity Foundation

**Status:** ACCEPTED

**Reviewed local-green checkpoint:**

`d13c5b8f834ab9642b0fb3f629bf05f46616e543`

### Task 12 local build and Studio regression

- [x] `git diff --check` clean before full local regression.
- [x] Base full Task 12 build succeeded.
- [x] Dungeon full Task 12 build succeeded.
- [x] Phase 2C.A Race Definitions PASS - 35 assertions.
- [x] Profile Schema/Migration PASS - 43 assertions.
- [x] Phase 2C.A Profile Migration PASS - 38 assertions.
- [x] Phase 2C.A Identity Service PASS - 58 assertions.
- [x] Attribute Config PASS - 14 assertions.
- [x] Attribute Service PASS - 30 assertions.
- [x] Progression Service PASS - 9 assertions.
- [x] Phase 2B Progression Service PASS - 42 assertions.
- [x] Progression Snapshot Builder PASS - 37 assertions.
- [x] Base Progression Controller PASS - 25 assertions.
- [x] Character Combat Stats PASS - 32 assertions.
- [x] Race Presentation Service PASS - 51 assertions.
- [x] Damage Service PASS - 15 assertions.
- [x] Basic Attack Timing Rules PASS - 25 assertions.
- [x] Critical Hit Rules PASS - 10 assertions.
- [x] Shield Bash Integration PASS - 17 assertions.
- [x] Arc Slash Integration PASS - 10 assertions.
- [x] Mend Service PASS - 9 assertions.
- [x] Defensive Combat Integration PASS - 42 assertions.
- [x] Dodge Direction PASS - 45 assertions.
- [x] Dodge Swept Clearance PASS - 8 assertions.
- [x] accepted Core/Base/Dungeon/Phase 2A/Phase 2B regression families remained green.

### Local manual Base/Dungeon regression

- [x] mandatory unresolved race selection.
- [x] incomplete identity blocks gated Base/Dungeon behaviour.
- [x] Human -> Fighter.
- [x] Human baseline 5/4/6/5/5.
- [x] Human Resolve.
- [x] Human Shield Bash + Mend.
- [x] Elf -> Fighter.
- [x] Elf baseline 5/6/4/5/5.
- [x] Elven Grace.
- [x] Elf Shield Bash + Mend.
- [x] Elf ears.
- [x] Elf ears survive respawn.
- [x] race presentation remains idempotent.
- [x] sword combo.
- [x] attack buffering.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] Arc Slash.
- [x] no red runtime exception observed.

### Task 13 published TEST safety

- [x] reviewed Task 12 local-green candidate identified.
- [x] TEST environment confirmed.
- [x] Universe ID `10765241947` confirmed.
- [x] Starting Base Place ID `134132328219009` confirmed.
- [x] Test Dungeon Place ID `117293035754309` confirmed.
- [x] live paid revives remained disabled.
- [x] no PROD profile/DataStore path used.
- [x] no Robux spend.
- [x] no Task 13 monetisation changes.

### New Elf published persistence

- [x] fresh TEST race selection.
- [x] Elf -> Fighter.
- [x] Level 1.
- [x] baseline 5/6/4/5/5.
- [x] Elven Grace.
- [x] Shield Bash + Mend.
- [x] Elf ears in Base.
- [x] Base -> published Dungeon.
- [x] Elf ears in Dungeon.
- [x] normal sword/basic attack behaviour.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] normal Dungeon completion.
- [x] Dungeon -> Base.
- [x] Elf / Fighter preserved after return.
- [x] ears preserved after return.
- [x] leave Experience.
- [x] rejoin Starting Base.
- [x] Elf / Fighter persisted.
- [x] baseline/passive persisted.
- [x] ears persisted.
- [x] skills/progression persisted.

### New Human published persistence

- [x] TEST profile reset to a fresh identity.
- [x] Human -> Fighter.
- [x] Level 1.
- [x] baseline 5/4/6/5/5.
- [x] Human Resolve.
- [x] Shield Bash + Mend.
- [x] Base -> published Dungeon.
- [x] normal sword/basic attack behaviour.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] normal Dungeon completion.
- [x] Dungeon -> Base.
- [x] Human / Fighter preserved after return.
- [x] leave Experience.
- [x] rejoin Starting Base.
- [x] Human / Fighter persisted.
- [x] baseline/passive persisted.
- [x] skills/progression persisted.

### Published sensitive regressions

- [x] one combat HUD/runtime presentation.
- [x] published sword presentation.
- [x] one Marauder Captain runtime.
- [x] camera/view shield visible.
- [x] shield arm remains behind shield during Block.
- [x] shield arm remains behind shield during Shield Bash.
- [x] swept Dodge does not place player under floor.
- [x] swept Dodge does not place player inside monster.
- [x] first free revive works.
- [x] second death reaches normal defeated boundary.
- [x] live paid revive remains disabled.
- [x] Return to Base remains available.
- [x] Arc Slash Skill Book awarded to Inventory.
- [x] Arc Slash learning works.
- [x] Arc Slash loadout works.
- [x] Arc Slash knowledge/loadout persists after rejoin.

### Legacy published migration qualification

- [x] automated Profile Schema/Migration coverage green.
- [x] automated Phase 2C.A Profile Migration coverage green.
- [x] automated Identity Service coverage green.
- [ ] LIVE LEGACY MIGRATION PROOF WAIVED FOR THIS PRE-PLAYER TEST GATE.

The project owner deliberately waived the live legacy-character migration proof
because there are no real players and the current TEST data is disposable
developer/test data.

A live legacy migration proof remains required before any future release that
must migrate real existing player profiles.

### Known deferred issue

- [x] Skill Book reward is correctly granted to Inventory.
- [ ] Skill Book is not listed in the Dungeon Completed reward summary.

The completion-summary display issue is explicitly deferred to the next patch
and is not being treated as a reward/persistence failure.

### Acceptance close-out

- [x] Phase 2C.A acceptance evidence record created.
- [x] explicit user acceptance received.
- [x] Phase 2C.A marked ACCEPTED.
- [x] canonical roadmap updated through external Roadmap v1.30.
- [x] acceptance documentation committed at d3685be4a507f00e0b08bf8d948a41ecfa80b47.
- [ ] merge to `main` deliberately approved/completed.

Phase 2C.A was explicitly accepted by the project owner on 9 September 2026.

## Phase 2C.B - Equipment + Trainer Architecture

**Status:** DESIGN APPROVED - RED CONTRACT PREPARATION
**Starting baseline:** `19f8c31284da80dc87cf5d44560d366e48427888`
**Formal Phase 2C.A acceptance ancestor:** `ad3685be4a507f00e0b08bf8d948a41ecfa80b47`

### Design lock

- [x] user approved Phase 2C.B architecture.
- [x] equipment slots locked: Weapon / OffHand / Helmet / Body / Gloves / Boots.
- [x] Base-only server-authoritative equipment mutation locked.
- [x] race/base-class/class restriction architecture locked.
- [x] level/attribute restrictions deferred.
- [x] unique item instances / random affixes / durability deferred.
- [x] accepted combat sword/shield visual pipeline preserved.
- [x] data-driven Fighter trainer catalogue required.
- [x] Human Fighter trainer path required.
- [x] Elf Fighter trainer path required.
- [x] functional trainer UI required.
- [x] functional six-slot equipment UI required.
- [x] Dungeon Completed Arc Slash Skill Book summary presentation fix included.
- [x] PROD/Robux/monetisation remain out of scope.
- [x] art/dungeon-environment-prototype remains isolated.

### TDD RED bootstrap

The following checks are intentionally expected to fail before production
implementation:

- [x] Equipment Slots contract RED observed.
- [x] Equipment Rules RED observed.
- [x] Phase 2C.B schema-v5 equipment migration RED observed.
- [x] Equipment Service RED observed.
- [x] Phase 2C.B remote contract RED observed.
- [x] Trainer Catalogues RED observed.
- [x] Trainer authorization transport RED observed.
- [x] Completion Reward Presentation RED observed.

Do not mark any of these green merely because Rojo builds successfully.
Actual Roblox Studio runtime output is required.

### Critical migration guard

When schema advances to v5, only pre-v4 data is legacy. Accepted schema-v4
Phase 2C.A Human/Elf profiles must retain their identity and progression and
receive an empty/sanitized Equipment table.

### Acceptance status

Phase 2C.B is NOT accepted and no implementation PASS is claimed at this
checkpoint.
### Phase 2C.B GREEN candidate gate

- [x] Equipment Slots GREEN observed.
- [x] Equipment Rules GREEN observed.
- [x] schema-v5 equipment migration GREEN observed.
- [x] Equipment Service GREEN observed.
- [x] Phase 2C.B remote contract GREEN observed.
- [x] Trainer Catalogues GREEN observed.
- [x] Trainer authority GREEN observed.
- [x] Completion Reward Presentation GREEN observed.
- [x] accepted Base/Core regression families remain GREEN.
- [x] Human Fighter six-slot equipment visual check passed.
- [x] Human TEST Elven Helmet shows RaceRestricted.
- [x] Human Fighter trainer catalogue check passed.
- [x] Elf Fighter trainer catalogue check passed.
- [x] Elf TEST Elven Helmet is eligible/equippable.
- [x] Dungeon accepted regression families remain GREEN.
- [x] Dungeon completion summary lists a newly awarded Arc Slash Skill Book.
- [x] no PROD / Robux / monetisation action occurred.
### Phase 2C.B observed GREEN evidence

Date: 9 September 2026

Base:
- new 2C.B RED families all transitioned to PASS;
- Equipment Slots PASS: 24 assertions;
- Equipment Rules PASS: 9 assertions;
- Equipment Migration PASS: 20 assertions;
- Equipment Service PASS: 38 assertions;
- Trainer Catalogues PASS: 10 assertions;
- Trainer Authority PASS;
- Remote Contract PASS;
- Completion Reward Presentation PASS: 4 assertions;
- Phase 2B / Phase 2C.A migration and identity regressions remained green;
- Human/Fighter and Elf/Fighter equipment/trainer visual checks passed;
- race-specific TEST helmet restriction behaved correctly.

Dungeon:
- accepted combat/dungeon/revive/reward/progression regression families passed;
- Marauder Captain playthrough completed;
- completion rewards committed successfully;
- return window opened normally;
- Arc Slash Skill Book appeared in the completion reward summary.

Result:
GREEN and ready for explicit Phase 2C.B acceptance.

No commit, merge, push, Roblox publish, PROD or Robux action is part of this
GREEN evidence record.
### Phase 2C.B acceptance result

- [x] Fresh Base GREEN evidence reviewed.
- [x] Fresh Dungeon GREEN evidence reviewed.
- [x] Human/Fighter equipment and Fighter Trainer functional check passed.
- [x] Human TEST Elven Helmet correctly rejected.
- [x] Elf/Fighter equipment and Fighter Trainer functional check passed.
- [x] Elf TEST Elven Helmet eligible/equippable.
- [x] Dungeon combat/revive/completion regression check passed.
- [x] Arc Slash Skill Book appeared in the Dungeon Completed reward summary.
- [x] Project owner explicitly accepted Phase 2C.B on 9 September 2026.
- [x] No PROD, Robux, monetisation or art-branch action was used for acceptance.

Result: ACCEPTED. This checkpoint may now be committed on the Phase 2C.B
feature branch. Merge and push remain separate deliberate actions.
### Phase 2C.B local merge verification

- [x] Accepted checkpoint commit verified before merge.
- [x] Local `main` and `origin/main` verified at accepted Phase 2C.A baseline.
- [x] Deliberate no-ff merge used.
- [x] Gameplay/source tree remains identical to accepted Phase 2C.B checkpoint.
- [x] Base and Dungeon rebuilt from merged local `main`.
- [x] Art worktree remains untouched.
- [x] No Roblox publish, PROD, Robux or monetisation action occurred.
- [x] Push local `main` to `origin/main` completed after explicit approval.
### Phase 2C.B remote push verification

- [x] Remote `origin/main` verified unchanged immediately before push.
- [x] Server-side `refs/heads/main` verified unchanged immediately before push.
- [x] Accepted Phase 2C.B merge pushed without force.
- [x] Server-side main verified at the Phase 2C.B merge commit.
- [x] Accepted Phase 2C.B checkpoint verified reachable from remote main.
- [x] Final continuity-doc closeout changes only CURRENT_STATE/HANDOFF/TEST_MATRIX.
- [x] Final local main, origin/main and server main verified equal.
- [x] Final origin/main...main ahead/behind verified 0/0.
- [x] No Roblox publish, PROD, Robux, monetisation or art-branch action occurred.

## Phase 2C.C - Equipment Effects + Combat Integration

**Status:** ACCEPTED - MERGED / PUSHED; MANUAL ARC SLASH + AUTOMATED RUNTIME QUALIFICATIONS RETAINED
**Starting canonical GitHub server main:**
`8587c1546aa1689b69606f860fb5c18a847de617`
**Phase 2C.B accepted checkpoint:**
`fd0d73df70b97efc4b3fb241e2fc6e5061a3ed47`

### Design lock

- [x] reuse the accepted six-slot Equipment state;
- [x] one pure server-authoritative equipment stat resolver;
- [x] representative physical-damage / MaxHealth / crit-chance proof effects;
- [x] runtime Equipment snapshot locks the gear brought into the Dungeon;
- [x] Dungeon equipment mutation remains rejected;
- [x] newly looted equipment cannot change the active runtime snapshot;
- [x] runtime Equipment, not prototype Tool presence, owns weapon tags;
- [x] Base Equipment UI receives server-computed effects/previews/deltas;
- [x] prototype sword/shield presentation may follow equipped representative items;
- [x] no duplicate DungeonSession equipment store;
- [x] deferred scope remains out of 2C.C;
- [x] art branch remains isolated;
- [x] legacy live-migration waiver remains NOT PASS.

### Test-first contract preparation

The following focused tests were authored before their corresponding production
behaviour in the isolated candidate. This environment cannot execute Roblox
Studio tests, so these are **not** being marked runtime RED/GREEN yet.

- [ ] Equipment Stat Resolver runtime GREEN observed.
- [ ] Progression Runtime Equipment runtime GREEN observed.
- [ ] Equipment Weapon Requirement runtime GREEN observed.
- [ ] Equipment Service Effects runtime GREEN observed.
- [ ] Equipment Effect Presentation runtime GREEN observed.
- [ ] Equipment Presentation Rules runtime GREEN observed.
- [ ] Dungeon Studio Equipment Bootstrap runtime GREEN observed.
- [ ] Arc Slash integration regression GREEN observed.
- [ ] accepted Character Combat Stats regression GREEN observed.
- [ ] accepted Equipment Service regression GREEN observed.
- [ ] accepted Base/Core regression families GREEN observed.
- [ ] accepted Dungeon/combat/revive/completion regression families GREEN observed.

### Build and manual evidence

- [x] `git diff --check` clean in the real feature worktree.
- [x] TEMP Base Rojo build succeeded.
- [x] TEMP Dungeon Rojo build succeeded.
- [x] Base Equipment UI functional placeholder accepted; visual overhaul deferred.
- [x] Dungeon gear-aware sword/shield presentation passed manual play.
- [ ] brought-in gear affects combat as expected.
- [ ] newly looted gear does not affect the active run.
- [ ] Human/Elf, crit, attack-rate, Mend, Shield Bash, Arc Slash, revive and
      completion regressions remain accepted.
- [x] no PROD / Robux / monetisation / art-branch action occurred.

The project owner approved the exact local Phase 2C.C commit after fresh build
and manual evidence. Arc Slash was not manually exercised because it was not
unlocked/equipped, and the authored Roblox automated runtime tests were not
separately observed GREEN. Do not rewrite either limitation as a PASS.
Push, merge and publish remain separate explicit approval gates.

### Phase 2C.C acceptance close-out

**Accepted / merged / pushed checkpoint:**
`4f13a4c3868f9f36f09b7519f5e81ec947dbc9b8`

- [x] exact implementation boundary verified at 27 files.
- [x] `git diff --check` clean before the gameplay commit.
- [x] TEMP Base Rojo build succeeded.
- [x] TEMP Dungeon Rojo build succeeded.
- [x] Base Equipment Manager showed all six representative Marauder items.
- [x] visible aggregate matched `+13% Physical Damage`, `+25 Max Health`,
  `+1% Critical Chance`.
- [x] current Equipment UI explicitly accepted as a functional placeholder.
- [x] Dungeon equipment-aware sword/shield presentation accepted in manual play.
- [x] normal requested Dungeon combat/regression flow accepted in manual play.
- [ ] Arc Slash manually exercised during the Phase 2C.C acceptance run.
- [ ] Roblox automated runtime GREEN separately captured for the new 2C.C tests.
- [x] the two unchecked evidence limitations above were explicitly accepted and
  are retained as qualifications rather than rewritten as PASS.
- [x] project-owner Phase 2C.C acceptance received.
- [x] gameplay/docs commit created at the checkpoint above.
- [x] Phase 2C.C feature branch pushed.
- [x] `main` fast-forwarded and pushed to the exact accepted checkpoint.
- [x] GitHub `main` independently confirmed at the accepted checkpoint.
- [x] no Roblox place was published.
- [x] no PROD / Robux / monetisation action occurred.
- [x] separate art worktree remained untouched.
- [x] older dirty recovery worktrees were not cleaned or modified.

Phase 2C.C is formally closed as ACCEPTED / MERGED / PUSHED with the two
explicit runtime-evidence qualifications above. Those qualifications do not
invalidate the accepted architecture or manual/build evidence, but they must
remain visible in future handoffs.

The tracked repository does not name a later Phase 2C sub-gate. The next
engineering gate must be selected from the canonical external Roadmap v1.31
before new source work; do not infer a Phase 2C.D from numbering alone.
## Phase 2C.D - Mage Base-Class + Support Foundation

**Status:** ACCEPTED - GAMEPLAY MERGED / PUSHED
**Accepted gameplay checkpoint:**
`41ac374496f01a1685b62cfd6d6237d0a7e702ec`
**Starting baseline:**
`38feb4a3c15286c56a98ab686357b7cf30f2c693`

### Locked design / implementation

- [x] Human and Elf can begin as Mage.
- [x] Apprentice Arcane Wand is the Mage starter Weapon.
- [x] persistent Equipment owns ArcaneWand authority.
- [x] Spirit Orb is the free ranged Mage basic attack.
- [x] Spirit Orb combo is normal Orb -> normal Orb -> larger AoE Orb.
- [x] projectile travel/collision/target legality/damage are server-authoritative.
- [x] Intellect drives offensive magical scaling.
- [x] Mage runtime Mana foundation implemented.
- [x] Spirit drives Max Mana / regen / heal / Ward scaling.
- [x] Wind Strike is the starter charged damage skill.
- [x] Wind Strike charge may be cancelled by Block or Dodge before resource/cooldown commit.
- [x] Wand basic attacks movement-lock the Mage during committed phases.
- [x] Wind Strike movement-locks during charge/release/recovery.
- [x] Arcane Ward uses replace-not-stack absorption before Humanoid Health.
- [x] local Ward HUD exposes current/max shield.
- [x] Mage Heal supports aimed injured ally or injured self.
- [x] Human/Elf Mage Heal delivery differs between instant/HoT portions.
- [x] Fighter Mend is self-only and costs 20 Stamina.
- [x] Marauder Captain chase speed raised to 17.5 studs/second.
- [x] normal Marauder tuning left unchanged.
- [x] Dungeon Equipment remains run-locked and non-mutable.
- [x] schema-v5 persistence reused; no profile schema bump.
- [x] no mid-run Dungeon unequip control added.
- [x] no Roblox publish / PROD / Robux / monetisation / art-branch action.

### Package / build evidence

- [x] accepted gameplay commit contains exactly 49 files.
- [x] accepted gameplay commit parent is the Phase 2C.C closeout baseline.
- [x] gameplay worktree clean at commit.
- [x] feature branch pushed to the accepted gameplay checkpoint.
- [x] GitHub `main` fast-forwarded to the exact accepted gameplay checkpoint.
- [x] GitHub `main` independently verified after merge.
- [x] fresh TEMP Base Rojo build succeeded before the approved merge.
- [x] fresh TEMP Dungeon Rojo build succeeded before the approved merge.

### Manual Dungeon gameplay acceptance

- [x] Wand presentation visible.
- [x] Spirit Orb basic projectiles fire.
- [x] Spirit Orb damages enemies.
- [x] third basic Orb is visibly larger / AoE.
- [x] Mage cannot move through committed Wand basic attack phases.
- [x] normal movement returns after the committed attack.
- [x] Wind Strike visibly charges.
- [x] Wind Strike fires and damages.
- [x] Block/Dodge can interrupt the Wind Strike charge.
- [x] Arcane Ward works.
- [x] remaining Ward amount is visible.
- [x] Mage Heal works on injured self.
- [x] faster Captain pursuit prevents effortless permanent kiting.
- [x] normal dungeon completion still succeeds.

### Runtime-evidence qualification

- [x] stale Mage identity test expectation was identified.
- [x] stale expectation was updated to Wind Strike / Ward / Heal slots 1/2/3.
- [x] Base rebuilt after the test cleanup.
- [x] Dungeon rebuilt after the test cleanup.
- [ ] fresh Roblox Studio runtime PASS for the corrected Mage identity assertion separately captured.

The unchecked item above is an explicit evidence qualification, not a known
gameplay failure. Do not rewrite it as runtime GREEN without a fresh Studio run.

The earlier Phase 2C.C manual Arc Slash and automated-runtime evidence
qualifications also remain historical qualifications.

### Acceptance result

- [x] project-owner gameplay acceptance received.
- [x] local accepted gameplay commit created.
- [x] feature branch push explicitly approved/completed.
- [x] main fast-forward explicitly approved/completed.
- [x] no Roblox publish occurred.
- [x] gameplay feature worktree/branch preserved after merge.

Result: Phase 2C.D gameplay is ACCEPTED / MERGED / PUSHED at
`41ac374496f01a1685b62cfd6d6237d0a7e702ec`.

The external Roadmap v1.33 leaves Ranger as the remaining prototype starting
archetype. Ranger is the next **design** target; no numbered Phase 2C.E source
gate is locked until that design is explicitly approved.

## Phase 2C.E - Ranger Marksman-Hunter Foundation

**Status:** ACCEPTED - GAMEPLAY MERGED / PUSHED
**Accepted gameplay checkpoint:** `6fe47a178987dc51a75212692201651eb0167326`
**Starting baseline:** `86d27228977dd6c98bd404f12086e93ad94fbe9a`

### Design / architecture lock

- [x] Human and Elf Ranger use one shared data-driven Ranger class foundation.
- [x] Apprentice Longbow is the defining two-handed starter Weapon.
- [x] Longbow reserves OffHand without changing schema-v5 Equipment shape.
- [x] Longbow cannot use Block and does not receive fallback shield presentation.
- [x] Normal / Precision (~0.45 s) / Full Draw (~0.80 s) are free server-timed basics.
- [x] draw permits reduced movement rather than rooting the Ranger.
- [x] Dodge cancels an active draw without firing.
- [x] Precision/Full Draw add damage and critical-chance reward.
- [x] Dexterity leads Ranger ranged damage scaling.
- [x] Piercing Shot costs 20 Stamina and uses diminishing multi-target penetration.
- [x] Human Ranger retains more damage through Piercing Shot penetrations.
- [x] Crippling Shot costs 20 Stamina and applies non-stacking movement slow.
- [x] Elf Ranger receives stronger/slightly longer Crippling control.
- [x] Volley costs 30 Stamina and uses ground-targeted initial impact + short pulses.
- [x] normal arrows do not consume ammunition in this foundation gate.
- [x] persistent Equipment remains weapon authority; Dungeon Equipment stays run-locked.
- [x] special arrows/quivers/poisons/traps/pets and secondary classes remain deferred.

### Automated/runtime evidence observed during acceptance

- [x] Ranger Identity Tests PASS - 30 assertions observed.
- [x] RangerDefinitionsTest PASS observed.
- [x] RangerDrawRulesTest PASS observed.
- [x] RangerSlowServiceTest PASS observed.
- [x] Ranger Marauder slow movement rules PASS observed.
- [x] Equipment reservation contract PASS observed.
- [x] accepted Core/Progression/Equipment/Combat/Dungeon regression families remained green in the captured runs.
- [x] post-hotfix Base/Dungeon retest was reported fully passing by the project owner.

### Manual Base/Dungeon acceptance

- [x] Ranger appears and completes Human/Elf identity flow.
- [x] Apprentice Longbow is granted/equipped persistently.
- [x] OffHand is reserved for the two-handed Longbow.
- [x] Normal bow release works.
- [x] Precision release works.
- [x] Full Draw release works.
- [x] movement is reduced while drawing and restored afterward.
- [x] Dodge cancels a held draw and fires no arrow.
- [x] Piercing Shot works, including multi-target penetration/falloff.
- [x] Crippling Shot works on ordinary Marauders and the Marauder Captain.
- [x] Volley works as ground-targeted area damage.
- [x] normal Marauder and Captain pursuit/combat continue functioning.
- [x] full Dungeon clear and completion rewards succeeded.
- [x] follow-up functional hotfix removes Ranger fallback shield.
- [x] follow-up functional hotfix prevents accepted Block while Longbow is equipped.
- [x] stale Ranger-as-unknown identity assertion corrected.
- [x] Mage/Ranger definition tests no longer wait for a Combat tree in Base.
- [x] no PROD / Robux / monetisation action occurred.
- [x] no Roblox place was published.
- [x] art/dungeon-environment-prototype remained isolated.

### Deferred presentation

- [ ] final Ranger bow/draw/skill animations are intentionally deferred.
- [ ] final Ranger projectile/VFX/audio polish is intentionally deferred.

These are presentation-polish follow-ups, not failures of the accepted Ranger
combat/authority architecture.

### Carry-forward qualification

The pre-player live legacy migration proof waiver remains **not a PASS** and
must be replaced by real migration evidence before a release that must support
real existing player profiles.

**Phase 2C status:** FUNCTIONALLY COMPLETE after accepted Phase 2C.A-E.

## Phase 2 - Starting Base + Temple Integration

**Status:** ACCEPTED
**Accepted integration checkpoint:**
`c7fe89ebda3c97634c97e89ad12e52ec23983ae9`

Accepted evidence includes semantic environment-anchor integration, authored
Starting Base/Temple composition, Base -> Temple -> Base flow, checkpoint and
Captain progression, save-before-return and reconnect/recovery preservation.

## Phase 2 - Profession Foundation

**Status:** ACCEPTED / MERGED / PUSHED
**Accepted gameplay checkpoint:** `ce1577990f2795bf208d7b897e645f32a4a39a4f`

### Supply-chain and persistence evidence

- [x] schema v6 profession state exists for Mining, Blacksmithing, Herbalism and
  Alchemy;
- [x] profession Level/XP migration/default contract;
- [x] Mining -> Blacksmithing complete supply chain;
- [x] Herbalism -> Alchemy complete supply chain;
- [x] Iron Bar / Ironbound Gloves crafting;
- [x] Tempering Oil crafting;
- [x] Blacksmithing Level 2 tempered-gloves gate;
- [x] Tempered Ironbound Gloves cross-profession recipe;
- [x] profession XP is explicitly separate from character XP;
- [x] authoritative Inventory presentation / category tabs;
- [x] crafting prepare is non-mutating and complete is atomic/server-owned;
- [x] Dungeon Equipment remains read-only/run-locked.

### Personal Temple gathering evidence

- [x] multiple resources exist in both Room 1 and Room 2;
- [x] floor/wall/rock raycast placement and partial embedding;
- [x] invalid placements are skipped;
- [x] resources do not collide/query as combat/navigation blockers;
- [x] each node is single-use per player per run;
- [x] another player retains their own copy of the resource;
- [x] duplicate claim rejection;
- [x] reconnect-safe claimed-node reconstruction;
- [x] provisional claim rollback when profile mutation fails;
- [x] client presentation hides claimed nodes only for the owning player.

### Final distribution refinement

- [x] v4 source contract verification PASS;
- [x] `git diff --check` PASS before Studio gate;
- [x] Base Rojo build PASS;
- [x] Dungeon Rojo build PASS;
- [x] published Base Rojo build PASS;
- [x] published Dungeon Rojo build PASS;
- [x] `[Profession Resource Distribution Tests] PASS` observed in Studio;
- [x] Room 1 resources visually distributed around the room;
- [x] Room 2 resources visually distributed around the room;
- [x] minimum same-room resolved spacing contract = 18 studs;
- [x] no new red runtime error reported during the final distribution gate;
- [ ] wider room-scale visual spread beyond the accepted 18-stud minimum is deferred presentation/environment polish and is not a gate blocker.

### Qualification

The pre-player live legacy migration waiver remains a qualification. A real live
schema-v6 migration proof is still required before releasing against real
existing profiles.

## Phase 2 - Second Modular Dungeon + Rare-State/Event Proof

**Status:** ACCEPTED
**Accepted gameplay checkpoint:** `d361348ec045873eed0fd992ceb04bfee908b06a`

The project owner reported the required Studio gameplay gate passed on
16 September 2026.

### Normal Abandoned Mine

- [x] New focused test families PASS.
- [x] Synthetic Abandoned Mine selected instead of Temple.
- [x] Two deterministic module IDs reported.
- [x] Room 1 enemy count = 2.
- [x] Room 2 enemy count = 3.
- [x] Corrupted Foreman presentation.
- [x] Completion and Studio return simulation.

### Forced Crystal Bloom + Deep Echoes

- [x] `Rare=CrystalBloom`.
- [x] `Event=DeepEchoes`.
- [x] Deep Echo presentation in Room 1.
- [x] Crystal Bloom presentation in Room 2.
- [x] Room 1 enemy count = 3.
- [x] Room 2 enemy count = 4.
- [x] Corrupted Foreman and completion remain functional.
- [x] No new red runtime errors reported.

Automated pre-Studio evidence included the RED-baseline contract proof, focused
static verification, clean `git diff --check`, and successful builds of all four
Base/Dungeon published/non-published Rojo compositions.

The current synthetic Mine is functional gameplay proof, not accepted launch
art. No Roblox publish, PROD, Robux, monetisation or art-worktree action
occurred.

## Phase 2 - Party Formation + 1-4-Player Group Entry

**Status:** ACCEPTED
**Accepted gameplay checkpoint:** `726299322fb31689e5e321878f287cccfcb07d81`

The project owner reported the required four-player Roblox Studio Local Server
gate passed on 16 September 2026.

### Multiplayer party flow

- [x] Profile Lease regression PASS with Studio negative synthetic UserIds.
- [x] Player1-Player4 reached authoritative identity Complete.
- [x] Party created by Player 1.
- [x] Players 2-4 invited and accepted.
- [x] Correct 4/4 membership shown.
- [x] Premature start blocked while not all members Ready.
- [x] All-member Ready flow worked.
- [x] Kick propagated and invalidated readiness.
- [x] Leader leave transferred authority deterministically.
- [x] Temple party entry Studio proof.
- [x] Abandoned Mine party entry Studio proof.
- [x] No new red DungeonMMO runtime errors reported.

### Test-environment compatibility

- [x] Negative local-server synthetic UserIds are permitted only in Studio.
- [x] Production positive-UserId rule remains intact.
- [x] Studio PlayerN Human/Fighter auto-identity routes through authoritative
      IdentitySelectionRequest / IdentityService rather than mutating identity
      client-side.

### Qualification

The local Studio proof does not perform a published reserved-server cross-Place
teleport. Real published TEST group teleport remains a later integration/release
check while the accepted party layer reuses the already group-capable
TeleportCoordinator / DungeonSession lower layer.

Automated evidence also included the party static contract, identity-harness
contract, profile-lease regression contract, `git diff --check`, and successful
builds of all four Base/Dungeon published/non-published Rojo compositions.

No Roblox publish, PROD, Robux, monetisation or art-worktree action occurred.

<!-- PHASE3_BLUEPRINT_RECIPE_LEARNING_ACCEPTED_20260917 -->
## Runtime acceptance Ã¢â‚¬â€ Phase 3 Blueprint / Recipe-Learning Ã¢â‚¬â€ 2026-09-17

- Base Ã¢â‚¬â€ `RecipeKnowledgeCraftingGateTest`: PASS, 12 assertions.
- Base Ã¢â‚¬â€ `RecipeKnowledgeServiceTest`: PASS, 23 assertions.
- Base Ã¢â‚¬â€ `ProfileMigrationQuestAdvancementV8Test`: PASS, 8 assertions.
- Base Ã¢â‚¬â€ identity runtime: PASS, completed `Elf / Ranger`.
- Dungeon Ã¢â‚¬â€ `RecipeKnowledgeServiceTest`: PASS, 23 assertions.
- Dungeon Ã¢â‚¬â€ `RecipeKnowledgeCraftingGateTest`: PASS, 12 assertions.
- Dungeon Ã¢â‚¬â€ `ProfileMigrationQuestAdvancementV8Test`: PASS, 8 assertions.
- Dungeon Ã¢â‚¬â€ completion/quest bridge: PASS, 8 assertions.
- Dungeon Ã¢â‚¬â€ admission: PASS, player admitted after full dungeon loop ready.

Non-blocking log debt:
- four synthetic Temple profession-resource placements are skipped because
  their resolved surface is invalid. No test or runtime admission failure
  accompanies these messages.

<!-- PHASE3_SYSTEMS_ALPHA_ACCEPTED_20260918 -->
## Phase 3 - Systems Alpha

**Status:** FORMALLY COMPLETE / ACCEPTED
**Accepted gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6
**Formal closeout date:** 18 September 2026

### Accepted architecture

- [x] Quest + first race-specific Secondary-Class Advancement foundation.
- [x] Damage/Tank/Support Contribution foundation.
- [x] Blueprint / Recipe Knowledge persistence and learning.
- [x] Bestiary + Scholars Reputation foundation.
- [x] Rogue selected/proven as the fourth prototype starting archetype.
- [x] Human Duelist / Elf Windstalker prototype advancement targets.
- [x] broader Rogue skill-tree/progression architecture.
- [x] deterministic Fortified / Rich Deposits / Bounty Dungeon modifiers.
- [x] Rich Deposits integration with reconnect-safe personal gathering.
- [x] Guild creation/membership/roles/progression/leader upgrades.
- [x] private functional Guild Hall.
- [x] limited fixed-price Market with escrow, tax and recovery.
- [x] DEV/TEST Race Change preview/apply/archive/restore.
- [x] shared economy audit events.
- [x] request-rate, stale-state, ownership/membership and replay safeguards.
- [x] shared persisted entity-adapter contract.
- [x] existing Phase 1/2 accepted gameplay architecture preserved.
- [x] catch-up deliberately deferred.
- [x] Transmog deliberately deferred.

### Final Studio evidence

- [x] Rogue Definitions - 43 assertions PASS.
- [x] Rogue Progression - 17 assertions PASS.
- [x] Rogue Advancement - 12 assertions PASS.
- [x] Class Advancement - 29 assertions PASS.
- [x] Contribution Service - 36 assertions PASS.
- [x] Contribution Damage Bridge - 9 assertions PASS.
- [x] Contribution Support Bridge - 13 assertions PASS.
- [x] Contribution real-session persistence - 10 assertions PASS.
- [x] Recipe Knowledge Service - 23 assertions PASS.
- [x] Recipe Knowledge Crafting Gate - 12 assertions PASS.
- [x] Bestiary Service - 33 assertions PASS.
- [x] Bestiary/Reputation reward integration - 25 assertions PASS.
- [x] Guild membership authority - 21 assertions PASS.
- [x] Guild Service / Guild Hall / Dungeon progression - PASS.
- [x] Market listing - 15 assertions PASS.
- [x] Market purchase recovery - 17 assertions PASS.
- [x] Market cancel/expiry - 15 assertions PASS.
- [x] Market remote contract - 6 assertions PASS.
- [x] Race Change planner - 15 assertions PASS.
- [x] Race Change migration - 13 assertions PASS.
- [x] Race Change service - 23 assertions PASS.
- [x] Race Change remote contract - 5 assertions PASS.
- [x] Economy Audit Integration - 27 assertions PASS.
- [x] Rate Limit - 8 assertions PASS.
- [x] Entity Adapter Contract - PASS.
- [x] Dungeon Modifier Definitions - 6 assertions PASS.
- [x] Profession Resource Distribution - PASS.
- [x] existing combat/progression/equipment/Bank/Travel/Dungeon regressions
      remained green in the consolidated run.

### Stress acceptance

- [x] 250 profile migration/save/reload cycles.
- [x] 1,000 market operations.
- [x] 1,000 duplicate/replay attempts.
- [x] 250 guild operations.
- [x] 100 session cycles.
- [x] 100 race-change round trips.
- [x] stress harness reported PASS.

### Release and published TEST evidence

- [x] feature branch pushed.
- [x] local main fast-forwarded to 84662948127eb1a37c9f184c6abbafe6f2daddb6.
- [x] origin/main pushed to 84662948127eb1a37c9f184c6abbafe6f2daddb6.
- [x] GitHub server main independently verified at the same SHA.
- [x] TEST Dungeon 117293035754309 published successfully.
- [x] TEST Starting Base 134132328219009 published successfully.
- [x] both Studio publish state machines reached PublishSuccessful.
- [x] no PROD publish / Robux / monetisation action.

Detailed evidence:
docs/testing/phase3-systems-alpha-acceptance-record.md.

**Next phase:** Phase 4 - Content Alpha.
**First design gate:** Starting Base launch-quality content/presentation.\n

<!-- PHASE4_PROGRESSIVE_DUNGEON_DEPTH_LOCAL_GREEN_20260918 -->
## Phase 4 - Progressive Dungeon Depth + Difficulty Backend Foundation

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Implementation checkpoint:** `1230e6c`
**Baseline:** `a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9`

### Backend contract

- [x] Temple and Abandoned Mine expose Depth1-Depth4.
- [x] Depth1/2/3/4 expose 3/4/5/6 logical encounters.
- [x] scaling increases monotonically by depth.
- [x] Depth4 reuses prior bosses as minibosses.
- [x] Depth4 ends with a new final boss.
- [x] schema v13 persists independent dungeon-depth progression.
- [x] legacy `DungeonProgress` remains independent.
- [x] Depth1 is logically unlocked by default.
- [x] sequential clears unlock the next depth idempotently.
- [x] solo and party entry validate authoritative difficulty.
- [x] all party members must own the selected unlock.
- [x] difficulty persists through session/reconnect/TeleportData.
- [x] immutable instance state carries the logical encounter plan.
- [x] Fortified composes with depth HP.
- [x] Bounty applies after depth monster-reward scaling.
- [x] completion Gold scales by depth.
- [x] completion records the depth clear before the profile save barrier.
- [x] Depth1 remains RuntimeReady.
- [x] Depth2-Depth4 remain fail-closed / RuntimeReady=false.

### Repository-wide validation

- [x] Luau parse: 467 files, 0 failures.
- [x] `git diff --check`: PASS.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary review: 44 changed files, 0 art/model/mesh/terrain/image
      files.
- [x] no `DungeonMMO_Art` merge or modification.

### Final Dungeon Studio evidence

- [x] Dungeon Difficulty Definitions: 78 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] no project CreatorErrors reported.

### Final Base Studio evidence

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] no project CreatorErrors reported.

### Carried-forward stress regression

- [x] 250 profile cycles.
- [x] 1,000 market operations.
- [x] 1,000 duplicate/replay attempts.
- [x] 250 guild operations.
- [x] 100 session cycles.
- [x] 100 race-change round trips.
- [x] Phase 3 Systems Stress reported PASS in both final compositions.

### Release qualification

- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`.


<!-- PHASE4_GENERIC_DUNGEON_ENCOUNTER_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Generic Dungeon Encounter Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `1e1574c`
**Implementation checkpoint:** `5ba9f4d`

### Generic runtime contract

- [x] generic materialized encounter plan.
- [x] arbitrary ordered encounter counts.
- [x] one active encounter at a time.
- [x] Pending -> Active -> Cleared/Skipped lifecycle.
- [x] required versus optional completion semantics.
- [x] stable encounter-ID checkpoints.
- [x] persisted immutable materialized run plan.
- [x] reconnect-safe encounter lifecycle reconstruction.
- [x] Combat encounter kind.
- [x] MiniBoss encounter kind.
- [x] Boss encounter kind.
- [x] FinalBoss encounter kind.
- [x] EventBoss encounter kind.
- [x] SecretBoss encounter kind.
- [x] optional InsertBeforeId / InsertAfterId.
- [x] server-owned InstanceFlag activation.
- [x] server-owned RareState activation.
- [x] required inserted encounter cannot be bypassed.
- [x] inactive optional encounter is absent from the materialized plan.
- [x] active optional encounter remains frozen into the run across reconnect.

### Depth1 compatibility integration

- [x] existing Room1/Room2/Boss physical triggers retained.
- [x] existing CombatRoom1 EncounterService ID retained.
- [x] existing CombatRoom2 EncounterService ID retained.
- [x] existing MarauderCaptain EncounterService ID retained.
- [x] logical boss ID decoupled as Depth1Boss.
- [x] Depth1 physical room-slot bindings are explicit.
- [x] unbound activated optional encounter fails with EncounterBindingMissing.
- [x] legacy Room1Start checkpoint supported.
- [x] legacy Room2Start checkpoint supported.
- [x] legacy BossRoomStart checkpoint supported.
- [x] stable EncounterStart:CombatRoom1 checkpoint supported.
- [x] stable EncounterStart:CombatRoom2 checkpoint supported.
- [x] stable EncounterStart:Depth1Boss checkpoint supported.
- [x] live Dungeon progression authority no longer uses Room1/Room2/Boss clear
      booleans.
- [x] existing doors, rewards, Marauder/Captain/Foreman implementations remain
      compatible.

### Focused Studio evidence

- [x] Dungeon Encounter Plan: 13 assertions PASS.
- [x] Dungeon Encounter Sequencer: 22 assertions PASS.
- [x] Dungeon Encounter Runtime State: 9 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 19 assertions PASS.
- [x] Depth1 Encounter Bindings: 14 assertions PASS.
- [x] Depth1 Encounter Flow: 14 assertions PASS.
- [x] Depth1 Encounter Recovery: 11 assertions PASS.
- [x] Dungeon Recovery Rules: 18 assertions PASS.

### Real live Dungeon acceptance

Temporary validation-only harness, removed before final source checkpoint:

- [x] real Room1 trigger entered.
- [x] real Room1 enemies spawned and died through live Humanoids.
- [x] CombatRoom1 persisted Cleared.
- [x] stable Room2 checkpoint persisted.
- [x] real Room2 trigger entered.
- [x] real Room2 enemies spawned and died.
- [x] CombatRoom2 persisted Cleared.
- [x] stable Depth1Boss checkpoint persisted.
- [x] real boss trigger entered.
- [x] real Marauder Captain spawned and died.
- [x] logical Depth1Boss persisted Cleared.
- [x] generic flow reported complete.
- [x] normal completion/save barrier committed.
- [x] Generic Encounter Live Acceptance: 13 assertions PASS.
- [x] temporary inspector/driver absent from final source.

### Repository-wide validation

- [x] `git diff --check`: PASS.
- [x] repository parse: 481 Lua/Luau files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 19 changed files, 0
      art/model/mesh/terrain/image files.

### Final committed Dungeon regression

- [x] Dungeon Difficulty Definitions: 78 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain RuntimeReady=false.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`.


<!-- PHASE4_ENCOUNTER_EXECUTION_REGISTRY_LOCAL_GREEN_20260918 -->
## Phase 4 - Encounter Execution / Spawn Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `c6e181c`
**Implementation checkpoint:** `fe1856e`

### Execution architecture

- [x] stable executor IDs.
- [x] CombatPack executor.
- [x] Boss executor.
- [x] server-owned combat-pack spawn catalogue.
- [x] stable BossId -> factory registry.
- [x] MarauderCaptain registered.
- [x] CorruptedForeman registered.
- [x] DungeonRuntime does not select concrete enemy/boss factories.
- [x] validation occurs before generic sequence start.
- [x] failed executor rolls Active back to Pending.
- [x] downstream EncounterService failure cleans spawned content and rolls back.
- [x] partial combat-pack factory failure cleans already-created enemies.
- [x] boss factory failure releases its spawn claim.
- [x] missing boss Humanoid cleans model and releases claim.
- [x] boss duplicate claims scoped by session + stable encounter ID.
- [x] several distinct boss-family encounters can coexist in one run.
- [x] missing packs/boss IDs/factories/bindings fail closed.
- [x] unimplemented Event/Secret boss content remains disabled.

### Focused Studio evidence

- [x] Dungeon Encounter Execution Registry: 16 assertions PASS.
- [x] Dungeon Encounter Spawn Catalog: 10 assertions PASS.
- [x] Dungeon Boss Factory Registry: 8 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Dungeon Encounter Execution Controller: 17 assertions PASS.
- [x] Dungeon Encounter Executors: 20 assertions PASS.
- [x] Boss Spawn Guard: 10 assertions PASS.
- [x] Dungeon Encounter Sequencer: 25 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 22 assertions PASS.
- [x] Depth1 Encounter Flow: 18 assertions PASS.
- [x] Depth1 Encounter Bindings: 18 assertions PASS.

### Temple live execution proof

- [x] real Room1 trigger.
- [x] StandardRoom1 spawned exactly 2 live enemies.
- [x] Room1 pack names came from catalogue.
- [x] real Room2 trigger.
- [x] StandardRoom2 spawned exactly 3 live enemies.
- [x] real boss trigger.
- [x] boss executor preserved DungeonBossRole=Boss.
- [x] compatibility runtime ID MarauderCaptain preserved.
- [x] logical Depth1Boss persisted Cleared.
- [x] completion/save barrier succeeded.
- [x] Execution Registry Live Acceptance: 15 assertions PASS.
- [x] no project CreatorErrors in validation run.

### Abandoned Mine live execution proof

Validation-only build forced DeepEchoes + CrystalBloom:

- [x] AbandonedMine selected.
- [x] DeepEchoes active.
- [x] CrystalBloom active.
- [x] Room1 spawned exactly 3 enemies (2 + event bonus 1).
- [x] Room2 spawned exactly 4 enemies (3 + rare bonus 1).
- [x] boss registry resolved CorruptedForeman.
- [x] Foreman display identity preserved.
- [x] logical Boss role preserved.
- [x] logical Depth1Boss persisted Cleared.
- [x] completion/save barrier succeeded.
- [x] Mine Execution Registry Live Acceptance: 16 assertions PASS.
- [x] all forced-selection hooks removed after validation.

### Repository-wide validation

- [x] `git diff --check`: PASS.
- [x] repository parse: 494 Lua/Luau files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 26 changed code/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.

### Final committed Dungeon regression

- [x] execution-registry focused families PASS.
- [x] Dungeon Difficulty Definitions: 114 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] repeat clean run: Training Dummy 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] repeat clean run: no project CreatorErrors.

### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain RuntimeReady=false.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-encounter-execution-registry-acceptance-record.md`.


<!-- PHASE4_MULTI_DEPTH_ROOM_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Multi-Depth Physical Room-Binding Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `2deb540`
**Implementation checkpoint:** `1aa81b5`

### Runtime architecture

- [x] physical room-slot metadata is data-driven.
- [x] logical encounters bind to room slots generically.
- [x] trigger anchors resolve from binding data.
- [x] enemy spawn anchors resolve from binding data.
- [x] boss spawn anchors are binding-specific.
- [x] exit barriers resolve from binding data.
- [x] stable encounter checkpoints resolve from binding data.
- [x] live progression no longer branches on fixed Room1/Room2/Boss clears.
- [x] legacy Depth1 checkpoint aliases remain recoverable.
- [x] existing Depth1 Temple behaviour remains compatible.
- [x] existing Depth1 Abandoned Mine behaviour remains compatible.
### Permanent fail-closed coverage

- [x] Temple Depth2 physical layout rejected as unregistered.
- [x] Temple Depth3 physical layout rejected as unregistered.
- [x] Temple Depth4 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth2 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth3 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth4 physical layout rejected as unregistered.
- [x] Dungeon Encounter Bindings: 30 assertions PASS.

### Temple real-trigger compatibility

- [x] temporary acceptance harness used only for validation.
- [x] three resolved Depth1 slots.
- [x] real Room1 trigger.
- [x] Room1 spawned exactly 2 enemies.
- [x] real Room2 trigger.
- [x] Room2 spawned exactly 3 enemies.
- [x] real boss trigger.
- [x] compatibility boss ID `MarauderCaptain` preserved.
- [x] stable checkpoints advanced correctly.
- [x] final completion/save barrier succeeded.
- [x] generic flow completed.
- [x] 23/23 assertions PASS.
- [x] temporary harness removed after validation.
### Abandoned Mine compatibility

Validation-only selection forced `AbandonedMine + DeepEchoes + CrystalBloom`.

- [x] Mine-specific anchors resolved through layout data.
- [x] Room1 spawned exactly 3 enemies.
- [x] Room2 spawned exactly 4 enemies.
- [x] Room3 used `Mine.Room3.ForemanSpawn`.
- [x] boss registry produced `Corrupted Foreman`.
- [x] stable checkpoints advanced correctly.
- [x] final completion/save barrier succeeded.
- [x] generic flow completed.
- [x] 23/23 assertions PASS.
- [x] all forced-selection/acceptance hooks removed afterward.

### Final committed static/build gate

- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 501 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 12 changed code/test files from `2deb540`.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
### Final committed Dungeon regression

- [x] Dungeon Encounter Bindings: 30 assertions PASS.
- [x] Dungeon Encounter Flow: 24 assertions PASS.
- [x] Dungeon Encounter Recovery: 10 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Dungeon Encounter Executors: 21 assertions PASS.
- [x] Dungeon Encounter Execution Controller: 17 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 22 assertions PASS.
- [x] Dungeon Difficulty Definitions: 114 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors.
### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain `RuntimeReady=false`.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`.


<!-- PHASE4_RUNTIME_CONTENT_READINESS_LOCAL_GREEN_20260918 -->
## Phase 4 - Dungeon Runtime Content Readiness Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `a942f6d`
**RED checkpoint:** `34b2a29`
**Implementation checkpoint:** `2e2420b`

### Test-first contract

- [x] permanent readiness test authored before implementation.
- [x] RED observed in Studio because
      `DungeonRuntimeContentReadiness` was missing.
- [x] no unrelated failure was required to establish RED.

### Readiness architecture

- [x] shared `DungeonRuntimeContentCatalog`.
- [x] shared `DungeonRuntimeContentReadiness`.
- [x] physical layout metadata has one shared static source.
- [x] combat-pack metadata has one shared static source.
- [x] boss-content metadata has one shared static source.
- [x] implemented executor IDs are declared centrally.
- [x] implemented boss-factory IDs are declared centrally.
- [x] Dungeon layout wrapper consumes the shared catalogue.
- [x] Dungeon spawn catalogue consumes the shared catalogue.
- [x] old `RuntimeReady` property removed.
- [x] explicit switch renamed to `RuntimeReleaseEnabled`.
- [x] analyser computes `ContentComplete`.
- [x] analyser computes `ReleaseEnabled`.
- [x] analyser computes final `Ready`.
- [x] analyser returns machine-readable readiness issues.
- [x] progression entry uses computed readiness.
- [x] TeleportCoordinator uses computed readiness.
- [x] not-ready content blocks before server reservation.
- [x] Dungeon bootstrap cross-checks actual executor/factory registrations.

### Current difficulty readiness

For both TestDungeon and AbandonedMine:

- [x] Depth1 content complete.
- [x] Depth1 release enabled.
- [x] Depth1 ready.
- [x] Depth1 has no readiness issues.
- [x] Depth2 content incomplete and release disabled.
- [x] Depth3 content incomplete and release disabled.
- [x] Depth4 content incomplete and release disabled.
- [x] higher depths report missing physical layout.
- [x] higher depths report missing encounter content.
- [x] Depth2-Depth4 remain fail closed.

### Focused Studio evidence

Base:

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.

Dungeon:

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Spawn Catalog: 10 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Boss Factory Registry: 8 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed static/build acceptance

- [x] clean committed implementation checkpoint `2e2420b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 504 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Spawn Catalog: 10 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Boss Factory Registry: 8 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] source-boundary audit: 13 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-runtime-content-readiness-acceptance-record.md`.


<!-- PHASE4_ENEMY_ARCHETYPE_COMBAT_PACK_LOCAL_GREEN_20260918 -->
## Phase 4 - Generic Enemy Archetype + Heterogeneous Combat Pack Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `5298699`
**RED checkpoint:** `ad56735`
**Implementation checkpoint:** `464bd44`

### Test-first contract

- [x] enemy-factory registry test authored before implementation.
- [x] heterogeneous CombatPack executor test authored before implementation.
- [x] Studio RED observed because `DungeonEnemyFactoryRegistry` was missing.
- [x] Studio RED observed because `CombatPackEncounterExecutor` was missing.
- [x] no unrelated failure was required to establish RED.

### Generic enemy architecture

- [x] shared enemy archetype definitions.
- [x] stable enemy FactoryId values.
- [x] server-owned `DungeonEnemyFactoryRegistry`.
- [x] production Marauder factory registered through stable FactoryId.
- [x] CombatPack entries are ordered and typed.
- [x] CombatPack execution no longer assumes Marauders.
- [x] generic `CombatPackEncounterExecutor`.
- [x] old `MarauderPackEncounterExecutor` removed.
- [x] per-entry naming preserved.
- [x] per-entry spawn-index ranges preserved.
- [x] per-archetype reward definitions preserved.
- [x] difficulty health/damage/reward scaling applies across archetypes.
- [x] partial mixed-pack failure cleans all prior spawns.
- [x] Deep Echoes bonus targets an explicit EntryId.
- [x] Crystal Bloom bonus targets an explicit EntryId.
- [x] readiness validates pack entry structure.
- [x] readiness validates enemy archetype registration.
- [x] readiness validates implemented enemy factories.
- [x] readiness validates pack bonus targets.
- [x] no new production enemy archetype enabled.

### Depth1 compatibility

- [x] Temple Room1 count remains 2.
- [x] Temple Room2 count remains 3.
- [x] Mine Room1 normal count remains 2.
- [x] Mine Deep Echoes Room1 count remains 3.
- [x] Mine Room2 normal count remains 3.
- [x] Mine Crystal Bloom Room2 count remains 4.
### Heterogeneous synthetic proof

- [x] synthetic pack contains two Marauder enemies.
- [x] synthetic pack contains one Elite enemy.
- [x] distinct injected factories are selected by archetype.
- [x] deterministic entry/factory order.
- [x] per-entry names verified.
- [x] per-entry spawn-index ranges verified.
- [x] per-archetype scaled rewards verified.
- [x] mixed-archetype combat scaling verified.
- [x] synthetic Elite factory failure cleans Marauder spawns.
- [x] missing enemy factory fails closed.
- [x] unknown pack fails closed.
- [x] synthetic Elite is test-only, not production content.

### Focused GREEN evidence

- [x] Enemy Factory Registry: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Spawn Catalog: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Combat Target Rules repeat: 9 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed implementation checkpoint `464bd44`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 507 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] added implementation source lines meet 79-character limit.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Enemy Factory Registry: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Spawn Catalog: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS on clean repeat.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed on clean repeat.

### Release qualification

- [x] no new production enemy archetype enabled.
- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] source-boundary audit: 11 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`.


<!-- PHASE4_RUNTIME_LAYOUT_SELECTION_LOCAL_GREEN_20260918 -->
## Phase 4 - Runtime Layout Selection + Environment Activation

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `0177b17`
**RED checkpoint:** `5ab0b4e`
**Implementation checkpoint:** `ccd289b`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing `resolve_selection` failed as expected.
- [x] missing layout-activation module failed as expected.

### Runtime selection

- [x] Studio default difficulty resolves.
- [x] explicit Studio Depth1 resolves.
- [x] unregistered selected layout fails closed.
- [x] unknown difficulty fails closed.
- [x] production preserves TeleportData DifficultyId.
- [x] Runtime Selection: 7 assertions PASS.
### Environment activation

- [x] physical slots declare explicit ExitBarrierAnchor.
- [x] arbitrary four-slot trigger activation works.
- [x] arbitrary three-barrier activation works.
- [x] missing trigger fails closed.
- [x] missing barrier fails closed.
- [x] Environment Layout Activation: 12 assertions PASS.
- [x] bootstrap contains no Temple/Mine trigger arrays.
- [x] readiness requires a physical barrier anchor when a logical
      ExitBarrierRoomId exists.

### Final committed static/build acceptance

- [x] clean committed checkpoint `ccd289b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 510 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.

### Final committed Dungeon regression

- [x] Runtime Selection: 7 assertions PASS.
- [x] Environment Layout Activation: 12 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] Roblox Controls Emulator plugin errors classified as external.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no physical higher-depth rooms or anchors added.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 7 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-runtime-layout-selection-acceptance-record.md`.


<!-- PHASE4_ENVIRONMENT_BINDING_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Environment Binding Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `caf56c5`
**RED checkpoint:** `5bcd281`
**Implementation checkpoint:** `cfbf2ea`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing DungeonEncounterEnvironmentRuntime failed as expected.
- [x] get_group-only combat environment failed before migration.
- [x] missing binding-owned spawn groups failed before migration.

### Physical binding contract

- [x] combat-capable slots declare EnemySpawnGroup.
- [x] bindings expose EnemySpawnGroup.
- [x] bindings expose ExitBarrierAnchor.
- [x] readiness rejects CombatPack bindings without EnemySpawnGroup.
- [x] current Temple/Mine Depth1 binding compatibility preserved.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
### Generic combat spawning

- [x] CombatPackEncounterExecutor requires binding.EnemySpawnGroup.
- [x] executor uses environment:get_group(...).
- [x] ordered group BaseParts are converted to CFrames.
- [x] missing/empty resolved spawn groups fail closed.
- [x] mixed-pack factory/reward/scaling behavior preserved.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Generic exit barriers

- [x] DungeonEncounterEnvironmentRuntime exists.
- [x] arbitrary binding-owned physical barrier opens.
- [x] arbitrary binding-owned physical barrier closes.
- [x] slots without barriers are safe no-ops.
- [x] missing declared barriers fail closed.
- [x] invalid environment adapters fail closed.
- [x] Dungeon Encounter Environment Runtime: 8 assertions PASS.
- [x] DungeonRuntime clear path uses ExitBarrierAnchor.
- [x] DungeonRuntime recovery path uses ExitBarrierAnchor.
### Final committed static/build acceptance

- [x] clean committed checkpoint `cfbf2ea`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 512 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Dungeon Encounter Environment Runtime: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Dungeon Encounter Executors: 21 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no physical higher-depth rooms or anchors added.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 11 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-environment-binding-runtime-acceptance-record.md`.


<!-- PHASE4_LAYOUT_ENVIRONMENT_CONTRACT_LOCAL_GREEN_20260918 -->
## Phase 4 - Layout-Derived Environment Contract

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `87a88c1`
**RED checkpoint:** `1729151`
**Implementation checkpoint:** `405dde5`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing DungeonLayoutEnvironmentContract failed as expected.

### Selected-layout contract

- [x] runtime base contracts contain only environment-wide anchors.
- [x] current combat slots own EnemySpawnGroup.
- [x] current combat slots own EnemySpawnPrefix.
- [x] current combat slots own EnemySpawnMinCount.
- [x] readiness validates complete combat group metadata.
- [x] selected layout contributes entrance/trigger/checkpoint anchors.
- [x] selected layout contributes exit-barrier anchors.
- [x] selected layout contributes boss-spawn anchors.
- [x] selected layout contributes combat spawn-group definitions.
### Synthetic Room4 proof

- [x] Room4 exact anchors are generated by contract builder.
- [x] Room4 enemy group name/prefix/minimum are generated from slot metadata.
- [x] real EnvironmentAnchorResolver exposes Room4 exact anchors.
- [x] real EnvironmentAnchorResolver exposes Room4 enemy group.
- [x] insufficient Room4 group anchors fail closed.
- [x] incomplete Room4 combat group metadata fails closed.
- [x] Dungeon Layout Environment Contract: 14 assertions PASS.

### Production integration

- [x] DungeonEnvironmentBootstrap uses selected-layout runtime contract.
- [x] DungeonEnvironmentRouter rebuilds the selected-layout runtime contract.
- [x] Temple adapter accepts optional explicit contract.
- [x] Mine adapter accepts optional explicit contract.
- [x] legacy adapter default contracts remain available.
- [x] production bootstrap/router do not use static full Depth1 contracts.
### Final committed static/build acceptance

- [x] clean committed checkpoint `405dde5`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 514 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] clean-repeat Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] clean-repeat Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] Roblox Controls Emulator plugin errors classified as external.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no higher-depth layout registered.
- [x] no Room4+ authored content added.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 9 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-layout-environment-contract-acceptance-record.md`.


<!-- PHASE4_STUDIO_DIFFICULTY_PARITY_LOCAL_GREEN_20260918 -->
## Phase 4 - Studio Difficulty / Session Parity

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `5fb3491`
**RED checkpoint:** `efc6a47`
**Implementation checkpoint:** `d9297f8`

### Test-first contract

- [x] RED captured before implementation.
- [x] explicit Studio Depth2 failed to reach session creation.

### Studio parity contract

- [x] StudioSessionFactory accepts optional DifficultyId.
- [x] session creation receives selected DifficultyId.
- [x] DungeonInstanceDirector receives selected DifficultyId.
- [x] Studio routing data preserves DifficultyId.
- [x] reused Studio sessions prefer authoritative session difficulty.
- [x] omitted Studio difficulty still defaults through normal definitions.
- [x] DungeonRuntime passes environment-resolved DifficultyId.
- [x] production TeleportCoordinator routing unchanged.
- [x] Studio Session Factory: 7 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `d9297f8`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 514 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] clean-repeat Studio Session Factory: 7 assertions PASS.
- [x] Dungeon Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] clean-repeat Training Dummy: 9 assertions PASS.
- [x] clean-repeat Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no higher-depth layout registered.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 3 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`.


<!-- PHASE4_DEPTH2_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth2 Backend Combat + Boss Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `468cf76`
**RED checkpoint:** `dad8990`
**Implementation checkpoint:** `b525235`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth2 combat packs failed as expected.
- [x] missing TempleDepth2BossFactory failed as expected.
- [x] Depth2 readiness reported missing encounter content before implementation.

### Depth2 combat content

- [x] TestDungeon Depth2Room1 registered with 3 Marauders.
- [x] TestDungeon Depth2Room2 registered with 4 Marauders.
- [x] TestDungeon Depth2Room3 registered with 5 Marauders.
- [x] AbandonedMine Depth2Room1 registered with 3 Marauders.
- [x] AbandonedMine Depth2Room2 registered with 4 Marauders.
- [x] AbandonedMine Depth2Room3 registered with 5 Marauders.
- [x] Mine Deep Echoes adds one Depth2 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth2 Room2 Marauder.
- [x] Depth2 Content: 32 assertions PASS.
### Depth2 boss content

- [x] TempleDepth2Boss registered.
- [x] TempleDepth2Boss display identity: Temple Warden.
- [x] AbandonedMineDepth2Boss registered.
- [x] AbandonedMineDepth2Boss display identity: Deep Overseer.
- [x] both factories registered in execution bootstrap.
- [x] both bosses retain accepted Captain controller tag/behavior.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 17 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Readiness boundary

- [x] Depth2 remains Ready = false for both current dungeons.
- [x] Depth2 remains ReleaseEnabled = false.
- [x] Depth2 no longer reports EncounterContentNotRegistered.
- [x] Depth2 reports exactly one issue: DungeonLayoutNotRegistered.
- [x] no Depth2 physical layout registered.
- [x] Depth3-Depth4 remain content-incomplete.
- [x] Runtime Content Readiness: 66 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `b525235`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 518 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 66 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 17 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Studio Session Factory: 7 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 66 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth2 remains release-disabled.
- [x] Depth2 remains physically unregistered.
- [x] Depth3-Depth4 remain content-incomplete and release-disabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 8 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth2-content-acceptance-record.md`.


<!-- PHASE4_DEPTH3_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth3 Backend Combat + Boss Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `3d978af`
**RED checkpoint:** `b205914`
**Implementation checkpoint:** `092bd99`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth3 combat packs failed as expected.
- [x] missing TempleDepth3BossFactory failed as expected.
- [x] Depth3 readiness reported missing encounter content before implementation.

### Depth3 combat content

- [x] TestDungeon Depth3Room1 registered with 4 Marauders.
- [x] TestDungeon Depth3Room2 registered with 5 Marauders.
- [x] TestDungeon Depth3Room3 registered with 6 Marauders.
- [x] TestDungeon Depth3Room4 registered with 7 Marauders.
- [x] AbandonedMine Depth3Room1 registered with 4 Marauders.
- [x] AbandonedMine Depth3Room2 registered with 5 Marauders.
- [x] AbandonedMine Depth3Room3 registered with 6 Marauders.
- [x] AbandonedMine Depth3Room4 registered with 7 Marauders.
- [x] Mine Deep Echoes adds one Depth3 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth3 Room2 Marauder.
- [x] Depth3 Content: 36 assertions PASS.
### Depth3 boss content

- [x] TempleDepth3Boss registered.
- [x] TempleDepth3Boss display identity: Relic Guardian.
- [x] AbandonedMineDepth3Boss registered.
- [x] AbandonedMineDepth3Boss display identity: Hollow Taskmaster.
- [x] both factories registered in execution bootstrap.
- [x] both bosses retain accepted Captain controller tag/behavior.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 19 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Readiness boundary

- [x] Depth2 and Depth3 remain Ready = false.
- [x] Depth2 and Depth3 remain ReleaseEnabled = false.
- [x] Depth3 no longer reports EncounterContentNotRegistered.
- [x] Depth2/Depth3 each report exactly one issue: DungeonLayoutNotRegistered.
- [x] no Depth2/Depth3 physical layout registered.
- [x] Depth4 remains content-incomplete.
- [x] Runtime Content Readiness: 68 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `092bd99`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 522 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 68 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] Depth3 Content: 36 assertions PASS.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 19 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Studio Session Factory: 7 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 68 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth3 remains release-disabled.
- [x] Depth3 remains physically unregistered.
- [x] Depth2 remains release-disabled and physically unregistered.
- [x] Depth4 remains content-incomplete and release-disabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 8 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth3-content-acceptance-record.md`.


<!-- PHASE4_DEPTH4_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth4 Final-Difficulty Backend Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `230f7f5`
**RED checkpoint:** `8c3b8c2`
**Implementation checkpoint:** `8bcb58b`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth4 combat pack failed as expected.
- [x] missing TempleDepth4BossFactory failed as expected.
- [x] Depth4 readiness reported missing encounter content before implementation.

### Depth4 combat content

- [x] TestDungeon Depth4Room1 registered with 5 Marauders.
- [x] TestDungeon Depth4Room3 registered with 7 Marauders.
- [x] AbandonedMine Depth4Room1 registered with 5 Marauders.
- [x] AbandonedMine Depth4Room3 registered with 7 Marauders.
- [x] Mine Deep Echoes adds one Depth4 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth4 Room3 Marauder.
- [x] Depth4 Content: 38 assertions PASS.
### Locked miniboss chain

- [x] Depth4 keeps six logical encounters.
- [x] Room2 reuses DifficultyBossIds[1] as MiniBoss.
- [x] Room4 reuses DifficultyBossIds[2] as MiniBoss.
- [x] Room5 reuses DifficultyBossIds[3] as MiniBoss.
- [x] Room6 uses DifficultyBossIds[4] as FinalBoss.
- [x] no replacement miniboss factories introduced.

### Depth4 final-boss content

- [x] TempleDepth4Boss registered.
- [x] TempleDepth4Boss display identity: Sanctum Ascendant.
- [x] AbandonedMineDepth4Boss registered.
- [x] AbandonedMineDepth4Boss display identity: Buried Tyrant.
- [x] both factories registered in execution bootstrap.
- [x] both final bosses preserve BossRole = FinalBoss.
- [x] both retain accepted Captain controller behavior/tag.
- [x] Depth4 Boss Factory: 10 assertions PASS.
- [x] Encounter Spawn Catalog: 20 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
### Readiness boundary

- [x] Depth2, Depth3 and Depth4 remain Ready = false.
- [x] Depth2, Depth3 and Depth4 remain ReleaseEnabled = false.
- [x] no higher depth reports EncounterContentNotRegistered.
- [x] Depth2/Depth3/Depth4 each report exactly one issue:
  DungeonLayoutNotRegistered.
- [x] all Depth1-Depth4 encounter content is registered.
- [x] no Depth2/Depth3/Depth4 physical layout registered.
- [x] Runtime Content Readiness: 70 assertions PASS.

### Final committed static/build acceptance

- [x] clean committed checkpoint `8bcb58b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 526 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
### Final committed Base regression

- [x] verified PlayServer/PlayClient run.
- [x] Runtime Content Readiness: 70 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.

### Final committed Dungeon regression

- [x] verified PlayServer/PlayClient run.
- [x] Depth4 Content: 38 assertions PASS.
- [x] Depth4 Boss Factory: 10 assertions PASS.
- [x] Depth3 Content: 36 assertions PASS.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 20 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 70 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
### Release qualification

- [x] Depth2-Depth4 remain release-disabled.
- [x] Depth2-Depth4 remain physically unregistered.
- [x] all Depth1-Depth4 backend encounter content registered.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 10 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth4-content-acceptance-record.md`.

### Optional Boss candidate: 19 September 2026
- [x] Policy: 49 assertions PASS in Dungeon Studio.
- [x] Optional Secret flow: 9 assertions PASS.
- [x] Four boss factories: 24 assertions PASS.
- [x] Release locks: 14 assertions PASS.
- [x] 537 Luau parse; four Rojo builds PASS.
- [x] Base/Dungeon gameplay regression suites PASS.
- [ ] Optional physical boss arenas and event/secret unlock issuers remain unimplemented.
- [ ] Commit/push/merge/publish not performed.

### Optional-boss code-only backend closeout

- [x] Run-state issuer: 28 offline Luau assertions PASS.
- [x] Instance director: 10 additional rollout-lock checks authored.
- [x] All four final candidate Rojo builds and git diff check PASS.
- [ ] Extended director/run-state Studio tests not rerun.
- [ ] Physical arenas and full gameplay acceptance not started.
- [ ] Production release remains disabled.\r\n\r\n
## UI/HUD candidate - 19 September 2026

- [x] 531 Lua/Luau files parsed and git diff whitespace check clean.
- [x] Four Rojo builds pass.
- [x] Base Studio regression and Phase 3 stress pass.
- [x] Dungeon repeat: Training Dummy 9/9, Combat Target Rules 9/9,
  Phase 3 stress, player admission, zero project errors.
- [x] No art/model/mesh/terrain/image files changed.
- [ ] Player-facing desktop/mobile viewport visual acceptance.
- [ ] Contextual prompts, modal close, party entry and boss HUD manually
  exercised by player before release.
- [ ] Feature branch merge / publish only with explicit approval.

Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.
