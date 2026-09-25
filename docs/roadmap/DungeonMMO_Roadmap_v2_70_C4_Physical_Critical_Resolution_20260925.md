# DungeonMMO Roadmap v2.70 — C4 Physical Critical Resolution

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.69](
DungeonMMO_Roadmap_v2_69_C4_Normal_Attack_Hit_Resolution_20260925.md).

## Goal

Continue the disabled source-combat migration with exact ordinary physical
critical resolution before any source result is allowed to change live HP.

This milestone covers normal weapon attacks only. It does not claim that PDAM
skill criticals or magical criticals are complete.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The reviewed C4 source establishes:

- `CharStat.getCriticalHit` truncates final PHYSICAL_CRITICAL_RATE to an
  integer and caps it at `Config.MAX_PCRIT_RATE`;
- C4 `MaxPCritRate` defaults to 500, or 50%;
- `Formulas.calcCrit(rate)` succeeds only when `rate > Rnd.get(1000)`;
- therefore an integer 0–999 roll equal to the critical rate does **not** crit;
- `calcPhysDam` reads PHYSICAL_CRITICAL_POWER from neutral base 1;
- `calcPhysDam` reads PHYSICAL_CRITICAL_POWER_ADD from neutral base 0;
- critical damage applies the source multiplier and additive power through the
  existing physical-damage formula.

The current pinned skill data already contains reviewed critical-power
modifiers such as Critical Power and Vicious Stance.

## GitHub implementation

`C4UnifiedStatReference` now carries the exact source-neutral calculator
bases:

- `PHYSICAL_CRITICAL_POWER = 1`;
- `PHYSICAL_CRITICAL_POWER_ADD = 0`.

That allows actually-owned passives and actually-active effects to modify the
same authenticated source candidate instead of applying a second custom
critical-damage layer.

`C4CombatFormulaReference` now provides:

- `physical_critical_rate_per_thousand(...)`;
- `resolve_physical_critical(...)`.

`C4SourceCombatCalculationService` now provides:

- `normal_attack_critical(attacker_user_id, defender_user_id)`.

The provider:

- derives final critical rate from the authenticated source candidate;
- owns the 0–999 random roll server-side;
- derives critical-power multiplier/additive values from that same source
  candidate;
- requires the target to be source-ready;
- remains source-only and does not modify HP, CP, MP, threat or cooldowns.

## Explicit remaining critical limits

This milestone does **not** claim full critical integration.

Still explicit:

- `PhysicalSkillCriticalIntegrated=false`;
- `MagicCriticalIntegrated=false`;
- target-specific critical modifiers are not yet integrated;
- generic `CriticalResolutionIntegrated=false` remains conservative until
  those separate paths are complete.

## Fresh focused Studio acceptance

Production candidate was built at:

`0e96be70f443e2e4e4cadc29615a94e8b02d69b3`.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Corrected targeted Studio focus:

- Base: **14/14 PASS**;
- Dungeon: **16/16 PASS**;
- C4 Combat Formula: **26 assertions PASS**;
- C4 Source Combat: **13 assertions PASS**.

An initial expanded runner also invoked the older
`C4UnifiedStatReferenceTest`, which contains a stale pre-current-armour
expectation for Knight heavy mastery. That unrelated assertion failed in both
places while every v2.70 critical test passed. The stale suite was removed from
this targeted runner rather than altering unrelated production behaviour.
Only test-scope files changed after the production build; the v2.70 production
modules remained identical.

Current feature-branch head after that test-scope cleanup:

`8b6252bc6fce485c06f077381d86906050b558f4`.

## Safety boundary

The source-combat provider is still OFF by default.

Nothing in v2.70:

- applies live source damage;
- consumes shots;
- changes production saves;
- publishes a place;
- merges to `main`;
- changes the animation project.

## Next backend implementation

Next integrate exact C4 weapon random-damage variance.

The reviewed source uses each active weapon's `rnd_dam` value and a
server-owned inclusive integer roll from `-rnd_dam` through `+rnd_dam`,
producing `1 + roll / 100`. Unarmed attacks use
`5 + floor(sqrt(level))` as the range.

After random damage:

1. shield/perfect-shield source handling;
2. magic failure/resistance;
3. elemental resolution;
4. Soulshot/Spiritshot/Blessed Spiritshot ownership and consumption;
5. PvP/source-target modifiers;
6. separately gated live source combat executor.
