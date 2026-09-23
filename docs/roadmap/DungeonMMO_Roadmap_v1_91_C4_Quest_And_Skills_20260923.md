# DungeonMMO backend roadmap v1.91 — original C4 QUESTS AND SKILLS

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Authoritative player decision

Follow **original Lineage 2 Chronicle 4 class starting families,
original distinct first/second/third transfer branches and their
historical skill progression**, adapted to DungeonMMO's agreed
hub-and-instanced-dungeon world. Fresh characters begin as
Fighter or Mystic (temporary internal ID: `Mage`).
They select one original race/family branch and must complete
that branch's genuine quest before receiving its class-specific
abilities. Original C4 has five race families and 18 first transfers.
The original Fighter-only Dwarf starter must not acquire an invented
Mystic choice.

This supersedes v1.90 for **current C4 quest/skill engineering**;
[v1.90 explicit first-transfer choice](
DungeonMMO_Roadmap_v1_90_C4_Explicit_First_Transfer_Choice_20260923.md)
still records its final **8/8 focused regression and actual
one-/two-client selection playtests**. The separate newer
humanoid/quadruped art, rigging and animation roadmap
remains authoritative for models and animation.

## Important correction: the skills are NOT all finished

The historical **396/396** tally covers just six previously
inventoried *DungeonMMO functional analogue* lists:
four supported Human/Elf starting classes (168),
Human Rogue (99) and Elven Scout (129).
It **does not certify** exact original C4 skill-rank parity
even for those six inventories, and it does not cover
all other original first/second/third class trees.
The game has two partly implemented first-transfer
analogue skill lists, but their authentic class
transfer, trainers, branch identity and quests
are still pending. No original first-transfer
class is currently fully playable.

## v1.91 genuinely implemented and tested

- [x] Researched and registered separate *ordered* original
  source quest blueprints for Human Rogue (quest 403:
  Bezique, Neti, ten bones using original trial weapons,
  four distinct stolen items and Ramos) and Elven Scout
  (quest 407: Reisa, Moretti, four different letter
  fragments, Prias, Sentry key, Moretti, Rains).
  These are not a renamed generic dungeon-clear quest.
- [x] Added original source quest proof rules enforcing NPC
  order, real unique server-event IDs, verified original
  quest weapon, distinct quest drops/key and no replay.
  Quest stage readiness never automatically awards a
  new class, skill rank or item.
- [x] Added server-authoritative Base original quest
  service with real profile mutation, read-only
  stage snapshot and distinct world-binding
  authorization. It **fails closed** when live
  physical NPC, monster, quest-item and combat
  proof bindings are unavailable. The current
  world does not have those original C4
  actor/item bindings, so **these class quests are
  NOT currently playable**. Simulated world evidence
  is used only inside a checked-in Studio test.
- [x] Persist the source-matched stage/proof ledger
  through existing profile migration, preserving
  original race, class, skill history and profession
  slots and refusing a foreign branch/quest.
- [x] Added `C4OriginalClassSkillCoverage` across all
  eighteen source first-transfer classes. Only
  Human Rogue and Elven Scout have completed
  DungeonMMO **analogue** inventories; sixteen
  other *full original class inventories*
  remain unmapped and unimplemented.
- [x] Began **actual C4-source rank enumeration** for the
  next two Human Fighter paths: exactly **12 original
  Warrior level-20 entries** and **16 original Human
  Knight level-20 entries** (28 source records).
  These include distinct weapon/armor mastery
  ranks, active attacks, buffs and passives
  taken from their original C4 class lists.
  `DungeonSkillId=nil` and
  `GameplayStatus="NotImplemented"` deliberately
  forbid counting documented skill names as
  learned, functional DungeonMMO abilities.
  The full subsequent rank brackets,
  class-bound training and actual effects
  remain future work.
- [x] Updated original class-choice server snapshot
  and closable GUI to show researched quest data,
  pending live quest world, mapped DungeonMMO
  analogues, separate sourced Warrior/Knight
  rank entries and each class's still-unimplemented
  original skill inventory accurately.
- [x] Unpublished focused Studio acceptance
  **5/5 PASS**, including **117 new original
  quest and skills assertions**, real class-choice
  persistence and original profile migration
  regressions. Verified that simply choosing
  Human Rogue or Elven Scout, or finishing a
  simulated source quest, **does not let a
  Fighter buy first-transfer Scout skills**.
  Changed Luau parses and Base/Dungeon
  disposable Rojo builds PASS.
  [v1.91 actual test record](
../testing/c4-original-quest-skill-scope-v1-91-20260923.md).
- [x] GitHub-only changes to code, tests and documents.
  Preserved local unrelated untracked quadruped
  Python cache without resetting/overwriting it.
  No `main` merge, Roblox publishing,
  production DataStore writes, local project
  source edits or paid actions.

