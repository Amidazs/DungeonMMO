# Profession blueprint acquisition evidence — v3.29
**Date:** 28 September 2026

## Scope

This evidence covers optional profession blueprint distribution, trading,
learning and crafting on top of the accepted v3.28 profession economy.

## Source-controlled build

Validated branch:

wip/phase-4-test-hud-integration-v1

Accepted code/test head before documentation:

18761195cb44e5299ec626340002b275ae3551d7

Local validation:

- git diff --check: PASS;
- new/edited blueprint files: no lines above 79 characters;
- fresh Rojo Dungeon build: PASS;
- unpublished Studio Play: PASS.

## Blueprint pools

Foundation pool:

- blacksmith_iron_guard_blueprint;
- alchemy_restorative_tonic_recipe.

Foundation sources:

- MarauderCaptain — 0.02;
- CorruptedForeman — 0.02;
- TestDungeon completion — 0.01;
- AbandonedMine completion — 0.01.

Advanced pool:

- blacksmith_masterwork_batch_blueprint;
- alchemy_aetheric_batch_recipe;
- leatherworking_masterwork_batch_pattern;
- enchanting_arcane_batch_inscription.

Advanced boss sources:

- TempleDepth2Boss;
- AbandonedMineDepth2Boss;
- TempleDepth3Boss;
- AbandonedMineDepth3Boss;
- TempleDepth4Boss;
- AbandonedMineDepth4Boss;
- TempleEventBoss;
- TempleSecretBoss;
- AbandonedMineEventBoss;
- AbandonedMineSecretBoss.

Each advanced boss definition uses chance 0.02.

Higher-depth/optional boss release status is not changed by this work.

## Batch-recipe neutrality

Each learned level-5 batch recipe is exactly two normal crafts combined into
one server transaction.

For every profession:

- same ingredient IDs as the normal level-5 recipe;
- each input quantity multiplied by two;
- output quantity multiplied by two;
- XP multiplied by two;
- normal recipe stays default-known.

Focused config result:

[Profession Blueprint Config] PASS: 44 assertions

## Reward routes

Real RewardService coverage proves:

- Depth-1 boss -> foundation blueprint;
- higher-depth boss -> advanced blueprint;
- normal completion -> foundation blueprint;
- boss replay is idempotent;
- completion replay is idempotent;
- failed boss/completion chance grants no blueprint.

Result:

[Profession Blueprint Reward] PASS: 14 assertions

Blueprint reward IDs are stored in existing monster/completion reward-history
records, so replay after persistence does not reroll or duplicate the item.

## End-to-end trade and learning

ProfessionBlueprintAcquisitionIntegrationTest uses the real:

- ProfileService;
- InventoryService;
- ProgressionService;
- RewardService;
- MarketService;
- ProfessionService;
- RecipeKnowledgeService.

Accepted flow:

1. off-profession seller receives Masterwork Frame Batch Blueprint;
2. duplicate reward request returns stored result;
3. seller save/release/reload preserves one copy;
4. post-reload replay still grants no duplicate;
5. failed-roll profile receives nothing;
6. level-5 Blacksmith can prepare normal Masterwork Frame without blueprint;
7. batch recipe rejects with RecipeNotLearned;
8. seller lists the blueprint;
9. buyer purchases it;
10. learning consumes exactly one blueprint;
11. learned knowledge becomes visible;
12. batch craft consumes double normal materials;
13. exactly two Masterwork Frames are produced.

Result:

[Profession Blueprint Acquisition] PASS: 33 assertions

## Focused Studio package

Final marker:

VERIFIED_PROFESSION_BLUEPRINT_ACQUISITION_PASS 12

All 12 suites passed:

- ProfessionBlueprintDropConfigTest;
- ProfessionBlueprintRewardTest;
- ProfessionBlueprintAcquisitionIntegrationTest;
- ProfessionDefinitionContractTest;
- ProfessionServiceTest;
- RecipeKnowledgeDefinitionsTest;
- RecipeKnowledgeServiceTest;
- RecipeKnowledgeCraftingGateTest;
- RewardServiceTest;
- RareSkillBookRewardTest;
- MarketListingServiceTest;
- MarketPurchaseRecoveryTest.

## Full profession regression

The existing v3.28 22-suite economy package was rerun on the same build.

Final marker:

VERIFIED_PROFESSION_ECONOMY_REGRESSION_PASS 22

Notable unchanged results include:

- Economy Topology: 113 assertions;
- Launch Economy Integration: 214;
- Gearwright Premium Economy: 24;
- Skinning Eligibility: 42;
- Gearwright capacity: 23;
- Deepclaimer capacity: 20.

## Non-claims

This checkpoint does not claim final drop-rate balance, production availability
of higher-depth/optional bosses, final blueprint presentation, final crafting
minigames, final profession station art, production publishing or main merge.
