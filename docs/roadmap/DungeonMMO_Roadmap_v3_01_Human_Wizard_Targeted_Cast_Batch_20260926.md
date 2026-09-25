# DungeonMMO Roadmap v3.01 — Human Wizard Targeted Cast Batch

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.00](
DungeonMMO_Roadmap_v3_00_Human_Wizard_Direct_MDAM_Bridge_20260926.md).

## Status

**IMPLEMENTED IN GITHUB — LARGE LOCAL/STUDIO VALIDATION PENDING.**

Remote Desktop Commander remains intentionally unavailable tonight. No local
checkout, Rojo build, Roblox Studio run or live rehearsal was performed.

Latest code candidate before this documentation:

`a8d66d1dda51816a52f64a7eacc33aa44aa5f598`.

v2.99 remains the latest fully validated point until tomorrow's large test is
green.

## Targeted Human Wizard cast batch

The staged Human Wizard runtime has expanded from one direct spell to four
targeted spell families that reuse the same source-authoritative cast pipeline.

### Pure direct MDAM

The disabled direct bridge now reviews three single-target damage spells:

- `EmberweaverEmberBolt` -> source 1220 rank 6;
- `EmberweaverFlameBurst` -> source 1172 rank 6;
- `EmberweaverFocusedBolt` -> source 1274 rank 3.

The bridge verifies the creative/source mapping and exact source ranges before
it stores a cast receipt.

Skills with additional semantics remain excluded. For example, Frost Lance has
a slow effect and Ember Field is area magic, so neither is silently treated as
plain single-target damage.

### Periodic poison

A separate disabled `C4SourcePeriodicMagicCastService` now stages:

- `EmberweaverVenomHex` rank 2 -> source Poison 1168 rank 3.

The service shares the same cast scheduler and split-MP authority as direct
magic, but hands the completed cast to the existing source periodic-status
executor.

Area poison remains outside this first bridge.

## Non-elemental source magic

The pinned C4 source treats a magic skill with no element as neutral
elemental multiplier 1.

The source combat calculator now follows that behavior instead of rejecting a
missing element.

This unlocks exact source calculation for Flame Burst and Focused Bolt while
keeping elemental Ember Bolt on its existing vulnerability path.

## Exact source range phases

The source cast contract already contained both authored ranges. They now flow
through timing, scheduler and launch evidence.

The reviewed targeted spells use:

- Ember Bolt: cast 750, effect 1250 source units;
- Flame Burst: cast 150, effect 650;
- Focused Bolt: cast 400, effect 900;
- Venom Hex: cast 600, effect 1100.

The server executor now has a read-only source-range preflight using
authoritative character roots and the explicit source-units-per-stud cutover
scale.

The bridge checks:

1. `castRange` before initial MP/cast start;
2. `effectRange` again at the source hit deadline.

An invalid hit-time target therefore cancels before launch-time MP, source shot
resolution or damage/status execution.

## Cross-service integration

A new staged integration test uses the real:

- source cast contract;
- split-MP resource lifecycle;
- source timing planner;
- source scheduler;
- direct-MDAM bridge;
- periodic poison bridge;
- authenticated Emberweaver progression identity.

Only world/executor effects are replaced with isolated test authorities.

It covers all four staged spell families and proves the shared scheduler blocks
a direct and periodic cast from overlapping.

## Runtime composition

`C4SourceCastRuntimeComposition` now contains both direct and periodic magic
bridges, sharing the same scheduler.

A new composition regression checks both bridges remain default-off and owner
cleanup removes private source-shot state.

Base runtime still does not compose the Dungeon-only cast runtime.

## Tomorrow's large validation

Two prepared runners are now available:

- `c4_human_wizard_source_cast_focus.luau`: **14 suites**;
- `c4_human_wizard_big_backend_focus.luau`: **32 suites**.

The 32-suite runner now reaches beyond skill data into:

- first-transfer definitions and training;
- Human Wizard quest/foundation;
- exact skill tree/effect/source-link audits;
- primary/unified/resource stats;
- passive ownership;
- cast cost/timing/reuse/scheduler;
- direct and poison bridges;
- cross-service staged casting;
- source calculation and executor;
- combat dispatch adapter;
- ManaService split-spend behavior;
- DamageService source-dispatch hook;
- contribution/quest damage bookkeeping;
- Base runtime composition boundary.

Tests copied by the big runner stay beside their original Core or Combat test
folder so relative `script.Parent` dependencies remain valid.

## Validation order tomorrow

When Remote Desktop Commander returns:

1. fast-forward the local worktree to this branch;
2. run `git diff --check`;
3. build Base with Rojo;
4. run the **32-suite big backend runner** in unpublished Edit mode;
5. run the **14-suite cast-focused runner** for a concise second pass;
6. build Dungeon with Rojo;
7. inspect Dungeon startup/runtime logs;
8. verify the combat damage observer is installed through the existing
   CombatService -> C4 dispatch binding;
9. if all static/focused checks are green, run one unpublished live
   Emberweaver-to-reviewed-NPC rehearsal;
10. only then mark v3.00/v3.01 implementation green.

## Live rehearsal target

The desired first full rehearsal remains:

`cast request -> source cast-range check -> initial MP -> source cast time ->
effect-range recheck -> launch MP -> one magical shot resolution -> exact C4
effect -> NPC HP/status -> contribution/quest/threat bookkeeping -> reuse gate`.

The direct and periodic bridges remain disabled by default and are not yet
wired to ordinary client spell input.

## Deliberately excluded from this batch

Still separate future gates:

- Frost Lance slow application;
- Ember Field/AOE magic;
- Life Siphon/drain healing semantics;
- Sleep and other non-periodic debuffs;
- corpse/mana conversion skills;
- companion/servitor families;
- ordinary client-facing Wizard spell activation.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
