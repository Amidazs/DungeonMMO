# DungeonMMO Roadmap v2.72 — C4 Shield Resolution

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.71](
DungeonMMO_Roadmap_v2_71_C4_Physical_Random_Variance_20260925.md).

## Goal

Integrate the reviewed Chronicle 4 shield-block path into the disabled
source-combat provider without applying source damage live.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The reviewed `Formulas.calcShldUse` path:

1. reads the defender's final `SHIELD_DEFENCE_RATE`;
2. multiplies it by the defender DEX bonus;
3. rejects the block when the attacker is outside the shield-facing angle;
4. multiplies the block rate by 1.3 when the attacker uses a bow;
5. compares that rate strictly against an integer `Rnd.get(100)` roll.

The source shield-facing angle is base 120 degrees plus any source
`SHIELD_DEFENCE_ANGLE` stat. No launch-reachable reviewed source effect in
the current level-30 scope modifies that angle, so the represented launch
boundary is 120 degrees.

The reviewed source shield item 102 provides:

- shield defence power 79;
- shield defence rate 20;
- evasion penalty 8.

After a successful block, `calcPhysDam` uses the shield defence power as
additional P.Def. The pinned default `AltPerfectShieldBlockRate` is 5, and
the source perfect-block comparison is strict:

`(100 - 5) < Rnd.get(100)`.

Therefore rolls 96–99 are perfect blocks; roll 95 is not.

## GitHub implementation

The branch already contained the source-only shield arithmetic and reviewed
shield item statistics. This milestone completes the combat-provider wiring.

`C4SourceCombatCalculationService` now:

- resolves shield rate/power only from the authenticated final source stat
  candidate;
- resolves defender DEX bonus from the authenticated source boundary;
- identifies a reviewed bow attacker from the reviewed source loadout;
- owns the 0–99 shield and perfect-shield rolls server-side;
- rejects malformed source shield state;
- refuses to invent shield-facing state;
- applies the resulting shield/perfect-shield state to PDAM calculations.

The existing `physical_skill(...)` call now accepts an optional
server-owned `facing_eligible` argument. It is required only when the
defender actually has a reviewed source shield. Existing no-shield callers
remain compatible.

A shielded PDAM call without authoritative facing state fails closed with:

`ShieldFacingEligibilityRequired`.

## Safety boundary

The source provider remains disabled by default.

The provider does **not** accept a client-provided shield result. The
`facing_eligible` input is a server-semantic input for this source-only
calculation layer. The later live executor must derive it from authoritative
attacker/defender transforms before source combat can be enabled live.

No source damage is applied to HP or CP by this milestone.

## Regression coverage

The pure formula test now covers:

- DEX multiplication;
- bow x1.3 shield-rate multiplier;
- strict shield-roll comparison;
- facing rejection;
- perfect-shield roll 95 rejection;
- perfect-shield roll 96 success.

The source-combat service test now covers:

- reviewed shield source rate/power;
- shield-facing fail-closed behaviour;
- server-owned block/perfect rolls;
- PDAM refusing missing facing state on a shielded defender;
- PDAM applying the returned shield/perfect-shield state to the physical
  formula.

The focused C4 runner is extended through v2.72.

## Local build status

Implementation candidate:

`54362bf7fd74a6b4c38c21055322f97e4fa75647`.

A safe local fast-forward and fresh unpublished Rojo build were completed
before the final runner-label/documentation commits:

- Base: PASS;
- Dungeon: PASS.

Disposable artifacts:

- `%TEMP%\DungeonMMO_v272_Base.rbxl`;
- `%TEMP%\DungeonMMO_v272_Dungeon.rbxl`.

Fresh focused Studio acceptance is GREEN on the source/test candidate:

- Base: **14/14 PASS**;
- Dungeon: **16/16 PASS**;
- formula: **37 assertions PASS**;
- source combat: **21 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Source-combat marker:

`hit=true critical=true variance=true shield=true pdam=true mdam=true heal=true live=false`.

## Next backend implementation

After v2.72 focused Studio acceptance, continue with source magic resolution:

1. exact magic failure/resistance;
2. magic critical resolution;
3. elemental multiplier source inputs;
4. server-owned Spiritshot/Blessed Spiritshot ownership and consumption;
5. PvP/source-target modifiers.

Then add the separately gated live source-combat executor and run targeted
cross-class/player/NPC regressions before any default activation.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
