# DungeonMMO Roadmap v2.68 — C4 Source Combat Calculation Provider

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.67](
DungeonMMO_Roadmap_v2_67_C4_Reversible_Resource_Cutover_20260925.md).

## Goal

Start the next migration phase without replacing live DungeonMMO damage yet.

The project now has a disabled server-only provider that combines the
authenticated final C4 stat candidate with the pinned original skill rank and
the already-reviewed C4 physical, magical and instant-heal formulas.

This keeps historical skill `power` as formula input rather than treating it
as direct Roblox HP damage.

## GitHub implementation

Added
`src/ServerScriptService/Core/Services/C4SourceCombatCalculationService.luau`.

The provider is disabled by default and currently supports three deterministic
source families:

- `PDAM` physical skill damage;
- `MDAM` magical skill damage;
- instant `HEAL`.

Every calculation requires:

- an authenticated server-owned character;
- zero C4 cutover prerequisite blockers;
- the final source stat candidate;
- a genuinely owned creative skill rank;
- an exact reviewed creative-to-C4 source rank;
- the pinned C4 skill-effect row.

No caller supplies source P.Atk, P.Def, M.Atk, M.Def, source skill ID, source
rank or source power.

## Physical damage

For `PDAM` the provider uses:

- attacker `PHYSICAL_ATTACK`;
- defender `PHYSICAL_DEFENCE`;
- exact source skill `power`;
- `C4CombatFormulaReference.physical_damage`.

The initial provider intentionally keeps these later inputs neutral:

- Soulshot;
- critical;
- weapon random range;
- race/weapon vulnerability;
- PvP multiplier;
- Noble PvP bonus.

Those must come from authoritative runtime state before live use.

## Magical damage

For `MDAM` the provider uses:

- attacker `MAGICAL_ATTACK`;
- defender `MAGICAL_DEFENCE`;
- exact source skill `power`;
- `C4CombatFormulaReference.magic_damage`.

The initial provider keeps magic failure, Spiritshot/Blessed Spiritshot,
critical, elemental and PvP multipliers neutral.

## Healing

For `HEAL` the provider finds the actual source `Heal` effect power and
uses `C4CombatFormulaReference.heal_amount`.

Caster M.Atk is deliberately not used because the reviewed C4
`EffectHeal.java` path applies heal effect power directly.

Spiritshot heal multipliers remain neutral until shot ownership/consumption is
server-authoritative.

## Safety boundary

`C4SourceCombatCalculationService` has its own disabled-by-default gate.

Even while enabled for tests, results are marked:

- `SourceOnly=true`;
- `LiveApplied=false`.

The provider does not:

- call Humanoid.TakeDamage;
- change HP;
- spend MP;
- start cooldowns;
- apply threat;
- apply status effects;
- change CP;
- publish or persist anything.

Unsupported skill families such as `BLOW`, `DRAIN`, debuffs and control
effects remain explicitly outside this milestone.

## Regression coverage

Added
`C4SourceCombatCalculationServiceTest.server.luau`.

It verifies:

- default provider gate is OFF;
- disabled provider cannot calculate a hit;
- owned Human Fighter `IronCleave` rank 1 resolves to source Power Strike
  skill 3 rank 1, power 25;
- PDAM output equals the direct pinned physical formula using authenticated
  final P.Atk/P.Def;
- owned Human Mystic `WindStrike` rank 1 resolves to source Wind Strike
  1177 rank 1, power 12;
- MDAM output equals the direct pinned magic formula using authenticated
  final M.Atk/M.Def;
- owned `MageHeal` rank 1 resolves to source Self Heal 1216 rank 1,
  direct Heal power 42;
- a PDAM skill cannot enter the MDAM formula;
- an unowned creative rank is rejected.

## Fresh local acceptance

Commit tested:

`0e859222eb47aba6e8ffdf942fda4c26a208e4bd`.

Fresh Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Focused Studio:

- Base: **13/13 PASS**;
- Dungeon: **15/15 PASS**.

New source-combat test:

`[C4 Source Combat] SOURCE_ONLY_PASS: 9 assertions
pdam=true mdam=true heal=true live=false`

Evidence directory:

`%TEMP%\DungeonMMO_v268_source_combat`

No Roblox publish, production DataStore mutation or main merge occurred.

## Next backend implementation

The next safe step is to supply the remaining source formula inputs before
applying source damage to real HP:

1. server-owned hit/miss from final Accuracy/Evasion;
2. physical critical roll and C4 critical-power components;
3. weapon random-damage range;
4. shield/perfect-shield source handling;
5. magic failure/resistance result;
6. elemental vulnerability;
7. shot ownership and consumption;
8. PvP/source-target modifiers.

After those inputs are source-authoritative, add a **separate disabled live
combat executor** that can apply PDAM/MDAM/HEAL results to real players already
running the reversible v2.67 source resource mode.

Existing Roblox combat stays the default path until that executor passes
targeted and cross-class real-client regressions.
