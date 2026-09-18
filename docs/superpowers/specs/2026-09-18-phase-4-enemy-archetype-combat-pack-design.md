# Phase 4 Enemy Archetype + Combat Pack Registry - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Generic Enemy Archetype + Heterogeneous Combat Pack Registry
**Baseline:** `5298699`
**Scope:** backend only

## Goal

Remove the remaining assumption that `CombatPack` means "spawn Marauders".

A combat pack must be able to contain one or more typed enemy entries while the
current Temple and Abandoned Mine Depth1 rooms continue to spawn exactly the
same Marauders, with the same names, counts, rewards, health and event/rare
bonuses.

No new production enemy archetype is enabled in this gate.

## Shared content model

Extend `DungeonRuntimeContentCatalog` with:

- enemy archetype definitions;
- implemented enemy-factory IDs;
- heterogeneous pack entry definitions.

The only production archetype initially registered is `Marauder`.

Each pack contains ordered `Entries`.

Each entry declares:

- stable EntryId;
- EnemyArchetypeId;
- BaseCount;
- EnemyNamePrefix;
- SpawnIndexBase.

Pack bonus rules target an EntryId so future events can modify one component of
a mixed pack without changing unrelated enemies.

Current Deep Echoes and Crystal Bloom bonuses continue to add one Marauder.

## Server factory boundary

Add `DungeonEnemyFactoryRegistry`.

It maps stable enemy FactoryId values to server-only factory modules.

The execution bootstrap registers:

`Marauder -> DungeonMarauderFactory`

and verifies every factory declared implemented by the shared catalogue is
actually registered.

## Generic CombatPack executor

Replace `MarauderPackEncounterExecutor` with
`CombatPackEncounterExecutor`.

The executor:

- resolves the pack by PackId;
- resolves every entry's enemy archetype;
- resolves the matching server factory;
- calculates entry counts from immutable instance state;
- consumes room spawn points in deterministic pack-entry order;
- applies the existing difficulty health/damage/reward scaling;
- cleans all partial spawns if any entry/factory fails;
- returns one combined enemy list and objective.

The executor accepts injected registry/catalog dependencies for focused tests.

## Readiness integration

Static readiness must validate pack structure as well as pack existence.

A CombatPack is incomplete if:

- it has no valid entries;
- an entry references an unknown enemy archetype;
- an archetype references an unimplemented enemy factory;
- a bonus rule targets an unknown EntryId.

## Compatibility

- Temple Room1 remains 2 Marauders.
- Temple Room2 remains 3 Marauders.
- Mine Deep Echoes Room1 remains 3 Marauders.
- Mine Crystal Bloom Room2 remains 4 Marauders.
- Existing enemy names and spawn-index ranges remain unchanged.
- Existing Marauder tuning/factory remains unchanged.
- Boss execution is untouched.
- Depth2-Depth4 remain release-disabled/not ready.
- Event/Secret boss content remains disabled.
- No modelling, meshes, terrain, authored rooms or presentation work.

## Acceptance

Require test-first RED -> GREEN, current pack parity, heterogeneous synthetic
pack proof, partial-failure cleanup, readiness coverage, execution-bootstrap
coverage, repository parse, four Rojo builds and final Base/Dungeon regressions.
