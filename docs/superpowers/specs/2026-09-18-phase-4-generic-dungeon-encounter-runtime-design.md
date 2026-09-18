# Phase 4 Generic Dungeon Encounter Runtime - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha, backend-only gate
**Status:** Implemented / local green; awaiting project-owner closeout
**Baseline:** `1e1574c`
**Implementation checkpoint:** `5ba9f4d`

## Purpose

Replace the current hard-coded Room1 -> Room2 -> Boss progression authority with
a reusable server-owned encounter plan and sequencer.

The accepted Depth1 runtime must remain behaviourally compatible while the new
backend can later execute Depth2-Depth4 and optional Event/Secret encounters
without rewriting the dungeon controller.

## Encounter kinds

Supported stable kinds:

- `Combat`
- `MiniBoss`
- `Boss`
- `FinalBoss`
- `EventBoss`
- `SecretBoss`

Kinds describe presentation/spawn context, not separate boss classes.

## Optional insertion contract

A difficulty owns its normal `EncounterSequence`.

Future optional content is described separately and inserted relative to a
stable encounter ID:

- `InsertAfterId` or `InsertBeforeId`;
- an authoritative activation condition;
- `CompletionRequired`.

Examples:

- Event Boss: active only while a session Event flag is true and may be
  `CompletionRequired = true`;
- Secret Boss: active only after a hidden/rare-state condition and may be
  `CompletionRequired = false`.

Inactive optional encounters are absent from the materialised run plan.

## Activation authority

Activation conditions are evaluated only from immutable/server-owned session
instance state. Client payloads never decide whether an Event/Secret encounter
exists.

Initial supported condition shapes are intentionally small:

- `InstanceFlag`: key/value comparison against InstanceState;
- `RareState`: compare InstanceState.RareStateId.

The condition module can be extended later without changing the sequencer.

## Sequencer contract

The sequencer owns:

- ordered materialised encounter records;
- encounter lifecycle: Pending -> Active -> Cleared or Skipped;
- exactly one active encounter at a time;
- completion-required versus optional encounters;
- monotonic checkpoint sequence;
- current encounter identity for reconnect;
- completion readiness only when every required encounter is cleared.

Optional encounters may be explicitly skipped without marking a required
encounter complete.

## Reconnect

Persisted runtime progress records stable encounter IDs/checkpoints, never raw
array positions.

On reconnect:

- cleared encounters remain cleared;
- the active/current encounter restarts from its start checkpoint;
- inserted optional encounters resolve from the same immutable InstanceState;
- sequence changes caused by client data are impossible.

## Compatibility

Depth1 Temple/Mine keeps the existing physical Room1/Room2/Boss triggers and
spawn adapters during this gate. The live runtime will delegate progression
authority to the generic sequencer while the environment adapter still maps
those three existing physical rooms.

Depth2-Depth4 remain `RuntimeReady = false`.

## Non-goals

- no new rooms/models/meshes;
- no Event/Secret boss content yet;
- no new boss mechanics;
- no UI;
- no procedural geometry;
- no enabling Depth2-Depth4.

## Exit definition

- plan resolver supports base and optional Event/Secret encounters;
- sequencer handles arbitrary ordered encounter counts;
- required/optional completion semantics are proven;
- reconnect/checkpoint reconstruction is stable by encounter ID;
- current Depth1 runtime uses sequencer authority;
- existing Depth1 Dungeon regressions remain green;
- all four Rojo builds pass;
- no art/modelling files change.
