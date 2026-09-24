# DungeonMMO v2.43 — original class primary-stat source baseline

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Baseline commit: `812dc07fc770d2411d9cbd2c817df7793bd86ab1`.
Predecessor: [v2.42 all-class stats](
DungeonMMO_Roadmap_v2_42_C4_All_Classes_Stat_Baseline_20260924.md)
and [v2.42 all-class skill inventory](
DungeonMMO_Roadmap_v2_42_All_Implemented_Class_Skill_Fidelity_20260924.md).

## Original C4 six-stat reference for all currently implemented paths

Added `C4PrimaryStatReference.luau` with historical
STR/DEX/CON/INT/WIT/MEN values for the four original Human/Elf
Fighter and Mystic starters. All five already-authored first
transfers resolve to their race's Fighter starting stat baseline:
Human Rogue/Warrior/Knight and Elven Scout/Knight. No legacy
Ranger/Rogue or cross-race class is silently assigned a C4
original stat identity. `for_character` rejects a copied
first-transfer class label without its original mentor receipt.

| Original starting scope | STR | DEX | CON | INT | WIT | MEN |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Human Fighter | 40 | 30 | 43 | 21 | 11 | 25 |
| Human Mystic | 22 | 21 | 27 | 41 | 20 | 39 |
| Elven Fighter | 36 | 35 | 36 | 23 | 14 | 26 |
| Elven Mystic | 21 | 24 | 25 | 37 | 23 | 40 |

Sources: https://l2hub.info/c4/classes/fighter ,
https://linedia.ru/wiki/Human ,
https://linedia.ru/wiki/Elven_Fighter_%28C4%29 ,
https://linedia.ru/wiki/Elf .
The official **2018 Classic** stat table corroborates the six
starting stats but is explicitly NOT proof of C4's entire level
growth or combat formula:
https://www.lineage2.com/en-us/news/lineage-ii-classic-launch-patch-notes .

## Why HP, MP, CP and skill damage are not silently replaced yet

`CharacterCombatStats`, `AttributeConfig`, `RaceDefinitions`
and existing profile data still use the older Roblox five-attribute
and 100-HP system. Original historical class-base HP is not the
final displayed HP: the latter also depends on CON, class
transfer, equipment, passives and applicable modifiers. The
archival HP samples in
[the existing stat migration plan](
../design/C4_All_Classes_Stats_And_Skills_Target_20260924.md)
have not been verified against a specifically C4-era level-by-level
HP/MP/CP datapack for all nine paths. An Interlude or later
chronicle chart cannot silently satisfy that requirement.

The new source provider therefore returns
`C4ClassLevelHpMpCpSourceUnverified` for level vitals instead
of inventing level-30 HP or silently converting a source HP
table to final character HP. It does **not** change production
MaxHealth, MaxMana, stamina, weapon power, passives, combat
damage or already-saved characters. This is the first strict
source-data milestone, **not** a C4 balance migration or
numerical skills fix.

## Next acceptance gates

1. Retrieve a confirmed C4-specific full 1-30 per-class
   base HP/MP/CP table for four starters and five first
   transfers, and the original CON/MEN modifiers and
   level-dependent stat derivation. Record exact source
   version, provenance and numerical test vectors.
2. Implement the original stat and derived damage/heal/
   mitigation engine as one shared path across every
   implemented original class; stage safe persistent-profile
   migration and refresh health/mana/CP, combat and HUD
   together. Preserve bounded blocking and dodge security.
3. Audit all 1,353 current class-scoped skill-rank
   occurrences (shared ranks repeated across classes) against
   original sources and update effect/costs only when
   stat-equivalent formulas are ready. First-transfer rank
   schedules alone are not source effect parity. Preserve
   distinct creative names, not copied assets or quest text.
4. Run exact C4 numerical vectors, save/rejoin acceptance,
   per-skill formulas, anti-exploit guard chip checks and
   real-client cross-class combat tests before live deployment.

No main merge, Roblox publication, production DataStore edit or
animation/art changes. Permanent source/docs through GitHub.
