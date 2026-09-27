# DungeonMMO Roadmap v3.23 — Dwarf Profession Model Accepted

Date: 28 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous:
[Roadmap v3.22](
DungeonMMO_Roadmap_v3_22_Dwarf_Profession_Design_Boundary_20260927.md).

## Status

**DESIGN ACCEPTED — Dwarf profession/economy rules are now locked for the
level-30 launch implementation.**

The latest accepted gameplay checkpoint remains **v3.21 Ashspeaker GREEN**.
No Dwarf gameplay code has been implemented yet.

## Accepted profession capacities

DungeonMMO keeps the normal profession rule:

- ordinary characters: **1 gathering + 1 crafting** profession.

Dwarven progression modifies that rule only after first transfer:

- **Dwarven Fighter:** 1 gathering + 1 crafting;
- **Artisan:** 1 gathering + **2 crafting** professions;
- **Scavenger:** **2 gathering** + 1 crafting profession.

Dwarves do **not** receive 2 gathering + 2 crafting by default.

This preserves economic interdependence, keeps trading relevant and gives the
two Dwarf branches different economic identities.

## Artisan class identity

Artisan receives a class-owned **Dwarven Blueprint** system in addition to
ordinary professions.

Blueprints are not merely duplicate profession recipes. They may cover
specialist engineered items such as:

- distinctive equipment and components;
- dungeon consumables and deployables;
- mechanical utility items;
- specialist tools;
- trade goods;
- later siege/castle-battle equipment and mechanisms.

Blueprint recipes may deliberately require materials from several professions
and Scavenger salvage so an Artisan cannot become self-sufficient.

Normal profession items must remain relevant. Artisan-exclusive crafts should
primarily provide different capabilities and specialist value rather than
simply replacing every ordinary crafted item with a stronger version.

The exact relationship between original C4 Create Item ranks and DungeonMMO
blueprint tiers must be established from the pinned source audit rather than
guessed.

## Scavenger class identity

Scavenger retains **Spoil/Sweep** as a class-owned combat/economy mechanic in
addition to its two gathering professions.

Accepted direction:

- Spoil marks an eligible enemy for secondary salvage;
- Sweep claims the secondary salvage after that enemy dies;
- salvage may contain profession materials, monster components, blueprint
  parts, rare trade goods and other specialist resources;
- salvage outputs should normally be tradeable;
- Scavenger should improve access and efficiency without becoming the sole
  source of every progression-critical material.

Important materials may therefore have alternate lower-efficiency acquisition
routes where appropriate, such as bosses, dismantling or rare ordinary drops.

## Economy safeguards

Carry these rules forward:

- no blanket 2 gathering + 2 crafting Dwarf privilege;
- neither Dwarf branch should cover the entire production chain alone;
- ordinary professions remain useful on all races;
- Dwarf class outputs should be tradeable where practical;
- Artisan and Scavenger should have strong reasons to trade with each other;
- guilds may benefit from economic class diversity, but dungeon groups must not
  require a Dwarf merely to progress;
- Dwarf specialist systems must not invalidate normal gathering/crafting;
- future profession switching follows the ordinary profession-change rules
  unless a separate rule is deliberately approved later.

## Next implementation order

Proceed in this order:

1. audit pinned C4 Dwarven Fighter inheritance and **Artisan** source rows;
2. choose independent DungeonMMO creative names;
3. map exact level-30 ranks and source effects;
4. implement Artisan combat plus the accepted profession/blueprint bridge;
5. run focused Studio regression and genuine unpublished Play acceptance;
6. audit and implement **Scavenger**;
7. implement and validate Spoil/Sweep secondary salvage;
8. close the level-30 first-transfer catalogue at **18 / 18**;
9. run an all-class level-30 regression across stats, resources, passives,
   skills, advancement, source cutover and rollback.

The existing aggregate accepted source position before Dwarf work remains:

- **21 source paths**;
- **1305 learning rows**;
- **162 unique source skill IDs**;
- **162 source skills / 634 rank-effect pairs**;
- **16 / 18 first-transfer branches complete**.

No `main` merge, Roblox publish, production DataStore mutation or Dwarf
gameplay implementation is part of this design acceptance checkpoint.
