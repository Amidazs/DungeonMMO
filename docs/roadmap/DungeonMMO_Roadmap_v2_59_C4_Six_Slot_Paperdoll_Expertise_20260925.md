# DungeonMMO Roadmap v2.59 — C4 Six-Slot Paperdoll + Expertise

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.58](
DungeonMMO_Roadmap_v2_58_C4_Launch_Core_Gear_Source_Expansion_20260925.md).

## Goal

Finish source mapping for the **current DungeonMMO six-slot equipment model**
and reproduce the original Chronicle 4 P.Def paperdoll order before moving on
to actually-owned passive ranks.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## Exact C4 paperdoll rules added

The pinned C4 `FuncPDefMod` applies item P.Def at order 0x10, then at 0x20
deducts the class paperdoll bases before multiplying by level modifier:

- Head equipped: deduct 12;
- Chest equipped: deduct 31 Fighter / 15 Mystic;
- Gloves equipped: deduct 8;
- Feet equipped: deduct 7.

DungeonMMO has no separate Legs slot, so the current six-slot migration covers:

- Weapon;
- OffHand;
- Helmet -> source Head;
- Body;
- Gloves;
- Boots -> source Feet.

`C4EquippedStatReference` now stages all of those supported source armour
slots together before passive operations. Existing robe MP remains deferred
until the original 0x60 stage.

## New pinned source equipment

Added reviewed source records for:

- Low Boots 38 — P.Def 15;
- Wooden Helmet 43 — P.Def 19;
- Leather Helmet 44 — P.Def 23;
- Gloves 49 — P.Def 13;
- Leather Gloves 50 — P.Def 15;
- Bracer 51 — P.Def 17;
- Mithril Gloves 61 — D-grade, P.Def 29;
- Gauntlets 63 — D-grade, P.Def 24.

## All current equipment now mapped

`C4CreativeItemSourceMap` now covers **all 27 current Equipment definitions**.
The earlier 18 Weapon/Body/OffHand links remain, and Helmet/Gloves/Boots now
translate into the correct source paperdoll slot names.

Current creative CombatModifiers remain ignored by source calculations.

The crafted-glove migration uses historical C4 item stat records as the future
balance source:

- basic leatherbound -> Leather Gloves 50;
- basic ironbound -> Bracer 51;
- tempered ironbound -> D-grade Gauntlets 63;
- runic/warded upgraded gloves -> D-grade Mithril Gloves 61.

This is a stat-source migration choice, not a claim that the creative item
names are historical C4 item names.

## C4 Expertise

Added `C4EquipmentExpertiseRules`.

The original C4 runtime gives skill 239 Expertise automatically at:

- D: level 20;
- C: level 40;
- B: level 52;
- A: level 61;
- S: level 76.

The launch cap reaches D only, but all original thresholds are recorded now.
A reviewed D-grade source item at level 19 fails closed; at level 20 it passes.

The authenticated resource boundary now reports current equipment mapping and
Expertise readiness. For a valid level-30 six-slot loadout,
`OriginalInventoryIntegrated=true`.

The global inventory-mapping blocker is therefore closed. The remaining live
resource blockers are:

1. actually-owned passive source resolution;
2. active-effect ordering;
3. live CP runtime authority.

A per-character invalid/unmapped/under-level loadout dynamically adds an
equipment-migration blocker.

## Fresh local acceptance

At commit `e93d46bd0bbf0d8df642a274bcf57219a29788df`:

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- Base focused source/resource suite: **6/6 PASS**;
- Dungeon focused source/resource suite: **7/7 PASS**.

Focused assertion results:

- C4SkillRuntimeRulesTest: 13;
- ManaServiceTest: 13 in Dungeon;
- C4NineClassAuthenticatedSkillPreviewTest: 554;
- C4ResourceMigrationBoundaryTest: 42;
- C4CreativeItemSourceMapTest: 61;
- C4LaunchCoreGearSourceTest: 8;
- C4SixSlotPaperdollSourceTest: 11.

No Roblox publish or production DataStore operation occurred.

## Next backend implementation

Resolve **actually owned creative passive ranks** into one highest owned
historical C4 passive rank per source skill and feed that list into the unified
source-stat calculator.

The resolver must:

- use only authenticated server-owned class identity;
- include inherited starter passives for first-transfer characters;
- never infer unpurchased ranks merely because character level allows them;
- keep automatic Expertise separate from purchased combat passives;
- identify owned creative passives that have no reviewed C4 counterpart;
- fail closed rather than applying custom passive percentages on top of C4.

After that, active effect ordering and CP remain before the coherent live
HP/MP/CP cutover.

Permanent scripts/docs remain GitHub-only. Remote Desktop Commander is used
only for fast-forwarding, disposable builds and unpublished Studio tests.
