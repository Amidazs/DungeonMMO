# DungeonMMO Agent Operating Rules

These rules apply to autonomous or semi-autonomous development agents working
in this repository.

## Startup sequence

Before modifying source:

1. Read `docs/ai/CURRENT_STATE.md`.
2. Read `docs/ai/HANDOFF.md`.
3. Read `docs/ai/TEST_MATRIX.md`.
4. Read `docs/ai/AUTOMATION.md`.
5. Treat `docs/roadmap/DungeonMMO_Roadmap_v1_43.docx` as the canonical
   long-form roadmap.
6. Read the active approved design and implementation plan under
   `docs/superpowers/specs/` and `docs/superpowers/plans/`.
7. Inspect branch, HEAD, status, worktrees, remotes and `git diff --check`
   before changing source.

If repository state disagrees with continuity documents, stop source
modification and reconcile without destructive Git operations.

## Current accepted boundary

- Phase 1: ACCEPTED / functionally complete.
- Phase 2 - Vertical Slice: FORMALLY COMPLETE / ACCEPTED.
- Phase 3 - Systems Alpha: FORMALLY COMPLETE / ACCEPTED.
- Phase 3 gameplay release: `84662948127eb1a37c9f184c6abbafe6f2daddb6`.
- Phase 3 documentation closeout: `a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9`.
- Phase 4 - Content Alpha: ACTIVE.
- Progressive Dungeon depth + difficulty backend foundation: LOCAL GREEN.
- Progressive-depth checkpoint: `1230e6c`.
- Generic Dungeon encounter runtime gate: LOCAL GREEN.
- Generic-runtime implementation checkpoint: `5ba9f4d`.
- Encounter execution/spawn registry gate: LOCAL GREEN.
- Execution-registry implementation checkpoint: `fe1856e`.
- Multi-depth physical room-binding runtime gate: LOCAL GREEN.
- Multi-depth room-runtime implementation checkpoint: `1aa81b5`.
- Runtime content readiness registry gate: LOCAL GREEN.
- Runtime-readiness implementation checkpoint: `2e2420b`.
- Generic enemy archetype + combat-pack registry gate: LOCAL GREEN.
- Enemy-pack implementation checkpoint: `464bd44`.
- Runtime layout selection + environment activation gate: LOCAL GREEN.
- Runtime-layout implementation checkpoint: `ccd289b`.
- Environment binding runtime gate: LOCAL GREEN.
- Environment-binding implementation checkpoint: `cfbf2ea`.
- Layout-derived environment contract gate: LOCAL GREEN.
- Layout-environment implementation checkpoint: `405dde5`.
- Studio difficulty/session parity gate: LOCAL GREEN.
- Studio-parity implementation checkpoint: `d9297f8`.
- Depth2 backend combat + boss content gate: LOCAL GREEN.
- Depth2-content implementation checkpoint: `b525235`.
- Depth3 backend combat + boss content gate: LOCAL GREEN.
- Depth3-content implementation checkpoint: `092bd99`.
- Gate release state: not pushed, merged or published.
- Active branch: `wip/phase-4-depth3-content-v1`.
- Active worktree:
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth3Content_v1`.

The user has explicitly parked modelling, meshes and Starting Base presentation
work for now. Do not reopen accepted Phase 1-3 architecture unless a real
regression or integration defect is demonstrated.

## Git safety

- `main` is for deliberately accepted checkpoints.
- Do not develop directly on `main`.
- New gameplay gates use an isolated feature branch/worktree.
- Never reset hard, clean, force-push, rewrite history or discard local work
  without explicit user approval.
- Review exact diffs before deliberate commits.
- Commit, push, merge and Roblox publish are consequential actions. Follow the
  user's explicit choice for each closeout.
- A local-merge choice does not imply a remote push.

## Build and validation rules

- `default.project.json` builds the Dungeon Place.
- `base.project.json` builds the Starting Base Place.
- `published-dungeon.project.json` and `published-base.project.json` are also
  required for final cross-composition gates.
- Write validation `.rbxl` files only to timestamped TEMP paths.
- Never overwrite `DungeonMMO.rbxl`.
- Run `git diff --check` after source changes.
- Preserve relevant accepted regression families.
- New behaviour follows test-first RED -> GREEN development.
- A Rojo build does not prove Roblox runtime tests passed. Fresh Studio
  evidence is required for genuinely runtime/visual behaviour.

## Roblox authority and environment rules

Combat, progression, inventory, equipment, professions, party/session state,
rewards, saves and handoff remain server-authoritative.

Do not autonomously:
- publish PROD;
- publish TEST without explicit approval;
- enable live paid-revive Developer Products;
- spend Robux;
- mutate production DataStores;
- alter monetisation;
- bypass TEST/PROD guards.

TEST-only debug hooks must remain rejected or disabled in PROD.

## Accepted party invariants

- PartyService is temporary same-Base-server authority only.
- Party membership is not Profile/DataStore persistence.
- Party size is 1-4.
- Multi-member parties require all members Ready.
- Membership changes and selected-dungeon changes invalidate readiness.
- Leader transfer is deterministic to the longest-standing remaining member.
- Server revalidation occurs immediately before entry.
- Accepted members are handed to existing TeleportCoordinator /
  DungeonSessionService authority; the Base party is not parallel dungeon
  membership authority.
- Both Temple and Abandoned Mine entry are supported.
- Studio negative synthetic UserIds are allowed only under
  `RunService:IsStudio()`.
- The Studio `PlayerN` Human/Fighter auto-identity harness must never become a
  production identity shortcut.

## Selected next-gate discipline

The generic encounter execution/spawn registry is locally green at `fe1856e`.
The multi-depth physical room-binding runtime is locally green at `1aa81b5`.
The runtime content readiness registry is locally green at `2e2420b`.
The generic enemy archetype/combat-pack registry is locally green at
`464bd44`.
The runtime layout-selection/environment-activation gate is locally green at
`ccd289b`.
The environment binding runtime gate is locally green at `cfbf2ea`.
The layout-derived environment contract gate is locally green at `405dde5`.
The Studio difficulty/session parity gate is locally green at `d9297f8`.
The Depth2 backend content gate is locally green at `b525235`.
The Depth3 backend content gate is locally green at `092bd99`.

Do not push, merge, publish, enable higher depths, or enable Event/Secret boss
content without a deliberate next action from the project owner. Continue
backend-only content work with Depth4 while keeping every unauthored depth
release-disabled.

Locked rules that carry forward:

- Depth1/2/3/4 expose 3/4/5/6 logical encounters respectively.
- Each deeper difficulty adds content and stronger enemies; it is not merely a
  stat multiplier.
- The final depth reuses earlier difficulty bosses as minibosses and ends with a
  new true final boss.
- Dungeon modifiers remain an independent session-owned axis.
- Existing Depth1 behaviour is the compatibility baseline.
- Depth2-Depth4 are defined in backend data but fail closed until their physical
  runtime content is explicitly ready.
- Persistent unlock progression uses schema v13 and a separate versioned
  profile field; legacy `DungeonProgress` remains untouched.
- A completed Depth1 may unlock Depth2 logically while Depth2 entry still fails
  closed until runtime content is deliberately accepted.
- No client may supply authoritative difficulty tuning values.
- Live Dungeon progression authority is the generic encounter sequencer, not
  Room1/Room2/Boss booleans.
- Supported encounter kinds include Combat, MiniBoss, Boss, FinalBoss,
  EventBoss and SecretBoss.
- Optional Event/Secret encounters are inserted only from server-owned
  instance-state conditions and are frozen into the materialized run plan.
- Required inserted encounters cannot be bypassed by later room triggers.
- Current Depth1 physical bindings fail closed when an activated encounter has
  no authored room/spawn/checkpoint binding.
- DungeonRuntime must not choose concrete enemy/boss factories; encounter
  descriptors route through the server-owned execution registry.
- Combat packs contain ordered typed entries rather than assuming Marauders.
- Pack entries resolve stable enemy archetypes and server-owned factory IDs.
- Pack bonus rules target explicit EntryIds.
- Current production enemy archetypes remain intentionally limited to Marauder.
- Boss-family content resolves through stable BossId -> factory registration.
- Boss spawn claims are scoped by session + stable encounter ID so multiple
  miniboss/boss/event/secret encounters can coexist in one run.
- Missing packs/boss IDs/factories/execution bindings fail closed.
- Failed encounter startup must clean partial spawns and roll sequence state
  back to Pending.
- Physical room slots/triggers/spawn anchors/barriers/checkpoints resolve from
  generic layout/binding data; live progression must not reintroduce fixed
  Room1/Room2/Boss branching.
- Boss spawn anchors are binding-specific.
- Both current dungeons must continue to fail closed for unregistered Depth2,
  Depth3 and Depth4 physical layouts.
- `RuntimeReleaseEnabled` is only the explicit rollout switch.
- Production entry must use computed `DungeonRuntimeContentReadiness`; no
  entry path may treat the release switch alone as runtime readiness.
- Shared static layout/pack/boss/executor/factory registrations belong in
  `DungeonRuntimeContentCatalog`; Dungeon wrappers must not duplicate them.
- Runtime environment setup must derive triggers/barriers from the selected
  registered layout; do not reintroduce dungeon-specific trigger arrays.
- Production runtime selection must preserve TeleportData DifficultyId and
  validate the selected registered layout.
- Generic combat spawning must use binding-owned EnemySpawnGroup data; do not
  translate logical room IDs through dungeon-specific spawn maps.
- Generic encounter barrier progression must use binding-owned
  ExitBarrierAnchor data; do not translate logical room IDs through
  dungeon-specific barrier maps.
- Production environment resolution must derive room exact anchors and spawn
  groups from the selected registered layout, not static Depth1 contracts.
- Combat slots must own spawn-group name, prefix and minimum anchor count.
- Studio-created dungeon sessions must preserve the same selected DifficultyId
  as the environment/runtime selection path.
- Depth2 and Depth3 encounter content is registered for both current dungeons,
  but both depths remain physically unregistered and release-disabled.
- Depth4 remains content-incomplete and release-disabled.
- No Event/Secret boss content is enabled yet.
- No modelling, meshes, terrain, room authoring or visual-content work belongs
  in this gate.

## Separate environment-art branch

`art/dungeon-environment-prototype` is a separate art worktree/branch.

Do not switch to it, merge it, reset it, clean it, apply its stash or wholesale
copy it into gameplay. Follow the canonical asset-library REUSE -> VARIANT ->
NEW ASSET workflow for later authored environment work.

## Handoff discipline

At every meaningful WIP checkpoint:
- update `docs/ai/CURRENT_STATE.md`;
- update `docs/ai/HANDOFF.md`;
- update `docs/ai/TEST_MATRIX.md` when evidence changes;
- record branch/checkpoint and exact next action;
- record known defects and unresolved evidence.

At an accepted gate, update the canonical roadmap.

No critical implementation knowledge may exist only in an agent chat.
