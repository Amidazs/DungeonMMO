# Phase 2 Second Modular Dungeon + Rare-State/Event Proof Design

**Project:** DungeonMMO
**Date:** 16 September 2026
**Status:** APPROVED delegated design direction for the selected Roadmap v1.36 Phase 2 slice
**Baseline:** `60fc0dfd9954e2d580157a580da2425e2b71dd70`

## Purpose

Prove that the accepted Base/Dungeon architecture can host a genuinely different second dungeon without parallel persistence, combat, equipment, profession, reward or reconnect systems.

The second dungeon is the **Abandoned Mine**. The first implementation is a functional candidate, not launch art. It proves a second semantic environment, deterministic handcrafted module selection, one persistent rare state, and one time-limited event state. Normal completion remains valid in every state.

## Functional route

The runtime encounter skeleton deliberately keeps the accepted encounter/checkpoint IDs so recovery logic is reused safely:

- Entry Shaft;
- Room 1 module: **Ore Gallery** or **Rooted Cavern**;
- Room 2 module: **Winch Chamber** or **Flooded Cut**;
- Foreman's Vault boss room.

Module identities are selected once per new session from the session ID and persisted with the run.

## Rare state: Crystal Bloom

`CrystalBloom` is the first rare dungeon state. Prototype chance is **20%** for a normal Abandoned Mine session; this is a WORKING balance value.

The decision is deterministic and stored on `DungeonSessionService.InstanceState`, so reconnect/reconstruction cannot reroll it. Functional delta:

- Room 2 receives one additional enemy;
- cyan crystal-state presentation appears in Room 2;
- completion uses the rare-state reward table;
- the ordinary boss/completion route remains valid.

Studio can force the state for deterministic testing.

## Time-limited event: Deep Echoes

`DeepEchoes` is the first event-window proof. Its cadence is operations-controlled rather than hard-coded: optional server attributes define a start/end Unix window. Only eligible **newly-created** sessions receive the event; existing sessions never mutate.

Functional delta:

- Room 1 receives one additional enemy;
- purple event presentation appears in Room 1;
- completion uses the event reward table;
- event and Crystal Bloom may coexist, with the event reward table taking precedence;
- normal completion remains valid.

Studio can force the event for deterministic testing.

## Authority and persistence

All instance-state authority is server-owned. `DungeonSessionService:set_instance_state(session_id, state)` initializes the state once on a Creating/Active session and rejects a second mutation.

State stores `DungeonId`, `Module1Id`, `Module2Id`, `RareStateId`, `EventId`, `EventActive`, and `CreatedAt`. No profile-schema change is required because this data is run-scoped.

## Rewards

The Mine reuses the accepted idempotent RewardService/completion save barrier and existing safe item definitions. It has normal, Crystal Bloom and Deep Echoes completion tables. The Temple-only Arc Slash first-clear grant remains Temple-only.

## Environment contract

A new semantic `AbandonedMine` contract provides entry, three room checkpoints/triggers, Room 1/2 barriers, enemy-spawn groups, Foreman spawn, completion and return anchors. The functional proof uses a synthetic mine shell. Authored Mine art is later and must use the isolated art-library workflow.

## Base / routing

The Base dungeon board exposes Temple and Abandoned Mine entry. Both use the existing Dungeon Place and accepted handoff/session architecture. The Temple portal remains a Temple shortcut.

## Acceptance gate

Before acceptance:

- new tests are observed RED before production implementation;
- focused tests turn GREEN;
- all four Rojo compositions build;
- normal Mine state completes;
- forced Crystal Bloom + Deep Echoes completes;
- state/module presentation and enemy-count deltas are visible;
- reconnect/recovery preserves the same instance state;
- Temple regressions remain green;
- no duplicate rewards or new red runtime errors appear.

No Roblox publish, PROD, Robux, monetisation or art-worktree action is part of this gate.
