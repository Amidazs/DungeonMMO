# DungeonMMO Roadmap v2.73 — C4 Magic Failure and Critical Resolution

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.72](
DungeonMMO_Roadmap_v2_72_C4_Shield_Resolution_20260925.md).

## Goal

Continue the disabled source-combat migration with Chronicle 4 magical
critical resolution and the exact optional magic-failure algorithm.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The reviewed `Formulas.calcMagicDam` path:

- computes base MDAM from final M.Atk/M.Def and source skill power;
- checks the optional `MagicFailures` configuration;
- if the first magic-success roll fails, a second independent success roll
  may downgrade failure to half damage when the target is no more than nine
  levels above the attacker;
- otherwise a full resistance produces one damage;
- magic critical multiplies successful damage by four.

`calcMagicSuccess` uses:

`round(pow(1.3, targetLevel - magicLevel) * 100)`

and succeeds only when a server random integer from 0 through 9999 is strictly
greater than that threshold.

The pinned configuration defaults `MagicFailures=false`. Therefore the
algorithm is represented exactly, but normal launch-source MDAM does not
randomly fail unless that source setting is deliberately changed later.

The reviewed magical critical path:

- starts from the character template M.Crit base of 8 for the current scope;
- truncates the final calculator value to an integer;
- caps at `MaxMCritRate=300`;
- compares strictly against a server random integer from 0 through 999.

A roll equal to the critical chance does not crit.

## GitHub implementation

`C4UnifiedStatReference` now carries the reviewed base:

- `MAGICAL_CRITICAL_RATE = 8`.

`C4CombatFormulaReference` now provides:

- `resolve_magic_success(...)`;
- `resolve_magic_failure(...)`;
- `magic_critical_rate_per_thousand(...)`;
- `resolve_magic_critical(...)`;
- the pinned `MagicFailures=false` default.

`C4SourceCombatCalculationService.magic_skill(...)` now:

- resolves final M.Crit only from the authenticated source stat candidate;
- owns the 0–999 M.Crit roll server-side;
- resolves the source skill's actual `magicLvl`;
- represents the exact optional two-roll magic-failure path;
- honours the pinned disabled-by-default magic-failure setting;
- feeds failure and magical critical state into the existing C4 MDAM formula;
- exposes detached source evidence without applying damage live.

## Fresh acceptance

Candidate:

`6f5fe20ac26d3c01b6c5938bf87127228b53da59`.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS;
- `git diff --check`: PASS.

Fresh focused Studio:

- Base: **14/14 PASS**;
- Dungeon: **16/16 PASS**;
- formula: **46 assertions PASS**;
- source combat: **23 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Source-combat marker:

`hit=true critical=true variance=true shield=true magiccrit=true magicfailure=true pdam=true mdam=true heal=true live=false`.

## Safety boundary

The source-combat provider remains OFF by default.

No live source HP/CP damage is applied. No client may provide M.Crit rolls,
magic-failure rolls, source stats or source skill power.

## Next backend implementation

Next integrate the reviewed C4 elemental damage multiplier and its
source-owned skill element/target vulnerability inputs. After elemental
resolution: server-owned Soulshot/Spiritshot/Blessed Spiritshot ownership and
consumption, PvP/source-target modifiers, then a separately gated live source
combat executor.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
