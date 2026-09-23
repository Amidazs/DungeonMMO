# DungeonMMO v2.07 — resumed Ironvow Base and Knight magic/healing

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.06 Warrior/Knight physical and skills](
ironvow-oathguard-physical-and-rank-audit-v2-06-20260923.md).

## Recovering interrupted original Warrior client test

The dedicated `scripts/studio/c4_ironvow_base_live.luau`
is now confirmed present in GitHub. The first pre-update physical
Studio run returned a genuine **FAILED** prompt trigger:
the physical NPC prompt was not shown at four studs. The
development branch was advanced to the latest v2.06 physical
hub/mentor fixes, pulled fast-forward-only and the disposable
Base was rebuilt and rerun.

The current-build genuine two-client Studio **Ironvow Base
physical run PASS** was verified from the *specific Roblox Studio
process log*, with these sequential markers:

- `REAL_IRONROOT_TWO_NPCS_PASS`
- `REAL_FOUR_MARKER_TURNIN_PASS`
- `REAL_BOSS_SEAL_TURNIN_PASS`
- `REAL_CLIENT_IRONVOW_TRAINER_PASS`
- `VERIFIED_WARRIOR_BASE_PASS`

The client actually held physical original source, turn-in,
class mentor and training prompts. Earlier stage-three/five
dungeon loot was prepared in test-only Base character profiles;
this still does not demonstrate an uninterrupted fully
player-controlled Base → Dungeon → Base progression. A second
concurrent Studio process wrote unrelated Scout test markers
to the named output file; the Ironvow-specific Studio process
log, **not** that mixed output file, was used to establish PASS.

## Oathguard: two new genuine rank/effect lines

- `OathguardRunicResistance`: **eight** individually purchased
  ranks, two at level 20, three at 24 and three at 28, available
  only to an authentically earned Human Fighter → Oathguard.
  Every rank gives 0.6% mitigation against actual
  `EnemyMagic` damage, up to **4.8%**. The shared passive
  rules reject copied ranks on a forged or unawarded Fighter.
  The runtime exposes only that character's saved mitigation
  and the existing combat DamageService now includes it
  alongside the original Mystic anti-magic calculation.
  Physical and ordinary player damage are unaffected.
- `OathguardMendingOath`: **three** separately bought level-28
  ranks after genuine Fighter Resting Recovery. The existing
  authoritative owner-only heal executor has total base
  healing of **30, 37, 44** across ranks, with mana spend
  and server cooldown. An unadvanced or other-class
  Fighter cannot learn it. The historical source category
  is the Knight's three level-28 self-recovery rank rows.

These are independently named original DungeonMMO implementations.
They do not copy source-game icons, dialogue or protected text.

## Executed tests and exact boundaries

- Actual temporary Base and Dungeon Rojo builds **PASS**.
- Isolated genuine ProfileService/SkillProgressionService
  Knight quest, mentor and training suite
  `c4_oathguard_quest_focus.luau`: **2/2 PASS**
  (**56 Oathguard Quest** and **56 Oathguard Foundation**
  assertions). The Knight owner purchased all eight
  individually registered magic ranks at the correct
  20/24/28 levels and all three level-28 recovery ranks
  after its actual precursor requirement, then saved
  them with the earned class. The runtime magic
  reduction was **4.8%** only for the awarded Knight;
  forged Fighter identity received zero. The three
  heal ranks are registered as a real server-owned
  owner-only heal with increasing amounts; the
  new full live-client Knight self-heal and enemy
  spell-hit tests are **still pending**.
- Latest level-30 inventory Studio audit
  `c4_level30_launch_coverage_focus.luau`:
  **27 assertions PASS**. Against the repository's
  recorded first-transfer source inventory,
  Oathguard maps **35/54** rank schedule entries
  and has **19** unmapped. Ironvow remains
  **27/62** mapped with **35** unmapped;
  Ashenblade and Greenward Scout remain
  **59/59** and **77/77** mapped *training rows*,
  respectively. This is not independently
  verified full C4 game-mechanics equivalence,
  level-1–19 starter coverage or every live effect.
- Previous v2.06 genuinely physical Base and two-client
  Dungeon tests were not all rerun after the new
  Knight magic/healing implementation. No new live
  client healing or spell-damage claim is made.

Permanent scripts, tests and documentation are changed
only via GitHub. Desktop was used only for clean Git
pulls, temporary builds, unpublished Studio tests and
logs. No Roblox publication, production DataStore
write, destructive local reset or `main` merge.
