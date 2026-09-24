# Chronicle 4 skill mechanics fidelity — initial evidence-based audit

Date: 24 September 2026. Current baseline:
`9a5c5fb905e00056c381159c7bd798313c7c759a`. Scope is the currently authored Human/Elf starting classes
and five scheduled level-20 first-transfer paths **through level 30**.
**Finding: skill effect, damage, mana and passive parity is NOT
established.** A C4 rank count is NOT a C4 damage/effect calculation.

## Historical sources and the limitations of numeric equivalence

Historical sources reviewed for this first pass:
- [C4 Elven Knight](https://l2hub.info/c4/classes/elven_knight);
- [C4 Human Warrior](https://l2hub.info/c4/classes/warrior);
- [C4 Human Knight](https://l2hub.info/c4/classes/knight);
- [C4 Human Rogue](https://l2hub.info/c4/classes/rogue);
- [C4 Elven Scout](https://l2hub.info/c4/classes/elven_scout);
- [C4 patch notes](https://lineage2wiki.org/c4/patch-notes/).

These sources support *specific* C4 historical rank powers, MP
costs, unlock levels and qualitative effects. They do not establish
every underlying hit, stat, buff, resist or reuse-time formula
needed for exact combat equivalence. **Source skill power is NOT
direct target HP damage.** A standalone source skill-power value
cannot be pasted into `BASE_DAMAGE` without the corresponding
original attack/defence/skill formula and stat scales. The
DungeonMMO combat system has weighty active blocking, dodge
i-frames, stamina, custom HP pools and instanced encounters,
which introduce further balance differences even if historical
numeric parameters were ported.

## Demonstrated discrepancies in currently live gameplay

| C4 reference, exact historical row | Current DungeonMMO analogue | Assessment |
| --- | --- | --- |
| Elven Knight Elemental Heal source rank 4, available at level 20: power **95**, **53 MP** | GreenwardWardenElementalHeal rank 1: `TOTAL_HEAL=24`, `MANA_COST=13`, `COOLDOWN_SECONDS=6` | Both MP number and effect scale differ; cannot certify same heal formula or cost. |
| Elven Knight Charm source rank 1: power **132**, **37 MP** | GreenwardWardenCharm rank 1: fixed **10%** own-threat removal and **7 mana** | C4 power-based hate reduction is not proved equivalent to a fixed percentage. |
| Elven Knight Aggression source rank 1 at level 24: power **655**, **20 MP** | GreenwardWardenAggression rank 1: **24** threat, **9 mana** | Same intended taunt role, different threat economy and numeric cost. |
| Elven Knight Defense Aura level 20: `Effect 2`, **20 MP**, temporary physical defence increase | GreenwardWardenDefenseAura: **7%** Roblox physical guard for 120 s, **10 mana** | Source effect category and duration/formula are not established as identical. |
| Elven Knight Heavy Armor Mastery ranks 1-9: adds physical defence with real heavy gear | GreenwardWardenHeavyArmorTraining: `PhysicalReductionPerRank=0.006` | Flat/stat defence vs additive Roblox percentage reduction: not exact C4 passive math. |
| Human Warrior Power Smash source rank 1, level 20: **90 skill power**, **22 MP**, sword/blunt restriction | IronvowDrivingStrike rank 1: **25 BASE_DAMAGE**, **21 stamina**, 7 s cooldown, one-handed sword-tag progression gate | Different resource and effect-stat model; source power is not direct HP damage. |
| Human Knight Shield Stun rank 1: **22 MP**, shield required, stun with same-status immunity | OathguardShieldImpact rank 1: **19 stamina**, `BASE_DAMAGE=7`, `STAGGER_SECONDS=0.70` | Present stun/stagger, power and costs are not established to match C4. |
| Human Rogue/Elven Scout: rank-graded dagger/bow attacks have distinct C4 **skill powers**, **MP costs**, weapon conditions; Rogue Unlock rank 1 needs **two keys** with 30% success | Wayfinder/Scout analogues currently use Roblox attack/evasion/lockpicking systems; source mapping is inventory/rank based | Actual damage, resource, proc, item-consumption and lock success formula parity not certified. |

Source for the Elven Knight rows:
https://l2hub.info/c4/classes/elven_knight
and for source heal power/MP rank values:
https://l2hub.info/c4/skills/58-elemental-heal%3A12/levels .
Human Warrior: https://l2hub.info/c4/classes/warrior .
Human Knight: https://l2hub.info/c4/classes/knight .
Human Rogue: https://l2hub.info/c4/classes/rogue .
Elven Scout: https://l2hub.info/c4/classes/elven_scout .

The [earlier rank-volume document](C4_Skill_Count_Parity_20260922.md)
explicitly instructed keeping separate custom combat numbers; that
conflicts with the player's **newer** request to faithfully emulate
historical C4 mechanics. See the appended superseding direction
in that document. Preserve unrelated production gameplay until
each source stat is verified and the shared formula is implemented;
never silently multiply original skill power by an arbitrary
conversion factor or claim that a numerical cost alone proves
the resource economies match.

## New machine-readable reference and reproducible mismatch report

- `src/ReplicatedStorage/Core/Shared/C4SkillEffectReference.luau`:
  24 independently checked original Elven Knight rank power/MP
  rows across Elemental Heal, Charm and Aggression. The first
  nine Elven Knight Elemental Heal ranks in this cap are C4
  skill levels **4-12**, *not* levels 1-9.
- `src/ReplicatedStorage/Core/Shared/C4SkillEffectFidelityAudit.luau`:
  reads actual resolved current rank values (not copied constants)
  and emits explicit source/runtime rows. Power vs Roblox magnitude
  are intentionally marked as different units.
- `C4SkillEffectFidelityAuditTest.server.luau` and the focused
  `c4_skill_effect_fidelity_focus.luau` runner: report 24 actual
  source/runtime comparisons in an unpublished Studio build.
  A passing **audit execution** is NOT a passing mechanics
  fidelity or game-balance test.

These 24 rank rows are a **documented first pass**, not a claim
that the other 32 Warden rank entries, base-class skills or
four other scheduled first-transfer classes have identical
effects. Counts and stored rank levels alone cannot prove this.

## Implementation and certification plan

1. Complete C4 source-row inventories per implemented skill
   family: rank, historical skill power, MP/HP cost, SP,
   duration, reuse, target type, weapon/armour restriction,
   passive stat type, resistance, effect chance and stacking.
   Label any field not independently sourced **unknown**.
2. Reconcile class-to-class shared mechanics using original C4
   stat semantics (P.Atk/P.Def, M.Atk/M.Def, shield success,
   stun/hold resistance, hate and heal formula), with separate
   anti-exploit validation. For mechanics that cannot be
   represented faithfully in Roblox, document deliberate
   deviations and test their resulting balance.
3. Replace the provisional one-off percentages and `BASE_DAMAGE`
   conversion factors only after the underlying formula/stat
   model is implemented. Preserve existing safety invariants:
   damage cannot be negated nearly to zero by stacking block,
   passives and buffs, self-cures cannot produce free healing,
   and threat changes do not mint damage/quest drops.
4. Run per-rank pure formula fixtures first, then focused real
   client tests for buffs, debuffs, pets/party, recovery, AoE,
   armour and shield, finally cross-class/PvP and resource
   economy. Only mark exact parity when both sourced data and
   actual runtime effects match in comparable units; otherwise
   label the specific deviation.
5. Audit all currently playable Human/Elf base skills plus
   Human Rogue, Elven Scout, Human Warrior, Human Knight and
   Elven Knight first-transfer families, then extend to every
   original class branch. Avoid a blanket certification from
   an incomplete subset.

**Current certification: zero skill families have verified
full C4 mechanical and numeric parity.** This is an evidence
status, not a count of unimplemented skills. No production
combat values were changed as part of this reference audit.
