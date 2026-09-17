# Phase 3 Blueprint / Recipe-Learning Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the existing profession/crafting system with persistent server-authoritative recipe knowledge and atomic blueprint-item learning for Blacksmithing and Alchemy.

**Architecture:** `RecipeKnowledgeService` owns learned-recipe state and authoritative blueprint learning. Recipe definitions explicitly declare whether knowledge is `Default` or `Learned`; the existing crafting path consults the knowledge service before consuming ingredients. Blueprint learning is a single authoritative profile mutation that revalidates ownership and duplicate state before consuming exactly one item and recording learned membership.

**Tech Stack:** Roblox Luau, Rojo, existing ProfileService/InventoryService/ProfessionService/crafting runtime, versioned profile migration, PowerShell 5.1 packaging and verification.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-blueprint-recipe-learning-design.md`

## Global Constraints

- Start from canonical local main `fddcf0ad1aac7f194e8ebd2479bc86204e19b40c`.
- `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.
- Use branch `wip/phase-3-blueprint-recipe-learning-v1`.
- Use worktree `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_BlueprintRecipeLearning_v1`.
- Do not work directly on `main`.
- Preserve all existing worktrees, especially the art worktree.
- No reset, clean, force push, history rewrite, pull, push, publish, PROD or monetisation actions.
- Reuse existing profession/crafting/inventory authority; do not create a second crafting system.
- Only bump profile schema from v8 to v9 if no semantically equivalent persistent learned-recipe field already exists.
- Blueprint item determines the learned recipe server-side; clients cannot supply an arbitrary recipe ID.
- Duplicate learning must not consume an additional blueprint.
- Knowledge validation must occur before crafting ingredient consumption.
- No blueprint drops, quest rewards, vendors, trading, market, reputation or UI redesign in this gate.
- TDD: RED tests must fail for the intended missing behavior before production implementation is added.
- If current source differs materially from expected accepted architecture, inspect and adapt to the accepted source instead of inventing parallel services.

---

## File Structure

**Create**
- `src/ServerScriptService/Core/Services/RecipeKnowledgeService.luau`
  - recipe-knowledge queries, authoritative blueprint learning, snapshots.
- `src/ServerScriptService/Core/Tests/RecipeKnowledgeServiceTest.server.luau`
  - ownership, requirements, duplicate safety, atomic consumption and persistence.
- `src/ServerScriptService/Core/Tests/ProfileMigrationRecipeKnowledgeTest.server.luau`
  - schema migration only if v9 is required.
- `src/ServerScriptService/Core/Tests/RecipeKnowledgeCraftingGateTest.server.luau`
  - learned/default knowledge enforcement before material consumption.
- `src/ServerScriptService/Core/Tests/RecipeKnowledgeDefinitionsTest.server.luau`
  - Blacksmithing + Alchemy blueprint/recipe definition contract.

**Modify after source inspection**
- existing shared recipe definition module;
- existing shared item definition module;
- `src/ServerScriptService/Core/Services/RuntimeServices.luau`;
- existing authoritative profession/crafting service;
- existing profile schema/migration service only if v9 is required;
- existing inventory helper/service only if a small atomic-consumption API is needed.

---

### Task 1: Isolated worktree, current-source inspection, schema decision and RED contracts

**Files:**
- Create design/plan docs in the worktree.
- Create all four/five RED test files listed above.

**Interfaces:**
- Consumes canonical local main `fddcf0ad1aac7f194e8ebd2479bc86204e19b40c`.
- Produces exact current-source map plus RED tests for the accepted APIs.

- [ ] **Step 1: Create isolated feature worktree**

```powershell
git -C C:\Users\Remko\Documents\Roblox\DungeonMMO worktree add `
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_BlueprintRecipeLearning_v1 `
  -b wip/phase-3-blueprint-recipe-learning-v1 `
  fddcf0ad1aac7f194e8ebd2479bc86204e19b40c
