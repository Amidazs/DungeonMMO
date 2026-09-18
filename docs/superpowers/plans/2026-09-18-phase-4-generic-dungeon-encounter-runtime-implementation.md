# Phase 4 Generic Dungeon Encounter Runtime - Implementation Plan

**Baseline:** `1e1574c`
**Branch:** `wip/phase-4-generic-dungeon-runtime-v1`

### Task 1 - Encounter descriptor + plan resolution

Create pure modules/tests for:

- supported encounter kinds including EventBoss/SecretBoss;
- stable optional before/after insertion;
- server-owned InstanceFlag/RareState activation;
- required versus optional encounters;
- duplicate/unknown anchors fail closed.

### Task 2 - Generic encounter sequencer

Create a pure sequencer with tests for:

- arbitrary encounter counts;
- one active encounter;
- ordered start/clear;
- optional skip;
- required-completion readiness;
- idempotent clear;
- reconnect snapshot/reconstruction by stable IDs.

### Task 3 - Generic checkpoint/recovery mapping

Add stable checkpoint IDs derived from encounter IDs and prove:

- monotonic sequence;
- current encounter restarts after reconnect;
- earlier clears stay cleared;
- optional insertion does not break checkpoint reconstruction.

### Task 4 - Depth1 live runtime integration

Replace Room1/Room2/Boss boolean progression authority with the sequencer while
keeping existing physical triggers/spawn adapters.

Depth1 must remain behaviourally compatible.

### Task 5 - Event/Secret extension contract

Add definition-level optional encounter support without adding actual Event or
Secret boss content. Prove example descriptors can materialise deterministically
from immutable instance state.

### Task 6 - Cumulative regression

- repository-wide Luau parse;
- `git diff --check`;
- generic plan/sequencer/recovery suites;
- existing difficulty/session/modifier/reward/completion suites;
- Base/Dungeon Studio compositions;
- four Rojo builds;
- no art/model/mesh/terrain changes.

### Task 7 - Documentation checkpoint

Update continuity and test-matrix documents. Do not push/merge/publish without
explicit approval.
