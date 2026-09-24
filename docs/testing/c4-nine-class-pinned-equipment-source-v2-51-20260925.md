# C4 item/stat reference validation — v2.51

Date: 25 September 2026.
Candidate: `90fa5129d5170e1bfad89d1a4729158ebd5b01f1`.
GitHub runner:
`scripts/studio/c4_original_item_stat_reference_focus.luau`.
Local disposable Studio log:
`%TEMP%\\DungeonMMO_v251_c4_original_item_stats\\item_stats.log`.

## Exact pinned source records

Reference commit:
`07f8536384e799f128d44198dd7ab23519660eea`
from
https://github.com/Neco-spain/l2jadmins_C4-Scions-of-Destiny
under
`L2jAdmins_Data/data/xml/stats/weapon/`,
`L2jAdmins_Data/data/xml/stats/armor/`,
`L2jAdmins_Data/sql/game/weapon.sql` and
`L2jAdmins_Data/sql/game/armor.sql`.

Original IDs 1 short sword, 4 club, 6 apprentice wand,
10 dagger, 13 short bow, 22 leather shirt, 25 piece-bone
heavy chest, 425 apprentice magic tunic, 102 round shield.
The XML specifies weapon set order 0x08, armour P.Def
add 0x10, robe MP 0x60 and shield power/rate and
evasion penalty. Original SQL distinguishes weapon,
chest and left-hand slots and confirms bow is two-handed.

`C4EquippedStatReference` computes the source weapon
and armour stages BEFORE class multiplier and
existing historical level-30 passive reference.
Test examples: Human Fighter level30 shirt P.Def must be
`floor((80 + 43 - 31) * level_modifier)`, not
`already_derived_naked_PDef + 43`.
An original Mage chest uses -15 rather than -31.
The source robe's +19 MAX_MP applies after earlier
passive/stat stages. The round shield has defence
power79/rate20 and evasion -8, not a generic
passive 79% damage reduction.

## Executed Studio outcome

Both `rojo build base.project.json` and
`rojo build default.project.json` passed on the
unpublished worktree after GitHub fast-forward.
Focused Base Studio log:
`[C4 Original Item Stats] SOURCE_ONLY_PASS: 46 assertions
nine_paths=9 live=false`;
`[C4 Original Item Stats] VERIFIED_SOURCE_ONLY_NOT_LIVE`.

The 46 assertions cover nine distinct HP profiles,
source item stat ordering, chest class deductions,
Source-only flags, independently authorized bow/light
and knight/heavy passives, wrong-slot gear, unknown
source IDs, two-handed bow+shield incompatibility,
wrong-race class identity and cross-class skill denial.
The previous v2.50 read-only 35-assertion test remains
separate; it was not rerun as part of the new focused
gear test.

## Not certified

No creative live inventory item's C4 ID/stats,
full original gear database/sets/enchantments,
actual player HP/MP/CP, original damage/status/reuse
formula application, source resource economy,
persistent/rejoin or PvP class balance was
migrated or certified by this focused source-only
test. No release/publish/main merge.
