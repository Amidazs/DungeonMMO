# DungeonMMO Roadmap v3.28
## Launch profession economy GREEN
**Date:** 28 September 2026

This checkpoint closes the first launch-ready profession/economy backend
ladder after the v3.27 Dwarf spatial checkpoint. It keeps the accepted
profession-capacity rules intact while extending normal profession progression
through level 5 and making higher tiers depend on real cross-player trade.

## Accepted profession authority

Capacity remains unchanged:

- normal character: **1 gathering + 1 crafting**;
- Gearwright: **1 gathering + 2 crafting**;
- Deepclaimer: **2 gathering + 1 crafting**.

No recipe, material or class skill in this checkpoint grants an extra slot.

## Gathering progression

Gathering now has an authoritative `RequiredLevel` gate in
`ProfessionService:gather`.

A node is rejected with `ProfessionLevelTooLow` before inventory or XP
mutation when the selected gathering profession is below its authored tier.

The launch advanced resources are:

- Mining level 3: **Deep Iron Ore**;
- Herbalism level 3: **Moonpetal**;
- Skinning level 3+: **Thick Hide** from an otherwise eligible beast corpse.

Skinning still preserves the accepted animal-only boundary. A humanoid enemy
does not become skinnable through a display name, generic family assignment
or arbitrary tag.

## Physical Dungeon nodes

Room 3 now contains the first two advanced world gather nodes:

- `Temple.Room3.DeepIronVein`;
- `Temple.Room3.MoonpetalPatch`.

Fresh Play verified both models and their prompts in the real
`ProfessionRuntime`. Both resolved against floor geometry and their prompt
roots were **27.00 studs apart**, above the existing 18-stud resource spacing
minimum.

## Crafting ladder through level 5

All four normal crafting professions now have a generic level 3 -> 4 -> 5
component path:

| Profession | Level 3 | Level 4 | Level 5 |
| --- | --- | --- | --- |
| Blacksmithing | Deep Iron Bar | Hardened Fittings | Masterwork Frame |
| Alchemy | Moonpetal Extract | Prismatic Catalyst | Aetheric Catalyst |
| Leatherworking | Reinforced Leather | Rune Binding | Masterwork Lining |
| Enchanting | Resonant Rune | Prismatic Seal | Arcane Matrix |

These are tradeable components rather than newly balanced combat equipment.
The checkpoint therefore grows the economy without silently changing player
combat power.

## Cross-player dependency

The generic level-3-to-5 ladder deliberately requires materials made by other
crafting professions.

A four-player real-service integration test now proves:

1. separate players own Blacksmithing, Alchemy, Leatherworking and Enchanting;
2. higher-tier raw materials are gathered or supplied through authoritative
   inventory paths;
3. components are listed and purchased through the real `MarketService`;
4. level-4 components are assembled by their correct profession owners;
5. the final Blacksmith completes one **Masterwork Frame** at profession
   level 5;
6. the finished component survives profile save/reload.

That integration returned:

`[Profession Launch Economy] PASS: 214 assertions`

## Gearwright premium economy

Gearwright keeps its class-owned blueprint authority across only its two
selected crafting professions.

Four level-5 premium outputs now exist:

- Blacksmithing: Gearwright Precision Assembly;
- Alchemy: Gearwright Stabilizing Compound;
- Leatherworking: Gearwright Articulated Binding;
- Enchanting: Gearwright Runic Matrix.

Each premium recipe requires:

- normal higher-tier profession components;
- exactly one tradeable Deepclaimer salvage ingredient;
- authenticated Gearwright blueprint rank 2;
- the exact selected crafting profession.

A real market integration proves an earned Gearwright must purchase a
Masterwork Frame, Aetheric Catalyst and Salvaged Mechanism Fragment before
crafting its Precision Assembly. The same character remains unable to use an
unselected third crafting profession.

Fresh result:

`[Gearwright Premium Economy] PASS: 24 assertions`

This intentionally creates a Dwarf trade niche without making Dwarves
mandatory for normal profession progression.

## Focused Studio acceptance

Fresh Rojo Dungeon build from branch head
`9ab2136c2dd8bb0e64589422eb92cf459c73500c` passed
`git diff --check` and build.

The combined unpublished Play package returned:

`VERIFIED_PROFESSION_LAUNCH_ECONOMY_FOCUS_PASS 22`

Notable focused results include:

- Profession Definition Contract: **81 assertions**;
- Profession Service: **45 assertions**;
- Gather Tier: **21 assertions**;
- Cross Dependency: **57 assertions**;
- Leather/Enchant Trade: **83 assertions**;
- Exclusive Choice Trade: **70 assertions**;
- Economy Topology: **113 assertions**;
- Launch Economy Integration: **214 assertions**;
- Gearwright Premium Economy: **24 assertions**;
- Runtime Rules: **43 assertions**;
- Skinning Eligibility: **42 assertions**;
- Corpse Skinning: **18 assertions**;
- two-user Skinning: **11 assertions**;
- C4 Profession Skills: **96 assertions**;
- Gearwright capacity: **23 assertions**;
- Deepclaimer capacity: **20 assertions**.

World-facing marker:

`VERIFIED_PROFESSION_ROOM3_ADVANCED_NODES_PASS`

## What is GREEN

- authoritative gathering-level gates;
- level-3 Mining and Herbalism world nodes;
- level-3+ Thick Hide selection for valid beast corpses;
- normal level-3-to-5 crafting component ladders;
- cross-profession material dependencies;
- real market transfer through a four-player level-5 chain;
- Gearwright premium recipes;
- optional Deepclaimer salvage demand;
- normal / Gearwright / Deepclaimer slot authority;
- reconnect/profile persistence for the exercised economy path.

## What remains content work

This checkpoint does not claim that final profession presentation is complete.

Still pending:

- bespoke final Leatherworking/Enchanting station art;
- removal of the temporary Base hide-cache presentation once live beast
  content supplies early Skinning consistently;
- final launch beast placement/AI for the approved skinnable species;
- broader blueprint drop/vendor/quest acquisition content beyond the existing
  recipe-learning foundation and class-owned Gearwright blueprint authority;
- economy drop-rate, recipe-cost and market-price tuning with real players;
- final crafting minigames and VFX;
- production publish or main-branch merge.

## Next development gate

Move into **launch-level quest/content integration** while using the now-green
profession economy as a dependency.

Priority order:

1. connect launch quests and dungeon content to profession materials,
   blueprints and tradeable rewards where appropriate;
2. author the first real beast sources needed for non-placeholder Skinning;
3. add blueprint acquisition sources without making one profession
   self-sufficient;
4. preserve one-page/one-place UI clarity and the existing trading-house
   boundary;
5. continue broader launch quests/content, then guild/raid and later
   PvP/castle systems.

Do not expand profession slot counts as part of content work. Those capacities
are already accepted game rules.
