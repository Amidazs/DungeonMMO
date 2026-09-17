# Phase 3 Systems Alpha Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the remaining meaningful Phase 3 Systems Alpha architecture from local-main checkpoint `541ce425573807afbd815948b97fbf6b746bf2c4` while preserving all accepted Phase 1/2 and earlier Phase 3 contracts.

**Architecture:** Execute six independent implementation gates in one cumulative isolated worktree: Rogue/skill breadth, dungeon modifiers/profession cleanup, guild/hall, limited market, Race Change migration, and systems hardening. Shared persistent multi-player entities use one reusable entity-adapter boundary; character progression continues to use the accepted ProfileService authority. Manual Studio testing is consolidated into one final Phase 3 acceptance round.

**Tech Stack:** Roblox Luau (`--!strict`), Rojo, existing ProfileService/RuntimeServices/identity/progression/combat/dungeon/profession services, DataStore-backed adapters with InMemory test adapters, Windows PowerShell 5.1, Git worktrees.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- Exact starting local-main checkpoint: `541ce425573807afbd815948b97fbf6b746bf2c4`.
- Work in isolated branch `wip/phase-3-systems-alpha-completion-v1`.
- Worktree: `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1`.
- Do not touch `C:\Users\Remko\Documents\Roblox\DungeonMMO_Art`.
- No hard reset, clean, force-push, history rewrite, Roblox publish, PROD monetisation or Robux action.
- Do not push or merge to `main` until final Phase 3 runtime acceptance is explicitly accepted.
- Preserve accepted Human/Elf Fighter/Mage/Ranger behaviour, equipment authority, progression/loadout/proficiency, party/session/reconnect/revive/completion, professions, Contribution, Recipe Knowledge, Bestiary and Reputation.
- No progression catch-up implementation.
- No Transmog implementation.
- All new reward/value/membership/race-change authority is server-owned.
- Every gate follows RED -> GREEN -> repository-wide Luau parse -> `git diff --check` -> relevant Base/Dungeon builds -> commit.
- Build all four project variants at cumulative checkpoints P3.D, P3.G and P3.H.
- Only P3.H requires project-owner Studio testing unless an automated blocker cannot be diagnosed otherwise.

---

## Programme File Structure

### Shared persisted entity adapter introduced in P3.D

- Create: `src/ServerScriptService/Core/Adapters/InMemoryEntityAdapter.luau`
- Create: `src/ServerScriptService/Core/Adapters/RobloxEntityAdapter.luau`
- Create: `src/ServerScriptService/Core/Tests/EntityAdapterContractTest.server.luau`

Adapter contract:

```luau
export type EntityAdapter = {
    load: (self: EntityAdapter, key: string) -> any?,
    update: (
        self: EntityAdapter,
        key: string,
        transform: (any?) -> any
    ) -> (boolean, any?),
    remove: (self: EntityAdapter, key: string) -> boolean,
}
```

`InMemoryEntityAdapter` and `RobloxEntityAdapter` must satisfy the same tests. `RobloxEntityAdapter.new(store_name)` is the only new direct DataStoreService boundary added for shared Phase 3 entities.

### Profile schema progression

- Current accepted schema: v10.
- P3.B: no schema change.
- P3.C: no schema change.
- P3.D: no character-profile schema change; guild authority lives in dedicated shared entities.
- P3.E: schema v11 adds per-character market transaction/escrow recovery receipts.
- P3.F: schema v12 adds Race Change archive/preview state.
- P3.G: no schema change unless a failing stress test demonstrates a missing recovery field; any such change requires its own migration test before implementation.

---

## Gate sequence

- [ ] **P3.B - Rogue + broad skill-tree architecture**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-b-rogue-skill-tree-implementation.md`.
  - Expected checkpoint message: `feat(phase3): complete rogue skill-tree foundation`.

- [ ] **P3.C - Dungeon modifiers + profession cleanup**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-c-dungeon-modifiers-profession-implementation.md`.
  - Expected checkpoint message: `feat(phase3): complete dungeon modifier foundation`.

- [ ] **P3.D - Guild + hall foundation**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-d-guild-hall-implementation.md`.
  - Expected checkpoint message: `feat(phase3): complete guild hall foundation`.

- [ ] **P3.E - Limited market foundation**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-e-market-implementation.md`.
  - Expected checkpoint message: `feat(phase3): complete limited market foundation`.

