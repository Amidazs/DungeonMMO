# Phase 3.F Race Change Migration Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prove deterministic DEV/TEST Race Change preview/apply/archive/restore semantics without monetisation or bypassing earned progression.

**Architecture:** Add a character-scoped archive in schema v12 and a pure RaceChangePlanner that computes a deterministic preview from current character state plus target race. RaceChangeService applies the exact preview inside one ProfileService mutation, archives incompatible skill/proficiency knowledge, refunds only current incompatible SP rank allocation, updates identity, recalculates eligibility and stores an idempotent transaction receipt.

**Tech Stack:** Roblox Luau, existing RaceDefinitions/ClassProgressionDefinitions/ClassAdvancementService/SkillProgression/Loadout/Equipment/ProfileService, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- DEV/TEST only.
- No Robux/product IDs/player purchase UI.
- No consumed Skill Book/material return.
- No manufactured advancement/proficiency/books.
- Per-race advancement history retained.
- Profile schema v11 -> v12.

---

### Task 1: Schema-v12 Race Change archive

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfileMigrationRaceChangeV12Test.server.luau`

**Character state:**

```luau
RaceChange = {
    Version = 1,
    ArchivedByRace = {},
    History = {},
}
```

Each archived race record stores skill knowledge, proficiency and advancement snapshots only.

- [ ] **Step 1: RED v11->v12 migration**
- [ ] **Step 2: add defaults/sanitization**
- [ ] **Step 3: preserve market/bestiary/reputation/quest/profession/advancement**
- [ ] **Step 4: repeated migration idempotent**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add race change archive state`

---

### Task 2: Pure deterministic RaceChangePlanner

**Files:**
- Create: `src/ServerScriptService/Core/Services/RaceChangePlanner.luau`
- Create: `src/ServerScriptService/Core/Tests/RaceChangePlannerTest.server.luau`

**Interface:**

```luau
RaceChangePlanner.preview(
    character: any,
    target_race_id: string
): any
```

Preview includes source/target race, incompatible knowledge/ranks, refundable SP, archived proficiency, loadout clears, equipment unequips, advancement compatibility, binding/trade recalculation and deterministic preview hash.

- [ ] **Step 1: RED Human<->Elf Fighter/Mage/Ranger/Rogue previews**
- [ ] **Step 2: reject same/unknown race and incomplete identity**
- [ ] **Step 3: derive incompatibility only from canonical definitions**
- [ ] **Step 4: consumed books/materials never appear in refund output**
- [ ] **Step 5: identical state produces identical preview/hash**
- [ ] **Step 6: commit**

Commit:
`feat(phase3): add race change planner`

---

### Task 3: RaceChangeService apply and restore

**Files:**
- Create: `src/ServerScriptService/Core/Services/RaceChangeService.luau`
- Create: `src/ServerScriptService/Core/Tests/RaceChangeServiceTest.server.luau`
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`

**Interface:**

```luau
RaceChangeService:preview(user_id, target_race_id): any
RaceChangeService:apply(
    user_id,
    target_race_id,
    preview_hash,
    transaction_id
): any
```

- [ ] **Step 1: RED stale-preview/idempotency tests**
- [ ] **Step 2: apply exact authoritative preview only**
- [ ] **Step 3: archive incompatible knowledge/proficiency before deactivation**
- [ ] **Step 4: refund only incompatible allocated rank SP, not lifetime entitlement**
- [ ] **Step 5: clear invalid loadout/unequip through existing helpers**
- [ ] **Step 6: returning to archived race restores knowledge/proficiency eligibility but not refunded ranks**
- [ ] **Step 7: replay transaction returns stored result**
- [ ] **Step 8: commit**

Commit:
`feat(phase3): add race change apply restore`

---

### Task 4: Per-race advancement history

**Files:**
- Modify only existing advancement state/definitions consumed by `ClassAdvancementService.luau`.
- Extend: `RaceChangeServiceTest.server.luau`
- Extend: `ClassAdvancementServiceTest.server.luau`

- [ ] **Step 1: RED advancement round-trip**
- [ ] **Step 2: Human completion remains recorded but inactive while Elf**
- [ ] **Step 3: no automatic equivalent-class completion**
- [ ] **Step 4: returning race restores historical completion without replaying one-time rewards**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): preserve race advancement history`

---

### Task 5: DEV/TEST-only proof surface

**Files:**
- Add functional Studio/TEST Race Change panel or existing developer command integration.
- Add environment/remote guard tests.

- [ ] **Step 1: RED PROD guard**
- [ ] **Step 2: PROD always returns `RaceChangeUnavailable`; TEST/Studio exposes Preview/Apply**
- [ ] **Step 3: preview display shows deactivated skills, refundable SP and equipment changes**
- [ ] **Step 4: Base/Dungeon builds and full progression regression**
- [ ] **Step 5: cumulative P3.F commit**

Commit:
`feat(phase3): complete race change migration foundation`