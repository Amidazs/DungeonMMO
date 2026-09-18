# Phase 4 Runtime Layout Selection - Implementation Plan

**Baseline:** `0177b17`
**Branch:** `wip/phase-4-runtime-layout-selection-v1`

## Task 1 - RED contract

Add focused tests for:

- new runtime selection object;
- TeleportData difficulty propagation;
- Studio difficulty override/default;
- invalid difficulty rejection;
- generic four-slot environment activation.

Run the Dungeon candidate in Studio and capture the intended RED.

## Task 2 - Physical layout metadata

Add explicit `ExitBarrierAnchor` to registered physical slots while preserving
`ExitBarrierRoomId` for the environment adapter/runtime.

## Task 3 - Runtime selection

Implement `resolve_selection(...)` in `DungeonRuntimeSelection`.

Keep `resolve(...)` as a compatibility wrapper returning only DungeonId.

Selection must validate the difficulty and registered layout before returning.

## Task 4 - Generic environment activation

Add `DungeonEnvironmentLayoutActivation`.

Replace hard-coded Temple/Mine trigger and barrier arrays in
`DungeonEnvironmentBootstrap.server.luau` with selected-layout activation.

Publish Workspace attributes for resolved difficulty and layout.

## Task 5 - Acceptance

Run focused Studio tests, repository parse, four Rojo builds, committed Base and
Dungeon regressions, and source-boundary audit.

Update continuity docs and create a local closeout checkpoint.

Do not enable higher depths, add physical content, push, merge or publish.
