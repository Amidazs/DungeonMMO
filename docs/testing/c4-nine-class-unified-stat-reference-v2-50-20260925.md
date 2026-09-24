# v2.50 — complete nine-path source stat snapshots and equipment gates

Date: 25 September 2026. Unpublished, disposable Base Studio;
candidate commit `4ea8f0d7c4a31a49e3efdaf2897a8d4b8f4be39d`.

## Source scope

All four race-specific original starters and all five current
Fighter first transfers are included: Human Fighter/Mystic,
Elven Fighter/Mystic, Human Warrior/Knight/Rogue, Elven
Knight/Scout. Source C4 class templates and HP/MP/CP curves
are pinned to the same C4-emulator revision as v2.44:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f85363`.
These are implementation references, not independent proof
of every historical retail-server edge case.

`C4UnifiedStatReference.get` composes each original
level-specific naked stat snapshot and applies class- and
level-authorized original passive rank operations in one
equipment-aware calculator pass. A simultaneous Bow+Light
setup can receive its bow physical attack mastery and light
armour evasion, while Sword+Heavy Knight receives the
original Heavy mastery P.Def. Inappropriate equipment
conditions, copied cross-class skills, early rank9 at
level20, and armour names passed as weapon slot (or the
reverse) are denied. A naked character never receives
gear-only passive effects.

## Actual tested outputs

For the nine source paths at character level 30, expected
historical naked MaxHP/MaxMP/MaxCP:

| Class path | HP | MP | CP |
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

Disposable Base and Dungeon Rojo builds PASS. The focused
`scripts/studio/c4_unified_stat_reference_focus.luau`
Studio runner using
`%TEMP%\\DungeonMMO_v250_nine_class_stat_source_r2\\stats.log`
reported:
`[C4 Unified Stats] SOURCE_ONLY_PASS: 35 assertions
nine_paths=9 live=false`
and `VERIFIED_SOURCE_ONLY_NOT_LIVE`.
The first variant had 33 assertions PASS; the final rerun
adds two wrong-slot anti-borrowing tests and is the
authoritative v2.50 result.

## Explicit limits

These are source-only, naked-before-item stat snapshots.
Current Roblox item definitions have custom damage/HP
bonuses, not original C4 gear P.Atk/P.Def/M.Atk/M.Def
values; the new code does not fabricate them. It does
not apply original shot usage, enchantments, active
buffs/auras, real CP damage absorption, or modify the
live Roblox character's Humanoid Health/Mana or save
schema. It also does not verify equivalent real-client
skill damage, exact C4 threat/status mechanics, or
complete balance across classes. The previously audited
476 original learning rows contain 454 creative skill
candidates and 22 explicit gaps; linkage does not
guarantee mechanical fidelity. No public publish,
production DataStore write or main merge was performed.
