# Whole-current-class source-to-runtime skill audit — v2.42

Unpublished Dungeon Rojo build and focused Studio runner:
`%TEMP%\\DungeonMMO_v242_all_classes_skill_audit\\audit.log`
for `58cfe32c3fac47289523786e8260546e848287b8`. The audit was a read-only source
inspection; no user or production character was modified.

| Current race/class path | Authored families | Authored rank rows | Historical numerical reference rows |
| --- | ---: | ---: | ---: |
| Human Fighter | 17 | 75 | 1 |
| Elven Fighter | 19 | 79 | 1 |
| Human Mystic | 28 | 77 | 1 |
| Elven Mystic | 26 | 74 | 1 |
| Human Rogue / Ashenblade | 40 | 136 | 1 |
| Elven Scout / Greenward Scout | 44 | 158 | 1 |
| Human Warrior / Ironvow | 33 | 139 | 1 |
| Human Knight / Oathguard | 30 | 130 | 1 |
| Elven Knight / Greenward Warden | 34 | 135 | 24 |
| Legacy Human Ranger | 26 | 75 | 0, no direct C4 class |
| Legacy Elven Ranger | 29 | 94 | 0, no direct C4 class |
| Legacy Human Rogue | 32 | 86 | 0, no direct C4 class |
| Legacy Elven Rogue | 33 | 95 | 0, no direct C4 class |
| **Class-scoped totals** | **Shared skills repeated** | **1,353** | **32** |

The 1,353 rows are per race/class context, not unique
skill names: starter and inherited active/passive ranks are
counted in every context in which a character is allowed
to use them. 1,321 row occurrences still lack an
individual original numeric source record.

Machine-readable `C4AllImplementedClassSkillAudit`
returns ALL individual rows and their live resolved rank,
progression/passive and combat effect definition, level,
source sample when known, and explicit false source-parity
flag. The separate cross-class source samples cover one
confirmed reference rank for each of the nine original
classes in scope; all other historic rank powers,
MP/SP, passive stats, cast/reuse, duration and
underlying C4 combat formulas require verification.

Original C4 primary data:
https://l2hub.info/c4/classes/fighter ,
https://l2hub.info/c4/classes/elven_fighter ,
https://l2hub.info/c4/classes/mage ,
https://l2hub.info/c4/classes/elven_mage ,
https://l2hub.info/c4/classes/rogue ,
https://l2hub.info/c4/classes/elven_scout ,
https://l2hub.info/c4/classes/warrior ,
https://l2hub.info/c4/classes/knight ,
https://l2hub.info/c4/classes/elven_knight .

This test is *not* a statement that matching skill-rank
counts, names or a successfully functioning game
proves original C4 damage, passives or PvP balance.
The C4 source/runtime data and formulas still differ.

## Final full-field audit rerun

The completed full-definition candidate `ed570e51e36052f6093bb2da0195f711e33a20d5` was fast-forwarded,
Rojo-built and run again in an unpublished disposable Dungeon place:
`%TEMP%\\DungeonMMO_v242_all_classes_skill_audit_final\\audit.log`.
The final run passed `VERIFIED_INVENTORY_NOT_PARITY` and reported
13 race/class scopes, 1,353 class-scoped current rank rows, 32
individually sourced numeric rank rows, **32/32 different numerical
MP values**, and 1,321 rank occurrences still without an individual
verified original C4 numerical record. Each row now also retains its
full current progression/passive and resolved combat definition,
including settings outside the compact numeric summary. A numeric
mana mismatch by itself is not proof that the original and Roblox
mana economies have comparable scales; no class is mechanically
certified from this inventory result. No gameplay values changed.
