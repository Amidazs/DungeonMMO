# DungeonMMO backend v2.20 — earned Warrior common crafting tiers

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Continues [v2.19](
DungeonMMO_Roadmap_v2_19_Warrior_Equipment_20260924.md).
[Precise actual crafting and anti-duplication evidence](
../testing/ironvow-common-crafting-v2-20-20260924.md).

## Completed and verified

- [x] Distinct original Warrior common item tiers at
  level20 and28 separately paid from earned class
  trainer, dependent on base recipe literacy/common
  creation and one selected crafting profession.
  Doesn't award materials or a second craft/gather slot.
- [x] Eight authored material-backed recipes across
  four creation careers. Blacksmith tier1 makes
  genuinely usable 2-handed halberd, tier2 makes
  owned D-grade Warrior-only heavy armour; its
  equipment expertise is still independently bought.
- [x] Actual real server blacksmith crafting of
  both ranks spends input inventory and awards
  output, resists other creation career access
  and save/reload retains owned personal rank.
  Prepared rank2 craft fails closed if rank
  revoked before completion, no input loss/output
  duplication. Fresh Quest/Award/Foundation
  **31/182/131 PASS**, source audit **27 PASS**.
  Disposable Base/Dungeon Rojo PASS.
- [ ] Other three Warrior careers require isolated
  full material consumption live/server tests;
  true user-originated gathering/crafting UI,
  cross-place persistence, original C4 automatic
  advanced creation and economy aren't identical
  or release-certified.

## Exact original level-30 class mapping

Warrior **56/62** source-rank rows mapped,
**6 remain**: CriticalStance 3 (20/24/28),
HealthRecovery 1 (24), AccuracyStance 1 (24)
and EnduranceSurge 1 (28). Knight 55/55,
Rogue59/59 and Elf Scout77/77 are only schedule
mapped; original formula/skill-effects end-to-end
evidence remains open. Only four of 18 first-
transfer source catalogues audited through level30,
**0/18** classes release-certified. Fourteen other
first-transfer source audits, base classes1–19,
natural Quest/Trainer→Dungeon→save/rejoin and
other boss/world-boss held-Block chip checks open.

Next implement true source critical damage stance
three owned ranks with continuous MP upkeep (not
a renamed Rogue stamina toggle), passive actual HP
recovery, accuracy toggle with continuous MP, and
rank1 temporary maxHP/restoration skill; retain
single chosen gathering/creation professions.

Permanent source/docs only GitHub, remote desktop
only disposable targeted unpublished tests. No
main merge, production DataStores, Roblox
publish or parallel animation worktree edits.
