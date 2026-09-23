# DungeonMMO backend roadmap v1.90 — original C4 explicit class choice

Confirmed design (23 September 2026): follow the **original
Lineage 2 Chronicle 4 race-specific Fighter/Mystic starting
classes and their original first, second and third
class-transfer paths**. This is the latest authoritative
class-progression supplement after [v1.89 Fighter/Mystic-only
fresh starters](
DungeonMMO_Roadmap_v1_89_C4_Starter_Classes_20260923.md).
The separate newer humanoid/quadruped animation and
model-production roadmap remains authoritative for art/rigs.

## C4 progression contract

1. Choose an original, currently implemented C4 race.
   The original five-race source list and all **18** first
   transfers are catalogued, but only Human/Elf are
   currently playable; do not prematurely enable
   Dark Elf, Orc or Dwarf.
2. Begin as the race's **Fighter or Mystic** where
   historically supported. `Mage` remains a temporary
   internal compatibility family ID for Mystic;
   new Ranger/Rogue starter creation is prohibited.
   Dwarf has Fighter only.
3. At **level 18**, explicitly select one exact,
   race/family-appropriate original first-transfer
   branch. Store that choice on the character.
   A chosen branch is **not** a granted class.
4. Start and complete its real original branch-specific
   advancement quest, including actual objective
   evidence and skill proficiency requirements.
   Only after that quest and **level 20** may the
   server atomically grant the selected original
   first-transfer class and make its skill tree
   visible/teachable.
5. Maintain the original level-40 second and
   level-76 third transfer trees with distinct
   class quests, rank prerequisites and persistent
   advancement history; never auto-map a comparable
   custom DungeonMMO role into an original C4 class.

## Completed and actually verified in v1.90

- [x] Added real Base server-authoritative
  `C4FirstTransferSelectionService`. It uses the
  original 18-path source registry but permits only
  the currently playable character's actual race
  and original Fighter/Mystic family options.
  At source level 18, one explicit choice is saved
  in `ClassAdvancement.OriginalFirstTransferChoiceId`.
  The server refuses out-of-race/family, forged,
  underlevel and previously chosen new paths.
  The choice alone grants **no class/quest/reward**.
- [x] Added closable original class-choice GUI using
  the existing profile-ready Base advancement
  request/result/snapshot channel. It shows the
  original source class and individual quest name,
  actual chosen path and accurate not-yet-available
  quest status. The GUI reopens through its
  class-path button and does not permanently keep
  another large window open.
- [x] Old one-candidate `SecondaryClassDefinitions`
  trials are no longer offered or startable for
  a fresh Fighter/Mystic. The old
  `ClassAdvancementService` retains accepted
  already-started quest **claim** functionality
  and saved historical completed custom classes,
  without letting new C4 starters farm an
  unearned Vanguard/Arcanist/Thornwarden
  advancement via the generic dungeon quest.
- [x] Old Ranger/Rogue specialist profiles,
  earned skill/proficiency, equipment,
  level/XP/gold, quests and profession slots
  remain loadable for explicit later migration;
  no automatic C4 class is assigned from their
  old role name. Existing old active/completed
  class histories block destructive new-path
  choice until migration is specifically defined.
- [x] Saved original source choice is sanitized
  during existing profile migration only when
  it still matches the selected original
  race and Fighter/Mystic starting family.
  Development-only race change now fails closed
  once an original race-bound source path has
  been chosen, including inside its
  authoritative mutation. Old characters
  with no original choice retain previous
  approved race-change behavior.
- [x] Focused unpublished Studio tests:
  **5/5 PASS**, including 46 explicit
  choice/reload/race-safety checks,
  40 updated old-trial/grandfathered-claim
  tests, 144 original branch registry,
  14 original path rules, and 7
  strict source coverage assertions.
  Luau parser PASS, disposable Base and
  Dungeon Rojo builds PASS.
- [x] Actual **two-client unpublished Base
  playtest PASS**: two genuine Human
  Fighter clients reached test-seeded
  level 18, saw the original choice
  panel and race-specific card,
  independently chose **Human Rogue**
  and **Human Knight** through normal
  client remotes; server persisted both
  separately without awarding either
  a level-20 class or the old trial.
  A forged second class choice and
  old automatic Vanguard request were
  refused. This verified visible GUI
  and genuine client remotes, not
  an actual manual mouse-click on the
  GUI card or a completed quest run.
  [Read v1.90 actual test evidence](
../testing/c4-explicit-first-transfer-choice-v1-90-20260923.md).
- [x] All game-code, test and roadmap edits
  performed directly via GitHub; desktop
  was used only for clean pull,
  disposable builds and unpublished
  Studio tests. No `main` merge,
  Roblox publishing, production
  DataStore mutation or destructive
  local operation.

