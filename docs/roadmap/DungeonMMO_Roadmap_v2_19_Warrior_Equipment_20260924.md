# DungeonMMO backend v2.19 — Warrior D-grade equip expertise

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`
Continues [v2.18](
DungeonMMO_Roadmap_v2_18_Warrior_Stonebreaker_20260924.md).
[Exact focused acceptance](
../testing/ironvow-equipment-expertise-v2-19-20260924.md).

## Verified now

- [x] Independent original level20 Warrior equipment
  expertise as a personally earned and paid trainer
  passive. Real registered D-grade heavy body armour
  with actual server equip and +20 max-HP, only with
  owned rank and earned correct first-transfer class.
  Copied/unawarded/underlevel and rival Knight gear
  cannot bypass class/equipment permission. No items
  granted by learning the skill.
- [x] Two disposable Rojo builds and diff check PASS;
  quest/award/foundation **31/144/125 PASS**, original
  rank audit **27 PASS**, genuine in-memory save/reload
  of equipped body item and purchased skill passed.
- [ ] Natural user-controlled trainer/equipment flow,
  multiplayer exploit and cross-place/rejoin persistence,
  full original C4 stat/gear math are not certified.

## Remaining level-30 source work

Warrior **54/62** historical rank training rows mapped;
**8 remain**: CommonItemCreation 2 (20,28),
CriticalStance 3 (20,24,28), HealthRecovery 1 (24),
AccuracyStance 1 (24), EnduranceSurge 1 (28).
Knight 55/55, Rogue 59/59, Elf Scout 77/77 training
schedules mapped, but no career is certified to match
all original C4 gameplay: **0/18 release-certified**.
Four of 18 original first-transfer inventories audited;
other 14, original starter 1–19 classes, C4 stat,
weapon, caster and economy formulas, natural saved
multiplayer and boss/world-boss block stacking open.

Next implement Warrior common-item creation with one
gathering + one creation profession only, plus a
distinct actually earnable recipe and transaction
for both purchased ranks; do NOT create a second
creation slot or simply copy the Knight's class skill.
Then implement source critical toggle, health
recovery, accuracy toggle and HP surge with real
server effects and narrowly targeted tests.

All permanent files through GitHub. Remote desktop
only for disposable unpublished targeted tests.
Do not merge main, publish Roblox, mutate production
DataStores or edit other animation worktrees.