```

- [ ] **Step 2: Copy approved design and this plan into the worktree**

Write:

```text
docs/superpowers/specs/2026-09-17-phase-3-blueprint-recipe-learning-design.md
docs/superpowers/plans/2026-09-17-phase-3-blueprint-recipe-learning-implementation.md
```

- [ ] **Step 3: Inspect current profession/crafting source**

Search for:

```text
ProfessionDefinitions
Recipe
Recipes
Craft
Crafting
Ingredients
Output
InventoryService
ProfessionService
ProfileSchema
migrate
mutate
ItemDefinitions
```

Record exact file paths and constructor/method signatures before patching.

- [ ] **Step 4: Decide whether schema v9 is needed**

Search current profile/default/migration code for an existing persistent field semantically equivalent to learned recipe membership.

If such a field exists:
- reuse it;
- preserve current schema version.

If not:
- add `CraftingKnowledge.Version = 1`;
- add `CraftingKnowledge.LearnedRecipes = {}`;
- bump schema from 8 to 9;
- migrate v8 → v9 idempotently.

- [ ] **Step 5: Write RED definition-contract test**

Require exactly two learnable proof definitions:

```luau
check(
    BlacksmithingRecipe.Knowledge.Mode == "Learned",
    "Blacksmithing proof recipe must require learned knowledge."
)

check(
    BlacksmithingBlueprint.Type == "RecipeBlueprint",
    "Blacksmithing blueprint item type mismatch."
)

check(
    BlacksmithingBlueprint.RecipeLearning.ProfessionId == "Blacksmithing",
    "Blacksmithing blueprint profession mismatch."
)

check(
    AlchemyRecipe.Knowledge.Mode == "Learned",
    "Alchemy proof recipe must require learned knowledge."
)

check(
    AlchemyBlueprint.RecipeLearning.ProfessionId == "Alchemy",
    "Alchemy blueprint profession mismatch."
)
```

Also prove at least one existing recipe remains `Default`.

- [ ] **Step 6: Write RED `RecipeKnowledgeServiceTest`**

Using existing fake Profile/Inventory/Profession patterns, prove:

```luau
local result = service:learn_from_item(player, blueprint_item_id)
check(result.ok == true, "Valid owned blueprint must learn.")
check(result.RecipeId == expected_recipe_id, "Server must resolve recipe ID.")
```

Add explicit RED cases for:
- unknown blueprint -> `UnknownBlueprintItem`;
- malformed learning payload -> `InvalidRecipeLearningDefinition`;
- missing owned item -> `BlueprintNotOwned`;
- unavailable profession -> `ProfessionUnavailable`;
- insufficient profession level -> `ProfessionLevelTooLow`;
- duplicate -> `RecipeAlreadyKnown`;
- duplicate does not consume another item;
- one valid learn consumes exactly one item;
- snapshot is a copy;
- `knows_recipe` returns true only after learning;
- item definition, not client, selects recipe ID.

- [ ] **Step 7: Write RED atomic/concurrency test**

Seed exactly one blueprint and issue two learn calls against the same profile authority.

Required outcome:

```luau
check(success_count == 1, "Exactly one duplicate-racing learn may succeed.")
check(remaining_blueprints == 0, "Exactly one blueprint must be consumed.")
check(learned_count == 1, "Recipe knowledge remains boolean membership.")
```

Use the repository's existing serial profile mutation primitive; do not invent threading semantics beyond that authority.

- [ ] **Step 8: Write RED crafting knowledge-gate test**

Prove:

```luau
-- Learned recipe, not known
check(result.reason == "RecipeNotLearned")
check(material_count_after == material_count_before)

-- Same recipe after learning
check(result.reason ~= "RecipeNotLearned")

