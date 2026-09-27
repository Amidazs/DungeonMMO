# DungeonMMO Roadmap v3.22 — Dwarf Profession Design Boundary

Date: 27 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous:
[Roadmap v3.21](
DungeonMMO_Roadmap_v3_21_Orc_Shaman_Ashspeaker_GREEN_20260927.md).

## Status

**DOCUMENTATION / DESIGN CHECKPOINT — no new Dwarf gameplay has been
implemented.**

The latest accepted gameplay checkpoint remains **v3.21 Ashspeaker GREEN** at
accepted code/test commit
`f28824bdc0f3d2b6fbdf1b1940ec17b3f78cb1c5`.

Repository HEAD before this documentation update:
`7ec16b2e6175ddad1ef2621fa9b349aec7e7c88b`.

This checkpoint exists to:

1. make the roadmap index reflect the accepted v3.17-v3.21 work;
2. restate the overall level-30 C4 catalogue position;
3. record the unresolved Dwarf profession/economy decision before any Dwarf
   source audit or implementation begins.

## Level-30 class backend position

The level-30 launch catalogue is now accepted for **16 of the 18 original C4
first-transfer branches**.

Aggregate accepted source coverage at v3.21:

- **21 source paths**;
- **1305 learning rows**;
- **162 unique source skill IDs**;
- **162 source skills / 634 rank-effect pairs**;
- **16 / 18 first-transfer source audits complete**;
- **16 / 18 first-transfer rank schedules mapped**.

The only remaining first-transfer branches are:

- **Dwarf Artisan**;
- **Dwarf Scavenger**.

No Dwarf class names, source mapping, race enablement, skills, crafting
integration, Spoil/Sweep runtime, trainer content or Play acceptance has been
authored yet.

## Recent accepted class checkpoints missing from the roadmap index

The roadmap index must surface the following accepted work:

- v3.17 — Dark Wizard / **Nightweaver** GREEN:
  86/86 rows, 25 families, 25/25 broad backend regression and unpublished
  Play acceptance;
- v3.18 — Shillien Oracle / **Duskseer** GREEN:
  92/92 rows, 26 families and unpublished Play acceptance;
- v3.19 — Orc Raider / **Warhowl** GREEN:
  63/63 first-transfer rows plus inherited Orc Fighter source authority;
- v3.20 — Orc Monk / **Spiritclaw** GREEN:
  41/41 first-transfer rows, force-charge authority and unpublished Play
  acceptance;
- v3.21 — Orc Shaman / **Ashspeaker** GREEN:
  77/77 first-transfer rows, 29 families, 21/21 focused regression and
  unpublished Play acceptance.

## Existing profession rule

DungeonMMO currently intends normal characters to choose:

- **one gathering profession**; and
- **one crafting profession**.

That rule is important because it creates material interdependence and makes
player trading meaningful rather than allowing one character to produce every
part of its own economy.

## Dwarf design question

The original C4 Dwarf identity is unusual because crafting and scavenging are
not merely side activities: they are part of the class fantasy itself.

A direct translation creates a conflict with DungeonMMO's profession rule:

- making Artisan simply duplicate a normal crafting profession risks making
  the class feel pointless;
- making Scavenger's Spoil/Sweep the only source of important materials risks
  making the class mandatory;
- giving every Dwarf two gathering **and** two crafting professions risks
  making Dwarves the default economic alt and weakening the one-plus-one
  profession/trading model.

### Proposed direction for owner discussion — not yet accepted

The strongest current design candidate is **branch-specific extra capacity**
rather than a blanket two-plus-two Dwarf bonus:

- **Dwarven Fighter before first transfer:** normal 1 gathering + 1 crafting;
- **Artisan path:** 1 gathering + **2 crafting** professions;
- **Scavenger path:** **2 gathering** + 1 crafting profession.

This preserves the distinction between the two first-transfer branches.
Neither branch becomes self-sufficient, so Artisan and Scavenger still benefit
from each other and from non-Dwarf players.

This proposal is **not an accepted rule yet** and must not be implemented until
the owner approves it.

## Proposed class-specific economy layer

Profession slots alone should not carry the entire Dwarf identity.

### Artisan

The Artisan class should retain a separate class-owned blueprint/crafting
identity in addition to ordinary professions.

Candidate rules:

- learns **Dwarven Blueprints** through class progression, drops, quests,
  reputation or specialist vendors;
- blueprint use is class-gated to Artisan;
- crafted outputs are normally tradeable;
- recipes can combine ordinary profession materials with salvaged Dwarf
  components;
- special blueprints should focus on distinctive utility, engineered gear,
  dungeon consumables, deployables, mechanical items and later siege/castle
  systems rather than simply being a second copy of Blacksmithing;
- exact original C4 Create Item skill ranks should be audited before deciding
  how their numerical progression maps to blueprint tiers.

### Scavenger

The Scavenger class should retain Spoil/Sweep as a class-owned loot mechanic,
not as a replacement for ordinary gathering.

Candidate rules:

- **Spoil** marks an eligible defeated enemy for a secondary salvage table;
- **Sweep** claims that secondary salvage after the enemy dies;
- salvage may include profession materials, components, rare blueprint parts
  and trade goods;
- outputs should be tradeable;
- Spoil/Sweep should improve access and efficiency without being the only
  possible source of every progression-critical material.

This gives Scavenger a meaningful economic combat loop while avoiding a design
where every serious group or guild is forced to field one.

## Economy safeguards to preserve trading

Whichever Dwarf rule is accepted, preserve these constraints:

- do not give both Dwarf paths 2 gathering + 2 crafting by default;
- do not let one Dwarf character cover the entire production chain;
- keep normal profession outputs relevant;
- keep Dwarf-produced materials/items tradeable where practical;
- avoid progression-critical items that can only exist when a particular
  Dwarf class is online;
- preserve cross-profession and cross-player dependencies;
- future profession switching must obey the same cost/cooldown rules as other
  characters unless a separate Dwarf rule is deliberately approved.

## Next implementation gate after the design decision

Once the Dwarf economy rule is approved:

1. audit pinned C4 Dwarven Fighter inheritance and Artisan source rows;
2. choose independent DungeonMMO creative names;
3. map exact level-30 ranks and source effects;
4. implement Artisan combat plus the approved blueprint/profession bridge;
5. run focused Studio regression and genuine unpublished Play acceptance;
6. repeat the same gate for Scavenger, including Spoil/Sweep;
7. close the catalogue at **18 / 18** first-transfer branches;
8. run one all-class level-30 regression across stats, resources, passives,
   skills, advancement, source cutover and rollback.

After the first-transfer catalogue closes, continue the wider roadmap rather
than treating classes as the whole game. Remaining major workstreams include
the profession/economy implementation, quests/content, HUD/presentation,
guild systems, PvP/castle capture, raids/world-boss content, additional
dungeons and later class/level expansion.

No `main` merge, Roblox publish, production DataStore mutation or Dwarf
gameplay implementation is part of this documentation checkpoint.
