# Launch profession economy acceptance evidence — v3.28
**Date:** 28 September 2026

## Scope

This record covers the launch profession economy expansion after the accepted
Dwarf class/world/spatial work. It validates profession-level gathering,
higher-tier components, cross-player trading, advanced Skinning selection and
Gearwright/Deepclaimer economic interaction.

## Build

Accepted source head before documentation:

`9ab2136c2dd8bb0e64589422eb92cf459c73500c`

Fresh local validation:

- `git diff --check`: PASS;
- `rojo build default.project.json -o _tmp_profession_economy_v2.rbxlx`:
  PASS.

## Gathering authority

`ProfessionService:gather` now validates authored
`RequiredLevel` against profession XP-derived level before mutation.

Focused result:

`[Profession Gather Tier] PASS: 21 assertions`

The test proves:

- level-1 Mining cannot harvest level-3 Deep Iron;
- rejection grants no material;
- normal Mining XP reaches level 3;
- level-3 harvest then succeeds;
- invalid tiers above the profession maximum fail closed.

## Advanced Room 3 nodes

Fresh Play on the v2 build returned:

`VERIFIED_PROFESSION_ROOM3_ADVANCED_NODES_PASS`

Observed runtime facts:

- Deep Iron model exists;
- Moonpetal model exists;
- both have `ProfessionGatherPrompt`;
- Deep Iron reports Mining / `deep_iron_ore`;
- Moonpetal reports Herbalism / `moonpetal`;
- both resolved with `PlacementMode = "Floor"`;
- prompt-root distance = **27.00145149230957 studs**.

The existing minimum runtime spacing is 18 studs.

## Skinning tier

The corpse runtime now asks the authoritative profession service for the
player's Skinning level.

Accepted yield rule:

- Skinning 1-2 -> Raw Hide;
- Skinning 3+ -> Thick Hide.

All previous eligibility rules remain unchanged: approved beast identity,
server tag, dead corpse, completed loot, one claim and player range.

Fresh focused results:

- `[Skinning Eligibility] PASS: 42 assertions.`
- `[Corpse Skinning] PASS: 18 assertions.`
- `[Skinning Two User] PASS: 11 assertions.`

## Generic crafting ladder

The new normal level-3-to-5 outputs are:

- Blacksmithing:
  Deep Iron Bar -> Hardened Fittings -> Masterwork Frame;
- Alchemy:
  Moonpetal Extract -> Prismatic Catalyst -> Aetheric Catalyst;
- Leatherworking:
  Reinforced Leather -> Rune Binding -> Masterwork Lining;
- Enchanting:
  Resonant Rune -> Prismatic Seal -> Arcane Matrix.

The topology regression requires every generic higher-tier recipe to:

- stay usable through normal profession progression;
- avoid Deepclaimer salvage requirements;
- produce a tradeable component;
- require at least one component produced by another crafting profession.

Fresh result:

`[Profession Economy Topology] PASS: 113 assertions`

## Real four-player economy chain

`ProfessionLaunchEconomyIntegrationTest` uses:

- real `ProfileService`;
- real `InventoryService`;
- real `ProfessionService`;
- real `MarketService`;
- four independent profession owners.

The chain performs actual listings and purchases before completing a level-5
Masterwork Frame.

Fresh result:

`[Profession Launch Economy] PASS: 214 assertions`

The final output survives save and reload.

## Gearwright premium path

Four premium level-5 Gearwright recipes were added across the four crafting
professions.

The Blacksmithing execution test proves an earned Gearwright with
Blacksmithing + Enchanting:

- cannot craft the premium assembly without materials;
- buys a Masterwork Frame from another owner;
- buys an Aetheric Catalyst from another owner;
- buys a tradeable Salvaged Mechanism Fragment;
- consumes each exactly once;
- creates one Gearwright Precision Assembly;
- remains unable to use unselected Alchemy.

Fresh result:

`[Gearwright Premium Economy] PASS: 24 assertions`

This proves the extra Gearwright crafting slot does not remove market
dependence.

## Combined focused package

The final 22-suite package returned:

`VERIFIED_PROFESSION_LAUNCH_ECONOMY_FOCUS_PASS 22`

Additional accepted results:

- Profession Definition Contract: 81;
- Profession Profile Migration: 26;
- Profession Service: 45;
- Profession Cross Dependency: 57;
- Leather/Enchant Trade: 83;
- Profession Exclusive Choice: 70;
- Profession Runtime Rules: 43;
- Profession Craft Guard: 21;
- Profession Reconnect: 21;
- Recipe Knowledge Crafting Gate: 13;
- Recipe Knowledge Definitions: 15;
- C4 Profession Skills: 96;
- Gearwright capacity: 23;
- Deepclaimer capacity: 20.

## Non-claims

This checkpoint does not claim final profession station art, final beast
placement, complete blueprint acquisition content, finished crafting
minigames, market-price tuning, a production publish or a main-branch merge.
