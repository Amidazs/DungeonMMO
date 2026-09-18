# DungeonMMO Current Engineering State

**State date:** 18 September 2026
**Canonical long-form roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_43.docx
**Current phase:** Phase 4 - Content Alpha
**Phase 2 - Vertical Slice:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Canonical release boundary

Phase 3 is closed. The accepted gameplay release checkpoint was pushed to the
Phase 3 feature branch and to main, then independently verified so local main,
origin/main and the GitHub server main ref all resolved to 84662948127eb1a37c9f184c6abbafe6f2daddb6 before
the documentation closeout.

Published TEST places:

- Starting Base: 134132328219009
- Dungeon: 117293035754309
- Universe: 10765241947

The Dungeon was published first and the Starting Base second. Roblox Studio's
publish state machine reached PublishSuccessful for both places. No PROD place,
Robux purchase flow or production DataStore action was used.

## Accepted Phase 3 systems

The accepted Systems Alpha boundary now includes:

- reusable Quest/objective state and first race-specific Secondary-Class
  Advancement architecture;
- persistent, server-authoritative contribution channels for Damage, Tank and
  Support;
- schema-backed Blueprint / Recipe Knowledge and authoritative teaching-item
  consumption;
- persistent Bestiary and Scholars Reputation foundations;
- Rogue as the deliberately selected fourth prototype starting archetype;
- Human Duelist and Elf Windstalker as prototype race-specific Rogue
  advancement targets;
- broader Rogue skill-tree/progression architecture while retaining the
  accepted limited active loadout;
- deterministic Dungeon modifiers: Fortified, Rich Deposits and Bounty;
- Rich Deposits interaction with reconnect-safe personal profession gathering;
- Guild creation, membership, Leader/Officer/Member roles, Guild XP, Guild
  Gold, leader-only level upgrades and a private functional Guild Hall;
- a limited fixed-price player-market proof with escrow, tax, tradability
  checks, buy/cancel/expiry recovery and replay-safe transactions;
- DEV/TEST Race Change preview/apply with per-race advancement history,
  incompatible skill/proficiency archive, SP release and restore-on-return;
- shared economy audit events and request-rate/replay/ownership validation;
- the reusable persisted entity-adapter boundary used by shared MMO entities.

The current profile schema is v13. Schema v13 adds independent persistent
Dungeon difficulty progression while preserving legacy `DungeonProgress`.

## Final runtime and stress evidence

The final consolidated Studio regression round on 18 September 2026 included,
among other accepted families:

- Rogue Definitions: 43 assertions PASS;
- Rogue Progression: 17 assertions PASS;
- Rogue Advancement: 12 assertions PASS;
- Class Advancement: 29 assertions PASS;
- Contribution Service: 36 assertions PASS;
- Contribution Damage Bridge: 9 assertions PASS;
- Contribution Support Bridge: 13 assertions PASS;
- Contribution real-session persistence: 10 assertions PASS;
- Bestiary Service: 33 assertions PASS;
- Bestiary/Reputation reward integration: 25 assertions PASS;
- Guild membership authority: 21 assertions PASS;
- Guild Service / Guild Hall / Dungeon progression: PASS;
- Market listing, purchase recovery, cancel/expiry and remote contracts: PASS;
- Race Change planner, migration, service and remote-contract tests: PASS;
- Economy Audit Integration: 27 assertions PASS;
- Entity Adapter Contract: PASS;
- Dungeon Modifier Definitions: 6 assertions PASS;
- Profession Resource Distribution: PASS;
- existing Phase 1/2 combat, progression, equipment, Bank, Travel, Dungeon,
  reward, revive and session regressions remained green in the same run.

The Phase 3 stress harness passed:

- 250 profile cycles;
- 1,000 market operations;
- 1,000 duplicate/replay attempts;
- 250 guild operations;
- 100 session cycles;
- 100 race-change round trips.

No duplicate/lost value or invalid final profile state was accepted by the
stress gate.

Detailed closeout evidence is recorded in
docs/testing/phase3-systems-alpha-acceptance-record.md.

## Explicit Phase 3 deferrals

Two roadmap concepts were intentionally not implemented:

- **Progression catch-up** - defer until real player population/progression data
  demonstrates a need.
- **Transmog** - defer until the equipment/content catalogue is mature enough to
  justify wardrobe engineering.

These are future work, not missing Phase 3 exit criteria.

## Phase 4 backend gates

Phase 4 - Content Alpha remains active.

The user has explicitly parked Starting Base presentation, modelling, meshes and
environment-art work for now.

The **Progressive Dungeon Depth + Difficulty backend foundation** remains local
green at `1230e6c`. It provides schema v13 depth progression, authoritative
difficulty routing, 3/4/5/6 logical-depth definitions, scaling and fail-closed
Depth2-Depth4 content.

