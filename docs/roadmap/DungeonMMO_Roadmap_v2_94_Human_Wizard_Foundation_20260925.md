# DungeonMMO Roadmap v2.94 — Human Wizard First-Transfer Foundation

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.93](
DungeonMMO_Roadmap_v2_93_Human_Wizard_Source_Audit_20260925.md).

## Status

**GREEN — creative Human Wizard class, quest, trainer and non-servitor training
schedule foundation are accepted.**

Acceptance:
[Human Wizard foundation v2.94](
../testing/c4-human-wizard-foundation-v2-94-20260925.md).

## Delivered

The Human Wizard source path now has an independently authored DungeonMMO
identity: **Emberweaver**.

The existing original-first-transfer architecture now supports a Mage-family
career rather than being Fighter-only:

- explicit Human Mystic branch selection;
- creative level-18 **Emberglass Trial**;
- server-owned personal quest proof and bound items;
- level-20 transfer requirement;
- one-use physical mentor receipt;
- saved Emberweaver identity preserving the Mage base family;
- class-bound `EmberweaverTrainer`;
- generic first-transfer skill receipt gating for Fighter and Mage families.

## Training catalogue status

The source audit remains **93 rows** through level 30.

The class trainer now maps **74/93** rows across 24 non-servitor creative skill
families.

The remaining **19 rows** stay intentionally unmapped until a real companion
authority exists. They are the source Servitor Heal, Servitor Recharge and two
summon lines.

This is a deliberate fail-closed boundary, not missing bookkeeping.

## Fresh verification

Candidate:
`3d31e7344a379fc3808c59d5551dd21990179c2c`.

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- Human Wizard foundation: **166 assertions PASS**;
- Human Wizard quest/transfer transaction: **22 assertions PASS**;
- level-30 launch audit: **37 assertions PASS**;
- focused runner: **3/3 PASS**.

## What is not yet complete

Rank schedules are not live effect parity.

The following still require the accepted C4 source-stat/formula path rather
than creative Roblox constants:

- direct magic damage;
- short-range magic damage;
- drain;
- slow/sleep/weakness/fire-vulnerability controls;
- poison and area poison;
- fire area damage;
- HP-to-MP and corpse recovery;
- casting/reuse/mana/passive stat families;
- robe/equipment behaviour;
- all four companion-dependent source families.

## Next implementation order

1. add exact source identity/rank mapping for the 24 non-servitor families;
2. extend the source-effect catalogue to the Human Wizard ranks;
3. route ordinary direct-magic families through the existing C4 calculator and
   executor;
4. add source debuffs/area/status behaviour through existing server authority;
5. reconcile passive stats and recovery;
6. design one server-owned companion boundary;
7. only then map the remaining 19 companion-dependent rows.

After Human Wizard reaches the agreed level-30 launch scope, continue Human
Cleric, Elven Wizard/Oracle and the remaining Dark Elf, Orc and Dwarf branches.

No main merge, Roblox publish, production save mutation or animation work.
