# C4 numerical skill-fidelity reference test — 24 September 2026

Branch `wip/phase-4-test-hud-integration-v1`, executed source commit
`99e995430fa1bfa237ecc69f6a0b7d91bd5f34d2`. Runner:
`scripts/studio/c4_skill_effect_fidelity_focus.luau`.
Unpublished disposable Dungeon Rojo build and Studio
audit log:
`%TEMP%\\DungeonMMO_v241_c4_skill_fidelity_audit\\fidelity.log`.

## Reviewed actual rank rows

- C4 Elven Knight Elemental Heal source ranks 4-12:
  original skill powers
  95/100/106/118/124/130/143/150/157 and MP
  53/57/59/62/65/69/75/79/83. Current Warden
  learned ranks1-9 heal
  24/29/34/39/44/49/54/59/64 game HP,
  current mana13/13/13/16/16/16/19/19/19.
- C4 Charm original skill ranks1-9: source powers
  132/137/143/153/159/164/176/182/188 and MP
  37/38/39/40/42/43/47/48/49; runtime
  threat-reduction fractions0.10-0.30 by 0.025,
  game mana7 at every rank.
- C4 Aggression ranks1-6: original source powers
  655/679/703/752/777/803 and MP
  20/21/22/23/24/25; runtime threat bonus
  24/32/40/48/56/64, game mana9 at every rank.

C4 source:
https://l2hub.info/c4/classes/elven_knight
and
https://l2hub.info/c4/skills/58-elemental-heal%3A12/levels .

## Executed result

`C4SkillEffectFidelityAudit.report()` iterated actual
`SkillProgressionDefinitions` and
`SkillDefinitions.get_for_rank()` for all 24 rows,
printing historical and live numeric fields together
and explicitly `ExactC4ParityCertified=false`.
Studio log ends:
`[C4 FIDELITY] AUDIT_ONLY families=3 ranks=24
different_MP_numbers=24 exact_parity=NOT_CERTIFIED`
and
`[C4 FIDELITY]
VERIFIED_AUDIT_EXECUTION_PARITY_NOT_CERTIFIED`.

The rank-comparison test did **not** assert that C4
heal/threat *power* should equal Roblox HP healing or
one-to-one threat. These are different semantic units
until an original formula/stat engine is implemented.
No claim that 24 of 56 ranks have matching original
effects, nor that the whole C4 catalogue has been
mechanically checked. Numeric mismatches are factual
observations only. All original gameplay tests are
separately scoped and were not rerun here.
