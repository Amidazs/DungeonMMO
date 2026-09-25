# DungeonMMO Roadmap v2.93 — Human Wizard Level-30 Source Audit

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.92](
DungeonMMO_Roadmap_v2_92_C4_Multiplayer_Cutover_Hardening_20260925.md).

## Status

**GREEN — first Mage-transfer source inventory is now audited through level 30.**

Acceptance:
[Human Wizard source audit v2.93](
../testing/c4-human-wizard-level30-source-audit-v2-93-20260925.md).

## What changed

The broader backend roadmap resumed after closing C4 combat-cutover hardening.

Human Wizard is the next original first-transfer path under the Human Mystic
starter family. Its C4 training schedule is now recorded independently rather
than inferred from Fighter 20/24/28 brackets.

The source audit contains **93** training-rank rows through the level-30 launch
cap:

| Source bracket | Rank rows |
|---|---:|
| 20 | 29 |
| 25 | 32 |
| 28 | 1 |
| 30 | 31 |
| **Total** | **93** |

The branch remains unimplemented and unplayable. No creative DungeonMMO class
award, trainer or first-transfer skill tree is claimed yet.

## Cross-class audit correction

The fresh test also caught a stale Human Knight source count. The old audit
incorrectly counted another bow-defence row at level 28. The launch-cap Knight
inventory is now **54**, not 55:

- 20: 16;
- 24: 16;
- 28: 22.

This returns the source audit to the previously documented C4 class-table
structure and matches the existing bow-defence implementation, whose next rank
is outside the level-30 launch scope.

## Current original first-transfer coverage

There are still **18** original first-transfer paths in scope.

After v2.93:

- source inventories audited through the launch cap: **6/18**;
- trainer-rank schedules mapped: **5/18**;
- fully release-certified first-transfer paths: **0/18**.

The five currently mapped Fighter transfers remain Human Warrior, Human Knight,
Human Rogue, Elven Knight and Elven Scout.

Human Wizard is the sixth source-audited branch and the first newly audited Mage
transfer. It intentionally remains **0/93 mapped** until a real DungeonMMO
career and actual effects exist.

## Verification

Fresh candidate `8144fa41ac01345d51ba9ed20d22801bb9d87797`:

- git diff validation: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused level-30 source audit: **37 assertions PASS**.

## Next implementation

Proceed with Human Wizard rather than returning to cutover work:

- add a creative DungeonMMO Human Wizard first-transfer identity;
- add a creative advancement quest using the existing authenticated quest
  architecture;
- add a class-bound trainer;
- map the 93 C4 source rows into independently named abilities/ranks;
- implement spell damage, debuffs, recovery and passive families against the
  accepted C4 mechanical targets;
- design server-owned summoned companions before counting any summon/servitor
  rows as implemented;
- then run only targeted source/effect and genuine client tests.

After Human Wizard, continue Human Cleric, Elven Wizard/Oracle, then remaining
Dark Elf, Orc and Dwarf first-transfer branches.

No main merge, publish, production save mutation or animation work.
