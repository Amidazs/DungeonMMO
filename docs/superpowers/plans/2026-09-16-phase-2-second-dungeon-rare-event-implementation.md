# Phase 2 Second Modular Dungeon + Rare-State/Event Proof Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an Abandoned Mine second dungeon with deterministic module selection, persistent Crystal Bloom rare state, and Deep Echoes event-window state while reusing accepted DungeonMMO architecture.

**Architecture:** Extend dungeon definitions; persist immutable run-scoped `InstanceState`; let existing Base/Teleport/Dungeon/Reward flows choose definitions rather than assuming TestDungeon. A Mine adapter implements the accepted dungeon-environment surface so encounter/revive/recovery/completion logic remains shared.

**Spec:** `docs/superpowers/specs/2026-09-16-phase-2-second-dungeon-rare-event-design.md`

## Constraints

- Baseline `60fc0dfd9954e2d580157a580da2425e2b71dd70`.
- Isolated feature worktree only.
- No automatic stage/commit/push/merge/publish.
- Preserve TEST/PROD/Robux safeguards and all accepted systems.
- Do not touch the art worktree.
- New runtime behavior follows RED -> GREEN evidence.

## Tasks

1. Add RED contracts for second definition, director, immutable instance state and Mine environment modules.
2. Add Abandoned Mine definitions, environment contract and reward tables.
3. Add `DungeonInstanceDirector` and immutable session state.
4. Generalize TeleportCoordinator / StudioSessionFactory / Base entry by dungeon definition.
5. Add Mine synthetic environment, adapter, runtime selection and environment router.
6. Generalize DungeonRuntime around `active_definition`, state-aware enemy counts, Mine Foreman and state-aware completion rewards.
7. Run `git diff --check`, build all four compositions, then perform normal and forced rare/event Studio acceptance.
