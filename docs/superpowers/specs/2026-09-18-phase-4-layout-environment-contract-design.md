# Phase 4 Layout-Derived Environment Contract - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Selected-Layout Environment Contract
**Baseline:** `87a88c1`
**Scope:** backend only

## Demonstrated blocker

EnvironmentAnchorResolver only returns exact anchors and groups declared by its
supplied contract.

The production contracts are still Depth1-specific:

- Temple declares Room1/Room2 spawn prefixes and Room1-Room3 anchors;
- Abandoned Mine declares Room1/Room2 spawn prefixes and Room1-Room3 anchors.

Therefore a registered Room4+ layout would still be invisible to the runtime
even though layout selection, encounter binding, spawning and barriers are now
generic.

## Goal

Build the runtime environment contract from:

1. a dungeon-wide base contract; and
2. the selected physical layout.

The selected layout becomes the authority for room anchors and enemy-spawn
groups.

## Runtime base contracts

Add environment-wide runtime base contracts containing only anchors that are
not owned by a room layout.

For the current dungeons these are:

- CompletionPosition;
- ReturnToBase.

The selected layout supplies:

- EntranceAnchor;
- TriggerAnchor;
- CheckpointAnchor;
- ExitBarrierAnchor when present;
- BossSpawnAnchor when present;
- enemy-spawn group definitions for combat-capable slots.

Existing full TEMPLE / ABANDONED_MINE contracts remain available for backwards
compatibility tests and legacy adapter calls.

## Combat spawn-group metadata

Combat-capable physical slots add:

- EnemySpawnPrefix;
- EnemySpawnMinCount.

Together with the existing EnemySpawnGroup, these fields fully describe the
resolver group without a static EnvironmentAnchorDefinitions room entry.

Readiness rejects incomplete combat group metadata.

## Contract builder

Add `DungeonLayoutEnvironmentContract`.

Given one runtime base contract and one physical layout, it returns a resolver
contract with:

- deduplicated required exact anchors;
- selected layout room anchors;
- selected layout combat spawn groups;
- the same EnvironmentId as the base contract.

Invalid layout anchors, invalid group metadata or duplicate conflicting group
definitions fail closed.

## Production integration

DungeonEnvironmentBootstrap must build the selected-layout contract before
calling EnvironmentAnchorResolver.

DungeonEnvironmentRouter must rebuild the same selected-layout contract after
bootstrap and pass it into the selected adapter.

TempleEnvironmentAdapter.resolve and AbandonedMineEnvironmentAdapter.resolve
accept an optional contract. When omitted, they retain the legacy full contract
for compatibility callers.

## Compatibility and scope

- Current Temple Depth1 environment remains unchanged.
- Current Mine Depth1 environment remains unchanged.
- Existing adapter-specific tests can continue using legacy contracts.
- No higher-depth layout is registered by this gate.
- No Room4+ model, anchor or mesh is created.
- Depth2-Depth4 remain release-disabled/content-incomplete.
- No Event/Secret boss content is enabled.

## Acceptance

Require RED -> GREEN proving:

- a synthetic four-room selected layout produces Room4 exact anchors;
- a synthetic Room4 enemy group is generated from layout metadata;
- EnvironmentAnchorResolver resolves the Room4 anchors/group from that contract;
- insufficient Room4 group anchors fail closed;
- invalid combat group metadata fails closed;
- current Depth1 Base/Dungeon regressions remain green;
- repository parse, four Rojo builds and source-boundary audit pass.
