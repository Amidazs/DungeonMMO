# DungeonMMO v2.41 — C4 skill mechanics/source fidelity audit

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`; executed reference-audit candidate `99e995430fa1bfa237ecc69f6a0b7d91bd5f34d2`.
Previous: [v2.40](DungeonMMO_Roadmap_v2_40_Warden_Disposable_Profile_Handoff_20260924.md).

## Owner's updated skill requirement

The owner wants actual original Chronicle 4 skills' *effects,
damages, passive stats, resource costs and rank-by-rank
mechanics* as the target, with separate DungeonMMO creative
names/visuals, rather than only matching the historical
number of skill ranks. Existing design wording that favored
independent combat values has been explicitly superseded in
[the skill volume design](../design/C4_Skill_Count_Parity_20260922.md).

## Verified: existing effects are NOT equivalent yet

[Initial multi-class evidence-based fidelity audit](
../design/C4_Skill_Effect_Fidelity_Audit_20260924.md)
compares source rows across the five currently fully
rank-scheduled first-transfer branches and finds different
numerical/effect models. Example Elven Knight source
Elemental Heal first class rank (historical skill lv4):
95 source heal power /53 MP; actual Greenward Warden
rank1 heals 24 Roblox HP for 13 mana. Charm original
rank1 threat power132 /37MP is currently 10% personal
threat removal /7 mana. Aggression original first
rank655 power /20 MP becomes 24 game threat /9 mana.
Nine Warden Heavy Armor Mastery ranks use additive
0.6%-per-rank physical mitigation rather than the
original P.Def stat model. Human Warrior Power Smash's
original 90 skill power /22 MP is currently represented
by a 25 Roblox base-damage /21-stamina attack.
Source skill **power is not raw inflicted HP damage**;
blindly replacing `BASE_DAMAGE` with 90 or 95 is not
a correct port of the original formula.

## Executed machine-readable first pass

New historical
`C4SkillEffectReference` contains **24 individually
sourced rank rows** across Elven Knight's three distinct
Elemental Heal/Charm/Aggression families. The new
`C4SkillEffectFidelityAudit.report()` reads *resolved*
actual current combat definitions for each rank rather
than making assumptions from class-level rank counts.
The unpublished disposable Dungeon Rojo build and focused
Studio runner `c4_skill_effect_fidelity_focus.luau`
recorded: `AUDIT_ONLY families=3 ranks=24
different_MP_numbers=24 exact_parity=NOT_CERTIFIED`
and
`VERIFIED_AUDIT_EXECUTION_PARITY_NOT_CERTIFIED`.
See [test evidence](
../testing/c4-skill-effect-source-runtime-differences-20260924.md).

This PASS means the **discrepancy reporter executed**,
not that 24 skills or entire classes meet C4 balance.
The other 32 Elven Knight rank entries and other branches
still need detailed source-by-source numerical and
underlying formula verification. Historical Warden
rank schedule 56/56 is intact; **mechanical parity
remains unverified for all implemented skill families**.

## Next work in priority order

1. Record original class/rank skill effect and resource
   parameters for **every implemented level<=30 skill
   family** with reliable C4 references. Audit base
   Fighter/Mystic plus Human Rogue/Warrior/Knight and
   Elven Scout/Knight, including all passive, proc,
   status, healing, cooldown, equipment and party effects.
2. Implement/test a shared source-semantic stat and
   combat-formula layer before rewriting individual
   skill `BASE_DAMAGE`, `TOTAL_HEAL`,
   `PhysicalReductionPerRank` or threat fractions.
   Reference power and live Roblox HP/threat have
   different units; record any intentional platform
   adaptations rather than claiming exact source parity.
3. Run focused formula and genuine client regressions
   for each reviewed family, including anti-exploit
   guard chip damage, self-healing, stacking, status
   resistance and cross-class combat. A copied source
   coefficient alone does not guarantee C4 balance
   because the Roblox combat loop, armour, HP and
   resources are distinct.
4. Continue remaining original first-transfer paths;
   release cannot be certified from rank counts or
   this limited numeric reference subset.

No game-combat values were changed speculatively by
the audit. No main merge, public publish, production
DataStore changes or unrelated animation edits.
All permanent script and documentation edits were
made through GitHub, desktop used only for disposable
Rojo build and focused Studio inspection.