-- Existing Default recipe
check(default_recipe_is_not_blocked_by_knowledge == true)
```

The first assertion must happen before any material decrement.

- [ ] **Step 9: Write RED migration test only if v9 is required**

Start from a representative v8 profile containing:
- identity;
- progression;
- professions;
- inventory;
- bank;
- quest/class advancement;
- equipment.

After migration assert:
- all existing data is preserved;
- schema version is 9;
- `CraftingKnowledge.Version == 1`;
- `LearnedRecipes` is empty;
- running migration again is idempotent.

- [ ] **Step 10: Verify RED**

Build/run the accepted Base test harness with production knowledge service/definitions absent.

Valid RED failures:
- missing `RecipeKnowledgeService`;
- missing knowledge metadata;
- missing migration field/version when v9 is required;
- crafting does not yet reject `RecipeNotLearned`.

Reject syntax errors or unrelated baseline failures as invalid RED.

- [ ] **Step 11: Commit design/plan/RED tests**

```powershell
git add docs/superpowers src/ServerScriptService/Core/Tests
git diff --cached --check
git commit -m "test: define recipe knowledge foundation"
```

---

### Task 2: Add recipe knowledge definitions and persistence model

**Files:**
- Modify exact accepted recipe definition module from Task 1.
- Modify exact accepted item definition module from Task 1.
- Modify ProfileSchema/migration only if v9 is required.
- Test definition and migration tests.

**Interfaces:**
- Produces:
  - recipe `Knowledge.Mode` = `Default | Learned`;
  - blueprint `RecipeLearning` payload;
  - persistent boolean learned membership if v9 is required.

- [ ] **Step 1: Add explicit knowledge metadata to proof recipes**

Add one Blacksmithing and one Alchemy learnable proof without changing unrelated balance.

Use existing/test-safe outputs already present in item definitions.

- [ ] **Step 2: Add two blueprint items**

Exact IDs:

```text
blacksmith_iron_guard_blueprint
alchemy_restorative_tonic_recipe
```

Each item definition carries:

```luau
RecipeLearning = {
    RecipeId = "<knowledge id>",
    ProfessionId = "<profession>",
    RequiredProfessionLevel = 2,
}
```

- [ ] **Step 3: Mark existing baseline recipes as `Default` where needed**

Do not force existing content into `Learned`.

- [ ] **Step 4: Implement v9 model only if required**

Add:

```luau
CraftingKnowledge = {
    Version = 1,
    LearnedRecipes = {},
}
```

Migration from v8 must preserve all unrelated fields.

- [ ] **Step 5: Run definition/migration tests**

Expected:
- both proof definitions pass;
- default recipe contract passes;
- migration passes if present.

- [ ] **Step 6: Commit definitions/persistence**

```powershell
git add <exact-definition-files> <exact-schema-files> <definition-tests>
git diff --cached --check
git commit -m "feat: add persistent recipe knowledge definitions"
```

---

### Task 3: Implement `RecipeKnowledgeService`

**Files:**
- Create `src/ServerScriptService/Core/Services/RecipeKnowledgeService.luau`
- Modify `RuntimeServices.luau`
- Modify existing inventory/profile helper only if required by accepted mutation patterns.
- Test `RecipeKnowledgeServiceTest.server.luau`.

**Interfaces:**
- Produces:

```luau
RecipeKnowledgeService.new(
    profileService,
    inventoryService,
    professionService,
    itemDefinitions,
    recipeDefinitions
)

RecipeKnowledgeService:learn_from_item(player, itemId)
RecipeKnowledgeService:knows_recipe(player, recipeId)
RecipeKnowledgeService:get_snapshot(player)
```

- [ ] **Step 1: Implement read-only knowledge query**

`knows_recipe`:
- validates loaded profile;
- returns default-recipe knowledge as true from definition policy;
- checks persistent learned membership for `Learned`.

- [ ] **Step 2: Implement blueprint validation**

For `learn_from_item(player, itemId)`:
- server looks up item definition;
- type must be `RecipeBlueprint`;
- learning payload must contain valid recipe ID/profession/level;
- payload must correspond to an actual learnable recipe contract.

- [ ] **Step 3: Validate profile/inventory/profession requirements**

Return exact stable reasons from the spec.

- [ ] **Step 4: Implement one atomic profile mutation**

Inside existing authoritative serial mutation:
- revalidate blueprint count;
- revalidate duplicate learned state;
- consume exactly one blueprint;
- set learned membership true;
- commit once.

If the mutation fails, return `RecipeKnowledgeMutationFailed`.

- [ ] **Step 5: Implement snapshot**

Return a deep/read-only copy of known learned membership; do not expose mutable profile table references.

- [ ] **Step 6: Compose in `RuntimeServices`**

Use existing Profile/Inventory/Profession instances.

No new public remote yet.

- [ ] **Step 7: Run service tests**

All ownership, requirement, duplicate, atomicity and concurrency cases must pass.

- [ ] **Step 8: Commit knowledge service**

```powershell
git add src/ServerScriptService/Core/Services/RecipeKnowledgeService.luau `
        src/ServerScriptService/Core/Services/RuntimeServices.luau `
        <exact-helper-files-if-any> `
        src/ServerScriptService/Core/Tests/RecipeKnowledgeServiceTest.server.luau
git diff --cached --check
git commit -m "feat: add recipe knowledge service"
```

