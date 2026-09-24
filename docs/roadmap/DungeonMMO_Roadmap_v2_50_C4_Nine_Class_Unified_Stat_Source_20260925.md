# DungeonMMO v2.50 — nine-path unified C4 stat reference

Date: 25 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.49](DungeonMMO_Roadmap_v2_49_C4_Nine_Class_Creative_Mapping_20260924.md).

The approved scope is **all** nine original C4 Human/Elven starter
and first-transfer paths through level 30, not one Warden class.
The source layer already records nine class-specific HP/MP/CP
curves, six attributes, naked derived stats and 476 original
learning rows. The 454 candidate skill/rank links are candidates,
not confirmed matching effects; 22 rows remain explicit gaps.

New `C4UnifiedStatReference` composes exact C4 naked level-specific
HP/MP/CP and derived stats, then applies separately owned,
level-eligible source passive ranks with one simultaneous
original-kind weapon/body/offhand loadout. The enhanced
`C4PassiveStatReference.apply_loadout` sorts all active source
passive operations together rather than calculating weapon and
armour in separate arithmetic groups. A different class cannot
borrow a skill, and a lower-level class cannot use future ranks.
Equipment types remain exact original C4 source names supplied
by a *trusted* caller. No gameplay item is silently assigned
invented C4 P.Atk/P.Def values.

New focused test checks **all nine level-30 class HP/MP/CP
vectors**, combined Scout Bow+Light bonuses, Knight Heavy
mastery, wrong-equipment exclusion, cross-class denial,
and level-20 versus level-28 rank gating.

These source-only snapshots are **not** complete final C4 stats:
real equipped item stat values, enchantments, active effects,
CP mechanics, buff priority and world-target modifiers must still
be integrated before feeding real HP/MP/skill-power calculations.
The live Roblox five-attribute/custom-health/damage/mana
systems remain unchanged. A source-only PASS must never be
presented as a live C4-balance or all-skill-effect PASS.

Next: complete source-equivalent gear stat lookup and combined
calculator, close the 22 unmapped original learning rows
(particularly Scout's nine Elemental Heal ranks), then migrate
character HP/MP/CP/profile/HUD and actual class skill executors
together with multi-class combat/anti-exploit testing.
No main merge, publish, production saves or unrelated
animation/art changes.
