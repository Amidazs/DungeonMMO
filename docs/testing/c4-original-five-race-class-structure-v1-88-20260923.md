# v1.88 — Original C4 class structure and advancement decision

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Decision: DungeonMMO will follow the **original Chronicle 4
class structure and advancement paths**, rather than use
C4-style skills inside an unrelated permanent class tree.

## Verified original source scope

Five original source races: Human, Elf, Dark Elf, Orc, Dwarf.
The exact first-class transfer inventory contains **18 distinct
level-20 class paths**, not nine. The preceding roadmap's
"seven additional classes" referred *only* to the other
seven Human/Elf first-transfer options; it omitted the nine
first transfers belonging to Dark Elf, Orc and Dwarf.

| Original C4 race | Starting family | First transfer choices |
| --- | --- | --- |
| Human | Fighter | Warrior; Human Knight; Rogue |
| Human | Mystic | Human Wizard; Cleric |
| Elf | Fighter | Elven Knight; Elven Scout |
| Elf | Mystic | Elven Wizard; Elven Oracle |
| Dark Elf | Fighter | Palus Knight; Assassin |
| Dark Elf | Mystic | Dark Wizard; Shillien Oracle |
| Orc | Fighter | Orc Raider; Orc Monk |
| Orc | Mystic | Orc Shaman |
| Dwarf | Fighter | Artisan; Scavenger |

Original first-transfer quests can begin at **level 18**,
but the class transfer is available only at **level 20**.
The full design also retains the later original C4 class
splits: **second transfer at level 40** and
**third transfer at level 76**, with real branch-specific
prerequisites and quest progression. No extra Kamael
source race is imported from a later chronicle.

Historical quest references:
- https://legacy-lineage2.com/Knowledge/quest2.html
- https://www.lineage2.com/en-us/news/lineage-ii-classic-launch-patch-notes

## Code actually changed

- `C4FirstTransferBranches` now records all eighteen exact
  first-transfer paths, their stable separate source IDs,
  source race/base family, individual historical quest name,
  level-18 quest starting point, level-20 transfer gate,
  and explicit current implementation status.
- The former generic Human `Wizard` label is distinguished
  from the historical **Human Wizard** source class.
  Each explicit source ID resolves only under its matching
  original race and starting family; no comparable existing
  DungeonMMO role is silently counted as the original class.
- A dedicated `C4ClassPathRules` validates explicit
  original class choices, original starting family and
  playable race, individual branch and quest/transfer
  levels. It **fails closed** with
  `OriginalQuestNotImplemented` rather than interpreting a
  historical quest *name* or 396/396 existing skill rank
  mapping as evidence of a completed branch quest.
- `C4CatalogueCoverage` independently audits the
  original eighteen paths across all five races while
  calculating starter rank coverage **only** for the
  currently supported Human/Elf profile races. It
  retains an explicit false overall completion flag.

## Executed tests

The final unpublished Studio focused runner,
`scripts/studio/c4_full_first_transfer_structure_focus.luau`,
reported **3/3 PASS, 0 failed**:

- `C4FirstTransferBranchesTest`: **144 assertions**;
  all eighteen unique paths, source quest and level
  metadata, exact race/family choice and no accidental
  unlocking of the three currently unsupported playable
  races.
- `C4ClassPathRulesTest`: **14 assertions**;
  level-17 quest refusal, level-18 source quest gate,
  level-20 transfer restriction, missing-quest rejection
  even for the mapped Human Rogue, explicit choice,
  cross-race denial and legacy starting-role refusal.
- `C4CatalogueCoverageTest`: **7 assertions**;
  currently audited starting-class ranks 168/168,
  existing Rogue/Scout mapped ranks 228/228, **0/18
  original paths completed, 2 partial, 16 not
  implemented**, and `Completed=false`.

Five changed/new Luau sources parsed with the local
Luau compiler; disposable Base and Dungeon Rojo
compositions built successfully. No broader
already accepted aggro/wipe/combat suites were rerun
because those systems were not touched.

## Transition work not yet completed

The live game currently supports only Human and Elf
profiles and still contains **legacy specialist starting
class choices, custom level-20 advancement candidates and
generic Dungeon-clear quests**. The new source registry
and validation rules do *not* convert those old routes
into authentic C4 first transfers. Those systems must
be migrated with backwards-compatible profile handling,
an explicit original class-choice window, distinct
branch quest definitions/objectives and real class/
trainer/skill authorization before the original
paths become playable. The seven other Human/Elf
first-transfer paths and all nine Dark Elf/Orc/Dwarf
first-transfer paths still need original class skill
inventories and functional implementations.

No claim is made that the current 396/396
*subset of inventoried source ranks* represents
all original C4 classes or that the user's full
class-structure decision is already implemented.

All scripts, tests and documents were authored
directly through GitHub. Desktop access was
used only for clean fast-forward pull, read-only
status, disposable builds and unpublished Studio
verification. No `main` merge, Roblox publish,
production DataStore write or destructive local
repository operation was performed.