---

### Task 4: Enforce knowledge in the existing crafting path

**Files:**
- Modify exact accepted crafting/profession service discovered in Task 1.
- Test `RecipeKnowledgeCraftingGateTest.server.luau`.

**Interfaces:**
- Consumes `RecipeKnowledgeService:knows_recipe`.
- Produces stable rejection `RecipeNotLearned`.

- [ ] **Step 1: Inject or resolve recipe knowledge authority**

Follow existing dependency injection patterns.

- [ ] **Step 2: Place knowledge check before material consumption**

Required order:

```text
recipe exists
profession/level valid
knowledge valid
station/context valid
ingredients valid
atomic craft mutation
```

If existing station validation occurs before knowledge, preserve harmless validation ordering if necessary; the hard requirement is that knowledge rejection occurs before ingredients are consumed.

- [ ] **Step 3: Return `RecipeNotLearned` for unknown learned recipe**

Do not consume materials.

- [ ] **Step 4: Preserve default recipe behavior**

Existing recipes must remain craftable under their existing rules.

- [ ] **Step 5: Run crafting gate + all existing profession tests**

At minimum:
- Profession Service Tests;
- Profession Definition Contract Tests;
- Profession Runtime Rules Tests;
- Profession Resource Claim/Distribution;
- profile migration;
- new recipe knowledge tests.

- [ ] **Step 6: Commit crafting integration**

```powershell
git add <exact-crafting-service> `
        src/ServerScriptService/Core/Tests/RecipeKnowledgeCraftingGateTest.server.luau
git diff --cached --check
git commit -m "feat: enforce learned recipes in crafting"
```

---

### Task 5: Full regression/build gate and Studio handoff

**Files:**
- All approved recipe-knowledge files from Tasks 1–4.

**Interfaces:**
- Produces feature checkpoint ready for Studio evidence.
- Does not merge, pull, push or publish.

- [ ] **Step 1: Verify schema decision**

If v9 was required:
- exact ProfileSchema version is 9;
- migration test proves v8 preservation.

If an equivalent existing field was reused:
- ProfileSchema has no contribution-gate-unrelated changes and no duplicate learned-recipe structure.

- [ ] **Step 2: Run recipe-knowledge focused suite**

Required PASS lines:

```text
[Recipe Knowledge Definitions Tests] PASS
[Recipe Knowledge Service Tests] PASS
[Recipe Knowledge Crafting Gate Tests] PASS
```

If v9:
```text
[Recipe Knowledge Migration Tests] PASS
```

- [ ] **Step 3: Run broad Base and Dungeon suites**

No existing profession, inventory, quest, class advancement, bank, travel, contribution, combat or dungeon suite may regress.

- [ ] **Step 4: Run `git diff --check`**

Expected exit 0.

- [ ] **Step 5: Build all four Rojo projects to TEMP**

```powershell
rojo build base.project.json -o $env:TEMP\BlueprintRecipe_Base.rbxl
rojo build default.project.json -o $env:TEMP\BlueprintRecipe_Dungeon.rbxl
rojo build published-base.project.json -o $env:TEMP\BlueprintRecipe_PublishedBase.rbxl
rojo build published-dungeon.project.json -o $env:TEMP\BlueprintRecipe_PublishedDungeon.rbxl
```

All must exit 0.

- [ ] **Step 6: Verify feature boundary**

Only:
- design/plan;
- exact recipe/item definition modules;
- RecipeKnowledgeService;
- RuntimeServices;
- exact crafting/profile/inventory helpers required;
- recipe knowledge tests;
- schema/migration files if v9 was required.

No art, contribution, combat, quest, bank, travel or unrelated roadmap files.

- [ ] **Step 7: Create clean feature checkpoint**

Commit remaining accepted implementation only; skip empty commit.

- [ ] **Step 8: Stop for Studio evidence**

Request:
- Base output;
- Dungeon output if shared test placement includes it;
- new PASS lines;
- no new red runtime errors.

Controlled runtime proof:
1. blueprint exists in inventory;
2. learn succeeds;
3. count decreases by one;
4. knowledge persists;
5. duplicate does not consume;
6. learned craft passes knowledge gate.

No visual acceptance is required.
