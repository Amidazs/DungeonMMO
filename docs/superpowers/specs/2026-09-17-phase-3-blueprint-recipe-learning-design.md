# Phase 3 Blueprint / Recipe-Learning Foundation — Design

**Date:** 17 September 2026
**Phase:** Phase 3 — Systems Alpha
**Status:** Design approved in principle; awaiting written-spec confirmation
**Canonical local-main baseline:** `fddcf0ad1aac7f194e8ebd2479bc86204e19b40c`
**Remote note:** `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.

## Purpose

This gate adds persistent, server-authoritative recipe knowledge to the existing
profession/crafting system.

The system must distinguish between:

- recipes a character can use by default;
- recipes that must be learned;
- blueprint/recipe items that teach persistent knowledge;
- recipes the character knows but cannot yet craft because profession level or
  material requirements are not met.

This is a backend foundation. It does not add a new crafting UI, market,
trading system, reputation rewards, new professions, or loot/reward policy.

## Scope

This gate adds:

- data-driven recipe knowledge requirements;
- persistent learned-recipe knowledge;
- blueprint/recipe learning through authoritative item consumption;
- duplicate-learning protection;
- atomic learn-and-consume behavior;
- crafting eligibility checks against learned knowledge;
- migration coverage;
- reconnect persistence;
- one Blacksmithing blueprint proof and one Alchemy recipe proof.

This gate does **not** add:

- new professions;
- profession specialisations;
- a player market;
- blueprint trading rules;
- reputation gates;
- quest reward wiring;
- boss/drop wiring;
- new crafting stations;
- crafting UI redesign;
- new economy balancing;
- recipe discovery through world interaction.

## Existing-system rule

The implementation extends the accepted profession/crafting system. It must not
create a second crafting service or duplicate inventory authority.

Before modifying profile schema, implementation must inspect the current
canonical source.

If a semantically equivalent persistent learned-recipe field already exists,
reuse that exact accepted field and do **not** add a duplicate.

If no compatible field exists, this design advances the profile schema from
**v8 to v9** using the model below.

## Persistent data model

Preferred schema-v9 addition:

```luau
CraftingKnowledge = {
    Version = 1,
    LearnedRecipes = {
        ["blacksmith_iron_guard_blueprint"] = true,
        ["alchemy_restorative_tonic_recipe"] = true,
    },
}
```

Rules:

- recipe knowledge belongs to the character/profile;
- values are boolean membership, not counters;
- learning the same recipe twice has no effect;
- knowledge survives reconnect and migration;
- learned knowledge is independent of current inventory;
- learned knowledge is not removed when profession level changes;
- race/class changes do not erase compatible general crafting knowledge.

Default recipes are not redundantly copied into `LearnedRecipes`; they remain
definition-driven.

## Recipe definition model

Recipe definitions gain an explicit knowledge policy:

```luau
{
    Id = "iron_guard",
    ProfessionId = "Blacksmithing",
    RequiredProfessionLevel = 2,

    Knowledge = {
        Mode = "Learned",
        RecipeId = "blacksmith_iron_guard_blueprint",
    },

    Ingredients = {
        {ItemId = "iron_ore", Amount = 4},
        {ItemId = "wood", Amount = 1},
    },

    Output = {
        ItemId = "iron_guard",
        Amount = 1,
    },
}
```

Default recipes use:

```luau
Knowledge = {
    Mode = "Default",
}
```

Supported v1 modes are exactly:

- `Default`
- `Learned`

Unknown knowledge modes fail closed.

## Blueprint item model

Blueprint/recipe items are ordinary authoritative inventory items with a
learning payload.

Example:

```luau
{
    Id = "blacksmith_iron_guard_blueprint",
    Type = "RecipeBlueprint",

    RecipeLearning = {
        RecipeId = "blacksmith_iron_guard_blueprint",
        ProfessionId = "Blacksmithing",
        RequiredProfessionLevel = 2,
    },
}
```

Alchemy proof:

```luau
{
    Id = "alchemy_restorative_tonic_recipe",
    Type = "RecipeBlueprint",

    RecipeLearning = {
        RecipeId = "alchemy_restorative_tonic_recipe",
        ProfessionId = "Alchemy",
        RequiredProfessionLevel = 2,
    },
}
```

The item ID may equal the knowledge/recipe-learning ID. Craftable output recipe
IDs remain separate from blueprint item IDs.

## Learning service

Add a focused `RecipeKnowledgeService`.

Proposed location:

`src/ServerScriptService/Core/Services/RecipeKnowledgeService.luau`

Responsibilities:

- validate recipe-learning definitions;
- validate loaded profile;
- validate inventory ownership;
- validate profession membership/progression requirements;
- check duplicate knowledge;
- atomically consume the blueprint and persist learned knowledge;
- expose recipe-knowledge queries to crafting;
- build read-only snapshots.

Proposed API:

```luau
RecipeKnowledgeService.new(
    profileService,
    inventoryService,
    professionService,
    itemDefinitions,
    recipeDefinitions
)

