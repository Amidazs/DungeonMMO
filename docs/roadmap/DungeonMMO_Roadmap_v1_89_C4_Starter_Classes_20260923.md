# DungeonMMO backend roadmap v1.89 — original C4 starter classes

Decision confirmed 23 September 2026:
DungeonMMO will follow the **Lineage 2 Chronicle 4
starter-class model as well as its later advancement
paths**.

Fresh characters do **not** begin as Ranger, Rogue,
Knight, Cleric or other specialist roles. They begin
in their race's original starting family:

- Fighter
- Mystic

The existing internal ID `Mage` remains a temporary
compatibility key for the Mystic family until the
class/profile migration is completed. Player-facing
design should use **Mystic**, matching the C4 structure.

This supplements [v1.88 original C4 class structure](
DungeonMMO_Roadmap_v1_88_Original_C4_Class_Structure_20260923.md)
and supersedes any older roadmap text that treats
Ranger or Rogue as valid **fresh starter classes**.

## Target original progression

For every supported C4 race:

1. Character creation chooses **race**.
2. Character creation chooses that race's original
   **Fighter or Mystic** starting family where the
   source race supports both.
3. The character levels the starting class and
   purchases/uses its original skills.
4. At the original class-transfer stage, the
   character explicitly chooses one of the valid
   race/family branches and completes that branch's
   required advancement quest.
5. Later class transfers continue down the exact
   original C4 branch tree rather than swapping
   into custom DungeonMMO role classes.

Dwarf remains an original Fighter-only starting
race; its source tree must not manufacture a
Mystic starter. Other source races keep their
actual original starting families.

## Already enforced and tested

- [x] Fresh identity selection accepts only internal
  `Fighter` or `Mage` (player-facing **Mystic**).
  Fresh Ranger and Rogue selections are rejected with
  `OriginalC4StartingClassRequired`.
- [x] Existing Human/Elf character creation UI already
  presents **Fighter** and **Mystic** only. Ranger and
  Rogue definitions remain loadable for legacy saves
  and backend migration work, but are not offered to
  new characters.
- [x] The source class validator from v1.88 requires
  an original starting family before any first-transfer
  branch is selectable. A legacy Ranger/Rogue identity
  cannot use that shortcut to claim an original branch.
- [x] Focused unpublished Studio acceptance:
  **3/3 identity suites PASS**:
  - IdentityServiceTest: **58 assertions**
  - MageIdentityServiceTest: **26 assertions**
  - C4 starter identity replacement for the obsolete
    fresh Ranger test: **26 assertions**
  This verifies both currently playable races can start
  Fighter/Mystic, while fresh Ranger/Rogue attempts
  remain non-mutating refusals.
- [x] Base Rojo composition rebuilt successfully after
  the focused identity test changes.
- [x] Source/document edits were committed through
  GitHub; desktop access was used only for clean pull,
  disposable build and unpublished Studio execution.

## Migration rules for existing saves

- [ ] Do **not** delete or reset existing characters
  whose current persisted BaseClassId/ClassId is
  Ranger or Rogue. These are legacy DungeonMMO
  specialist identities and may contain earned skill
  ranks, proficiencies, equipment, loadouts,
  professions, quest state and market/economy history.
- [ ] Add an explicit versioned class-identity
  migration that maps legacy specialist history into
  the new original C4 lineage without gifting an
  unearned class transfer.
- [ ] Preserve earned skill/proficiency history for
  reuse only when the eventual target original branch
  legitimately owns the equivalent skill. Archive or
  disable incompatible skills rather than silently
  granting them to a different C4 class.
- [ ] Preserve the character's one gathering and one
  crafting profession exactly through class migration.
- [ ] Preserve race, inventory, gold, dungeon unlocks,
  marketplace history and other non-class progression.
- [ ] Require the original branch quest before the
  migrated character becomes officially marked as the
  corresponding C4 first-transfer class, unless a
  carefully defined legacy grandfathering rule is
  explicitly approved later.

## Next backend work

- [ ] Replace the generic automatic one-candidate
  `SecondaryClassDefinitions.resolve` advancement
  flow with an **explicit original C4 branch choice**
  from the current Fighter/Mystic family.
- [ ] Introduce persisted server-owned
  `SelectedFirstTransferClassId` (or equivalent)
  only after the player makes a valid choice; never
  infer it from role.
- [ ] Implement individual branch advancement quests
  rather than using the generic Fighter/Mage dungeon
  clear trial as proof of an authentic C4 transfer.
- [ ] Implement Human/Elf first-transfer branches first
  while retaining all 18 five-race source branches in
  the catalogue.
- [ ] Add Dark Elf, Orc and Dwarf character creation
  only after race definitions, starting-class skills,
  equipment and profile migration are complete.
- [ ] Continue later level-40 and level-76 advancement
  work using the same exact-original-tree rule.

## Current truth

Fresh playable characters: **Human/Elf only**.
Fresh starter families: **Fighter or Mystic only**.
Fresh Ranger/Rogue creation: **disabled**.
Original first-transfer branches catalogued: **18**.
Original first-transfer branches fully playable: **0/18**.
Legacy specialist profiles: **preserved for migration**.
Full original C4 race/class progression: **INCOMPLETE**.

The one-Gathering-plus-one-Crafting profession rule,
no-publish policy and separate humanoid/quadruped
animation roadmap remain unchanged.
