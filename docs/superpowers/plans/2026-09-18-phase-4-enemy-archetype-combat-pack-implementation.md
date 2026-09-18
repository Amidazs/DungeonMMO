# Phase 4 Enemy Archetype + Combat Pack Registry - Implementation Plan

**Baseline:** `5298699`
**Branch:** `wip/phase-4-enemy-archetype-combat-pack-v1`

## Task 1 - RED contract

Add focused tests for:

- missing enemy-factory registry;
- missing generic CombatPack executor;
- registry duplicate/invalid registration;
- a synthetic heterogeneous two-archetype pack;
- partial-factory failure cleanup.

Run the Dungeon candidate in Studio and capture the intended RED.

## Task 2 - Shared content catalogue

Add enemy archetype + enemy-factory registration metadata.

Migrate current StandardRoom1/StandardRoom2 packs to ordered Entries while
preserving exact existing counts/names/spawn-index ranges and Mine bonus rules.

## Task 3 - Server factory registry

Add `DungeonEnemyFactoryRegistry`.

Register DungeonMarauderFactory as stable FactoryId `Marauder`.

Make execution bootstrap verify every shared implemented factory ID exists
server-side.

## Task 4 - Generic pack executor

Add `CombatPackEncounterExecutor`.

Route `CombatPack` bootstrap execution through it.

Remove the Marauder-specific pack executor after all references migrate.

Keep current reward/health/damage scaling and transactional cleanup behavior.

## Task 5 - Readiness + catalogue compatibility

Extend runtime readiness to validate pack entries, archetypes, factories and
bonus-rule targets.

Keep `resolve_pack_count` as a compatibility total-count helper while adding a
per-entry count resolution API.

## Task 6 - Acceptance

Run focused Studio tests, then:

- repository-wide Luau parse;
- all four Rojo builds;
- final committed Base regression;
- final committed Dungeon regression;
- source-boundary audit.

Update continuity docs and create a local closeout checkpoint.

Do not enable higher depths, add production enemy content, push, merge or
publish without a separate deliberate action.
