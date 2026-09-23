# DungeonMMO backend roadmap v2.04 — expanded live combat / Warrior foundation

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.03 level-30 class skill-rank mapping](
DungeonMMO_Roadmap_v2_03_Level_30_First_Transfer_Rank_Coverage_20260923.md).
[Actual unpublished Studio evidence](
../testing/original-first-transfer-expanded-combat-and-ironvow-v2-04-20260923.md).
The separate humanoid and quadruped animation roadmaps remain current.

## Accepted this increment

- [x] One complete actual unpublished **two-client Dungeon**
  session passed newly added rank-nine Wayfinder dagger and
  bow impacts on a genuine instanced first-room enemy.
  Verified authoritative Humanoid health loss, active
  ability cooldown and generated enemy threat.
- [x] A genuinely client-triggered purchased Wayfinder
  Wound applied server-owned damage-over-time ticks
  after an actual damaging dagger hit. A purchased
  Greenward Calming Arrow hit an engaged enemy and
  reduced its caster's actual post-hit server threat.
  Exact strength versus all damage/aggro modifiers
  remains a separate balance test.
- [x] Begin independently authored Human Warrior
  (**Ironvow**) **backend foundation**, not a playable
  new class. Registered a non-creatable Human Fighter
  first-transfer class definition, nine individually
  ranked sword hits, three sword mastery passives
  and three temporary self-buff ranks at 20/24/28.
  Real combat definitions and purchased-passive runtime
  multiplier are connected, but unearned original
  class/skill claims grant no ability or passive bonus.
- [x] Disposable Base and Dungeon Rojo builds passed.
  Original Ironvow foundation Studio **33 assertions
  PASS**, including forged class ID/skill/passive denial.
  The actual live expanded combat script passed all
  four new effect checks in one two-client run.
- [x] Permanent changes made directly on the shared
  GitHub development branch. No local source edits,
  Roblox publication, `main` merge or production
  DataStore changes.

## Exact status — do not treat preparation as playability

Ashenblade and Greenward Scout remain **2/18** physical
and authentic original first-transfer class awards.
Their recorded first-transfer level-20/24/28 rank
schedules remain mapped (59 Human, 77 Elf according to
the repository's historical inventories). This does
not certify every passive, utility or rank's actual
live gameplay effect. Their newly added four combat
effects now have real two-client acceptance.
**Ironvow is an unearnable authored skill foundation**:
not a third actual class award, not a completed
Human Warrior quest or a 62-rank accepted catalogue.
The original first-transfer definitions deliberately
omit HumanWarrior until actual independent quest
proofs, server mentor and safe profile award exist.
The planned release cap remains 30; server-wide XP
progression is not yet capped in production.

## Next implementation sequence

1. Create independently authored **Human Warrior
   level-18 source quest** with genuine separate
   NPC dialogue/actions, personal physical monster
   proofs, branch-specific loot and ordered replay
   protection; use the existing authenticated
   first-transfer quest and profile transaction
   infrastructure. World actors/dungeon monster
   bindings must be real before enabling its
   quest choice. Do not recycle the Human Rogue
   source NPCs as a substitute.
2. Add **Ironvow** to the original earned-class
   registry and physically distinct level-20 mentor
   *only after* the real Human Warrior quest
   evidence is available. Verify wrong race,
   wrong branch, premature level, incomplete
   proofs, remote spoofing, single-use receipts,
   exclusive profile handoff and save/rejoin.
   Add a separate physical trainer and test
   genuine client purchases and rank-specific
   combat on a real instanced monster.
3. Complete the remaining recorded C4-through-30
   Human Warrior source families, including
   sword/blunt, polearm, body armour, survivability,
   control and general skills. Make every rank
   have a true implemented gameplay effect and
   verified purchase/prerequisite gate; do not
   assign a polearm icon to a sword executor
   and claim working polearm mechanics.
4. In parallel, individually test the existing
   Scouts' light-armour, passive critical/recovery,
   evasion, movement, lock/crafting and distinct
   level-20/24/28 rank effects through real
   character gameplay. Audit starter-level
   1–19 rank inventories; the recorded C4
   first-transfer row counts alone cannot
   establish a complete level-1→30 skill catalogue.
5. Continue original Human Knight, Human Wizard/
   Cleric and the other race branches after
   Warrior identity, quest and class gameplay
   have genuine acceptance. Implement a
   migration-safe level-30 server cap only
   when initial release progression is ready;
   preserve existing above-cap data and
   defer production cross-place publication
   until explicit approval.

Preserve one gathering and one crafting
profession per character, all-party difficulty
unlock checks, closest-before-damage/highest-
threat aggro with taunt, animal-only skinning,
player trading, hubs plus instanced dungeons,
and original NPC/monster/quest presentation.
All permanent code/docs through GitHub, not
Remote Desktop Commander.
