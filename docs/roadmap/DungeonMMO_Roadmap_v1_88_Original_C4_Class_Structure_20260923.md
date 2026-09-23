# DungeonMMO backend roadmap v1.88 — original C4 class tree

Decision confirmed 23 September 2026:
**Follow the original Lineage 2 Chronicle 4 class
structure AND its advancement paths**, not merely
its skills. This decision supersedes any
DungeonMMO-specific custom career naming or
one-role-per-starting-class design where it
conflicts with the original C4 class lineage.

This is the newest authoritative **C4 backend and
class-progression roadmap supplement**, following
[v1.87 Scout skill-rank coverage](
DungeonMMO_Roadmap_v1_87_C4_Scout_Source_Environment_20260923.md).
The separate humanoid/quadruped animation and
model-production roadmap remains unchanged.

## Corrected scope: all five original C4 races

The previous "seven additional classes" count
covered only the unmapped Human/Elf first-transfer
branches; it was **not** the entire C4 class
system. Chronicle 4 has **five original races**
and **18 distinct first-class transfers**.
The source tree must retain each original race,
starting class and branch without merging
different paths merely because their
combat roles resemble one another.

| Race | Original starting class | First transfer paths (level 20) |
| --- | --- | --- |
| Human | Human Fighter | Warrior, Human Knight, Rogue |
| Human | Human Mystic | Human Wizard, Cleric |
| Elf | Elven Fighter | Elven Knight, Elven Scout |
| Elf | Elven Mystic | Elven Wizard, Elven Oracle |
| Dark Elf | Dark Fighter | Palus Knight, Assassin |
| Dark Elf | Dark Mystic | Dark Wizard, Shillien Oracle |
| Orc | Orc Fighter | Orc Raider, Orc Monk |
| Orc | Orc Mystic | Orc Shaman |
| Dwarf | Dwarven Fighter | Artisan, Scavenger |

Class-quest starts: **level 18**; first transfer:
**level 20**. Preserve the original later
**second transfer at level 40** and
**third transfer at level 76** with their
own authentic branch structure, quest
requirements and prior skill mastery.
Do not introduce later-chronicle Kamael
or modern class/awakening features.

Source references:
- https://legacy-lineage2.com/Knowledge/quest2.html
- https://www.lineage2.com/en-us/news/lineage-ii-classic-launch-patch-notes

## v1.88 completed, directly committed and tested

- [x] Preserve exact original race/family/source
  class identities and individual historical
  quest names in `C4FirstTransferBranches`.
  Include all **18** original first-transfer
  paths, including the nine Dark Elf/Orc/Dwarf
  paths omitted from the earlier game-only
  nine-path roadmap. Source metadata does
  **not** mark those races playable.
- [x] Introduce explicit source-class choice
  validation in `C4ClassPathRules`:
  original starter family, existing playable
  race, user-requested specific class,
  source quest start level, transfer level,
  wrong-race/legacy-class refusal and a
  **fail-closed requirement for a real
  registered original branch quest**.
  A C4 source name is not a working quest.
- [x] Update strict C4 source-coverage
  accounting: all **18** first-transfer
  branches counted, **2 partially mapped
  skill inventories**, **16 without a
  completed original source skill/class
  implementation**, **0/18** fully
  operational branches. The aggregate
  `Completed` status stays **false**.
  Retain 396/396 only as the audited
  six-list *subset* (four currently playable
  original starting-class source inventories
  plus Human Rogue and Elven Scout).
- [x] Unpublished Studio source structure
  acceptance **3/3 PASS**: **144** source
  registry assertions, **14** explicit
  original path/level/quest safeguards,
  **7** strict total-coverage assertions.
  Changed Lua sources parsed and Base/
  Dungeon disposable Rojo builds passed.
  See [v1.88 executed test record](
../testing/c4-original-five-race-class-structure-v1-88-20260923.md).
- [x] GitHub-first script/document edits.
  No `main` merge, Roblox publishing,
  production DataStore write or destructive
  local operation.

