# Phase 4 Environment Binding Runtime - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Binding-Owned Spawn Groups + Exit Barriers
**Baseline:** `caf56c5`
**Scope:** backend only

## Demonstrated blocker

Higher-depth combat rooms still depend on dungeon-specific adapter maps:

- `GROUP_BY_ROOM` maps logical room IDs to enemy-spawn groups;
- `BARRIER_BY_ROOM` maps logical room IDs to physical barrier anchors.

That means adding Room4/Room5 combat content would still require edits inside
Temple/Mine adapters even though layout selection and encounter binding are now
generic.

## Goal

Move these runtime dependencies into physical layout/binding data so the generic
combat executor and runtime can use resolved binding metadata directly.

## Physical slot metadata

Combat-capable layout slots gain:

- `EnemySpawnGroup` - the resolved environment group containing ordered enemy
  spawn anchors.

Slots that own an exit barrier already expose:

- `ExitBarrierRoomId` - logical adapter/runtime room identifier;
- `ExitBarrierAnchor` - physical anchor ID.

Encounter bindings must carry both `EnemySpawnGroup` and
`ExitBarrierAnchor`.

Readiness must reject a CombatPack slot without a valid EnemySpawnGroup.

## Combat execution

`CombatPackEncounterExecutor` must no longer call
`environment:enemy_spawn_cframes(room_id)`.

Instead it reads `binding.EnemySpawnGroup`, requests that resolved group from
the environment adapter, and converts its ordered BaseParts to CFrames.

This makes spawn selection binding-owned rather than room-map-owned.

## Exit barrier runtime

Add a small `DungeonEncounterEnvironmentRuntime` helper that opens/closes the
physical barrier named by `binding.ExitBarrierAnchor`.

DungeonRuntime uses this helper for:

- normal encounter-clear barrier opening;
- reconnect/recovery barrier reconstruction.

The generic runtime no longer calls `environment:set_exit_open(room_id)`.

Existing adapter compatibility methods may remain for older tests/callers, but
they are no longer part of generic encounter progression.

## Compatibility

- Temple Room1/Room2 use their existing spawn groups.
- Mine Room1/Room2 use their existing spawn groups.
- Existing spawn order/counts remain unchanged.
- Existing exit barriers behave identically.
- Boss encounters do not require EnemySpawnGroup.
- No new higher-depth rooms, anchors or enemies are enabled.

## Acceptance

Require test-first RED -> GREEN proving:

- bindings expose EnemySpawnGroup and ExitBarrierAnchor;
- CombatPack execution succeeds using only environment:get_group;
- missing spawn group fails closed;
- generic barrier helper opens/closes an arbitrary physical anchor;
- missing barrier anchor fails closed;
- DungeonRuntime no longer calls enemy_spawn_cframes/set_exit_open for generic
  encounter progression;
- current Temple/Mine Depth1 regressions remain green;
- repository parse, four Rojo builds, Base/Dungeon regressions and
  source-boundary audit.
