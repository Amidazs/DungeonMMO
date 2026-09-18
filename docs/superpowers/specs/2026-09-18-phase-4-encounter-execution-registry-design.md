# Phase 4 Encounter Execution Registry Design

**Date:** 18 September 2026
**Status:** Implemented / local green; awaiting project-owner closeout
**Baseline:** `c6e181c`
**Implementation checkpoint:** `fe1856e`

## Purpose

Decouple the generic encounter sequencer from concrete enemy/boss creation.

The encounter runtime decides **what encounter is next**. The execution layer
decides **how that encounter creates its runtime enemies**.

## Design rules

1. Encounter descriptors select stable executor/content IDs.
2. Clients never select factories, pack counts or tuning.
3. `DungeonRuntime` supplies server-owned context but does not select concrete
   enemy/boss factories.
4. Combat packs resolve through a server-owned spawn catalogue.
5. Boss-family encounters resolve through a stable BossId -> factory registry.
6. Missing execution content fails closed.
7. Startup is transactional:
   validation -> sequencer start -> spawn -> EncounterService start.
8. A failed spawn rolls the generic encounter back from Active to Pending.
9. A downstream start rejection cleans spawned content and also rolls back.
10. Duplicate boss protection is encounter-scoped, not session-global.
11. Distinct miniboss/boss/event/secret encounters may coexist in one run.
12. Current Depth1 physical/reward/clear compatibility remains intact.

## Current executors

### CombatPack

Inputs:

- `PackId`;
- DungeonId;
- physical EnvironmentRoomId;
- authoritative tuning;
- immutable InstanceState.

The spawn catalogue defines:

- base enemy count;
- reward key;
- health key;
- name prefix;
- spawn-index base;
- optional server-owned count bonuses.

### Boss

Inputs:

- stable `BossId`;
- logical encounter kind;
- compatibility RuntimeEncounterId;
- authoritative tuning;
- environment boss spawn binding.

The boss catalogue maps BossId to:

- factory ID;
- reward key;
- display name.

The factory registry maps factory ID to the implemented server-owned factory.

## Future boss content

A future MiniBoss, Boss, FinalBoss, EventBoss or SecretBoss can use the same
Boss executor.

Adding it later should normally require:

1. descriptor BossId;
2. boss catalogue entry;
3. factory registration;
4. physical room/spawn/checkpoint binding.

No change to the generic dungeon controller should be required.

## Fail-closed boundary

Unimplemented boss IDs, missing factories, missing packs, missing bindings,
invalid context and insufficient spawn anchors reject startup.

Current Depth2-Depth4 remain runtime-disabled. The registry makes them easier to
implement later; it does not silently mark them ready.
