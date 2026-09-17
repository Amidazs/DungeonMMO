# Phase 3.C Dungeon Modifiers + Profession Interaction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic rotating dungeon modifiers and close the four known Temple profession-placement warnings without altering authored dungeon geometry.

**Architecture:** Add pure modifier definitions/resolution beside `DungeonDefinitions`; persist the selected modifier in the existing DungeonSession record so reconnect cannot reroll it. Reward, enemy-health and gathering systems consume the session modifier through server-owned helpers. Resource cleanup changes semantic placement metadata only.

**Tech Stack:** Roblox Luau, existing DungeonSessionService, RewardService, ProfessionService/ProfessionRuntime, DungeonDefinitions, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- No procedural geometry generation.
- No client modifier selection or reroll.
- One modifier per eligible run.
- Temple and Abandoned Mine remain accepted authored content.
- Personal/reconnect-safe gathering claims remain authoritative.
- No profile schema change.

---

### Task 1: Modifier definitions and deterministic selector

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/DungeonModifierDefinitions.luau`
- Create: `src/ServerScriptService/Core/Tests/DungeonModifierDefinitionsTest.server.luau`

**Interfaces:**

```luau
DungeonModifierDefinitions.get(id: string): any?
DungeonModifierDefinitions.all(): {any}
DungeonModifierDefinitions.resolve(
    dungeon_id: string,
    session_id: string,
    rotation_key: string
): string
```

Definitions:
- Fortified: `EnemyHealthMultiplier = 1.20`
- RichDeposits: `GatherYieldBonus = 1`
- Bounty: `MonsterGoldMultiplier = 1.10`

- [ ] **Step 1: RED definition/determinism test**
- [ ] **Step 2: implement frozen definitions**
- [ ] **Step 3: implement deterministic selector using server-owned dungeon/session/rotation strings**
- [ ] **Step 4: prove identical inputs resolve identically and definitions cannot be mutated**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add dungeon modifier definitions`

---

### Task 2: Persist modifier in DungeonSession

**Files:**
- Modify: `src/ServerScriptService/Core/Services/DungeonSessionService.luau`
- Extend: `src/ServerScriptService/Core/Tests/DungeonSessionServiceTest.server.luau`

**Interfaces:**

```luau
Modifier = {
    Id = "Fortified" | "RichDeposits" | "Bounty",
    RotationKey = string,
}
```

- [ ] **Step 1: RED create/reload/reconnect test**
- [ ] **Step 2: resolve modifier once during authoritative session creation**
- [ ] **Step 3: reconnect/claim reads stored Modifier and never rerolls**
- [ ] **Step 4: legacy session without Modifier receives one safe server selection**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): persist dungeon session modifiers`

---

### Task 3: Fortified and Bounty consumers

**Files:**
- Modify the existing dungeon enemy spawn/stat initialization seam.
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`
- Create: `src/ServerScriptService/Core/Tests/DungeonModifierRewardIntegrationTest.server.luau`
- Create a focused enemy-health modifier test beside existing dungeon tuning tests.

**Interfaces:**
- Fortified multiplies configured spawn MaxHealth/current Health by 1.20 once.
- Bounty multiplies monster Gold by 1.10 using existing integer rounding convention.
- XP, Bestiary, Reputation and Contribution are unchanged by Bounty.

- [ ] **Step 1: RED health/reward/idempotency tests**
- [ ] **Step 2: thread server-owned session modifier into existing enemy/reward call sites**
- [ ] **Step 3: same monster transaction replay remains exactly-once**
- [ ] **Step 4: GREEN RewardService/Bestiary regressions**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): apply fortified and bounty modifiers`

---

### Task 4: Rich Deposits integration

**Files:**
- Modify: `src/ServerScriptService/Core/Services/ProfessionService.luau` or its existing gather award helper.
- Modify: `src/ServerScriptService/Core/Services/ProfessionRuntime.luau`
- Extend: `src/ServerScriptService/Core/Tests/ProfessionServiceTest.server.luau`
- Create: `src/ServerScriptService/Core/Tests/RichDepositsIntegrationTest.server.luau`

**Interfaces:**
- Successful eligible gather yields base quantity + 1.
- Failed/rejected/already-claimed gather gets no extra yield.
- Existing personal claim key remains unchanged.

- [ ] **Step 1: RED normal/Rich/duplicate gather tests**
- [ ] **Step 2: apply bonus only after current gather validation/claim succeeds**
- [ ] **Step 3: ordinary runs preserve current quantities**
- [ ] **Step 4: commit**

Commit:
`feat(phase3): integrate rich deposits gathering`

---

### Task 5: Resolve four Temple invalid-surface placements

**Files:**
- Modify only the existing semantic resource-placement definition/source that contains:
  - `Temple.RichIronVein.02`
  - `Temple.Room1.Silverleaf`
  - `Temple.AncientSilverleaf.02`
  - `Temple.Room2.IronVein`
- Extend existing resource placement validator test.

- [ ] **Step 1: RED validator assertions name all four nodes**
- [ ] **Step 2: copy valid surface-anchor pattern from neighboring accepted resource nodes; do not edit art**
- [ ] **Step 3: validator GREEN with zero invalid Temple resource surfaces**
- [ ] **Step 4: Base/Dungeon builds**
- [ ] **Step 5: cumulative P3.C commit**

Commit:
`feat(phase3): complete dungeon modifier foundation`