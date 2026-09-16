# Rare Skill Book RNG Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace guaranteed/unidentified Arc Slash rewards with configurable named personal RNG skill-book drops from bosses and dungeon completion.

**Architecture:** Extend the existing authoritative `RewardService` transaction paths rather than creating a parallel loot service. Boss identity flows from `EncounterService`; completion identity flows from `DungeonSessionService.DungeonId`; successful book rolls are recorded inside existing reward-history records so current replay/idempotency behavior also protects books.

**Tech Stack:** Roblox Luau, Rojo, existing profile/inventory/reward/session services, Python/PowerShell static contract verification.

**Spec:** `docs/superpowers/specs/2026-09-16-phase-2-rare-skill-book-rng-design.md`

## Global Constraints

- Baseline is local `main` `d43f75f9cbfa22102650fb611712952493694615`.
- Work only on `wip/phase-2-rare-skill-book-rng-v1` in a host-owned isolated worktree.
- Do not push, merge, publish Roblox places, touch PROD DataStores, spend Robux, or alter monetization.
- No profile schema version bump.
- Skill-book drops are personal RNG and never class-filtered.
- Boss and completion book rolls are bonus rolls and never replace existing ordinary reward rolls.
- Keep the legacy bound Arc Slash book learnable for existing profiles.
- TDD order: install failing contract/tests, verify RED, then change production code and verify GREEN.
- Preserve accepted second-dungeon rare/event reward behavior and party behavior.

---

### Task 1: Define the named tradable book and drop configuration

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/SkillBookDropConfig.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ItemDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/LootTableConfig.luau`
- Test: `src/ServerScriptService/Core/Tests/SkillBookDropConfigTest.server.luau`

**Interfaces:**
- Produces: `SkillBookDropConfig.get_boss(boss_id)`, `get_completion(dungeon_id)`, `roll(definition, rng)`, and `first_item(definition)`.
- Produces item `arc_slash_book`.

- [ ] **Step 1: Write failing config/item tests.** Assert boss chance `0.02`, completion chance `0.01`, both initial dungeon IDs/boss IDs, deterministic success/failure, and the new item's named/tradable/stackable/learnable fields.
- [ ] **Step 2: Verify RED.** Run the package static verifier in RED mode. Expected: required production config/item markers are absent.
- [ ] **Step 3: Implement minimal config and item definition.** Add weighted book-pool support with Arc Slash as the sole initial entry. Mark `skill_book_test` test-only and remove it from `LootTableConfig.TEST_DUNGEON`.
- [ ] **Step 4: Verify config GREEN.** The config contract must pass without touching profile schema.

### Task 2: Add exactly-once personal boss book rolls

**Files:**
- Modify: `src/ServerScriptService/Dungeon/EncounterService.luau`
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`
- Test: `src/ServerScriptService/Core/Tests/RareSkillBookRewardTest.server.luau`

**Interfaces:**
- `EncounterService` adds optional `BossId` to the monster reward descriptor when the enemy is a boss.
- `RewardService:grant_monster_reward` returns `member_results[user].skill_book_item_id`.

- [ ] **Step 1: Write boss reward tests.** Cover two party members receiving independent personal success rolls, off-class receipt, duplicate book receipt, failure rolls, and replay of the same transaction.
- [ ] **Step 2: Verify RED.** New reward contract fails because boss metadata/book history support is absent.
- [ ] **Step 3: Pass boss identity into RewardService.** Read `Boss`/`BossId` attributes from the enemy model without changing ordinary enemies.
- [ ] **Step 4: Roll and persist the bonus book in the existing monster mutation.** Use the same per-member loop, add the book to inventory only on success, and write `SkillBookItemId` to the monster history record.
- [ ] **Step 5: Verify GREEN and replay safety.** Same transaction returns stored book result; a different boss transaction may drop another copy.

### Task 3: Add completion book rolls and remove guaranteed first-clear