The follow-on **Generic Dungeon Encounter Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT**.

Implementation checkpoint:

`5ba9f4d`

Accepted local engineering result:

- live Depth1 Room1 -> Room2 -> Boss progression authority is now the generic
  encounter sequencer rather than hard-coded clear booleans;
- arbitrary ordered encounter counts are supported by the generic controller;
- encounter kinds include Combat, MiniBoss, Boss, FinalBoss, EventBoss and
  SecretBoss;
- optional encounters support deterministic before/after insertion;
- Event/Secret activation is evaluated only from server-owned InstanceState;
- materialized encounter plans are persisted so reconnect cannot reroll an
  Event/Secret encounter that already exists in the run;
- required inserted encounters cannot be bypassed by later room triggers;
- stable encounter-derived checkpoints coexist with legacy Room1/Room2/Boss
  checkpoint aliases;
- existing EncounterService IDs, enemy/reward implementations, doors and
  Captain/Foreman implementations remain compatible;
- current Depth1 physical bindings fail closed if an activated optional
  encounter lacks an explicit authored room/spawn/checkpoint binding;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain, authored rooms or environment-art work was
  performed.

The follow-on **Encounter Execution / Spawn Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT** at:

`fe1856e`

Accepted local engineering result:

- encounter descriptors select stable execution/content IDs;
- CombatPack execution resolves through a server-owned spawn catalogue;
- Boss-family execution resolves through stable BossId -> factory registration;
- MarauderCaptain and CorruptedForeman are the currently registered boss
  contents;
- DungeonRuntime no longer chooses concrete Marauder/Captain/Foreman factories;
- encounter startup is transactional across validation, generic sequence start,
  spawn and EncounterService registration;
- failed execution rolls Active back to Pending;
- downstream start rejection cleans spawned content and rolls back;
- partial combat-pack and boss-factory failures clean up safely;
- boss duplicate protection is scoped by session + stable encounter ID, allowing
  multiple miniboss/boss/event/secret encounters in one run;
- missing future packs/boss IDs/factories/bindings fail closed;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain or authored-room work was performed.

Final local evidence includes:

- **494** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- real Temple registry-driven acceptance PASS with **15 assertions**;
- forced Abandoned Mine event+rare registry acceptance PASS with
  **16 assertions**;
- final repeat committed Dungeon regression green with no project errors;
- final committed Base regression green with no project errors;
- Phase 3 stress harness still passing in both final compositions;
- source-boundary audit: **26 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior encounter-execution gate worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EncounterExecution_v1

Prior encounter-execution branch:
wip/phase-4-encounter-execution-registry-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-encounter-execution-registry-design.md

Acceptance evidence:
docs/testing/phase4-encounter-execution-registry-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Multi-Depth Physical Room-Binding Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`1aa81b5`

Accepted local engineering result:

- physical room metadata is data-driven through generic layout definitions;
- logical encounters bind to generic room slots, triggers, spawn anchors, exit
  barriers and stable checkpoints;
- live DungeonRuntime progression no longer branches on fixed
  Room1/Room2/Boss clear cases;
- boss placement is binding-specific rather than hard-coded to one depth;
- checkpoint recovery remains compatible with legacy Depth1 aliases;
- Temple compatibility passed 23/23 assertions through the real generic path;
- forced Abandoned Mine + DeepEchoes + CrystalBloom compatibility passed 23/23;
- both production dungeons explicitly reject unimplemented Depth2, Depth3 and
  Depth4 physical layouts;
- Depth2-Depth4 therefore remained fail closed at this checkpoint;
- future EventBoss/SecretBoss insertion remains supported by the generic
  binding contract but no such content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `1aa81b5` includes:

- **501** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **30 assertions PASS**;
- Dungeon Encounter Flow: **24 assertions PASS**;
- Dungeon Encounter Recovery: **10 assertions PASS**;
- final committed Dungeon regression green, including Phase 3 stress,
  Training Dummy, Combat Target Rules and successful player admission;
- final committed Base regression green, including party/difficulty families
  and Phase 3 stress;
- source-boundary audit from `2deb540`: **12 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior multi-depth room-runtime worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_MultiDepthRoomRuntime_v1

Prior multi-depth room-runtime branch:
wip/phase-4-multidepth-room-runtime-v1

Acceptance evidence:
docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Dungeon Runtime Content Readiness Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`2e2420b`

Accepted local engineering result:

- a shared runtime-content catalogue is now the single static source for
  physical layouts, combat packs, boss content, executor IDs and boss-factory
  IDs used by Base/Dungeon readiness decisions;
- the old `RuntimeReady` difficulty property has been removed;
- `RuntimeReleaseEnabled` now means only the explicit rollout switch;
- `DungeonRuntimeContentReadiness` computes `ContentComplete`,
  `ReleaseEnabled`, `Ready` and machine-readable missing-content issues;
