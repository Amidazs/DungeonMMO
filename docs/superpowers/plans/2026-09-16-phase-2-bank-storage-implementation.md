# Bank / Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a persistent account-wide 40-slot Starting Base Bank with atomic server-authoritative deposit/withdraw, transfer/binding enforcement, physical proximity authorization and functional two-pane UI.

**Architecture:** Bank state lives at `Account.Bank` in schema v7 and remains inside the existing single-writer profile. `BankService` owns storage/capacity/transfer mutations; `BankRuntime` owns Base physical authorization/remotes; `BankPanel.client.luau` owns presentation. Existing Inventory, Equipment, crafting, Skill learning and Dungeon systems continue to read character Inventory only.

**Tech Stack:** Roblox Luau, Rojo, ProfileService/ProfileMigration, existing semantic environment anchors, RemoteEvents, Windows PowerShell 5.1 validation runner.

**Spec:** `docs/superpowers/specs/2026-09-16-phase-2-bank-storage-design.md`

## Global Constraints

- Starting accepted gameplay baseline is local main `5e3a5b3067e73b7ba62d01a413181431dbc0efb3`.
- Install Roadmap v1.39 on local main before creating the Bank feature worktree.
- Bank is account-wide at `Account.Bank`.
- Initial capacity is exactly 40 slots.
- Access distance is exactly 18 studs.
- Bound or explicitly non-tradable items cannot enter Bank.
- Gold is not banked.
- Character Inventory remains unlimited.
- Crafting, Skill learning and Equipment do not consume/use Bank items directly.
- Bank is Base-only.
- Deposit/withdraw are atomic profile mutations.
- Existing profile lease remains the only concurrency authority.
- No push, Roblox publish, PROD DataStore, Robux/monetization or art-worktree change.
- TDD: install failing Bank tests before production implementation.

---

### Task 1: Roadmap and isolated feature baseline

**Files:**
- Add on local main: `docs/roadmap/DungeonMMO_Roadmap_v1_39.docx`
- Create in feature worktree: `docs/superpowers/specs/2026-09-16-phase-2-bank-storage-design.md`
- Create in feature worktree: `docs/superpowers/plans/2026-09-16-phase-2-bank-storage-implementation.md`

**Interfaces:**
- Produces a docs-only local-main checkpoint.
- Produces isolated branch `wip/phase-2-bank-storage-v1`.

- [ ] Verify local `main` starts at the accepted Rare Skill Book merge.
- [ ] Safeguard unrelated dirty primary changes if present.
- [ ] Copy Roadmap v1.39 and commit it on local main.
- [ ] Restore unrelated primary changes exactly.
- [ ] Create a host-owned Bank worktree from the roadmap checkpoint.
- [ ] Commit the approved design spec and implementation plan on the feature branch.

### Task 2: Schema v7, config and transfer policy

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/BankConfig.luau`
- Create: `src/ReplicatedStorage/Core/Shared/ItemTransferRules.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- Test: `src/ServerScriptService/Core/Tests/BankConfigTransferRulesTest.server.luau`
- Test: `src/ServerScriptService/Core/Tests/ProfileMigrationBankV7Test.server.luau`

**Interfaces:**
- `BankConfig.VERSION == 1`
- `BankConfig.CAPACITY == 40`
- `BankConfig.ACCESS_DISTANCE == 18`
- `ItemTransferRules.can_bank(item_id) -> (boolean, string?)`
- `Account.Bank = {Version=1, Items={}}`

- [ ] Write config/transfer/migration RED tests.
- [ ] Verify RED because Bank modules/schema v7 do not exist.
- [ ] Add BankConfig and ItemTransferRules.
- [ ] Bump ProfileSchema to v7 and add Account.Bank.
- [ ] Add deterministic Bank sanitizer to ProfileMigration.
- [ ] Verify tests/build contract turns GREEN.

### Task 3: Atomic BankService

**Files:**
- Create: `src/ServerScriptService/Core/Services/BankService.luau`
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Test: `src/ServerScriptService/Core/Tests/BankServiceTest.server.luau`

**Interfaces:**
- `BankService.new(profile_service, context)`
- `BankService:build_snapshot(user_id)`
- `BankService:deposit(user_id, item_id, quantity)`
- `BankService:withdraw(user_id, item_id, quantity)`
- static raw-profile helpers for test-only multi-slot architecture proof.