Original C4 source references:
- [Rogue quest 403](https://l2hub.info/c4/quests/403-path-to-a-rogue)
- [Elven Scout quest 407](https://l2hub.info/c4/quests/407-path-to-an-elven-scout)
- [Human Warrior C4 skill ranks](https://l2hub.info/c4/classes/warrior)
- [Human Knight C4 skill ranks](https://l2hub.info/c4/classes/knight)

## Next implementation — quests and skills must advance together

- [ ] **Real in-world class-quest actors and proof** for
  Human Rogue and Elven Scout: Base hub NPC
  conversation prompts, secure dungeon/quest
  instance skeleton/Ol Mahum and bandit battles,
  real Neti trial weapon equipment and quest-only
  four distinct stolen items/letter fragments,
  sentry key and Prias rescue. NPCs, monster
  kills and item drops must call
  `C4OriginalFirstTransferQuestService`
  exclusively from authenticated server
  interactions. The current test-only mock
  world must never be used in production.
  Preserve hub-and-instanced-dungeon structure
  rather than introducing unwanted open world.
- [ ] **Atomic original level-20 class award and
  trainer skill authorization.** After completed
  genuine chosen quest, level-20 threshold
  and correct original transfer NPC, the
  server must revalidate original race/family,
  exact choice, valid quest receipt, previous
  skill/rank/proficiency requirements and
  existing legacy advancement history
  inside ONE exclusive profile mutation.
  Mark the original branch awarded,
  expose only its actual skill catalogue
  and prevent replay/cross-race/cross-class
  skill inheritance. Current Ranger/Rogue
  analogue skill definitions must not be
  offered to every unadvanced Fighter.
- [ ] **C4 original skill work is a first-class,
  parallel backend deliverable.** Complete
  Warrior and Human Knight source rank
  inventories after level 20, then implement
  each rank in the existing authoritative
  combat/equipment/party/profession systems
  with real effects, original class/weapon
  restrictions and proper proficiency/rank
  progression. Verify each class separately
  in an actual Studio server fixture.
  Source-audit existing Rogue/Elven Scout
  **analogue** lists against C4 skill pages,
  replacing incorrect names, ranks or
  weapon effects before certifying
  original C4 parity. Then enumerate and
  implement the other fourteen full
  not-yet-inventoried class source lists.
- [ ] Support exact original Mystic family
  alternatives (Human Wizard/Cleric,
  Elven Wizard/Oracle) and eventually
  Dark Elf, Orc and Dwarf as independent
  original race/class lineages. Keep all
  18 original first-transfer choices
  distinct; the current 28 source rank
  entries are just the *level-20 start*
  of two classes, not their full trees.
- [ ] Implement the authentic level-40
  and level-76 original C4 advancement
  branch trees, quest mastery and
  their actual class-specific skills
  only after the corresponding earlier
  branch has genuinely been earned.
- [ ] Preserve previously accepted
  paid profession policy: **exactly
  one Gathering + one Crafting**
  slot per character, with cross-career
  material trading. A class skill
  must not quietly grant another
  profession or delete earned profile
  inventory, gold, race, level or
  skill proficiency during migration.
- [ ] Preserve older legacy Ranger/Rogue
  profiles and completed custom class
  trials until a versioned, tested
  explicit conversion is approved.
  Do not reset, auto-assign an
  original advanced class or assume
  old rank analogues satisfy a
  never-completed C4 branch quest.
- [ ] Test actual client-to-server
  progression after real quest
  world actors exist: start through
  real hub NPC, both different
  client quest branches, independent
  instance drops, source trainer
  award, real skill unlock,
  save/rejoin, anti-replay and
  wrong-race/legacy denial.
  Existing v1.90 client class-choice
  test does NOT prove these later
  gameplay actions.

## Honest current backend gate

- Fresh starter model and level-18 original
  first-transfer choice: **implemented,
  previously tested with actual clients**.
- Original C4 class quests: **two
  source-authored and backend-tested,
  neither currently playable in a
  real world/quest instance**.
- Previously mapped functional analogue
  ranks: **396 across six lists**,
  NOT a complete original C4 catalogue.
- Newly documented original C4
  first-transfer source ranks: **28
  level-20 entries across Warrior/Knight,
  0/28 newly implemented skills**.
- Original first-transfer classes
  fully playable with class-specific
  authentic quests and skills:
  **0/18**. Entire C4 class
  progression still **INCOMPLETE**.