## Required migration and implementation sequence

- [ ] **Legacy class identity migration first.**
  Current characters can start as Fighter,
  Mage, Ranger or Rogue and earn custom
  advancements such as HumanVanguard and
  ElfWindrunner. C4 starts with race-specific
  Fighter/Mystic families; Human Rogue and
  Elven Scout must be *choices made on first
  transfer from their original fighter
  families*, not additional default
  starting classes. Map pre-existing
  progress, unlocked skills, equipment,
  profession slots and persistent class
  history explicitly. Do not automatically
  award an unearned original branch
  based only on an old generic role name.
- [ ] **Real explicit branch selection in
  the hub/level-18 class quest window.**
  Present only the original options for
  the character's race/base family;
  preserve independent user choice,
  level gates and trainers. Persist
  the selected branch server-side,
  require its own registered quest and
  server-evidenced objectives, and
  grant the chosen branch only after
  the level-20 quest claim commits
  atomically. Stop the old automatic
  one-candidate custom class trial
  from being presented as an
  authentic original C4 transfer.
  Migration must be tested before
  swapping the current live action.
- [ ] **Complete supported Human/Elf
  first-transfer implementations.**
  Human: Warrior, Knight, Rogue, Wizard,
  Cleric. Elf: Knight, Scout, Wizard,
  Oracle. Existing Human Rogue and
  Elven Scout 99/99 and 129/129
  rank analogues are reusable backend
  work, **not proof that either
  original quest/path is fully
  implemented**. Audit and implement
  the seven remaining source
  inventories with true class-specific
  skills and functionally different
  first-transfer outcomes.
- [ ] **Add the three other original
  race implementations**, without
  marking source-only metadata playable:
  Dark Elf (Palus Knight, Assassin,
  Dark Wizard, Shillien Oracle);
  Orc (Raider, Monk, Shaman);
  Dwarf (Artisan, Scavenger).
  Each requires starting stats,
  racial passives/gear, a genuine
  starter skill inventory, original
  distinct class quests, trainer
  eligibility and a real first
  transfer. Race, class and profile
  migration tests precede exposing
  the race in character creation.
- [ ] **Second- and third-transfer
  original source trees.** Enumerate
  all actual C4 level-40 and
  level-76 original branch choices
  from source references before
  coding; distinguish separate
  professions even when they share
  roles. Preserve the user's
  prerequisite skill ranks,
  earned proficiency, level and
  class-advancement quest gates,
  including first-transfer proof.
  Do not inherit abilities across
  incompatible branch histories.
- [ ] **Full original progression
  acceptance.** Two clients choose
  different classes within the same
  starting race/family, each completes
  only its selected trial, learns
  only authorized later skills,
  persists across save/rejoin and
  cannot cross-transfer using another
  race's quest, skills or historical
  save. Run focused playtests after
  each actual branch implementation.
- [ ] Preserve previously accepted
  dungeon aggro, party difficulty,
  combat, crafting and market systems
  while changing class identities.
  A character continues to select
  **one gathering plus one crafting
  profession** regardless of
  race/class branch. Original
  class-specific crafting *skill*
  differences must not silently
  override this explicit
  DungeonMMO economy rule.
- [ ] Preserve separate real-physics
  full fall traversal, original
  Mystic hostile-weakening
  client/NPC acceptance and
  documented progression
  proficiency regression.

## Current release gate

**Source structure: 18 original C4 first-transfer
branches catalogued and source selection guards
tested. Original first-transfer gameplay:
0/18 paths fully complete. Original races playable:
Human and Elf only. Full five-race original C4
progression and skill catalogue: INCOMPLETE.**

The existing generic in-game secondary-class
trial/runtime and old legacy starting class
paths have **not yet been migrated** to the
new original C4 player-choice workflow.
Do not describe source metadata alone as
the user's full class-system decision
already implemented.
