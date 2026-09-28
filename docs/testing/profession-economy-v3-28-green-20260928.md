# Launch profession economy acceptance evidence — v3.28
**Date:** 28 September 2026

## Scope

This evidence covers the first launch profession economy backbone:

- profession-level gathering gates;
- advanced raw materials;
- level 3-5 cross-profession component recipes;
- Gearwright premium blueprint components;
- real MarketService dependency;
- advanced Room 3 gathering presentation;
- tiered animal-only Skinning behavior.

## Source-controlled build

Validated branch:

`wip/phase-4-test-hud-integration-v1`

Accepted code/test head before documentation:

`9ab2136c2dd8bb0e64589422eb92cf459c73500c`

Local validation:

- `git diff --check`: PASS;
- `rojo build default.project.json`: PASS;
- unpublished Studio Play: PASS.

## Focused package

Final marker:

`VERIFIED_PROFESSION_LAUNCH_ECONOMY_FOCUS_PASS 22`

All 22 focused suites passed.

Key suite evidence:

- Definition Contract: 81 assertions;
- Profile Migration: 26;
- Profession Service: 45;
- Gather Tier: 21;
- Cross Dependency: 57;
- Leather/Enchant Trade: 83;
- Exclusive Choice Trade: 70;
- Economy Topology: 113;
- Launch Economy Integration: 214;
- Gearwright Premium Economy: 24;
- Runtime Rules: 43;
- Craft Request Guard: 21;
- Reconnect Recovery: 21;
- Skinning Eligibility: 42;
- Corpse Skinning: 18;
- Skinning Two User: 11;
- Recipe Knowledge Crafting Gate: 13;
- Recipe Knowledge Definitions: 15;
- C4 Profession Skills: 96;
- Gearwright profession capacity: 23;
- Deepclaimer profession capacity: 20.

## Real level-5 trade chain

`ProfessionLaunchEconomyIntegrationTest` uses four separate ordinary
characters and the real profile, inventory, profession and market authorities.

It proves:

1. exclusive profession selections remain intact;
2. level-3 raw materials are granted only through selected gathering careers;
3. level-3 components are actually crafted;
4. components move through MarketService escrow between owners;
5. level-4 components are actually crafted by their owning profession;
6. Rune Binding is traded back into Blacksmithing;
7. Blacksmithing commits one level-5 Masterwork Frame;
8. an ordinary smith is denied the Gearwright premium recipe;
9. the Masterwork Frame survives save/reload.

Final marker line in Studio:

`[Profession Launch Economy] PASS: 214 assertions`

## Gearwright premium trade chain

`GearwrightPremiumEconomyIntegrationTest` uses a fully earned Gearwright
proof state with its accepted **1 gathering + 2 crafting** capacity.

It proves:

- Blacksmithing and Enchanting can occupy the two creation slots;
- the premium Blacksmithing recipe is visible only through
  Gearwright Blueprint Training rank 2;
- missing premium inputs deny the craft;
- Masterwork Frame, Aetheric Catalyst and Salvaged Mechanism Fragment are
  transferred through the real market;
- the premium assembly consumes every traded dependency exactly once;
- the output is granted once;
- an unselected third crafting profession remains denied.

Final marker line in Studio:

`[Gearwright Premium Economy] PASS: 24 assertions`

## Advanced world resources

Fresh Play against the actual composed Dungeon runtime returned:

`VERIFIED_PROFESSION_ROOM3_ADVANCED_NODES_PASS`

Observed:

- `Temple.Room3.DeepIronVein`: Mining / Deep Iron Ore;
- `Temple.Room3.MoonpetalPatch`: Herbalism / Moonpetal;
- both had live ProximityPrompts;
- both resolved via `PlacementMode = "Floor"`;
- prompt-root distance: **27.00145 studs**;
- minimum authored resource spacing: 18 studs.

## Skinning

The existing animal-only rules remain unchanged:

- explicit skinnable species only;
- `CreatureFamily == "Beast"`;
- server tag required;
- corpse must be dead and fully looted;
- one claim per corpse;
- losing simultaneous claimant receives nothing.

The new yield tier is:

- Skinning levels 1-2 -> Raw Hide;
- Skinning level 3+ -> Thick Hide.

The focused single-user and two-user regressions both pass.

## Economy boundary

Normal profession progression never consumes:

- Dense Mineral Shard;
- Salvaged Mechanism Fragment;
- Ancient Binding Fragment.

Those specialist materials are reserved for optional Gearwright premium
outputs. This keeps Deepclaimer valuable without making it mandatory for
ordinary level-5 profession progression.

## Non-claims

This evidence does not claim final profession UI/art, real minigames,
high-tier blueprint drop acquisition, an accepted live advanced Skinning beast
spawn, production publication, or a main-branch merge.