- [ ] Write service RED tests for stack/non-stack, partial quantity, capacity, bound item, equipped item, spare copy, Base-only and atomic rejection.
- [ ] Implement snapshot helpers and stable row sorting.
- [ ] Implement atomic deposit.
- [ ] Implement atomic withdrawal.
- [ ] Add BankService to RuntimeServices using the existing ProfileService.
- [ ] Verify service tests/contracts GREEN.

### Task 4: Physical Base Bank anchor and access rules

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/BankAccessRules.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/EnvironmentAnchorDefinitions.luau`
- Modify: `src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau`
- Modify: `src/ServerScriptService/Base/BaseSyntheticEnvironment.luau`
- Modify: `src/ServerScriptService/Base/BaseEnvironmentBootstrap.server.luau`
- Test: `src/ServerScriptService/Core/Tests/BankAccessRulesTest.server.luau`

**Interfaces:**
- Semantic anchor: `Base.Service.Bank`
- Prompt: `BankPrompt`
- `BankAccessRules.within_distance(character_position, bank_position)`

- [ ] Write RED test for exact 18-stud boundary and semantic anchor.
- [ ] Rename only the Bank placeholder semantic ID to `Base.Service.Bank`; keep candidate selector placement.
- [ ] Bootstrap real `Open / Bank` prompt and BANK label.
- [ ] Implement distance helper.
- [ ] Verify environment build/tests GREEN.

### Task 5: Base Bank runtime/remotes

**Files:**
- Create: `src/ServerScriptService/Base/BankRuntime.luau`
- Modify: `src/ReplicatedStorage/Core/Remotes.model.json`
- Modify: `src/ServerScriptService/Base/BaseRuntime.server.luau`
- Test: `src/ServerScriptService/Base/Tests/BankRuntimeContractTest.server.luau`

**Interfaces:**
- Remotes: `BankSnapshotRequest`, `BankSnapshot`, `BankDepositRequest`, `BankWithdrawRequest`, `BankActionResult`
- `BankRuntime.attach({bank, profiles, environment, remotes, on_profile_changed, is_handoff_pending})`

- [ ] Write RED remote/runtime contract test.
- [ ] Add remote definitions.
- [ ] Implement access validation: loaded profile, complete identity, no teleport pending, character root, <=18 studs.
- [ ] Wire snapshot/deposit/withdraw handlers.
- [ ] Refresh existing profile/inventory presentation and Bank snapshot only after authoritative success.
- [ ] Integrate BankRuntime into BaseRuntime with minimal insertion points.
- [ ] Add Studio-only Iron Ore/tradable book/bound book test inventory.
- [ ] Verify remote/runtime contract GREEN.

### Task 6: Functional two-pane Bank UI

**Files:**
- Create: `src/StarterPlayerScripts/Base/BankPanel.client.luau`

**Interfaces:**
- Opens only from `Base.Service.Bank` / `BankPrompt`.
- Requests authoritative BankSnapshot.
- Sends ItemId + Quantity only.
- Auto-closes outside Bank distance.

- [ ] Create functional two-pane Inventory/Bank layout.
- [ ] Render Inventory rows including bankable/rejected state.
- [ ] Render Bank rows and `Used / 40`.
- [ ] Add selected item + quantity control.
- [ ] Add Deposit/Withdraw requests with pending state.
- [ ] Apply BankActionResult error text and authoritative snapshot refresh.
- [ ] Close UI when player moves outside configured range.

### Task 7: Full regression/build verification and Studio handoff

**Files:**
- Test all new Bank tests plus existing project tests in Studio.
- Build: `base.project.json`
- Build: `default.project.json`
- Build: `published-base.project.json`
- Build: `published-dungeon.project.json`

- [ ] Run static Bank contract verifier.
- [ ] Run `git diff --check`.
- [ ] Build all four Rojo projects to TEMP.
- [ ] Confirm no profile migration/schema contract regressions are statically visible.
- [ ] Confirm no Bank access is added to Dungeon client/runtime.
- [ ] Stop before commit/merge/push/publish and provide the fresh Base build for the unavoidable physical/UI Studio acceptance proof.
