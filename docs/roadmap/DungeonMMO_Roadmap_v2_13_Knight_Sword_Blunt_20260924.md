# DungeonMMO class backend v2.13 — Knight sword AND blunt mastery

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.12](
DungeonMMO_Roadmap_v2_12_Knight_Defense_Exploit_Bow_20260924.md).
[Exact current Studio evidence](
../testing/knight-sword-blunt-mastery-v2-13-20260924.md).

## Completed this candidate

- [x] Knight `OathguardSteelAndStoneTraining` rank1/2/3/4
  bought separately at C4 source levels 20/24/28/28;
  earned personal first-transfer receipt and real class
  trainer required. No invented source-per-use proficiency gate.
- [x] Authoritative melee physical-multiplier path includes
  this rank only for a genuinely equipped server-registered
  Sword **or** Blunt weapon category. A dagger using temporary
  sword-compatible hitbox animation, a missing weapon or
  forged Fighter class receives zero bonus. Added true
  registered `stonewatch_training_mace`, separately tagged
  `OneHandedBlunt` and routed to actual melee hit executor.
- [x] Focused Knight Quest/Foundation **108/103 assertions PASS**.
  Full-Dungeon Play measured real NPC HP gains from rank4:
  a 100-base test melee hit dealt **110** untrained and
  **114.8** with a Sword; **110 → 114.8** identically with
  registered Blunt. Wrong gear/forged class rejected.
- [ ] Provisional `0.012` Roblox damage multiplier per rank
  is not the exact original C4 P.Atk. stat formula.
  Full mouse-click blunt tool animation/owned item equip
  and other-player isolation still pending; models remain
  placeholders, as agreed for backend-first work.

## Current source-rank coverage, not release certification

| Original first-transfer source | C4 rank rows | Trainer mapped | Unmapped |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 55 | 52 | 3 |

The **three** Knight rows still missing are original source
Equipment Expertise rank 1 at lvl20, and Common Item Creation
ranks 2/3 at lvl20/lvl28. Do **not** reuse Scout expertise
or crafting rank as cosmetic aliases. Knight grade expertise
needs an actual earned-only D-grade equipment gate. Common
Item Creation must actually consume materials, require the
proper recipe/item rank and produce genuine usable common
equipment via real inventory and crafting transactions,
without violating one gathering and one chosen crafting
profession per character. No cosmetic "mapped" rank without
real benefit and actual focused/live tests.

Crucial: Even mapping 55/55 training rows will not certify
original source-faithful combat mechanics, user-authored
skillbooks, class quest progression, exact formula,
world-boss/raid block exploit, second-player isolation
or full natural Base→Dungeon→Base saved acceptance.
Earlier v2.12 live blocks are fixed for Marauder/Captain,
but audit every other enemy executor before publication.
Complete remaining Warrior 35 ranks and all other 14
first-transfer branches and starter levels1–19 up to cap30
without copying Lineage 2 names/assets/quests/narrative.

No main merge, Roblox publish, production DataStore,
or edits to parallel humanoid/quadruped animation projects.
Permanent source/docs edits via GitHub; desktop only for
fast-forward pulls, disposable builds and unpublished
Studio Play.
