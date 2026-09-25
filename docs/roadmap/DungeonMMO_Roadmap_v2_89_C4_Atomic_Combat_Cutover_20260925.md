# DungeonMMO Roadmap v2.89 — Atomic C4 Combat Cutover

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.88](
DungeonMMO_Roadmap_v2_88_C4_Level30_Dispatch_Audit_Closure_20260925.md).

## Goal

Replace independent manual source-gate switching with one server-only,
transactional and reversible cutover coordinator.

No normal gameplay activation is part of this milestone.

## Implementation

New service:

`C4CombatCutoverCoordinator`.

The coordinator owns orchestration only. Existing authorities remain separate:

- `C4ResourceCutoverService`;
- `C4SourceCombatCalculationService`;
- `C4SourceCombatExecutor`;
- `C4CombatDispatchAdapter`.

A source-combat enable transaction requires:

1. every underlying gate initially OFF;
2. damage-family audit `ActivationAuditReady=true`;
3. explicit server-selected participants;
4. explicit Roblox-stud -> source-unit height scale;
5. explicit server-owned source-night provider.

It then enables in order:

1. global resource cutover;
2. each explicit participant's source resources;
3. source combat calculations;
4. live source executor;
5. current-combat dispatch adapter.

If any participant or later gate fails, the coordinator reverses every
already-mutated state and returns the strict failing reason.

Disable order is the reverse:

1. dispatch OFF;
2. executor OFF;
3. calculation provider OFF;
4. participant resource opt-ins removed;
5. global resource gate OFF.

The global resource disable retains its existing fraction-preserving rollback
to the current resource model.

## Runtime composition

Dungeon `RuntimeServices` now composes and exposes one coordinator using the
already-bound live executor/resource/dispatch authorities.

Base runtime does not compose a usable cutover coordinator because live C4
resource authority remains Dungeon-specific.

Nothing calls `enable(...)` during normal server bootstrap.

## Fresh acceptance

Candidate:

`4dc1f2ee56814c9af3e0cf42de339c08f68c0211`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **22/22 PASS**;
- Dungeon: **25/25 PASS**;
- cutover coordinator: **7 assertions PASS**;
- dispatch adapter: **18 assertions PASS**;
- family audit: activation-ready;
- Dungeon dispatch integration: PASS;
- source resource cutover: PASS.

The isolated cutover test proves:

- default OFF;
- a blocked audit mutates nothing;
- a partial participant failure rolls everything back;
- a late dispatch failure rolls earlier resource/combat gates back;
- successful activation turns on every expected authority;
- snapshot evidence matches the active transaction;
- disable returns every gate and participant to OFF.

## Safety boundary

The coordinator has no client entry point.

No production spatial conversion or source-night mapping has been selected and
normal Dungeon bootstrap does not invoke the coordinator.

No main merge, Roblox publish, production persistence or animation mutation is
part of this milestone.

## Next backend implementation

Perform a real unpublished Dungeon cutover rehearsal using genuine runtime
services and genuine Studio players rather than injected fakes.

The rehearsal must:

1. use the actual runtime coordinator;
2. opt genuine connected test players into C4 resources;
3. activate source calculation/executor/dispatch together;
4. exercise real player-to-NPC attacks from multiple source families;
5. verify HP/MP/CP, threat, quest/contribution and progression callbacks;
6. disable the coordinator again;
7. prove current combat/resources recover cleanly.

Keep this local/unpublished until the complete rehearsal passes.
