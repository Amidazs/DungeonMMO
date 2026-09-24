# DungeonMMO backend v2.17 — real Warrior polearm area skill

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Continues [v2.16](DungeonMMO_Roadmap_v2_16_Warrior_Polearm_20260924.md).
[Precise source/focused combat evidence](
../testing/ironvow-crescent-sweep-v2-17-20260924.md).

## Completed and verified

- [x] Added separately learned/paid original Warrior
  polearm-area **nine-rank** source family, level
  20/20/20, 24/24/24, 28/28/28, genuine earned
  first-transfer quest, own trainer, real equip and
  separately learned polearm mastery prerequisite.
- [x] Correct original C4 area-skill MP costs and source
  power retained in rank definitions. Actual engine
  spends MP on regular melee-skill request (not an
  invented stamina cost). Real physical NPC damage uses
  a **provisional** 0.15 × source power Roblox adapter;
  identical C4 P.Atk calculations are NOT certified.
- [x] Distinct 7-stud, 125-degree server melee area
  acquisition, 20 independent PvE targets maximum
  even with normal 5/10-target polearm mastery.
  Real 22-NPC rank1 and9 hit tests: 46 HP
  assertions PASS, each target hit at most once.
- [x] Both disposable Rojo builds PASS. Earned Warrior
  Quest/Award/Foundation 31/118/96 PASS, separate
  27-assertion rank audit PASS. Source rank schedule:
  Warrior **44/62**, **18 missing**; Knight **55/55**,
  with mechanic/release flags still false.
- [ ] Actual player-originated mana and mouse-button
  end-to-end sweep, visual telegraphs, party ownership,
  cross-place save/rejoin, exact original C4 balance
  and broad boss/world-boss damage stacking remain open.

## Remaining Warrior 18 source ranks at level 30

BluntControl **9** (three ranks per bracket), CriticalStance
**3**, and one each for EquipmentExpertise,
CommonItemCreation level20/28 **2**, HealthRecovery,
AccuracyStance and EnduranceSurge. Count:
9 + 3 + 1 + 2 + 1 + 1 + 1 = **18**.

Next: implement distinct blunt-only targeted strike with
source daze immunity while already stunned, nine
rank-specific power/MP parameters, genuine trainer and
equipment authority. Its real NPC stun state and real
HP need focused tests, not fake rank naming. Then map
the remaining original active/passive utility families,
without treating rank schedules as complete C4 gameplay.
Other 14 first-transfer source inventories, base classes
level1-19 and full release certification still pending:
**0/18** first-transfer careers release certified.

Keep one gathering and one creation profession;
C4 is a reference, not copied player-facing names/assets.
Use GitHub for permanent code/docs, remote desktop only
for disposable test builds/unpublished Studio. Do not
merge main, publish Roblox places, change production
DataStores or disturb humanoid/quadruped animation work.