## What is still REQUIRED before original class transfers are playable

- [ ] **Historically accurate original C4 class quests.**
  For every original branch, research and
  register its own objectives from original
  C4 references; do not simply rename
  the old generic Temple-clear
  Fighter/Mage trial. A quest may
  start at level 18, but character
  class transfer must remain locked
  until 20. Record original skill-rank
  and proficiency conditions and
  specific objective/quest proof.
- [ ] **Atomic original class award and skill gate.**
  Advance only to the already selected
  original branch when its real
  quest is ready and actual level,
  race/family and prior-skill
  prerequisites still hold inside
  the profile mutation. Prevent
  double claiming, another race's
  quests and incompatible branch
  skill inheritance. Integrate
  the resulting ClassId/advancement
  state with trainer, combat,
  equipment, dungeon and HUD.
- [ ] **Explicit legacy class migration.**
  Define a versioned opt-in conversion
  for old Ranger/Rogue and old
  custom advanced profiles. Preserve
  their inventory, gold, XP,
  paid professions, quests and
  relevant archived skill mastery.
  Do not silently grant an original
  class they did not choose or
  a quest they did not complete.
  Preserve previously completed
  legacy trial claims without
  allowing fresh generic ones.
- [ ] **Other original race/class branches.**
  Current subset source-rank parity
  **396/396** describes only four
  mapped Human/Elf starter
  inventories plus Human Rogue
  and Elven Scout. It is not
  the entire C4 catalogue.
  Implement the other seven Human/Elf
  first-transfer original class
  inventories and all nine
  Dark Elf/Orc/Dwarf class trees,
  quests, racial creation data,
  trainers, and genuine source
  effects before enabling those races.
- [ ] **Original level-40/76 class trees and
  quests** after the first-transfer
  class/quest authority is working.
  Keep each distinct branch and
  its correct skill/level/proficiency
  prerequisites.
- [ ] Focused live two-client acceptance
  after actual quests are built:
  independent branch objectives and
  completion, actual awarded classes
  and class-specific skill differences
  after save/rejoin. Add a manual
  GUI mouse-click presentation
  test separately if needed.
- [ ] Preserve the agreed DungeonMMO
  one-Gathering-plus-one-Crafting
  profession restriction through
  every class advancement;
  do not invent extra class-linked
  crafting professions. Preserve
  previously tested aggro, party
  difficulty, dungeon reward and
  market systems. Keep the separate
  animation/rig roadmap unchanged.

## Current honest gate

Playable fresh starters: Human/Elf Fighter/Mystic only.
Original first-transfer branches in source: **18**.
Original paths with source skills partially mapped: **2**.
Original level-20 quests and class awards complete: **0/18**.
Original class selection at level 18: **implemented and tested**.
Existing old custom class histories: **preserved**.
Full original C4 class progression and catalogue: **INCOMPLETE**.


## Final v1.90 QA closeout after interrupted response

The interrupted focused Studio attempt exposed an
incorrect historical advanced-class test fixture.
It was corrected and the affected tests were
re-executed from a clean local fast-forward pull.
**Final targeted Studio result: 8/8 PASS, zero
failures**, covering the five initial source/
choice/legacy fixtures plus existing quest
advancement migration, race-change migration
and actual race-change service regression tests.
A further genuine **one-client Base playtest PASS**
confirmed the real Human Fighter choice window
shows Warrior, Knight and Rogue, refuses a
cross-race Elven Scout request, persists a
client-requested Human Rogue choice and updates
the actual visible choice/status UI without
awarding any class. This adds to, rather than
replaces, the previously passing **two-client
independent Rogue/Human Knight** playtest.
See the appended final acceptance evidence in
[the v1.90 testing record](
../testing/c4-explicit-first-transfer-choice-v1-90-20260923.md).

The roadmap's original 5/5 report remains an
earlier acceptance snapshot; **8/8 is the final
expanded closeout result**. All original
branch-specific level-18 quests, their
level-20 atomic class awards and the
versioned opt-in legacy-class conversion
remain pending. Do not mark any of the
18 original first-transfer paths complete
merely because a player can save a choice.