**Files:**
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`
- Modify: `src/ServerScriptService/Dungeon/CompletionService.luau`
- Modify: `src/ServerScriptService/Core/Services/SkillProgressionService.luau`
- Delete: `src/ServerScriptService/Dungeon/Tests/ArcSlashFirstClearRewardTest.server.luau`
- Modify: `src/ServerScriptService/Dungeon/Tests/CompletionServiceTest.server.luau`

**Interfaces:**
- `RewardService:grant_completion(..., rng?, skill_book_source_id?)` accepts the dungeon ID.
- Completion result exposes `skill_book_item_id`.

- [ ] **Step 1: Update tests to reject the guaranteed path.** Remove assertions that every completion invokes `grant_arc_slash_first_clear`; retain save-barrier/idempotency checks.
- [ ] **Step 2: Pass `session.DungeonId` into completion reward.** Preserve whichever accepted reward definition the session/runtime currently uses.
- [ ] **Step 3: Roll bonus book inside the existing completion mutation.** Store `SkillBookItemId` with the existing completion history record.
- [ ] **Step 4: Remove obsolete first-clear grant function.** Keep `arc_slash_book_bound` itself intact.
- [ ] **Step 5: Verify completion replay.** Repeated completion calls return the stored outcome without another RNG roll or inventory grant.

### Task 4: Prove class-independent receipt but class-restricted learning

**Files:**
- Test: `src/ServerScriptService/Core/Tests/RareSkillBookLearningTest.server.luau`

**Interfaces:**
- Consumes existing `SkillProgressionService:learn_skill(user_id, "ArcSlash", "arc_slash_book")`.

- [ ] **Step 1: Seed Fighter and Mage fixtures with the tradable book.** Both inventories may own `arc_slash_book`.
- [ ] **Step 2: Verify Fighter learning.** With sufficient SP, Fighter consumes exactly one book and learns Arc Slash.
- [ ] **Step 3: Verify Mage rejection.** Mage receives `ClassCannotTeachSkill` and retains the book.
- [ ] **Step 4: Verify duplicate ownership is legal.** Inventory stacking is independent of whether Arc Slash is already known.

### Task 5: Update reward presentation and compatibility tests

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/CompletionRewardPresentation.luau`
- Modify: `src/ServerScriptService/Core/Tests/CompletionRewardPresentationTest.server.luau`
- Modify: `src/ServerScriptService/Core/Tests/RewardServiceTest.server.luau`

**Interfaces:**
- Completion presentation reads `skill_book_item_id` and resolves the exact item name through `ItemDefinitions`.

- [ ] **Step 1: Replace old first-clear presentation payload.** Remove `completion.arc_slash_book`; render `Arc Slash Skill Book` from the generic bonus item ID.
- [ ] **Step 2: Remove unidentified-book assumptions from ordinary-loot regression.** Use deterministic ordinary loot and assert `skill_book_test` is not awarded by production completion loot.
- [ ] **Step 3: Verify legacy compatibility.** `arc_slash_book_bound` remains defined and learnable even though it is no longer granted.

### Task 6: Studio proof controls and full verification

**Files:**
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`

**Interfaces:**
- Studio-only Workspace attributes: `TEST_ForceSkillBookDrop` and `TEST_BlockSkillBookDrop`.

- [ ] **Step 1: Add Studio-only override around the configured RNG roll.** Production ignores both attributes.
- [ ] **Step 2: Run static GREEN verifier.** Check source contracts, obsolete path removal, tests, and exact initial tuning.
- [ ] **Step 3: Run `git diff --check`.** Expected: clean.
- [ ] **Step 4: Build all four project variants.** `base.project.json`, `default.project.json`, `published-base.project.json`, and `published-dungeon.project.json` must build to TEMP.
- [ ] **Step 5: Stop for unavoidable Studio gameplay evidence.** Use a fresh Dungeon build, enable `TEST_ForceSkillBookDrop` on the server, then prove a boss bonus book and completion bonus book through real dungeon gameplay. Do not commit/merge/push/publish before acceptance.