RecipeKnowledgeService:learn_from_item(
    player,
    itemId
)

RecipeKnowledgeService:knows_recipe(
    player,
    recipeId
)

RecipeKnowledgeService:get_snapshot(
    player
)
```

No client is allowed to mutate `LearnedRecipes` directly.

## Stable rejection reasons

Learning failures use stable reasons:

- `ProfileNotLoaded`
- `UnknownBlueprintItem`
- `InvalidRecipeLearningDefinition`
- `BlueprintNotOwned`
- `ProfessionUnavailable`
- `ProfessionLevelTooLow`
- `RecipeAlreadyKnown`
- `RecipeKnowledgeMutationFailed`

Crafting eligibility continues to return the existing crafting/profession
rejection shape where possible, with one new stable reason:

- `RecipeNotLearned`

Do not overload unrelated inventory errors to represent recipe knowledge.

## Atomic learning

Blueprint consumption and knowledge mutation must be one authoritative profile
mutation.

Required ordering:

1. resolve loaded profile;
2. validate item definition;
3. validate inventory ownership;
4. validate profession/level requirement;
5. reject if already known;
6. inside one authoritative mutation:
   - revalidate ownership;
   - revalidate duplicate state;
   - decrement/remove exactly one blueprint item;
   - set `LearnedRecipes[RecipeId] = true`;
7. save through existing profile authority.

If the mutation fails, neither knowledge nor consumption may remain applied.

If a duplicate is presented, the item is **not consumed**.

## Crafting eligibility

The existing crafting path remains authoritative.

Before consuming materials:

1. resolve recipe definition;
2. validate profession and level;
3. validate recipe knowledge:
   - `Default` -> allowed by knowledge;
   - `Learned` -> require learned membership;
4. validate station/context;
5. validate ingredients;
6. perform existing atomic material/output mutation.

Knowledge validation must occur before ingredient consumption.

A recipe can be known but still fail crafting because:

- profession level is too low;
- station/context is invalid;
- ingredients are missing;
- other existing crafting rules reject.

Knowledge does not bypass any existing crafting rule.

## Initial proof content

### Blacksmithing

Add one learnable Blacksmithing recipe:

- blueprint knowledge ID: `blacksmith_iron_guard_blueprint`
- profession: `Blacksmithing`
- required profession level: `2`
- output: a small existing or test-safe Blacksmithing output selected from
  current accepted item definitions during implementation.

The implementation must reuse an existing output/item where practical rather
than inventing a production equipment balance change.

### Alchemy

Add one learnable Alchemy recipe:

- recipe knowledge ID: `alchemy_restorative_tonic_recipe`
- profession: `Alchemy`
- required profession level: `2`
- output: an existing or test-safe Alchemy consumable selected from accepted
  definitions.

The purpose is cross-profession-system proof, not new content balancing.

## Migration

If schema v9 is required:

- v8 profiles migrate without losing any identity, progression, profession,
  bank, quest, class-advancement, contribution-independent, inventory or
  equipment data;
- `CraftingKnowledge.Version = 1`;
- `LearnedRecipes = {}`;
- existing default recipes remain craftable because they are definition-driven;
- migration is idempotent.

No historical blueprint knowledge is inferred from inventory or prior crafts.

## Reconnect and persistence

Learned knowledge persists through the existing profile save/load boundary.

Tests must prove:

- learn recipe;
- reconstruct/reload service/profile;
- recipe is still known;
- consumed blueprint remains consumed;
- unrelated profile fields remain unchanged.

## Item acquisition boundary

This gate does not wire blueprint items into:

- dungeon drops;
- boss rewards;
- quests;
- reputation;
- vendors;
- market listings.

Tests may seed blueprint items through existing authoritative test helpers.

Future systems can award a blueprint item without knowing how recipe learning
works.

## Security / exploit rules

Fail closed for:

- client-supplied recipe IDs that do not match owned blueprint definitions;
- forged item ownership;
- forged profession level;
- duplicate learn requests;
- simultaneous duplicate requests;
- unknown recipe-learning definitions;
- crafting a `Learned` recipe without knowledge;
- using knowledge to bypass ingredients or station rules.

The server derives the recipe ID from the blueprint item definition. A client
must not be able to say "consume item A but learn recipe B".

## Concurrency

Two simultaneous learn requests for the same single blueprint must result in:

- one successful learn;
- one rejected duplicate/ownership result;
- exactly one blueprint consumed;
- exactly one learned membership entry.

The authoritative profile mutation must provide this guarantee.

## Testing

Automated tests must prove:

1. default recipe requires no learned membership;
2. learned recipe rejects before learning;
3. valid blueprint ownership + profession + level learns recipe;
4. exactly one blueprint is consumed;
5. learned membership is persisted;
6. duplicate learn rejects;
7. duplicate learn does not consume another blueprint;
8. wrong profession rejects;
9. insufficient profession level rejects;
10. missing blueprint rejects;
11. unknown blueprint rejects;
12. malformed RecipeLearning definition rejects;
13. blueprint item determines recipe ID server-side;
14. simultaneous duplicate attempts cannot double-consume;
15. known learned recipe can pass the knowledge gate;
16. knowledge does not bypass ingredient requirements;
17. knowledge does not bypass station/context requirements;
18. Blacksmithing proof passes;
19. Alchemy proof passes;
20. migration preserves existing v8 data and creates empty knowledge state;
21. migration is idempotent;
22. reconnect preserves learned knowledge;
23. existing profession/crafting/inventory tests remain green;
24. quest, class-advancement, bank, travel, contribution, combat and dungeon
    tests remain green;
25. all four Rojo projects build.

## Runtime integration

`RuntimeServices` composes `RecipeKnowledgeService` from existing profile,
inventory and profession authorities.

The existing crafting service receives a recipe-knowledge dependency or
focused query callback.

No new public RemoteEvent is required unless the existing profession runtime
already exposes a generic item-use/crafting remote suitable for this action.

If a new request remote is genuinely required, it may carry only the owned
blueprint **item ID**. The server resolves the recipe-learning payload.

## Manual Studio acceptance

Studio evidence is requested only after automated verification.

Required evidence:

- Base test suite green;
- Dungeon test suite green if shared services are included there;
- recipe knowledge/migration tests green;
- Blacksmithing and Alchemy learning tests green;
- existing profession/crafting tests green;
- no new runtime errors.

One controlled runtime proof should demonstrate:

1. seed/possess blueprint item;
2. learn it;
3. item count drops by exactly one;
4. recipe becomes known;
5. duplicate attempt does not consume another item;
6. craft request passes knowledge check after learning.

No visual/UI acceptance is required.

## Worktree / Git safety

Create:

- branch: `wip/phase-3-blueprint-recipe-learning-v1`
- worktree:
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_BlueprintRecipeLearning_v1`

Start from canonical local main:

`fddcf0ad1aac7f194e8ebd2479bc86204e19b40c`

Rules:

- no direct development on `main`;
- preserve all existing worktrees;
- do not touch the art worktree;
- no reset/clean/force push/history rewrite;
- no pull/push/publish;
- build only to TEMP;
- integration only after accepted Studio evidence.

## Acceptance boundary

This gate is accepted when:

- recipe knowledge is persistent and server-authoritative;
- blueprint learning is atomic and duplicate-safe;
- crafting enforces learned knowledge before consuming ingredients;
- Blacksmithing and Alchemy proofs pass;
- migration/reconnect behavior is proven;
- no unrelated crafting/economy behavior changes;
- all existing automated/runtime suites remain green;
- all four Rojo builds pass;
- Studio evidence is clean.

Blueprint acquisition, trading, market behavior, reputation rewards, quest
rewards, and player-facing recipe UX remain later work.
