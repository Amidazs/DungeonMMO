# DungeonMMO roadmap v1.79 — exclusive WoW-style professions

Date: 23 September 2026
Working backend branch: `wip/phase-4-test-hud-integration-v1`

## Roadmap precedence

This is the latest **professions/economy backend supplement**, following
[v1.78 C4 hostile weakening](
DungeonMMO_Roadmap_v1_78_C4_Enemy_Weakening_20260923.md).
The separately maintained
[humanoid animation production roadmap](
DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
continues to govern animation/rig approvals. Neither C4 skill
catalogue completion nor animation production is implied here.

## New binding player rules

- A character may select **one Gathering and one Creation profession**.
  The categories are independent. Mining does not automatically
  unlock Blacksmithing; Herbalism does not unlock Alchemy.
- Gathering choices: Mining, Herbalism or Skinning.
  Crafting choices: Blacksmithing, Alchemy, Leatherworking or Enchanting.
- The player's explicit choice is server-authoritative and persists
  on the character. A second choice in either occupied category is
  rejected, including through direct forged RemoteEvent requests.
  No alternate character or client payload may add unauthorized XP.
- A character cannot use an unselected resource node, skin an animal
  using Skinning, learn that crafting career's blueprint, prepare
  or complete its recipe, or gain its profession XP. Every grant and
  craft must also recheck ownership inside the profile mutation.
- Every original crafting material, reagent and tradable output
  remains in existing inventory and the existing auction-house
  listing/buy/escrow workflow. Cross-career recipes are deliberate:
  a smith buys Alchemy flux; an alchemist buys smith bars. This
  creates demand for gathering, crafting and existing trading.
  Never secretly add a second profession merely to satisfy a recipe.
- The client displays both unfilled categories through the existing
  closable profession window. It shows the chosen career on a station,
  disables recipes outside it and directs players toward trading.

## Persistence, migration and choice policy

- Profile schema v14 adds `ProfessionSlots`, with empty Gathering
  and Creation selections on new characters.
- Older characters retain all previously earned profession XP,
  learned blueprints, items, equipment and market history. They must
  explicitly select one gathering and one crafting career; old XP
  in other professions becomes inactive, **not deleted**.
- During this backend increment no unlearning/respec is exposed.
  Future switching, XP reset/refund, cooldown or gold-cost rules
  require a separate design decision and migration proof.
- No production DataStore migration was performed.

## Evidence and unfinished acceptance

- [x] Source-controlled implementation of one-per-category
  selection, profile migration, gather/craft/blueprint authority,
  existing server remote and early UI choice.
- [x] Focused isolated `ProfessionExclusiveChoiceTradeTest`
  authored for forged requests, single slots, old XP preservation,
  two separate characters, actual existing market bar/flux sales,
  cross-profession equipment completion and profile reload.
- [x] After clean fast-forward pull, disposable Base and Dungeon
  Rojo builds PASS for the initial profession choice candidate;
  seven changed Luau files parse successfully with `luau-compile
  --only-parse`. The later blueprint check and test-reload
  additions still require a final rebuild/parse.
- [ ] Execute new focused test in an unpublished Studio server;
  then one real local Base client profession selection, one
  gathering node, opposite profession denial, a saved reload,
  and (with two clients) an actual market purchase. Do not
  equate authored tests or Rojo builds with execution evidence.
- [ ] Review and update older unrestricted-profession test
  fixtures: `ProfessionServiceTest`,
  `ProfessionCrossDependencyTest`,
  `ProfessionLeatherEnchantingDependencyTest`, and any
  profile/blueprint integration fixtures that assume a single
  character can train multiple gathering or crafting careers.
  Those legacy assumptions contradict the new requirement.
  They must become multi-character/trade scenarios **before
  any broad test-suite claim**.
- [ ] Add a clear profession trainer NPC/choice UX and decide
  retraining/unlearning policy (if any) after user approval.
- [ ] Integrate C4 RecipeReading/CommonItemCreation rank families
  with the **selected creation profession only**. Neither skill
  may bypass material, trainer, profession ownership or recipe
  knowledge authority. C4 raw-rank ledger is unchanged here.
- [ ] Continue source-mapping the seven missing ORIGINAL C4
  first-advancement catalogues and the remaining Rogue/Scout
  active world/resource skills after the profession contracts
  are verified.

No `main` merge, Roblox publishing, production save migration,
paid operations or repeated old dungeon wipe/revive/aggro suite.
Script and documentation edits were made in GitHub. The local
computer was used solely for clean pull, temporary Base/Dungeon
builds and source parser checks.

**Overall full C4 catalogue: INCOMPLETE; new profession system:
implementation candidate pending focused Studio acceptance.**
