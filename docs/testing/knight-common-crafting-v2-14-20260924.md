# v2.14 Knight original common creation: four-career focused acceptance

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Latest verified source: `f50db802af64e0c4f191ac2eaa01673eaaf7d4ed`

## Historical reference and what is actually implemented

The C4 source supplies Common Item Creation tier 1 at level 5,
tier 2 at level 20 and tier 3 at level 28, with recipe-book
crafting of common goods. See C4 patch notes:
https://lineage2wiki.com/c4/patch-notes/

DungeonMMO retains its agreed one-gathering/one-creation profession
limit and separate source-specific owner skills. For the personally
awarded Human Fighter -> Oathguard class, the **single**
`OathguardCommonItemCreation` skill has two separate trainable
ranks at levels 20 and 28, for common recipe tiers 2 and 3.
The previously introduced second identical `OathguardCommonCreation`
path was a branch conflict and has been removed (skill, trainer,
class entry, duplicate source key, eight duplicate recipes, preview
and transaction gates, duplicate function). The retained eight
`knight_*_rank_1/2` recipes use a real selected station, owned
material consumption, inventory output and atomic preparation/
completion checks. Blacksmithing tier 2 makes an actual equippable
blunt mace and tier 3 makes actual D-grade body armour; other
one-choice careers make usable materials through their own recipes.

**Difference still open:** the C4 source says Common Item Creation
is automatically granted at its level milestones; current
DungeonMMO source tiers require a paid class-trainer purchase,
and its present recipe catalogue/profession/fishing economy is a
WoW-style adaptation. This is **source rank/milestone and usable
crafting-gate coverage, not complete original C4 recipe-economy
parity or automatically balanced gameplay**.

## Exact executed proof

Unpublished, disposable Base and Dungeon Rojo compositions
both **PASS** at `2e79ca6`. Targeted unpublished Studio Quest
and Foundation run in
`0.740.0.7400927_20260924T100503Z_Studio_0A367_last.log`
reports Quest **172 assertions PASS**, Foundation
**112 assertions PASS**. Independently launched level-30
source coverage in
`0.740.0.7400927_20260924T100542Z_Studio_041B4_last.log`
reports **27 assertions PASS**, actual Knight **55/55**
rank schedule mapped and release/correct-mechanics flags false.

Extended the real isolated Knight quest/craft regression with:
- Actual paid rank tiers 20/28, ingredient consumption, real
  crafted mace and gated D-grade armour, no second profession.
- Revoking tier 3 **between** prepared minigame and authoritative
  completion: transaction denied, no ingredient consumption,
  no duplicated output; restored only inside disposable fixture.
- Three additional completely isolated in-memory copies of a
  genuinely quest-awarded, same-owner Knight profile, each with
  **one distinct selected** crafting profession (Alchemy,
  Leatherworking, Enchanting). Each completes *both* rank-tier
  material-backed recipes through the real server craft service
  and cannot forge a second crafting career.
- Same-owner distinct class and rank scenarios reject missing
  higher rank, wrong profession and forged/unawarded Fighter.

Fresh focused run `f50db802af64e0c4f191ac2eaa01673eaaf7d4ed`
in `0.740.0.7400927_20260924T100700Z_Studio_EE67F_last.log`:
Quest **247 assertions PASS**, Foundation **112 PASS**,
`VERIFIED_QUEST_AWARD_RANKS_PASS`.

**Not yet established:** normal real-client recipe UI selecting,
world-gathered ingredient chain, full saved cross-place crafting,
actual NPC fishing/recipe-book economics, or full C4 stat/balance
parity. Do not infer these from isolated in-memory service tests.
No main merge, publish or production DataStore operations.
