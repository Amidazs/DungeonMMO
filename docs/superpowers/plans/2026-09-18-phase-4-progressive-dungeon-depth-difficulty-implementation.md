# Phase 4 Progressive Dungeon Depth + Difficulty Implementation Plan

**Goal:** Implement the approved backend-only progressive dungeon depth system
without creating or changing authored geometry.

**Spec:**
`docs/superpowers/specs/2026-09-18-phase-4-progressive-dungeon-depth-difficulty-design.md`

**Baseline:** `a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9`

## Global constraints

- Work only in
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_DungeonDepth_v1`.
- Do not touch `DungeonMMO_Art`.
- No meshes, modelling, terrain or authored-room changes.
- Preserve Depth1 as the current gameplay compatibility baseline.
- Depth2-Depth4 must fail closed until runtime content is explicitly ready.
- New behaviour follows RED -> GREEN.
- Do not push, merge or publish without separate user approval.
- Never reset hard, clean, force-push or rewrite history.

---

### Task 1 - Progressive difficulty definitions

**Create:**
- `src/ReplicatedStorage/Core/Shared/DungeonDifficultyDefinitions.luau`
- `src/ServerScriptService/Core/Tests/DungeonDifficultyDefinitionsTest.server.luau`

**Modify:**
- `src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau`

Required proof:

- Depth1-Depth4 exist for Temple and Abandoned Mine;
- room counts are 3/4/5/6;
- scaling is monotonic;
- Depth1 is RuntimeReady;
- Depth2-Depth4 are not RuntimeReady;
- final depth references previous bosses as MiniBoss encounters;
- final depth ends in a unique FinalBoss;
- default difficulty is Depth1.

- [x] RED test
- [x] implementation
- [x] GREEN test
- [x] static/build check

---

### Task 2 - Schema v13 + persistent depth progression

**Create:**
- `src/ServerScriptService/Core/Services/DungeonDifficultyProgressionService.luau`
- `src/ServerScriptService/Core/Tests/ProfileMigrationDungeonDifficultyV13Test.server.luau`
- `src/ServerScriptService/Core/Tests/DungeonDifficultyProgressionServiceTest.server.luau`

**Modify:**
- `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- `src/ServerScriptService/Core/Services/RuntimeServices.luau`

Required proof:

- schema becomes v13;
- existing `DungeonProgress` is preserved;
- new `DungeonDifficultyProgress` defaults/sanitizes safely;
- Depth1 is logically unlocked by default;
- a Depth1 clear unlocks Depth2;
- replaying the same clear does not mint/increment state;
- later depth cannot unlock by skipping the previous depth.

- [x] RED migration/service tests
- [x] implementation
- [x] GREEN tests

---

### Task 3 - Solo/party difficulty selection and entry validation

**Modify:**
- `src/ServerScriptService/Base/PartyService.luau`
- `src/ServerScriptService/Base/PartyRuntime.luau`
- `src/ServerScriptService/Base/PartyEntryCoordinator.luau`
- `src/ServerScriptService/Base/BaseRuntime.server.luau`
- relevant Base tests

Required proof:

- party stores `SelectedDifficultyId`;
- dungeon change resets difficulty to default;
- difficulty change clears readiness;
- leader-only selection;
- all party members must own the unlock;
- unlocked but unbuilt depth returns `DifficultyContentNotReady`;
- legacy solo string request means Depth1;
- structured solo request supports `DungeonId + DifficultyId`;
- client-supplied tuning values are ignored.

No player-facing difficulty UI is required in this backend gate.

- [x] RED party/entry tests
- [x] implementation
- [x] GREEN tests

---

### Task 4 - Session, teleport and immutable run-plan persistence

**Modify:**
- `src/ServerScriptService/Core/Services/DungeonSessionService.luau`
- `src/ServerScriptService/Core/Services/TeleportCoordinator.luau`
- `src/ServerScriptService/Core/Services/DungeonInstanceDirector.luau`
- relevant Core tests

Required proof:

- omitted difficulty defaults to Depth1;
- selected difficulty persists in session;
- reconnect reads the same difficulty;
- member-session routing remains valid;
- TeleportData includes `DifficultyId` and no value data;
- instance state includes difficulty/order/logical encounter plan;
- unknown difficulty is rejected;
- non-runtime-ready depth is blocked by entry/coordinator authority.

- [x] RED tests
- [x] implementation
- [x] GREEN tests

---

### Task 5 - Enemy health/damage and reward composition hooks

**Modify:**
- `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- `src/ServerScriptService/Dungeon/DungeonMarauderFactory.luau`
- `src/ServerScriptService/Dungeon/MarauderCaptainFactory.luau`
- `src/ServerScriptService/Combat/TrainingMarauderController.server.luau`
- `src/ServerScriptService/Dungeon/MarauderCaptainController.server.luau`
- focused tests

Required proof:

- missing difficulty damage attribute = 1.0;
- Depth1 remains 1.0;
- health = base * difficulty * Fortified when both apply;
- outgoing damage = base * difficulty;
- depth monster reward scaling applies before Bounty;
- completion Gold scales by depth;
- reward transaction IDs remain unchanged/replay-safe;
- Bestiary/Reputation/Contribution semantics do not multiply.

- [x] RED tuning tests
- [x] implementation
- [x] GREEN tests

---

### Task 6 - Completion unlock integration

**Modify:**
- `src/ServerScriptService/Dungeon/CompletionService.luau`
- `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- `src/ServerScriptService/Dungeon/Tests/CompletionServiceTest.server.luau`

Required proof:

- only completion recipients receive a depth clear;
- failed/abandoned members do not;
- retry remains idempotent;
- save barrier includes the new progression mutation;
- quest/guild completion integration remains green.

- [x] RED completion progression test
- [x] implementation
- [x] GREEN test

---

### Task 7 - Compatibility and cumulative regression

Required checks:

- [x] repository-wide Luau parse;
- [x] `git diff --check`;
- [x] focused difficulty/profile/session/party/reward/completion tests;
- [x] existing Dungeon modifier tests;
- [x] existing Dungeon session tests;
- [x] existing TeleportCoordinator tests;
- [x] existing Party Service/Party Entry tests;
- [x] existing Completion Service tests;
- [x] existing Reward Service tests;
- [x] Base Rojo build;
- [x] Dungeon Rojo build;
- [x] published Base Rojo build;
- [x] published Dungeon Rojo build;
- [x] source-boundary review confirms no art/model/mesh change.

Studio runtime is only required if automated evidence identifies a genuine
Depth1 runtime risk.

---

### Task 8 - Documentation checkpoint

Update:

- `AGENTS.md`;
- `docs/ai/CURRENT_STATE.md`;
- `docs/ai/HANDOFF.md`;
- `docs/ai/TEST_MATRIX.md`.

Record:

- branch/worktree;
- accepted/remaining evidence;
- exact next backend action;
- Depth2-Depth4 RuntimeReady status;
- no modelling/art work performed.

Stop before push/merge/publish unless separately approved.
