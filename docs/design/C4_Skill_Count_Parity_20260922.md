# Chronicle 4 skill volume: exact rank counts, not placeholder buttons

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
First focused audit gameplay/test commit:
`29d117a0bbe9e54817b2a06577585ef3ca88ebb9`

## Interpretation of the player's requirement

Use **Lineage II Chronicle 4**, not later High Five/Interlude skill
catalogues, as the source for the *number of unlockable skill RANKS*
at each level in a mapped class. A repeated rank of one ability
counts as another offering at that trainer level; it does not mean
adding a new hotbar button or cloning an inert skill. Include
real active abilities, mastered passives, crafting/utility and
higher-rank variants, as appropriate to the original class role.

A target is satisfied only by implemented DungeonMMO rank
offerings that have an actual effect and are level/skill gated.
An empty catalogue entry, an unobtainable upgrade or a skill
with no executor/passive effect **cannot count as delivered**.
Keep original DungeonMMO names, lore, visual assets, combat
numbers and implementations; the reference fixes progression
density and role archetypes.

## Verified Chronicle 4 starting-class targets

Counts below are **separate rank entries newly listed in that
level's C4 class table**, not cumulative learned skills.

| DungeonMMO race/base | C4 source class | Lv 1 | Lv 5 | Lv 7 | Lv 10 | Lv 14 | Lv 15 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Human Fighter | Human Fighter | 2 | 13 | — | 12 | — | 12 |
| Elf Fighter | Elven Fighter | 2 | 13 | — | 13 | — | 12 |
| Human Mage | Human Mystic | 7 | 1 | 15 | — | 21 | — |
| Elf Mage | Elven Mystic | 7 | 1 | 14 | — | 20 | — |

Sources (explicitly set to C4):
[Human Fighter](https://l2hub.info/c4/classes/fighter),
[Elven Fighter](https://l2hub.info/c4/classes/elven_fighter),
[Human Mystic](https://l2hub.info/c4/classes/mage),
[Elven Mystic](https://l2hub.info/c4/classes/elven_mage).

These are the **only 16 verified brackets in the current manifest**.
Unlisted levels, branches, races and later skills are **not zero**;
they have not yet been entered and must not be silently represented
as complete.

## C4 class-tree mapping before full production parity

C4 Fighters start at levels 1/5/10/15; Mystics receive their
base training at 1/5/7/14. At level 20, C4 transfers to
distinct first classes; subsequent Fighter training follows
20/24/28/32/36, while Wizard training follows
20/25/30/35. Further specialisation begins at level 40
and changes the relevant class skill catalogue again.
See the [Human Knight](https://l2hub.info/c4/classes/knight),
[Elven Knight](https://l2hub.info/c4/classes/elven_knight),
[Human Wizard](https://l2hub.info/c4/classes/wizard),
[Elven Wizard](https://l2hub.info/c4/classes/elven_wizard),
[Human Rogue](https://l2hub.info/c4/classes/rogue) and
[Elven Scout](https://l2hub.info/c4/classes/elven_scout) pages.

Current DungeonMMO Ranger and Rogue are independent
**level-one** base classes, whereas C4's relevant bow/dagger
branches share the Human Rogue / Elven Scout level-20
first-class catalogue and split further at level 40.
Simply copying the entire C4 Rogue count into **both** the
current Ranger and Rogue would double-count its shared
bow/dagger tree and fabricate per-class parity.

The natural long-term map is Human Vanguard / Elf Thornwarden
to C4's Knight roles, Human Arcanist / Elf Spellweaver to
the Wizard roles, and Ranger/Rogue shared roots before
their ranged/stealth specialisations. Match each
**corresponding progression phase**, with an explicit
owned shared-skill catalogue, before declaring exact
per-class volume. Orc/Dwarf trees and levels beyond
the currently implemented playable range need separately
verified source profiles as those races/classes are added.

## First actual gap measurement

At `29d117a`, the focused Base audit printed:

- Human Fighter: rank counts 0/1/1/1 versus 2/13/12/12
  at levels 1/5/10/15.
- Elf Fighter: 0/1/1/1 versus 2/13/13/12.
- Human Mage: 0/0/1/1 versus 7/1/15/21
  at levels 1/5/7/14.
- Elf Mage: 0/0/1/1 versus 7/1/14/20.

All **16 verified level brackets currently miss the C4 volume
target**. These implemented counts include only ranks with
explicit author-assigned level data. Four Fighter and three
Mage earlier skill families lack complete rank schedules,
so the count is a deliberately conservative *mapped-rank
audit*, not the number of usable abilities a current
character possesses. Neither that undercount nor newly
created placeholder skills may be presented as parity.

The new `C4SkillVolumeTargets` table records source class,
URL and verified exact counts. The focused
`C4SkillVolumeAuditTest` fails if reference rows are
missing and prints the gaps and unmapped skill families.
It is a development planning report, not a production
unlock/quota check; do not disable valid existing gameplay
because a future content target is unmet.

## Implementation sequence without repeated dungeon testing

1. Complete a rank-entry inventory from each verified C4
   level/class page and explicitly assign each phase to
   DungeonMMO's existing or planned career. Keep first
   class transfer at level 20 and later career branch
   at level 40 in the long-term design.
2. Fill early-level volume with **real** attack/heal/control
   and passive/utility families, with separate rank offerings
   where the C4 source upgrades one family several times
   at a single level. Reuse current combat, equipment,
   proficiency, crafting and profile authorities.
3. Expand rank scheduling beyond the initial three-rank
   prototype where necessary. Every purchased rank needs
   an actual magnitude/cooldown/stat/utility difference,
   SP cost, character level and prior-rank/proficiency gate.
4. Extend the volume manifest to all mapped classes and
   relevant playable levels, then require actual-versus-
   reference parity for the **completed content phase only**.
5. Continue extending advanced-skill dependencies and
   advancement trials using earned basic rank/proficiency,
   per-class level thresholds and server-only eligibility.
   A character sees currently obtainable skills; a separate
   progression preview can explain future requirements.

The existing 1–40 gameplay cap is a current implementation
limit, not evidence of parity with C4's later skill trees.
Do not pad ranks or shift C4's trainer level brackets merely
to make a counter green. Content and actual skill effects
must arrive together. Full published multiplayer/cloud and
release tests remain separately approval-gated.
