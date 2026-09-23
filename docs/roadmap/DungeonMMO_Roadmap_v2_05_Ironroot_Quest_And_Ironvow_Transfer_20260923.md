# DungeonMMO backend roadmap v2.05 — Ironroot original Warrior progression

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.04 expanded Scout combat and Warrior foundation](
DungeonMMO_Roadmap_v2_04_Expanded_Combat_Ironvow_Foundation_20260923.md).
[Actual v2.05 tests and explicit limitations](
../testing/ironvow-quest-world-class-v2-05-20260923.md).
The separate humanoid/quadruped animation roadmaps remain current.

## Completed this increment

- [x] Author an independent **Human Warrior → Ironvow** six-stage
  Ironroot Oath quest, distinct from the existing Human Rogue
  and Elven Scout sources. Start level 18, transfer level 20.
  Ordered physical hub actor stages use separate **Marshal Torren**
  and **Smith Orla**. Four unique real Ridge Marauder deaths
  give owner-bound dispatch markers; one real Ridgebreaker
  gives its unique owner-bound Oath Seal. Explicit personal
  proof, monster life deduplication, inventory ownership,
  stage-four and stage-six turn-in and saved receipts are
  verified by existing server profile and dungeon services.
- [x] Add the correct branch/race progression requirements,
  physical original source NPC prompts, actual instanced quest
  enemy pack selection and unique final boss registration.
  Fix the undefined final-spawn count selector and prevent
  the unrelated Elven Scout rescue actor from intercepting
  the Warrior's stage-five monster authority.
- [x] Register a genuinely **server-authorized** new
  original first-transfer `Ironvow` identity, physical
  Marshal Torren class-award prompt and separate
  `IronvowTrainer`. A claimed class requires the exact
  personally ready quest, level 20, original Human
  Fighter choice, server-only one-use mentor evidence,
  correct saved receipt and no previous transfer.
  The player cannot create an Ironvow fresh, copy an
  old Vanguard class, forge its raw ID or learn its
  abilities merely by selecting the source branch.
- [x] Keep the first **15 authored Ironvow ranks** across
  Driving Strike (9), Blade Training (3) and Battle
  Call (3). Only actual implemented original skills
  appear at the matching advanced trainer. The
  existing source inventory's **62 recorded ranks**
  through the intended level-30 cap are **not**
  complete or certified for this new class.
- [x] Temporary local Base and Dungeon builds passed.
  Isolated Base tests passed: **31** ordered source
  quest/owned loot/save assertions; **17** mentor
  award/legitimate skill-purchase/fresh-save assertions;
  **34** first-skill foundation and forged-class
  assertions. Dedicated physical enemy registration
  test passed **11** assertions.
- [x] Genuine unpublished **two-client instanced Dungeon**
  run passed: independent Human Warrior players each
  performed a real client normal-attack hit on their
  own stage-three raider or stage-five boss; the test
  then used server-authored finishing hits to verify
  real lethal callbacks grant only that character's
  personal marker or Oath Seal. This is accepted
  *owner-only dungeon hit and loot behavior*,
  not an unassisted full quest journey.
- [x] Existing two-original-class skill/award regression
  **2/2 PASS (459 + 8 assertions)**, and updated
  level-30 source-rank audit **25 assertions PASS**.

## Remaining before Ironvow is accepted as an initial-playable class

1. A genuine player-controlled *Base* playtest holding
   original Marshal Torren and Smith Orla NPC prompts,
   first-return four-marker and final Oath Seal turn-ins,
   own level-20 physical class mentor and visible
   trainer interface, then actual client skill purchase.
   A proposed long test-runner creation did not
   complete; do not claim those physical UI/prompt
   acceptance steps already passed.
2. Continue the full source-level skill inventory,
   not just the currently authored 15 ranks:
   implement separately authored usable sword/blunt,
   polearm group combat, critical stance, light and
   heavy armour, health training, restorative buffs,
   control, equipment and general utilities at
   exactly the level-20, 24 and 28 ranks available
   through the launch cap. Preserve distinct
   legitimate equipped weapon/armour effects and
   one-gathering/one-crafting profession constraints.
3. Real first-rank and highest-rank client-controlled
   Ironvow combat, server calculation for heavy
   armour and all weapon styles, class-only threat,
   SP/prerequisite/mastery purchases, persisted
   skill ranks and save/reconnect. Test wrong
   race/branch, no proof, wrong trainer and
   out-of-range client requests.
4. An uninterrupted real Base → instanced Dungeon →
   Base two-place journey, all four client-controlled
   qualifying raider kills, personally owned quest
   returns, genuinely client-controlled boss kill,
   class transfer, actual trainer purchase and
   profile lease/save/rejoin. Current isolated
   tests seed parts of the previous sequence.
   Publication or production DataStore use
   requires the user's separate explicit approval.

## Remaining classes through the initial level-30 cap

- Next **Human Knight**: source 20/24/28 inventory is
  tracked, but an independently authored class,
  physical quest/mentor, taunt/shield mechanics,
  complete skill ranks and live acceptance do not
  yet exist.
- Next Human Wizard/Cleric, Elf Knight/Wizard/Oracle,
  Dark Elf, Orc and Dwarf first-transfer careers,
  preserving the existing five-race original
  18-branch structure and starter Fighter/Mage
  progression. Audit each historical C4-through-30
  unlock against a separately authored DungeonMMO
  skill with genuine gameplay behaviour. Do not
  substitute a legacy specialist or invented
  rank-count target for an actual reviewed branch.
- Release readiness: a migration-safe server
  level-30 cap that retains prior above-cap
  profiles, completed each advertised starter
  1–19 / first-transfer 20–30 skill tree, live
  combat/equipment/quest/loot and UI validation,
  plus safe cross-place persistence. Above-cap
  training and later class advancements remain
  future updates after the initial level-30 target.

## Accurate progress measurements

- Original source first-transfer branches in registry: **18**.
- Branches with an original class-award backend plus source
  quest/real Dungeon and physical actor bindings: **3/18**
  (Ashenblade, Greenward Scout, Ironvow).
- Branches with fully accepted genuine physical mentor/trainer
  client playtests: **2/18**; Ironvow's separate Base
  client-prompt acceptance is still open.
- Historical first-transfer 20/24/28 source inventories
  recorded through cap: **4/18** (the two Scouts,
  Human Warrior and Human Knight). The source
  counts need ongoing independent reference checking.
- Complete launch level-1→30 historically reconciled,
  actual effect-tested class catalogues: **0/18**.
  The existing 59/77 first-transfer recorded Scout
  rank mappings do not prove all starter/general
  1–19 and every passive/utility effect.
- A server-enforced production level-30 cap is
  **not** yet in place; it is a future migration-
  safe initial-release step.

Preserve hub/instanced dungeons, all-party difficulty
gating, nearest-before-damage/highest-threat aggro
with genuine taunt, animal-only skinning, one
gathering plus one crafting profession per character,
trading, independently authored art/quest text and
separate character/quadruped animation roadmaps.

Permanent code and document edits must remain
in GitHub. Use the desktop only for source pulls,
unpublished temporary builds and live Studio testing.
No Roblox publication or `main` merge without
explicit user approval.
