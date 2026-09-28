# DungeonMMO Roadmap v3.28
## Launch profession economy backbone GREEN
**Date:** 28 September 2026

This checkpoint closes the first launch-ready profession/economy backbone on
top of the accepted class and Dwarf boundaries. It does **not** claim that
profession presentation, blueprint acquisition, gathering art, or every live
resource source is finished.

## Accepted profession ownership

The existing server-owned slot rules remain unchanged:

- ordinary characters: **1 gathering + 1 crafting**;
- Gearwright: **1 gathering + 2 crafting**;
- Deepclaimer: **2 gathering + 1 crafting**.

No new recipe, material or gathering tier bypasses those selections.

## Gathering progression

Gathering nodes now carry an authoritative optional `RequiredLevel`.

`ProfessionService:gather` derives profession level from persisted XP and
rejects a high-tier node with `ProfessionLevelTooLow` **before** any XP or
item grant. The same level gate is rechecked inside the atomic profile
mutation.

Launch advanced raw materials:

- Mining level 3 -> **Deep Iron Ore**;
- Herbalism level 3 -> **Moonpetal**;
- Skinning level 3 -> **Thick Hide**.

The Dungeon now places:

- `Temple.Room3.DeepIronVein`;
- `Temple.Room3.MoonpetalPatch`.

Both use the accepted `Temple.Room3.Checkpoint` environment boundary and
surface-probe placement rather than invented absolute world coordinates.

Skinning remains corpse-authoritative and animal-only. Levels 1-2 grant Raw
Hide; level 3+ grants Thick Hide from the same eligible dead, looted,
single-claim beast contract.

## Level 3-5 crafting ladder

Every launch crafting profession now has a normal, non-Dwarf-gated component
ladder through profession level 5.

### Level 3

- Blacksmithing -> Deep Iron Bar;
- Alchemy -> Moonpetal Extract;
- Leatherworking -> Reinforced Leather;
- Enchanting -> Resonant Rune.

### Level 4

- Blacksmithing -> Hardened Fittings;
- Alchemy -> Prismatic Catalyst;
- Leatherworking -> Rune Binding;
- Enchanting -> Prismatic Seal.

### Level 5

- Blacksmithing -> Masterwork Frame;
- Alchemy -> Aetheric Catalyst;
- Leatherworking -> Masterwork Lining;
- Enchanting -> Arcane Matrix.

These are tradeable components rather than newly balanced combat equipment.
Each tier deliberately consumes outputs from other professions. The ordinary
level 3-5 ladder never requires Deepclaimer salvage and therefore does not make
a Dwarf mandatory for normal profession progression.

## Gearwright premium economy

Gearwright keeps its accepted two-crafting-slot advantage without gaining
self-sufficiency.

Four level-5 premium class-owned blueprint outputs now exist:

- Blacksmithing -> Gearwright Precision Assembly;
- Alchemy -> Gearwright Stabilizing Compound;
- Leatherworking -> Gearwright Articulated Binding;
- Enchanting -> Gearwright Runic Matrix.

Each requires:

1. Gearwright Blueprint Training rank 2;
2. the matching selected crafting profession at level 5;
3. normal high-tier components from the wider profession economy;
4. exactly one tradeable specialist salvage material.

Current premium salvage inputs reuse the already accepted Deepclaimer economy:

- Dense Mineral Shard;
- Salvaged Mechanism Fragment;
- Ancient Binding Fragment.

A Gearwright cannot use an unselected third crafting profession.

## Real market integration

A new real-service integration test exercises four ordinary characters with
exclusive careers through the actual InventoryService, ProfessionService and
MarketService.

The accepted chain:

1. produces Deep Iron Bars and Moonpetal Extract;
2. trades level-3 outputs between profession owners;
3. produces Reinforced Leather and Resonant Runes;
4. trades those into Hardened Fittings and Prismatic Catalysts;
5. trades a Prismatic Catalyst into Rune Binding;
6. trades Rune Binding back to the smith;
7. completes one **Masterwork Frame** at profession level 5;
8. saves and reloads the finished output.

A separate Gearwright integration proves the premium Precision Assembly only
crafts after buying a Masterwork Frame, an Aetheric Catalyst and a tradeable
Salvaged Mechanism Fragment. It also proves the same Gearwright cannot use the
unselected Alchemy premium recipe.

## Studio acceptance

Fresh unpublished Rojo Dungeon build from branch head
`9ab2136c2dd8bb0e64589422eb92cf459c73500c` passed:

- `git diff --check`;
- fresh Rojo build;
- **22 / 22** focused profession/economy suites;
- `VERIFIED_PROFESSION_LAUNCH_ECONOMY_FOCUS_PASS 22`;
- `VERIFIED_PROFESSION_ROOM3_ADVANCED_NODES_PASS`.

Focused evidence includes:

- Profession Definition Contract: **81 assertions**;
- Profession Service: **45**;
- Gather Tier: **21**;
- Cross Dependency: **57**;
- Leather/Enchant trade: **83**;
- Exclusive Choice trade: **70**;
- Economy Topology: **113**;
- four-player Launch Economy: **214**;
- Gearwright Premium Economy: **24**;
- Profession Runtime Rules: **43**;
- Craft Guard: **21**;
- Reconnect: **21**;
- Skinning Eligibility: **42**;
- Corpse Skinning: **18**;
- two-user Skinning: **11**;
- C4 Profession Skills: **96**;
- Gearwright capacity: **23**;
- Deepclaimer capacity: **20**.

The physical Room 3 rehearsal found both advanced nodes on real floor geometry
with **27.00 studs** between prompt roots, above the 18-stud minimum.

## What is GREEN

- exclusive profession capacity and migration rules;
- authoritative gathering level gates;
- level-3 advanced Mining/Herbalism world nodes;
- level-3 advanced Skinning yield logic;
- ordinary level 3-5 cross-profession component ladder;
- real market dependency through a level-5 craft;
- Gearwright premium level-5 blueprint transaction;
- Deepclaimer salvage as optional premium supply rather than mandatory normal
  progression;
- persistence/reconnect and anti-duplicate contracts already covered by the
  focused package.

## What is deliberately not GREEN yet

- advanced Skinning has no newly accepted live beast spawn in the current
  Dungeon; the animal-only runtime is ready but content supply is still
  pending;
- the Base Raw Hide Cache remains a temporary foundation source;
- final profession station/resource art is placeholder presentation;
- real crafting minigames have not replaced the current validated completion
  hook;
- high-tier blueprint **acquisition/drop distribution** is not yet authored;
- profession trainer/tutorial/selection presentation is not implied here;
- no production publish or main-branch merge is part of this checkpoint.

## Next development gate

Continue profession content before moving fully into launch quest expansion:

1. design and bind blueprint acquisition/drop distribution without making rare
   recipes mandatory for baseline progression;
2. audit where the first real animal-like Dungeon enemies should provide
   Skinning supply, preserving the animal-only rule;
3. expose the level 3-5 ladder cleanly through profession UI/station
   presentation;
4. keep real crafting-minigame implementation as a presentation/gameplay
   follow-up behind the already transactional server authority;
5. then continue launch-level quest/content expansion.

Do not add more raw profession capacity to Dwarves. Their economic advantage is
now expressed through extra slot capacity plus optional premium supply/demand.
