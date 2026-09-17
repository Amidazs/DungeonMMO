# Phase 3 Quest + Secondary-Class Advancement Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the reusable server-authoritative quest backend and prove the first race-specific Mage secondary-class advancement split without changing accepted Phase 2 combat/equipment semantics.

**Architecture:** Schema v8 adds per-character quest and class-advancement state. `QuestService` consumes normalized trusted server events and `ClassAdvancementService` atomically consumes a ready advancement quest into race-specific persistent advancement state. Existing Dungeon `CompletionService` emits a deduplicated `DungeonClear` event after reward grant and before the accepted save barrier.

**Tech Stack:** Roblox Luau, Rojo, existing ProfileService/ProfileMigration, PowerShell 5.1 packaging, Python standard library verification/patch tooling.

**Spec:** `docs/superpowers/specs/2026-09-16-phase-3-quest-secondary-class-advancement-design.md`

## Global Constraints

- Start from local main `c7d6721b1c30eb52660b620d02f9bcf9e5d180f2`.
- `origin/main` remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.
- Work only in `wip/phase-3-quest-advancement-v1`.
- Preserve all existing worktrees and unrelated primary-repo untracked files.
- No push, publish, PROD, Robux or monetisation action.
- Keep `Identity.ClassId` / `BaseClassId` on the accepted base-class family in this gate.
- No final advancement UI or new combat skills.
- Schema moves from v7 to v8 and must preserve Bank/profession state.
- TDD: install RED tests before production implementation.

---

## File structure

**Create**
- `src/ReplicatedStorage/Core/Shared/QuestDefinitions.luau` — validated quest data and objective matching.
- `src/ReplicatedStorage/Core/Shared/SecondaryClassDefinitions.luau` — race/base-class -> secondary-class definitions.
- `src/ServerScriptService/Core/Services/QuestService.luau` — start/progress/snapshot/ready-quest consumption.
- `src/ServerScriptService/Core/Services/ClassAdvancementService.luau` — Base-only start/claim and atomic advancement.
- `src/ServerScriptService/Core/Tests/QuestDefinitionsTest.server.luau`
- `src/ServerScriptService/Core/Tests/QuestServiceTest.server.luau`
- `src/ServerScriptService/Core/Tests/ClassAdvancementServiceTest.server.luau`
- `src/ServerScriptService/Core/Tests/ProfileMigrationQuestAdvancementV8Test.server.luau`
- `src/ServerScriptService/Dungeon/Tests/CompletionQuestBridgeTest.server.luau`

**Modify**
- `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- `src/ServerScriptService/Dungeon/CompletionService.luau`
- `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`

### Task 1: Install design, plan and RED contracts

**Interfaces**
- Tests refer to `QuestDefinitions`, `SecondaryClassDefinitions`, `QuestService`, `ClassAdvancementService`.
- Production modules do not exist yet.

- [ ] Copy this design and plan into the feature worktree.
- [ ] Create the five test files with assertions for the approved contracts.
- [ ] Run the RED verifier.
- [ ] Confirm RED verifier passes only when tests exist and production files do not.
- [ ] Commit design/plan/tests as `test: define quest advancement foundation`.

### Task 2: Add schema v8

**Interfaces**
- `ProfileSchema.VERSION == 8`.
- `Characters.Slot1.Quests = {Version=1, Active={}, Completed={}}`.
- `Characters.Slot1.ClassAdvancement = {Version=1, CompletedByRace={}}`.

- [ ] Update `ProfileSchema.luau` from v7 to v8.
- [ ] Add the two per-character default tables.
- [ ] Rely on the accepted `ProfileMigration.deep_fill` path to migrate missing v8 defaults; do not create a parallel migration system.
- [ ] Verify the migration test preserves Account.Bank and profession state.

### Task 3: Implement quest definitions and service

**Interfaces**
- `QuestDefinitions.get(id: string): any?`
- `QuestDefinitions.is_character_eligible(character: any, definition: any): boolean`
- `QuestDefinitions.objective_matches(objective: any, event: any): boolean`
- `QuestService.new(profileService: any): any`
- `QuestService:start(userId: number, questId: string): any`
- `QuestService:record_event(userId: number, event: any): any`
- `QuestService:build_snapshot(userId: number): any`
- `QuestService.character_state(character: any, questId: string): any?`
- `QuestService.complete_ready_character_quest(character: any, questId: string): (boolean, string?)`

- [ ] Implement the single `MageAdvancementTrial` definition.
- [ ] Implement Level/Race/BaseClass eligibility.
- [ ] Implement quest start.
- [ ] Implement trusted event validation.
- [ ] Implement objective matching, clamped counts and per-quest EventId dedupe.
- [ ] Implement Ready calculation.
- [ ] Implement snapshot and atomic-consumption helper.
- [ ] Verify service tests cover unrelated event, valid event and replayed EventId.

### Task 4: Implement secondary-class advancement service

**Interfaces**
- `SecondaryClassDefinitions.get(id: string): any?`
- `SecondaryClassDefinitions.resolve(raceId: string, baseClassId: string): any?`
- `ClassAdvancementService.new(profileService: any, questService: any, placeKind: string): any`
- `ClassAdvancementService:start_trial(userId: number): any`
- `ClassAdvancementService:claim(userId: number): any`
- `ClassAdvancementService:build_snapshot(userId: number): any`

- [ ] Define `HumanArcanist` and `ElfSpellweaver`.
- [ ] Resolve candidates from RaceId + BaseClassId.
- [ ] Enforce Base-only start/claim.
- [ ] Start the definition-owned quest through QuestService.
- [ ] Claim only Ready quest state.
- [ ] In one `ProfileService:mutate`, revalidate identity/candidate, consume the ready quest, update `CompletedByRace`, and set `ActiveClassId`.
- [ ] Verify Human/Elf outcomes and duplicate rejection.

### Task 5: Compose runtime and Dungeon completion bridge

**Interfaces**
- `runtime.QuestService`
- `runtime.ClassAdvancementService`
- `CompletionService.new(..., questService?)`
- completion event `{EventId=sessionId..":DungeonClear", Type="DungeonClear", TargetId=session.DungeonId, Amount=1}`.

- [ ] Require/create/return both services in `RuntimeServices`.
- [ ] Make QuestService an optional final dependency of `CompletionService`.
- [ ] After successful normal reward grant, record the DungeonClear event before the existing save barrier.
- [ ] Preserve existing reward semantics when no QuestService is supplied.
- [ ] Expose `runtime.QuestService` to DungeonRuntime and pass it into CompletionService.
- [ ] Verify the bridge test records exactly one event and does not replay after committed completion.

### Task 6: Automated gate and feature checkpoint

- [ ] Run the GREEN verifier.
- [ ] Run the worktree boundary verifier.
- [ ] Run `git diff --check`.
- [ ] Build `base.project.json` to TEMP.
- [ ] Build `default.project.json` to TEMP.
- [ ] Build `published-base.project.json` to TEMP.
- [ ] Build `published-dungeon.project.json` to TEMP.
- [ ] Commit implementation as `feat: add quest advancement foundation`.
- [ ] Record feature checkpoint.
- [ ] Stop without merging, pushing or publishing.
- [ ] Request project-owner Studio proof only for the real Base -> Dungeon -> Base persistence/handoff behavior that cannot be established by static/build verification.
