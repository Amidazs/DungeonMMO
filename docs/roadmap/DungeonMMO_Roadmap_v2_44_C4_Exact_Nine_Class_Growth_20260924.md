# DungeonMMO v2.44 — exact C4 nine-class growth source

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.43](
DungeonMMO_Roadmap_v2_43_C4_Nine_Class_Primary_Stat_Reference_20260924.md).

## C4-specific source gap closed

The earlier v2.43 reference intentionally refused to invent HP/MP/CP
curves. We now have an actual Chronicle 4 Scions of Destiny source
and datapack pinned at commit
`07f8536384e799f128d44198dd7ab23519660eea`:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny`.

The C4 `charTemplates.xml`, `statBonus.xml` and
`FuncMaxHp/Mp/Cp*` source provide exact class template IDs,
six primary stats, HP/MP/CP bases and growth coefficients,
CON/MEN bonuses, base P.Atk/P.Def/M.Atk/M.Def, attack/cast speed,
accuracy/evasion/crit/run speed and the class base level.

The read-only `C4PrimaryStatReference` now contains **nine exact
C4 templates**:
Human Fighter/Mystic, Elven Fighter/Mystic, Human
Warrior/Knight/Rogue and Elven Knight/Scout. DungeonMMO creative
class IDs map to those source templates without renaming the source
data. Legacy Ranger/Rogue variants remain excluded from claims of
being original level-one C4 classes.

## Exact C4 resource-growth formula now represented

For HP, C4 uses the class template base plus the average of its
level-dependent high/low growth terms, then multiplies by the
source CON bonus. MP uses the same growth shape with MEN; CP uses
CON. The class level delta is character level minus the template
`classLvl`. Positive Java integer conversion is reproduced with
`math.floor` for the final MaxHP/MaxMP/MaxCP, while raw values are
retained for regression vectors.

Examples at level 30 from the exact source arithmetic:

| C4 path | HP | MP | CP |
| --- | ---: | ---: | ---: |
| Human Fighter | 922 | 319 | 418 |
| Human Mystic | 699 | 466 | 366 |
| Elven Fighter | 792 | 324 | 353 |
| Elven Mystic | 666 | 469 | 348 |
| Human Warrior | 1070 | 320 | 849 |
| Human Knight | 1018 | 320 | 610 |
| Human Rogue | 983 | 320 | 399 |
| Elven Knight | 902 | 325 | 453 |
| Elven Scout | 874 | 325 | 354 |

These are source-template calculations, not yet the player's live
Roblox values. Current `AttributeConfig`, `CharacterCombatStats`,
ManaService and HUD are still the custom Roblox system.

## Why live migration is deliberately next, not mixed into this commit

The same C4 source also establishes the stat engine required before
skills can be copied faithfully: level modifier, STR/INT/DEX/WIT/
CON/MEN bonus tables, P.Atk/P.Def/M.Atk/M.Def, attack/cast speed,
accuracy, evasion, critical and regeneration formulas. Migrating
only MaxHealth while attacks, heals and passives still use the
custom five-stat system would produce a hybrid that is neither C4
nor safely balanced.

Next:
1. add a read-only shared C4 derived-stat engine with exact formula
   vectors for all nine templates;
2. port exact physical/magical skill formula semantics and item
   stat order from the pinned C4 source;
3. migrate live HP/MP/CP + six stats coherently across profile,
   server runtime and HUD with safe old-save handling;
4. then replace every current class skill's provisional cost,
   power, passive and effect with its verified C4 source values;
5. rerun anti-exploit blocking/dodge and genuine cross-class Play.

No production stat values changed here. No main merge, Roblox publish,
production DataStore write or animation/art worktree edit.
