# Phase 4 Runtime Layout Selection - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Authoritative Runtime Layout Selection + Environment Activation
**Baseline:** `0177b17`
**Scope:** backend only

## Demonstrated blocker

`DungeonEnvironmentBootstrap.server.luau` currently hard-codes:

- exactly three encounter trigger anchors; and
- exactly two exit-barrier anchors

for each current dungeon.

That means a future registered Depth2/Depth3/Depth4 physical layout could still
not be prepared without adding another dungeon-specific branch.

## Goal

Environment startup must derive its active physical trigger/barrier set from the
selected difficulty's registered layout.

## Runtime selection

Extend `DungeonRuntimeSelection` with a new selection API that resolves:

- DungeonId;
- DifficultyId;
- LayoutId.

Production selection comes from server-trusted TeleportData.

Studio selection uses:

- `DungeonMMOStudioDungeonId`;
- optional `DungeonMMOStudioDifficultyId`.

If Studio difficulty is omitted, use the selected dungeon's default difficulty.

Unknown dungeon/difficulty/layout selections fail closed.

The existing `resolve(...)` dungeon-only API remains as a compatibility
wrapper so unrelated callers are not broken.

## Environment activation

Add `DungeonEnvironmentLayoutActivation`.

Given:

- one registered physical layout; and
- one resolved environment anchor map,

it configures every slot's declared:

- TriggerAnchor as touch-enabled, non-collidable and invisible;
- ExitBarrierRoomId-derived barrier anchor through an explicit layout field.

To avoid interpreting logical room IDs as anchor IDs, physical slot definitions
gain an explicit `ExitBarrierAnchor` field. Existing `ExitBarrierRoomId`
remains for the environment adapter/runtime API.

Boss-only slots may omit exit barriers.

The activation module must support arbitrary slot counts and must not know
Temple, Mine, Room1, Room2 or Room3.

## Environment contract boundary

`EnvironmentAnchorDefinitions` remains the authored environment contract.

Registering a future higher-depth layout therefore requires its physical anchors
to exist in the relevant environment contract. This gate does not invent those
rooms or anchors.

The environment bootstrap:

1. resolves DungeonId + DifficultyId + LayoutId;
2. builds/locates the selected dungeon environment;
3. resolves the authored environment contract;
4. loads the registered selected layout;
5. activates triggers/barriers from layout data;
6. publishes resolved Dungeon/Difficulty/Layout attributes.

## Compatibility

- Current Temple Depth1 behavior is unchanged.
- Current Abandoned Mine Depth1 behavior is unchanged.
- Existing dungeon-only selection callers remain valid.
- Depth2-Depth4 remain release-disabled/content-incomplete.
- No new rooms, anchors, enemies, bosses, models or meshes are added.

## Acceptance

Require test-first RED -> GREEN proving:

- production TeleportData difficulty selection;
- Studio default difficulty selection;
- Studio explicit difficulty selection;
- unknown difficulty fails closed;
- arbitrary synthetic four-slot layout activation;
- missing declared trigger/barrier fails closed;
- current Temple/Mine Depth1 bootstrap still starts cleanly;
- repository parse, all four Rojo builds, Base/Dungeon regressions and
  source-boundary audit.