- Base-side progression entry and TeleportCoordinator use computed readiness
  rather than reading a release switch directly;
- not-ready content is rejected before reserved-server creation;
- Dungeon execution bootstrap cross-checks shared implemented declarations
  against actual server-side executor/factory registrations;
- both current Depth1 dungeons report content complete + release enabled +
  ready;
- Depth2-Depth4 in both current dungeons report content incomplete + release
  disabled + not ready, including missing layout/content diagnostics;
- no Event/Secret boss content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `2e2420b` includes:

- **504** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Runtime Content Readiness: **64 assertions PASS**;
- Difficulty Definitions: **114 assertions PASS**;
- Difficulty Progression: **19 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in Dungeon;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **13 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior runtime-readiness worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeReadiness_v1

Prior runtime-readiness branch:
wip/phase-4-runtime-content-readiness-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-runtime-content-readiness-design.md

Acceptance evidence:
docs/testing/phase4-runtime-content-readiness-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`464bd44`

Accepted local engineering result:

- `CombatPack` no longer means "spawn Marauders";
- shared combat-pack content now uses ordered typed entries;
- each entry references a stable enemy archetype;
- each enemy archetype references a stable server factory ID;
- `DungeonEnemyFactoryRegistry` owns server-only factory registration;
- `CombatPackEncounterExecutor` executes mixed-archetype packs generically;
- the old `MarauderPackEncounterExecutor` was removed;
- Deep Echoes and Crystal Bloom bonuses target explicit pack EntryIds;
- existing Temple/Mine Depth1 Marauder counts, names and spawn-index ranges are
  preserved;
- a synthetic 2-Marauder + 1-Elite pack proves heterogeneous execution without
  enabling Elite as production content;
- partial mixed-pack failures clean all previously spawned enemies;
- runtime readiness now validates pack entries, enemy archetypes, enemy
  factories and bonus-rule targets;
- no new production enemy archetype was enabled;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `464bd44` includes:

- **507** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Enemy Factory Registry: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Spawn Catalog: **15 assertions PASS**;
- existing Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in the clean Dungeon rerun;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior enemy-pack-registry worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnemyPackRegistry_v1

Prior enemy-pack-registry branch:
wip/phase-4-enemy-archetype-combat-pack-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-enemy-archetype-combat-pack-design.md

Acceptance evidence:
docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE
CLOSEOUT** at:

`ccd289b`

Accepted local engineering result:

- runtime selection now resolves DungeonId + DifficultyId + LayoutId;
- production preserves DifficultyId from TeleportData;
- Studio supports an optional explicit difficulty override;
- unregistered selected layouts fail closed;
- physical slots now declare explicit exit-barrier anchors;
- environment trigger/barrier activation is generic over arbitrary layout slots;
- DungeonEnvironmentBootstrap no longer contains Temple/Mine trigger/barrier
  arrays;
- readiness rejects logical exit-barrier bindings without physical anchors;
- synthetic four-slot activation passed;
- current Temple Depth1 boot/admission behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `ccd289b` includes:

- **510** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Runtime Selection: **7 assertions PASS**;
- Environment Layout Activation: **12 assertions PASS**;
- Encounter Bindings: **30 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **7 source/test files, 0 art/model/mesh/terrain/image
  files**.

Prior runtime-layout-selection worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeLayoutSelection_v1

Prior runtime-layout-selection branch:
wip/phase-4-runtime-layout-selection-v1

Acceptance evidence:
docs/testing/phase4-runtime-layout-selection-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`cfbf2ea`

Accepted local engineering result:

- combat-capable physical slots now declare EnemySpawnGroup;
- encounter bindings expose EnemySpawnGroup and ExitBarrierAnchor;
- CombatPackEncounterExecutor uses binding-owned environment groups instead of
  room-ID spawn translation;
- DungeonRuntime uses binding-owned physical barrier anchors for encounter clear
  and recovery;
- readiness rejects combat bindings without spawn groups;
- the generic runtime no longer depends on Temple/Mine GROUP_BY_ROOM or
  BARRIER_BY_ROOM maps;
- existing adapter compatibility helpers remain available for older callers;
- current Depth1 behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `cfbf2ea` includes:

- **512** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **34 assertions PASS**;
- Dungeon Encounter Environment Runtime: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Active worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnvironmentBindingRuntime_v1

Active branch:
wip/phase-4-environment-binding-runtime-v1

Acceptance evidence:
docs/testing/phase4-environment-binding-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

## Repository safety

Primary gameplay repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Phase 3 completion worktree/branch remains preserved for history:

- worktree:
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1
- branch: wip/phase-3-systems-alpha-completion-v1

Do not reset hard, clean, force-push, rewrite history or merge the art worktree
into gameplay. Validation builds belong in TEMP locations.
