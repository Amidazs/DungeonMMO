# Canonical Roadmap

**Latest ChatGPT-authored roadmap update: v1.48 (Phase 4 backend supplement, 20 September 2026).**
Read [the v1.48 Phase 4 backend roadmap update](DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md)
for completed higher-depth optional physical playtesting, precise
local-vs-cloud acceptance boundaries, and the next backend milestone:
multiplayer lifecycle at Depth 2–4. This is a *versioned supplement*,
not a replacement for the retained historical long-form
`DungeonMMO_Roadmap_v1_47.docx`. The new update was prepared in ChatGPT,
not edited through Remote Desktop Commander. A separately generated
Word-format copy can be opened from its ChatGPT artifact link.

**Current engineering checkpoint:** Integration branch
`wip/phase-4-test-hud-integration-v1`; pre-roadmap-update accepted
physical-playtest commit `cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.
The v1.48 update does not imply a merge to main, production release,
Roblox publish or real user DataStore mutation.

**20 September Depth2–4 optional physical checkpoint (after v1.47):**
GitHub-first edits added separate, opt-in TEMP Event/Secret side rooms,
bridges, physical gates and unique anchors to Temple and Mine Depth2,
Depth3 and Depth4. All six independent local Studio Play-mode routes
passed actual walking traversal into/out of both optional rooms,
server encounter activation/spawn identity and final dungeon
completion with assisted combat (6/7/8 encounters by difficulty).
A seventh Mine Depth4 run physically skipped Secret, returned to
clear it and then defeated Final, using a TEMP-only final-spawn hold.
New structural test: 139 assertions; optional focused suites 18/18;
broad backend matrix 30/30. The original optional-disabled Temple
Depth2 four-room route passed and all four local Rojo compositions
built. High-depth release flags, authored models, Roblox cloud places,
user DataStores and the canonical DOCX remain untouched. Evidence:
`docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md`.

**20 September depth-specific optional event backend checkpoint
(after v1.47):** Existing Temple/Mine Event/Secret encounter definitions
were validated across Depth1–4 and all independent eligibility
combinations, including expired global event windows preserving a
previously eligible saved run. Two issues were reproduced RED and fixed:
Secret side gates now use the preceding required room from the frozen
plan (rather than opening at Room2 for all depths), and Mine placeholder
side entrances are now synchronized by the existing server gate
controller. Local Studio: 712/116/32 assertions in new depth, timed-event
and gate suites; 17/17 optional suites; 30/30 broader backend suites;
assisted Temple and Mine Depth1 physical optional routes PASS. All four
local Rojo compositions built. Depth2–4 optional physical side arenas
and bridge routes are **not** registered or playable from this change,
and high-depth release flags remain OFF. No TEST/PROD cloud, player
DataStore, authored art or canonical DOCX modification. Evidence:
`docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md`.

**20 September four-depth integration checkpoint (after v1.47):**
Both Temple and Abandoned Mine Depth1–4 ladders passed a new
454-assertion profile/session/encounter integration test, including
3/4/5/6 required rooms, Depth4 returning miniboss identities,
ordered unlocks, interrupted miniboss checkpoints, and actual
CompletionService one-time rewards. Five focused Studio suites,
30/30 broad backend suites, four local Rojo builds, Base Play mode,
and a fresh assisted Temple Depth2 physical route passed. The
previous six separate Temple/Mine Depth2–4 physical tests retain
their dated evidence; an attempted all-six-in-one Studio runner
stopped after its first case and was removed. Higher-depth release
locks remain unchanged, with injected readiness used only inside
test storage. No production-code, authored model, Roblox cloud,
DataStore, main branch or canonical DOCX change. See
`docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md`.

**20 September full session-recovery checkpoint (after v1.47):**
The existing session/encounter backend has passed a new 42-assertion
persisted two-member recovery regression and all 15 local optional
focused suites. A fresh assisted physical Temple Secret backtracking
fixture also passed. The test constructs new session, controller and
reward services over a shared in-memory store; it is not a genuine
same-account Roblox reconnect or cloud server restart. No production
gameplay, model, DataStore, TEST/PROD place or original roadmap DOCX
was changed. The user separately confirms a successful manual solo
optional-boss playtest. See
`docs/testing/phase4-optional-full-session-recovery-2026-09-20.md`.

**20 September consecutive optional-combat follow-up (after v1.47):**
Two local two-client Temple tests passed ordinary-health Event -> Secret
combat with regular client attack requests. In the second run the server
confirmed Dodge and a slotted healing skill, restoring ~32 party HP
before Secret; final-room progression passed with test assistance.
This does not supersede the failed injured-solo attempt, and
required-room/final-boss manual combat, true rejoin and cloud
verification remain open. See
`docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md`.

**20 September normal-combat follow-up (after v1.47):** Local
GitHub-first normal-combat fixtures independently defeated Temple
Event and Secret bosses with real client attacks and normal player HP.
The consecutive attempt FAILED: the solo survivor entered Secret
injured after Event and died before defeating Secret. In a separate
healthy two-client run, Secret was defeated and the final route
completed (other rooms assisted). Both isolated boss wins are accepted
as local evidence; combined unassisted gameplay, legitimate recovery,
manual navigation and true same-account rejoin are not accepted.
See `docs/testing/phase4-optional-boss-normal-combat-playtest-2026-09-20.md`.
Cloud verification and art remain deferred.

The canonical long-form roadmap stored here is:

`DungeonMMO_Roadmap_v1_47.docx`

Version: **1.47**
Last updated: **20 September 2026**

SHA-256:

`f5ebe50872510067a671a67d7844d521adc512e6683322b8a99f37c811d13abf`

**Current phase: Phase 4 Content Alpha remains ACTIVE.** Phases 2 and 3 remain accepted. The 19 September Event/Secret backend milestone is complete historically and is not a reason to repeat the closed backend work.

**20 September local backend follow-up (after v1.47):** Normal/Event start
and optional Secret-skip persistence failures now roll back in-memory
progression so players can retry without bypassing a required encounter.
Focused Studio tests, all five local Rojo compositions, assisted Temple
placeholder backtracking, normal Dungeon Play mode, and a two-client
session-disconnect fixture passed. The local two-client optional-boss fight has since passed: one Event
boss despite simultaneous entry, a real mid-Event disconnect with the
other player continuing, isolated interrupted-boss state recovery,
Event reward replay protection and Secret/final boss completion.
Same-account network rejoin is still unproven. Evidence:
`docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md`
and `docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md`.
This is a working engineering update, not a new canonical DOCX version
or cloud release. Finished models and cloud verification remain deferred.

**20 September TEST evidence and scope:** The published TEST Lobby race/class flow worked after repairing seven semantic environment anchors and restoring the TEST profile DataStore, and the player entered/cleared normal TEST Temple rooms. One observed Secret objective stated that the secret route was not unlocked for that run; the visible branches are **EventArena after Room 1** and **SecretArena after Room 2**, not two guaranteed Secret rooms. A distinct Base-origin eligibility source correction was made; it must be verified on a *new cloud session*, not assumed to change old persisted runs.

On the combined integration branch `wip/phase-4-test-hud-integration-v1`, source `52222db` supports eligible Secret backtracking before dungeon completion; `f6d6401` adds **server-controlled placeholder side-entry gates** so Event opens after Room 1 and Secret after Room 2 only when that run is eligible. Local physical/regression and TEST-style composition tests passed. Final authored room art, normal-player unassisted optional boss fights and real multiplayer/recovery acceptance remain open.

**TEST Temple publish status is UNVERIFIED:** The latest gated-placeholder Publish As attempt on 20 September targeted the existing TEST Dungeon place `117293035754309` but Roblox Scripts publishing/version-history calls returned HTTP 429 rate limits. A publish timing marker and local tests do not prove that this newest gate/script version is playable in Roblox. Before any repeat publish, inspect the current TEST Temple Version History and join a genuinely fresh TEST Dungeon server; avoid rapid retries, preserve a current cloud rollback, and never overwrite the authored Lobby `134132328219009`, PROD or player DataStores.

Detailed evidence: `docs/testing/phase4-test-temple-optional-entrance-gates-2026-09-20.md`, `docs/testing/phase4-deferred-secret-backtracking-2026-09-20.md` and `docs/testing/phase4-test-lobby-optional-boss-origin-fix-2026-09-20.md`. Historical 19 September release-lock and unpublished-status entries below describe their **dated source checkpoints**, not the current TEST-only integration or uncertain 20 September publish attempt. The definitive updated status, next actions and restart brief are in v1.47 Sections 10 and Appendix J.

Historical note: Roadmap v1.45 added the four-step Event/Secret Boss **isolated backend**
checkpoint: recovery and reward replay, Mine live integration, four distinct
server-owned two-phase boss attack patterns, and fresh Base/Dungeon Studio
regressions. Gameplay source was validated at `3700dba`; the final regular
Base/Dungeon and static validation ran at `c86a904`.

See `docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md`
for the exact source/log evidence and outstanding network-reconnect, authored
physical-arena, unassisted combat, and multiplayer release gates. Optional boss
rollout remains disabled in both dungeons; **no merge to main or game publish**
is implied by this roadmap update. The v1.45 DOCX passed zip/structure checks;
a visual PDF/page-render review is still pending after the Word export stalled.

Version 1.43 formally closes **Phase 3 - Systems Alpha** and opens
**Phase 4 - Content Alpha**.

The accepted Phase 3 gameplay release checkpoint is:

`84662948127eb1a37c9f184c6abbafe6f2daddb6`

That checkpoint was pushed to the Phase 3 feature branch and to `main`, then
verified against the GitHub server `main` ref before the documentation
closeout.

Published TEST environment:

- Universe: `10765241947`
- Starting Base: `134132328219009`
- Dungeon: `117293035754309`

The Dungeon and Starting Base both reached Roblox Studio
`PublishSuccessful` during the Phase 3 release. No PROD publish or Robux
action occurred.

Phase 3 accepts the Quest/Secondary-Class Advancement foundation,
Damage/Tank/Support Contribution, Blueprint/Recipe Knowledge,
Bestiary/Reputation, Rogue fourth-archetype breadth, deterministic Dungeon
modifiers, Guild/Hall, limited Market, DEV/TEST Race Change migration and the
economy/audit/stress hardening boundary. Progression catch-up and Transmog are
explicitly deferred.

Roadmap v1.43 opened Phase 4 with Starting Base presentation as the first
default gate. On 18 September 2026 the project owner explicitly parked modelling
and presentation work and moved Phase 4 through backend-only Dungeon gates.

The **Progressive Dungeon Depth + Difficulty** foundation is locally green at
`1230e6c`: schema v13 progression, 3/4/5/6 logical depths, authoritative
solo/party/session routing, fail-closed higher depths, combat/reward scaling and
completion unlock integration all passed the local acceptance matrix.

The follow-on **Generic Dungeon Encounter Runtime** is locally green at
`5ba9f4d`. The live Depth1 runtime now uses generic sequencer authority with
stable encounter checkpoints and reconnect state. The backend supports
Combat/MiniBoss/Boss/FinalBoss plus future EventBoss/SecretBoss insertion from
server-owned conditions. Unbound optional content fails closed, no Event/Secret
boss content is enabled, and Depth2-Depth4 remain fail closed.

The next **Encounter Execution / Spawn Registry** gate is locally green at
`fe1856e`. Encounter descriptors now select stable CombatPack/Boss executors;
combat packs resolve through server-owned catalogue data; boss-family content
resolves through stable BossId -> factory registration; live DungeonRuntime no
longer chooses concrete Marauder/Captain/Foreman factories. Transactional
startup cleans partial spawns and returns the generic sequence to Pending on
failure. Boss duplicate claims are scoped by session + encounter ID, which
supports multiple miniboss/boss/event/secret encounters in a single future run.
Temple and forced Abandoned Mine live execution proofs passed. Depth2-Depth4
remain fail closed, and no Event/Secret boss content is enabled.

The follow-on **Multi-Depth Physical Room-Binding Runtime** is locally green at
`1aa81b5`. Physical room-slot metadata, triggers, spawn anchors, barriers and
checkpoints are now resolved generically from layout data; live progression no
longer branches on fixed Room1/Room2/Boss cases. Real Temple compatibility and
forced Abandoned Mine + event/rare compatibility each passed 23/23 assertions.
Both current dungeons explicitly reject unimplemented Depth2-Depth4 physical
layouts, so higher depths remain fail closed while the runtime is ready for
future authored room sets and later Event/Secret boss bindings.

The follow-on **Dungeon Runtime Content Readiness Registry** is locally green at
`2e2420b`. Static layout/pack/boss/executor/factory registrations now live in
one shared catalogue usable by both Base and Dungeon. The old `RuntimeReady`
boolean is removed: `RuntimeReleaseEnabled` is only a rollout switch, while
`DungeonRuntimeContentReadiness` computes content completeness and final
readiness. Base progression entry and TeleportCoordinator use the computed
result, so incomplete content is rejected before server reservation. Current
Depth1 is complete+enabled+ready; Depth2-Depth4 remain
incomplete+release-disabled+not-ready with explicit diagnostics.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
is locally green at `464bd44`. CombatPack execution is no longer
Marauder-specific: ordered pack entries resolve stable enemy archetypes and
server-owned factory IDs, while Deep Echoes / Crystal Bloom bonuses target
explicit entries. Current Temple/Mine Depth1 counts and naming remain
compatible. A synthetic 2-Marauder + 1-Elite pack proves mixed-factory
execution and rollback without enabling Elite as production content.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is locally green at `ccd289b`. Runtime startup now preserves
the selected DifficultyId and resolves its LayoutId before environment setup.
Encounter triggers and exit barriers are activated from registered layout data,
not hard-coded Temple/Mine arrays. A synthetic four-slot layout proves arbitrary
slot-count activation while current Depth1 boot/admission remains compatible.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is locally
green at `cfbf2ea`. Combat-capable physical bindings now carry their own
enemy-spawn groups, while exit-barrier progression uses physical binding
anchors. Generic encounter spawning and recovery no longer require Temple/Mine
room-ID translation maps, so future Room4+ combat slots can be registered
without editing dungeon-specific adapter maps.

The follow-on **Selected-Layout Environment Contract** gate is locally green at
`405dde5`. Runtime environment resolution now derives exact room anchors and
combat spawn groups from the selected physical layout. A synthetic Room4
contract resolves through the real EnvironmentAnchorResolver, removing the
remaining static Depth1 contract dependency from production bootstrap/router
resolution.

The follow-on **Studio Difficulty / Session Parity** gate is locally green at
`d9297f8`. Studio-created dungeon sessions now preserve the difficulty already
selected by runtime/environment routing through session creation,
DungeonInstanceDirector and Studio routing data. This closes the final
demonstrated generic higher-depth framework mismatch before deliberate
Depth2-Depth4 content registration.

The follow-on **Depth2 Backend Combat + Boss Content** gate is locally green at
`b525235`. Both current dungeons now have registered Depth2 combat packs and
distinct Depth2 boss identities/factories. Depth2 readiness now fails only
because its physical layout is deliberately absent; the release switch remains
disabled. No higher-depth room geometry or anchors were authored.

The follow-on **Depth3 Backend Combat + Boss Content** gate is locally green at
`092bd99`. Both current dungeons now have registered Depth3 combat packs at
4/5/6/7 base counts plus distinct Depth3 boss identities/factories. Depth2 and
Depth3 readiness now fail only on their deliberately absent physical layouts;
both release switches remain disabled. The Depth3 boss IDs are available for
the locked Depth4 miniboss chain.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is locally green
at `8bcb58b`. Both current dungeons now have complete backend content across
Depth1-Depth4. Depth4 preserves the locked six-encounter sequence: combat,
Depth1 miniboss, combat, Depth2 miniboss, Depth3 miniboss, then a new true final
boss. Depth2-Depth4 readiness now fails only on deliberately absent physical
layouts; all release switches remain disabled.

The following early Phase 4 evidence records remain historical; the latest
isolated optional-boss candidate has been committed and pushed to its feature
branch, but **has not been merged to main or published to Roblox**. Earlier
backend gates had separate local acceptance at the checkpoints listed below:

- `docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`;
- `docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`;
- `docs/testing/phase4-encounter-execution-registry-acceptance-record.md`;
- `docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`;
- `docs/testing/phase4-runtime-content-readiness-acceptance-record.md`;
- `docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`;
- `docs/testing/phase4-runtime-layout-selection-acceptance-record.md`;
- `docs/testing/phase4-environment-binding-runtime-acceptance-record.md`;
- `docs/testing/phase4-layout-environment-contract-acceptance-record.md`;
- `docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`;
- `docs/testing/phase4-depth2-content-acceptance-record.md`;
- `docs/testing/phase4-depth3-content-acceptance-record.md`;
- `docs/testing/phase4-depth4-content-acceptance-record.md`.

`docs/ai/CURRENT_STATE.md` is the fast engineering-status layer. It does not
replace this roadmap's LOCKED/WORKING/LATER/OPEN design decisions.

When the roadmap is deliberately revised, add the new canonical DOCX, update
its version/hash here, refresh `CURRENT_STATE.md`, and preserve an acceptance
or handoff record for the superseded engineering boundary.


The Phase 4 UI/HUD overhaul has a locally tested working candidate on
wip/phase-4-ui-overhaul-v1 (baseline ff2baa0). Shared dark-fantasy styling,
combat HUD/hotbar, refreshed core windows and entrance-/service-bound
dungeon/market windows are implemented. Parse, four builds, Base and
repeat Dungeon regressions passed. Visual/live interaction acceptance
remains OPEN; no push, merge or publish occurred.
Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.
The canonical roadmap DOCX remains v1.43 pending explicit revision.