- [ ] **P3.F - Race Change migration foundation**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-f-race-change-implementation.md`.
  - Expected checkpoint message: `feat(phase3): complete race change migration foundation`.

- [ ] **P3.G - Systems hardening + stress harness**
  - Execute `docs/superpowers/plans/2026-09-17-phase-3-g-hardening-implementation.md`.
  - Expected checkpoint message: `test(phase3): complete systems alpha hardening`.

---

## P3.H - Consolidated Phase 3 acceptance

**Files:**
- No production source change unless fresh runtime evidence proves a real defect.
- Update after acceptance only: `docs/ai/CURRENT_STATE.md`
- Update after acceptance only: `docs/ai/HANDOFF.md`
- Update after acceptance only: `docs/ai/TEST_MATRIX.md`
- Update after acceptance only: canonical roadmap DOCX using the existing roadmap workflow.

**Interfaces:**
- Consumes every P3.B-P3.G checkpoint.
- Produces one Phase 3 Systems Alpha candidate with fresh Base/Dungeon runtime evidence.

- [ ] **Step 1: verify clean cumulative feature branch**

```powershell
git status --short
git diff --check
git log --oneline --decorate -20
git rev-list --left-right --count main...HEAD
```

Expected:
- no tracked working-tree changes;
- no staged changes;
- branch is ahead of local `main`;
- all six gate checkpoint commits are present.

- [ ] **Step 2: run repository-wide Luau parser**

Parse every `.lua` and `.luau` under `src` with the verified `luau-compile.exe --null --only-parse` flow used by previous Phase 3 gates.

Expected: zero parse failures.

- [ ] **Step 3: build all four project variants to timestamped TEMP**

```powershell
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Out = Join-Path $env:TEMP "DungeonMMO_Phase3_Final_$Stamp"
New-Item -ItemType Directory -Force $Out | Out-Null

rojo build .\base.project.json -o (Join-Path $Out "Base_Phase3_Acceptance.rbxl")
rojo build .\default.project.json -o (Join-Path $Out "Dungeon_Phase3_Acceptance.rbxl")
rojo build .\published-base.project.json -o (Join-Path $Out "PublishedBase_Phase3_Verification.rbxl")
rojo build .\published-dungeon.project.json -o (Join-Path $Out "PublishedDungeon_Phase3_Verification.rbxl")
```

Expected: all four builds succeed.

- [ ] **Step 4: verify final Phase 3 source boundary**

Allowed changes from `541ce425573807afbd815948b97fbf6b746bf2c4` must be confined to:
- the six Phase 3 gate source/test files described by the subplans;
- schema/migration compatibility tests;
- Remotes/functional UI needed for guild/market/Race Change DEV/TEST flows;
- continuity documentation.

Explicitly reject:
- art worktree paths;
- monetisation IDs/products;
- PROD configuration;
- Transmog;
- catch-up;
- unrelated combat rebalance.

- [ ] **Step 5: project-owner Base Studio run**

Required new green families include:
- Rogue definitions/progression/trainer/identity tests;
- guild service/progression/hall tests;
- market service/escrow/recovery tests;
- Race Change preview/apply/archive tests;
- economy audit tests;
- Phase 3 stress summary PASS.

Required older families remain green:
- Bestiary/Reputation;
- Recipe Knowledge;
- Contribution;
- Quest/Advancement;
- Professions;
- Party/Travel/Bank/Equipment/Progression;
- Base identity lifecycle.

- [ ] **Step 6: project-owner Dungeon Studio run**

Required:
- Rogue combat actions load without breaking Fighter/Mage/Ranger;
- deterministic modifier selected once and survives session/reconnect contract;
- Fortified/Rich Deposits/Bounty authority tests pass;
- no four known invalid Temple surface warnings;
- guild-run reward integration tests pass;
- existing admission/combat/checkpoint/revive/completion flow remains green.

- [ ] **Step 7: acceptance documentation only after fresh green evidence**

Record:
- cumulative feature HEAD;
- Base/Dungeon runtime evidence;
- automated stress counts/results;
- deferred catch-up;
- deferred Transmog;
- no publish/push/Robux action.

- [ ] **Step 8: stop before local-main merge**

Do not merge the cumulative branch to local `main` until the project owner explicitly accepts the P3.H runtime evidence. Do not push or publish.