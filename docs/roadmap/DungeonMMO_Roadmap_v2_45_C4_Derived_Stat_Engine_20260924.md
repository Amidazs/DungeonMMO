# DungeonMMO v2.45 — C4 derived-stat source engine

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.44](
DungeonMMO_Roadmap_v2_44_C4_Exact_Nine_Class_Growth_20260924.md).

The pinned C4 Scions of Destiny source now drives a separate
read-only derived-stat reference engine in addition to the exact
nine class HP/MP/CP templates.

`C4DerivedStatReference` implements the source two-decimal
STR/INT/CON/MEN/DEX/WIT bonus equations, the C4 character level
modifier `(89 + level) / 100`, and naked/unbuffed source
P.Atk, P.Def, M.Atk, M.Def, physical/cast speed, run speed,
accuracy, evasion and physical critical-rate semantics.

It deliberately does **not** yet apply weapons, armour, jewelry,
mastery passives, buffs, dyes or target-specific modifiers.
Those are ordered through the C4 calculator/stat functions and
must be ported in source order before live combat is switched.
The critical-rate value remains in the C4 source engine's rate
units rather than being incorrectly relabeled as a 0-1 Roblox
probability.

The focused source test checks exact baseline bonuses and four
level-30 racial starter formula vectors. First-transfer HP/MP/CP
differences are already covered by v2.44 and use the same racial
primary/base combat stats before class skills/equipment.

Next: port C4 equipment/stat calculator order and physical/magic
damage/heal/status formulas from the pinned source, then provide
one authoritative C4 character snapshot that the Roblox runtime
can consume. Only after that shared layer is stable should live
profiles/HUD and every existing class skill be switched from the
custom five-stat/stamina/percentage model.

No live combat values changed. No main merge, publish, production
DataStore write or animation/art edits.
