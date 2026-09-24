# DungeonMMO backend v2.18 — Warrior source blunt-control ranks

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Continues [v2.17](
DungeonMMO_Roadmap_v2_17_Warrior_Crescent_Sweep_20260924.md).
[Exact real client and foundation evidence](
../testing/ironvow-stonebreaker-v2-18-20260924.md).

## Implemented and verified

- [x] Independently earned Warrior blunt-only stun
  `IronvowStonebreaker` bought in nine distinct C4
  source level20/24/28 ranks via actual class trainer.
  Pre-requisite real bought sword/blunt mastery and
  genuine server-equipped blunt, never sword/dagger/
  polearm or forged first-transfer identity.
- [x] Preserved source rank power and MP cost in real
  server skill definitions. One target per swing;
  distinct shock from polearm area skill. Source
  no-refresh-on-already-dazed behavior implemented for
  this skill in the genuine skill-target executor.
- [x] Base and Dungeon disposable Rojo builds PASS.
  Real Quest/Award/Foundation 31/137/119 PASS.
  Actual client hotbar -> server spent 30 MP, NPC lost
  21.3888 HP and received 1.1s shock; wrong gear,
  forged class, and immediate cooldown retry rejected.
  Strict source audit 27 assertions PASS.
- [ ] Two independent live players both trying to
  re-stun the same already dazed enemy is not tested,
  and source original shock duration, P.Atk formula,
  overhit/reward, NPC resistances and full C4 combat
  balance are NOT recreated by a short Roblox stagger.

## Through-level-30 source rank audit

| Career | Recorded C4 rank opportunities | Mapped source training rows | Missing |
|---|---:|---:|---:|
| Human Warrior -> Ironvow | 62 | 53 | 9 |
| Human Knight -> Oathguard | 55 | 55 | 0 |
| Human Rogue -> Ashenblade | 59 | 59 | 0 |
| Elf Scout -> Greenward Scout | 77 | 77 | 0 |

**Nine Warrior utility rank rows remain:**
EquipmentExpertise one at 20;
CommonItemCreation two at 20/28;
CriticalStance three at 20/24/28;
HealthRecovery one at 24;
AccuracyStance one at 24;
EnduranceSurge one at 28.

Source-row coverage does **not** certify matching source
combat balance, player-input gameplay, or release.
Only 4/18 original first-transfer source inventories
have been fully recorded at level30. All other 14
first-transfer career catalogues, starting 1–19 skills,
natural cross-place save/rejoin, multi-client hostility,
all boss/world-boss blocked-hit stacking and
PvE/PvP formula acceptance still need work.
**0/18 first-transfer classes release-certified.**

## Continue

Next implement the nine Warrior utility rows as
separate server-authoritative and owned abilities:
D-grade equipment permission from a real trainer and
actual equipped item, creation ranks while retaining
ONE gathering and ONE crafting profession,
critical-damage toggle with ongoing resource upkeep,
actual passive HP recovery, timed accuracy toggle and
server-owned temporary max-HP/heal effect. Never count
a renamed icon or untested skill row as complete.
Build targeted real health/gear/resource and
save/reload regressions, then audit all other classes.
The source C4 economy's automatic common creation
differs intentionally from DungeonMMO's single-profession
model; this difference must remain explicit.

Permanent scripts/docs through GitHub; desktop only
for unpublished disposable tests. Never merge `main`,
publish Roblox, touch production saves or parallel
humanoid/quadruped animation work.
