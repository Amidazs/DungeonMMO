# Phase 3.B Rogue + Broad Skill-Tree Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Rogue as the fourth Human/Elf starting archetype and prove a Lineage-2-inspired broad skill-tree architecture with Human Duelist and Elf Windstalker secondary targets.

**Architecture:** Extend the accepted `RaceDefinitions`, `ClassProgressionDefinitions`, combat `SkillDefinitions`, `SkillProgressionDefinitions` and `TrainerCatalogues`; do not create a parallel class system. Base Rogue owns shared positioning/mobility/evasion/critical families; race-specific secondary definitions add distinct burst versus speed/evasion families through the existing ClassAdvancement/Quest foundation.

**Tech Stack:** Roblox Luau, existing identity/progression/trainer/combat services, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- No catch-up implementation.
- No profile schema change.
- Stable internal IDs are independent of working display names.
- One-Handed Sword is accepted as temporary Rogue weapon compatibility; no dagger asset work.
- Existing six-slot active loadout remains authoritative.
- No final VFX/audio/art/balance work.
- Preserve Fighter/Mage/Ranger and existing advanced Fighter-class contracts.

---

### Task 1: Rogue definition contract

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/RaceDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ClassProgressionDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/TrainerCatalogues.luau`
- Create: `src/ServerScriptService/Combat/Tests/RogueDefinitionsTest.server.luau`

**Interfaces:**
- Produces base class ID: `Rogue`.
- Produces Human secondary stable ID: `HumanRogueDuelist`.
- Produces Elf secondary stable ID: `ElfRogueWindstalker`.
- Race/class selection remains through existing IdentityService/CharacterIdentityRules.

- [ ] **Step 1: write RED definition test**

Test exact contracts:

```luau
local rogue = assert(ClassProgressionDefinitions.get("Rogue"))
assert(rogue.Id == "Rogue")
assert(#rogue.StarterSkills >= 3)

local human = assert(RaceDefinitions.get("Human"))
local elf = assert(RaceDefinitions.get("Elf"))

assert(
    ClassProgressionDefinitions.get_secondary_target("Human", "Rogue")
        == "HumanRogueDuelist"
)
assert(
    ClassProgressionDefinitions.get_secondary_target("Elf", "Rogue")
        == "ElfRogueWindstalker"
)

assert(TrainerCatalogues.get("RogueTrainer") ~= nil)
```

Use the existing race allowed-class field already consumed by IdentityService; extend that field with Rogue rather than adding a second representation.

- [ ] **Step 2: verify RED**

Build Base. Expected runtime RED because `Rogue`/secondary targets are absent.

- [ ] **Step 3: implement minimum Rogue definitions**

Add `Rogue` to the same class-selection data structure used by Fighter/Mage/Ranger. Add secondary target metadata to the same progression definition boundary already used by ClassAdvancementService.

Working display names:
- `HumanRogueDuelist` -> `Duelist`;
- `ElfRogueWindstalker` -> `Windstalker`.

- [ ] **Step 4: extend Rogue trainer catalogue**

`RogueTrainer` must:
- accept Human/Elf Rogue;
- offer base Rogue skills/ranks only;
- reject Fighter/Mage/Ranger;
- not grant secondary-only skills before advancement.

- [ ] **Step 5: parse/build GREEN and commit**

Commit:
`feat(phase3): add rogue progression definitions`

---

### Task 2: Base Rogue skill families

**Files:**
- Modify: `src/ReplicatedStorage/Combat/Shared/SkillDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/SkillProgressionDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ClassProgressionDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/TrainerCatalogues.luau`
- Extend: `src/ServerScriptService/Combat/Tests/RogueDefinitionsTest.server.luau`

**Interfaces:**
Produce these eight stable base Rogue families:

```text
QuickStrike
Backstab
Feint
ShadowDash
EvasiveStep
CriticalFocus
LightFoot
ThreatDrop
```

Family roles:
- `QuickStrike`: fast frontal damage;
- `Backstab`: positional damage, higher rear bonus;
- `Feint`: short offensive setup/debuff marker;
- `ShadowDash`: gap-close/reposition;
- `EvasiveStep`: brief avoidance window;
- `CriticalFocus`: passive critical interaction;
- `LightFoot`: passive movement/evasion identity;
- `ThreatDrop`: PvE aggro reduction/escape utility.

- [ ] **Step 1: add RED assertions for all eight families**
- [ ] **Step 2: verify RED because skills are absent**
- [ ] **Step 3: implement data definitions with rear multiplier, range/duration/cooldown and passive metadata**
- [ ] **Step 4: at least five families support Rank 1-3 through existing SP/proficiency rules; passives do not occupy active slots**
- [ ] **Step 5: GREEN parse/build and commit**

Commit:
`feat(phase3): add rogue base skill families`

---

### Task 3: Server-authoritative Rogue combat runtime

**Files:**
- Modify: `src/ServerScriptService/Combat/CombatService.server.luau`
- Create: `src/ServerScriptService/Combat/Services/RogueMobilityService.luau`
- Create: `src/ServerScriptService/Combat/Services/RoguePositionService.luau`
- Create:
  - `src/ServerScriptService/Combat/Tests/RoguePositionRulesTest.server.luau`
  - `src/ServerScriptService/Combat/Tests/RogueMobilityServiceTest.server.luau`
  - `src/ServerScriptService/Combat/Tests/RogueThreatUtilityTest.server.luau`

**Interfaces:**

```luau
RoguePositionService.rear_factor(
    attacker_cframe: CFrame,
    target_cframe: CFrame
): number
```

```luau
RogueMobilityService:try_dash(player, target_position): any
RogueMobilityService:try_evasive_step(player, direction): any
```

- [ ] **Step 1: RED front/side/rear geometry tests; client damage multiplier is never accepted**
- [ ] **Step 2: RED dash/evasion tests reject over-range, NaN/infinity, invalid state, cooldown replay and wrong class**
- [ ] **Step 3: integrate through the accepted combat state/cooldown/progression validation path**
- [ ] **Step 4: ThreatDrop calls server NPC threat/aggro authority; client supplies intent only**
- [ ] **Step 5: GREEN parse/build and commit**

Commit:
`feat(phase3): add rogue combat runtime`

---

### Task 4: Human Duelist and Elf Windstalker breadth

**Files:**
- Modify: `src/ReplicatedStorage/Combat/Shared/SkillDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/SkillProgressionDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ClassProgressionDefinitions.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/TrainerCatalogues.luau`
- Modify the existing advancement definitions consumed by `ClassAdvancementService.luau`.
- Create: `src/ServerScriptService/Combat/Tests/RogueSecondaryDefinitionsTest.server.luau`

**Interfaces:**

Human Duelist:
```text
DuelistAmbush
DuelistDeadlyBlow
DuelistExposeWeakness
DuelistRush
DuelistCriticalMastery
```

Elf Windstalker:
```text
WindstalkerFlurry
WindstalkerSlipstream
WindstalkerBlur
WindstalkerQuickstep
WindstalkerEvasionMastery
```

- [ ] **Step 1: RED branch definition/inheritance/opposite-race rejection tests**
- [ ] **Step 2: implement through existing Quest/ClassAdvancement architecture**
- [ ] **Step 3: assert each developed Rogue line has at least 13 base+secondary skill families**
- [ ] **Step 4: GREEN Fighter/Mage/Ranger regression**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add rogue secondary skill breadth`

---

### Task 5: Rogue identity/trainer/runtime integration

**Files:**
- Modify only as required:
  - `src/ServerScriptService/Core/Services/IdentityService.luau`
  - `src/ServerScriptService/Base/BaseProgressionController.luau`
  - `src/ServerScriptService/Base/BaseRuntime.server.luau`
  - existing functional class-selection/trainer client scripts.
- Create: `src/ServerScriptService/Core/Tests/RogueIdentityServiceTest.server.luau`
- Extend: `src/ServerScriptService/Core/Tests/TrainerCataloguesTest.server.luau`

**Interfaces:**
- Fresh Human/Elf may select Rogue through existing identity flow.
- Existing identities never auto-change.
- Rogue starter grants are exactly-once.
- No catch-up grant exists.

- [ ] **Step 1: RED fresh-character selection/starter/rejoin tests**
- [ ] **Step 2: implement same identity path used by accepted classes**
- [ ] **Step 3: repository search must show no Phase 3 catch-up service/module/grant path**
- [ ] **Step 4: Base + Dungeon build and full class regression**
- [ ] **Step 5: cumulative P3.B commit**

Commit:
`feat(phase3): complete rogue skill-tree foundation`