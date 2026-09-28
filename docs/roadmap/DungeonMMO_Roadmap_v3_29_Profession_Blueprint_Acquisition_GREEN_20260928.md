# DungeonMMO Roadmap v3.29
## Profession blueprint acquisition GREEN
**Date:** 28 September 2026

This checkpoint closes the profession blueprint acquisition/distribution
backend identified as the first open content gate after v3.28.

It preserves the accepted rule that rare recipe knowledge is optional:
baseline profession progression through level 5 never depends on a random
blueprint drop.

## Blueprint ownership and trading

Profession blueprints are physical inventory items.

Accepted rules:

- any eligible reward recipient may receive a blueprint;
- blueprint drops are not filtered by the recipient's class or profession;
- valid profession blueprints are unbound and tradeable;
- another player may list and buy the blueprint through the existing market;
- learning consumes exactly one physical blueprint;
- learning still requires the matching selected crafting profession,
  profession level and Recipe Reading authority.

This makes an off-profession blueprint drop economically useful rather than a
dead reward.

## Foundation blueprint distribution

The existing level-2 recipe-learning items remain the foundation pool:

- Iron Guard Blueprint;
- Restorative Tonic Recipe.

Current reviewed sources:

- Marauder Captain: 2 percent independent blueprint roll;
- Corrupted Foreman: 2 percent;
- TestDungeon completion: 1 percent;
- Abandoned Mine completion: 1 percent.

These rolls are independent of ordinary loot and rare skill-book rolls.

## Advanced level-5 blueprint pool

Four new Rare, tradeable level-5 blueprint items now exist:

- Masterwork Frame Batch Blueprint — Blacksmithing;
- Aetheric Catalyst Batch Recipe — Alchemy;
- Masterwork Lining Batch Pattern — Leatherworking;
- Arcane Matrix Batch Inscription — Enchanting.

Their higher-depth/optional boss pool is registered for:

- Temple / Mine Depth2 bosses;
- Temple / Mine Depth3 bosses;
- Temple / Mine Depth4 bosses;
- Temple / Mine Event bosses;
- Temple / Mine Secret bosses.

Each registered boss uses a 2 percent independent profession-blueprint roll.

This is backend distribution authority only. Higher-depth and optional bosses
remain subject to their existing physical-layout/release gates and are not
claimed as presently farmable production content.

## No hidden economy advantage

Each advanced blueprint teaches one level-5 batch recipe.

The batch contract is intentionally neutral:

- exactly the same ingredient identities as the normal recipe;
- exactly 2x every ingredient quantity;
- exactly 2x output quantity;
- exactly 2x profession XP.

Therefore the rare recipe provides bulk-crafting convenience, not cheaper
materials, extra combat power, or an exclusive progression requirement.

Normal level-5 recipes remain default-known.

## Drop configuration safety

ProfessionBlueprintDropConfig.validate now requires every configured source
to have:

- chance greater than zero and no greater than one;
- a non-empty weighted pool;
- finite positive weights;
- real RecipeBlueprint item IDs;
- tradeable, non-bound, non-test blueprint items;
- valid recipe-learning metadata.

Unsupported boss/dungeon IDs return no blueprint definition.

## Reward persistence and idempotency

RewardService records the profession blueprint item ID inside the existing
persistent monster/completion reward history.

Accepted behavior:

- same-runtime replay does not duplicate the blueprint;
- save/release/reload replay does not duplicate the blueprint;
- failed chance rolls grant nothing;
- normal reward XP/Gold/loot and skill-book behavior remain independent.

## End-to-end acquisition path

The real-service integration now proves:

1. a player with no matching profession receives a higher-depth blueprint;
2. the same reward transaction cannot duplicate it;
3. persisted reward history survives profile reload;
4. the player lists the blueprint through MarketService;
5. a level-5 Blacksmith buys it;
6. the normal Masterwork Frame recipe is already usable without the blueprint;
7. the batch recipe is denied with RecipeNotLearned before learning;
8. RecipeKnowledgeService consumes the purchased blueprint;
9. the learned batch recipe prepares and commits;
10. exactly two Masterwork Frames are created from exactly double materials.

## Studio acceptance

Fresh Dungeon build at:

18761195cb44e5299ec626340002b275ae3551d7

passed:

- git diff --check;
- new/edited blueprint gate files under 80 characters per line;
- fresh Rojo build;
- dedicated 12-suite blueprint focus;
- full 22-suite v3.28 profession/economy regression.

Accepted markers:

VERIFIED_PROFESSION_BLUEPRINT_ACQUISITION_PASS 12

VERIFIED_PROFESSION_ECONOMY_REGRESSION_PASS 22

Focused assertion evidence:

- Profession Blueprint Config: **44**;
- Profession Blueprint Reward: **14**;
- Profession Blueprint Acquisition: **33**;
- Profession Definition Contract: **81**;
- Profession Service: **45**;
- Recipe Knowledge Definitions: **15**;
- Recipe Knowledge Service: **23**;
- Recipe Knowledge Crafting Gate: **13**;
- Reward Service: **27**;
- Rare Skill Book Reward: **16**;
- Market Listing Service: **15**;
- Market Purchase Recovery: **17**.

The complete v3.28 economy package also remained green.

## What is GREEN

- tradeable profession blueprint item contract;
- foundation boss/completion blueprint distribution;
- higher-depth/optional advanced blueprint distribution registry;
- four level-5 optional batch blueprint recipes;
- zero-efficiency batch equivalence;
- drop-config validation;
- persistent reward idempotency;
- real market resale;
- profession/level/Recipe Reading learning gates;
- end-to-end drop -> trade -> learn -> craft path.

## What remains deliberately open

- drop percentages are launch candidates, not final economy tuning;
- higher-depth/optional boss physical release remains governed elsewhere;
- final blueprint UI/presentation is not implied by this checkpoint;
- final station/resource art is still presentation work;
- real crafting minigames remain pending;
- a live accepted beast source for advanced Skinning is still missing;
- no production publish or main-branch merge is part of this checkpoint.

## Next development gate

Close the remaining **live Skinning supply** gap:

1. audit the already registered Forest Wolf combat path;
2. bind an actual animal-like Dungeon encounter without weakening the existing
   animal-only Skinning eligibility rules;
3. prove death -> loot complete -> one-player skin / contested skin behavior
   in the real Dungeon runtime;
4. preserve existing dungeon encounter counts and release boundaries;
5. then continue profession presentation and launch quest/content integration.
