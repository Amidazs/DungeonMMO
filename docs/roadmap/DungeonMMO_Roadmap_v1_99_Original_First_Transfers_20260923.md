# DungeonMMO backend roadmap v1.99 — original first-transfer awards

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues: [v1.98 Scout Cael source quest](
DungeonMMO_Roadmap_v1_98_Scout_Cael_Warden_Source_20260923.md).
Executed evidence: [v1.99 first-transfer test record](
../testing/c4-original-first-transfer-v1-99-20260923.md).
The independently updated quadruped/humanoid animation roadmaps
remain separate and must not be superseded by this class roadmap.

## What is committed and proven

- [x] Both **source quests** can reach `Ready`, as documented
  in v1.98. Their actual playable world actions were accepted in
  separate unpublished Studio sessions, not a real continuous
  cross-place quest journey.
- [x] Register first new, independently named DungeonMMO
  class identities **Ashenblade** (Human Rogue source branch)
  and **Greenward Scout** (Elven Scout source branch). Their
  persistent current `ClassId` is distinct from the old
  legacy `Rogue`, `Ranger` and secondary specialist IDs;
  their original saved starting family stays `Fighter`.
  These are the first two of the planned 18 first transfers.
- [x] Create real physical **Marshal Briar** and
  **Pathwarden Siora** class-award prompts in Base, with a
  **separate** physical advanced trainer station per class.
  Accepted actual client-held mentor interactions require
  source quest readiness, matching saved race/Fighter choice
  and completed personal proofs, level 20, living proximity,
  current single-use server-minted mentor receipt and no
  already earned or legacy secondary class. All required
  persistent class state is awarded together in one
  exclusive profile mutation; repeat or other-race prompts
  cannot award a different class.
- [x] Versioned schema **v15** accepts and preserves valid
  earned first-transfer identities/mentor receipts through
  profile save/reload without changing old quest and item
  storage keys or importing legacy specialist class aliases.
  Rejects a raw new ClassId unsupported by its earned
  branch, complete source proof and stored mentor receipt.
- [x] Preserve the normal starter/Fighter training path.
  First-transfer trainers currently offer only one
  *already implemented* original DungeonMMO analogue skill
  per class: Ashenblade's **Human Scout Sprint** and
  Greenward Scout's **Elven Scout Guard**. Class, race,
  level, purchased SP, earned mentor receipt and actual
  trainer proximity are checked by authoritative services.
  Completing the quest or selecting a class grants no
  unearned skill and cannot reveal skills from a
  legacy Ranger/Rogue specialist catalogue.
- [x] Actual disposable Rojo Base/Dungeon builds PASS.
  Focused server first-transfer suite **2/2 PASS**
  (47 award/persistence assertions plus 8 adjacent
  quest/advancement migration assertions).
- [x] Actual unpublished **two-client Base physical mentor**
  playtest PASS following correction of a visible prompt
  conflict: both real clients separately reached their
  own original named mentor; premature and wrong-race
  interactions were denied; eligible level-20 physical
  interactions granted exactly one saved original class;
  the respective separate advanced trainer allowed a
  real server-side skill purchase without cross-owner
  leakage. The focused test seeded completed earlier
  source quests **only in its disposable test place**.
- [x] All permanent scripts, tests and docs changed in
  GitHub on the existing development branch. No
  production publish, `main` merge, direct production
  DataStore edit or editing via Desktop Commander.

## What remains before a production-ready first-transfer phase

1. **Real uninterrupted route acceptance:** Begin each
   original source quest in the actual Base, clear ten/four
   separate appropriately owned kills using player input,
   complete the independently authored late challenge,
   actually return across Roblox places to Base, turn in
   all personally earned materials, level to 20, interact
   with correct real transfer mentor, then save/rejoin
   with the exact class and trained abilities. Current
   live combat, final NPC and first-transfer tests
   exercise *separate* disposable sessions and use
   test-only source stage/item preparation for isolated
   acceptance. Production cross-place teleport cannot
   be claimed from local unpublished Studio routing.
   Wait for explicit publication approval.
2. **More initial class skills:** Expand original
   DungeonMMO class-specific level-20 and higher
   trainer catalogues for Ashenblade/Greenward Scout
   based on the Fighter starter, with each ability's
   actual combat/heal/passive effect, prerequisite
   skills/rank/proficiency, minimum character level,
   race and unique class, visibility and saved purchase
   all demonstrated. One currently trainable ability
   per class is not the complete first-transfer skill
   catalogue; do not map all older legacy Rogue/Ranger
   abilities wholesale to the new classes.
3. **Trainer live handshake/robust saves:** Run a
   genuine client `ProgressionTrainerPrompt` →
   `TrainerSnapshotRequest` → purchased skill
   `SkillLearnRequest` test at the separate station,
   including remote attempts from outside range,
   wrong-race players, insufficient SP, fake saved
   class IDs, concurrent requests and restart.
   Check class-award/save failure recovery and
   handoff-lease retry. Focused live v1.99 checked
   physical trainer proximity and actual server
   skill purchase, not the entire trainer UI path.
4. **Other first-transfer classes:** Original,
   independently named Human/Elf Fighter and Mystic
   branches beyond the two accepted source quests,
   remaining races/starters, level-20 trainers and
   complete first-transfer skill inventories
   are separate work, followed by second/third
   transfer quests. Never mark existing legacy
   secondary specialists as substitutes.
5. **Original art/narrative:** Distinct mentor,
   class, monster and item silhouettes, 3D models,
   animations, UI and authored text are still
   pending. Separate original gameplay expression
   and independently authored quests are required;
   renaming third-party content alone does not
   guarantee copyright safety.

## Exact status

**2/18** first-transfer class identities now have
server-authenticated physical level-20 awards and
**one implemented trainable skill each**.
**0/18** original first-transfer class catalogues
are confirmed feature-complete or accepted through
an uninterrupted real cross-place client journey.
Do not treat those two measurements as interchangeable.

Retain hub-based instanced dungeons, all-member
difficulty gating, closest-before-damage/highest
threat combat aggro, animal-only skinning, one
gathering plus one crafting profession per
character, player trading and separate active
humanoid/quadruped animation roadmaps.
