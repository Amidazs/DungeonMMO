# Canonical Roadmap

The canonical long-form roadmap stored here is:

`DungeonMMO_Roadmap_v1_43.docx`

Version: **1.43**
Last updated: **18 September 2026**

SHA-256:

`be439c64fd89f2c953b2f73f01c508b1d876ffd24dfe7ccbc597113b356c7403`

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

The canonical DOCX remains v1.43 because these Phase 4 backend gates have not
received a project-owner release/closeout action and have not been pushed,
merged or published. Local acceptance evidence is recorded in:

- `docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`;
- `docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`;
- `docs/testing/phase4-encounter-execution-registry-acceptance-record.md`;
- `docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`;
- `docs/testing/phase4-runtime-content-readiness-acceptance-record.md`;
- `docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`;
- `docs/testing/phase4-runtime-layout-selection-acceptance-record.md`.

`docs/ai/CURRENT_STATE.md` is the fast engineering-status layer. It does not
replace this roadmap's LOCKED/WORKING/LATER/OPEN design decisions.

When the roadmap is deliberately revised, add the new canonical DOCX, update
its version/hash here, refresh `CURRENT_STATE.md`, and preserve an acceptance
or handoff record for the superseded engineering boundary.
