# DungeonMMO backend v2.42 — C4 stat foundation before all-class skills

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.41](DungeonMMO_Roadmap_v2_41_C4_Skill_Effect_Parity_Audit_20260924.md).

The owner clarified the target: original C4 **class-specific level
HP/MP/CP, six primary stats and underlying combat equations**
together with original C4 **skill-rank mechanics and numerical
parameters** for ALL existing classes, not only the Warden.
[Full shared baseline and rollout rules](
../design/C4_All_Classes_Stats_And_Skills_Target_20260924.md).

The currently authored Human/Elf Fighter and Mystic starters,
Human Rogue, Warrior and Knight, Elven Scout and Knight and
legacy playable Rogue/Ranger content are all in scope. Five
first transfers' historical rank schedules are mapped, but
none is certified for exact source effect/formula parity.
Warden's prior 24-rank audit is only an initial subset.

The current implementation's 100-base-HP, five custom
attributes, stamina skill costs and independent defence
percentage formulas are **not C4-character-stat parity**.
Archival class HP chart samples are documented separately,
clearly distinguished from final CON-adjusted displayed HP
and flagged for C4-version corroboration before live values
are migrated. No false 'copy skill power as HP damage' shortcut.

Next backend action: finish C4-versioned, per-level primary
stat/HP/MP/CP source tables for the current starter and
five first-transfer classes; build one shared stat/formula
provider and test safe profile/character migration; only
then replace provisional skill/damage/passive runtime
numbers across ALL implemented classes and run per-rank
and genuine client regressions. Preserve owner-authenticated
loot, the no-near-zero-damage shield stacking contract and
one gathering/one creation profession constraint.

No live stat numbers were changed in this requirements
commit; v2.40 gameplay and v2.41 mismatch audit retain
their *separate* scoped evidence. No main merge/publish/
production DataStore changes/animation edits.
