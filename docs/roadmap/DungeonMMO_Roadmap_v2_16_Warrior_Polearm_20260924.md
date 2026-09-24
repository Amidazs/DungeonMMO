# DungeonMMO backend v2.16 — Warrior source polearm and anti-stack checks

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.15](DungeonMMO_Roadmap_v2_15_Warrior_Sword_Blunt_20260924.md).
[Exact Studio evidence](
../testing/ironvow-polearm-mastery-v2-16-20260924.md).

## Completed and actually tested

- [x] Added distinct server-registered two-handed Polearm weapon,
  with restricted OffHand shield; both equip orders rejected
  by real server `EquipmentService` in actual earned Warrior
  class profile tests.
- [x] `IronvowPolearmTraining` four independent purchased
  source ranks at **20 / 24 / 28 / 28**, C4 source flat
  P.Atk **4.5 / 7.3 / 8.9 / 10.7** and +5 hit targets.
  Strict actual earned-first-transfer owner and current
  registered polearm required; sword/blunt/dagger/unarmed
  and forged class do not inherit hit-count/damage bonuses.
- [x] Separate server-owned polearm 7-stud 130-degree
  frontal multi-NPC swing. `MeleeHitService` limits
  5 untrained or 10 mastered targets **across all swing
  samples**, deduplicates NPC body parts, respects real NPC
  target tags and geometry obstruction. Existing sword/blunt
  attack geometry and shield block/parry rules unchanged.
- [x] Fresh unpublished disposable Base/Dungeon Rojo PASS,
  Warrior Quest/Award/Foundation **31 / 99 / 73 PASS**;
  actual twelve-NPC world HP 5/10 capped sweep
  **26 assertions PASS**; actual player-owned polearm
  NPC HP **110 -> 111.07**, wrong gear/class denied,
  real Play `VERIFIED_PLAY_MODE_PASS`; source audit
  **27 assertions PASS**. See exact logs in linked evidence.
- [ ] The flat P.Atk × 0.001 additive attack adapter is
  provisional Roblox balance, NOT copied C4 P.Atk/defence
  mathematics. A real user-controlled ten-monster sweep,
  animation, natural save/rejoin, multi-user authority
  and dungeon/world boss defensive-stacking regressions
  remain open.

## Level-30 source-rank schedule audit (not full gameplay equivalence)

| First-transfer branch | Recorded C4 ranks | Mapped training rows | Missing |
|---|---:|---:|---:|
| Human Rogue -> Ashenblade | 59 | 59 | 0 |
| Elf Scout -> Greenward Scout | 77 | 77 | 0 |
| Human Knight -> Oathguard | 55 | 55 | 0 |
| Human Warrior -> Ironvow | 62 | 35 | 27 |

These numbers count independently learned source rank
schedules, not verified exact effects or completed classes.
Only four of 18 original first-transfer branches have full
C4 source inventories; all 14 others, every starter level
1–19 catalogue, actual mathematical cross-class C4 balance
and fully persistent natural gameplay still remain.
**0/18 first-transfer careers release certified.**

## Continuing backend, with Desktop Commander credit conservation

Implement each of the **27 remaining Warrior source rank
rows** as separate genuine skill effects, beginning with
source-verified polearm-specific area attack and blunt
crowd-control (do not reuse a sword-only skill and rename it).
Match C4 owned rank levels, MP/stamina/HP costs and target
semantics where evidence supports them; mark Roblox
stat/encounter conversions explicitly where source formula
has not yet been reproduced. Next audit all 14 remaining
original first-transfer trees, implement race/base class
skill catalogues and personally earned advancement.
Prioritize targeted tests over repeating already green
Quest/Base suites; reserve desktop credits for live
real player/NPC, multiplayer, boss defence, save/rejoin
and full dungeon acceptance.

Keep previous v2.12 chip/guard-break anti-invulnerability
on every hostile melee path; equipment reservations
must prevent dual polearm/shield stacking. WoW-style
one gathering/one crafting profession remains the
intentional game economy difference from C4.

Permanent scripts/docs via GitHub; remote desktop only
for safe fast-forward/disposable unpublished Studio tests.
Do not merge main, publish Roblox, mutate production
DataStores or alter humanoid/quadruped animation work.
C4 polearm reference:
https://l2hub.info/c4/skills/216-polearm-mastery%3A4/classes
