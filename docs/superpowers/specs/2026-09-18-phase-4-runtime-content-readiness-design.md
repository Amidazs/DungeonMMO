# Phase 4 Runtime Content Readiness - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Dungeon Runtime Content Readiness Registry
**Baseline:** `a942f6d`
**Scope:** backend only

## Goal

A difficulty must not become playable because one boolean was changed.

Base-side entry must be able to prove that the static runtime content required
by a difficulty is registered before a session is created. The Dungeon keeps
its existing live checks for real Instances, spawn points and environment
anchors after the reserved server starts.

## Core distinction

Two independent states are required:

- **Release enabled:** an explicit project-owner rollout switch.
- **Content complete:** computed from registered backend content.

A difficulty is **Ready** only when both are true.

## Shared content catalogue

Create `DungeonRuntimeContentCatalog` under ReplicatedStorage/Core/Shared.

It becomes the static source of truth for:

- registered physical layout metadata;
- registered combat-pack specifications;
- registered boss-content specifications;
- implemented encounter executor IDs;
- implemented boss-factory IDs.

Dungeon-only wrappers consume this shared catalogue rather than duplicating its
data. Runtime-only factory modules and live Instances remain server-side.

## Readiness analyser

Create `DungeonRuntimeContentReadiness` under ReplicatedStorage/Core/Shared.

`analyze(dungeon_id, difficulty_id)` returns a detached result containing:

- `Ready`;
- `ContentComplete`;
- `ReleaseEnabled`;
- `Issues`;
- the resolved difficulty when valid.

Unknown dungeon/difficulty requests fail explicitly.

## Static checks

For every required encounter, readiness verifies:

1. the difficulty layout is registered;
2. the referenced room slot exists;
3. the slot supports the encounter executor family;
4. required anchor IDs are declared in the layout;
5. the encounter executor ID is implemented;
6. CombatPack encounters reference a registered pack;
7. Boss-family encounters reference registered boss content;
8. the boss content references an implemented boss factory.

The analyser does not pretend to prove that Roblox Instances currently exist.
That remains the responsibility of DungeonEncounterBindings and executor
validation inside the Dungeon server.

## Release switch

Rename the misleading `RuntimeReady` field to `RuntimeReleaseEnabled`.

Depth1 remains enabled. Depth2-Depth4 remain disabled.

Base entry services must use the readiness analyser rather than reading the
release flag directly.

## Compatibility and safety

- External entry failure remains `DifficultyContentNotReady`.
- Existing Depth1 gameplay is unchanged.
- Higher depths remain fail closed.
- Existing EventBoss/SecretBoss live fail-closed behavior remains unchanged.
- Optional Event/Secret content is not required for base difficulty readiness
  unless it is part of that difficulty's required encounter sequence.
- No modelling, meshes, terrain, authored rooms or presentation work.
- No TEST/PROD publish, PROD DataStore or Robux action.

## Acceptance

The gate requires:

- test-first RED then GREEN for readiness;
- Depth1 complete+enabled for both current dungeons;
- Depth2-Depth4 incomplete+disabled with useful issue codes;
- entry paths proven to use computed readiness;
- Dungeon bootstrap still proves actual current executors/factories;
- repository parse, four Rojo builds and focused Base/Dungeon regressions.
