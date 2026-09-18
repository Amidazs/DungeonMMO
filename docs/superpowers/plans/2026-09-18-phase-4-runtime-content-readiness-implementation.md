# Phase 4 Runtime Content Readiness - Implementation Plan

**Baseline:** `a942f6d`
**Branch:** `wip/phase-4-runtime-content-readiness-v1`

## Task 1 - RED contract

Add a Core test that expects the shared readiness module.

Prove:

- both Depth1 definitions are ready;
- higher depths are not ready;
- higher-depth diagnostics expose missing layout/content dependencies;
- unknown IDs fail explicitly.

Run the test in Studio and record the expected RED before implementation.

## Task 2 - Shared static catalogue

Add `DungeonRuntimeContentCatalog` and move current static layout, pack and
boss metadata into it.

Keep DungeonRoomLayoutDefinitions and DungeonEncounterSpawnCatalog as
compatibility wrappers over the shared source of truth.

## Task 3 - Readiness analyser

Add `DungeonRuntimeContentReadiness`.

Return all static blockers rather than only the first one. Keep issue codes
stable and machine-readable.

Rename `RuntimeReady` to `RuntimeReleaseEnabled` in difficulty definitions
and tests.

## Task 4 - Entry integration

Replace direct release-flag checks in:

- DungeonDifficultyProgressionService;
- TeleportCoordinator.

Both entry paths must use computed readiness and preserve the external
`DifficultyContentNotReady` result.

Add focused tests proving an injected/not-ready result blocks entry before
session creation or teleport preparation.

## Task 5 - Dungeon compatibility

Keep current execution bootstrap registrations unchanged.

Re-run:

- Dungeon Encounter Execution Bootstrap;
- Dungeon Encounter Bindings;
- Dungeon Encounter Executors;
- Difficulty Definitions;
- Difficulty Progression;
- Teleport Coordinator.

Depth1 must remain unchanged and Depth2-Depth4 must remain fail closed.

## Task 6 - Closeout

Run:

- `git diff --check`;
- repository Luau parse;
- all four Rojo builds;
- focused Base regression;
- focused Dungeon regression;
- source-boundary audit.

Then update continuity docs and create a local gate checkpoint. Do not push,
merge or publish without separate approval.
