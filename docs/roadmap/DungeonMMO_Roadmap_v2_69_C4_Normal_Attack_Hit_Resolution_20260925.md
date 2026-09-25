# DungeonMMO Roadmap v2.69 — C4 Normal Attack Hit Resolution

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.68](
DungeonMMO_Roadmap_v2_68_C4_Source_Combat_Calculation_Provider_20260925.md).

## Goal

Continue the C4 combat migration without changing live DungeonMMO damage.

This milestone adds the exact server-owned C4 normal-attack hit/miss roll on
top of the authenticated final source Accuracy and Evasion values.

The implementation deliberately does **not** route PDAM skills through this
normal-attack hit check. The reviewed C4 `SkillPdam` handler calculates PDAM
directly; `calcHitMiss` belongs to ordinary attack handling.

## Source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The C4 source:

- calculates `delta = Accuracy - Evasion`;
- maps that delta to the source hit table;
- applies the source positional/environment condition multiplier;
- clamps the final chance to 275–980 per thousand;
- rolls an integer from 0 through 999;
- misses only when final hit chance is strictly lower than the roll.

A roll equal to the chance still hits.

Reviewed hit-condition source values are:

- front: 0%;
- side: +5%;
- back: +10%;
- high ground: +3%;
- low ground: -3%;
- night: -10%;
- rain: -3% in data, although the reviewed source has no rain support active.

## GitHub implementation

`C4CombatFormulaReference` now provides:

- `hit_chance_with_condition(...)`;
- `resolve_normal_attack_hit(...)`.

`C4SourceCombatCalculationService` now provides:

- `normal_attack_hit(attacker_user_id, defender_user_id)`.

The service:

- derives Accuracy and Evasion from the authenticated final source candidate;
- owns the 0–999 random roll server-side through a private `Random`;
- exposes chance/roll evidence for verification;
- remains behind the existing disabled-by-default source-combat gate;
- remains source-only and never changes HP, MP, CP, cooldowns or threat.

## Deliberate remaining limitation

Roblox positional/elevation/night equivalents are not yet mapped into a
server-owned C4 hit-condition resolver.

Therefore the live provider currently uses a neutral condition multiplier of 1
and reports:

- `SourceConditionMultiplier=1`;
- `SourceConditionIntegrated=false`.

The pure formula layer already supports the exact multiplier and final source
caps, so later runtime integration does not require changing the source
arithmetic.

## Automated coverage

Formula tests now cover:

- neutral Accuracy/Evasion hit table;
- +5% style condition multiplication;
- 98% final cap;
- equal-roll hit semantics;
- above-chance miss semantics.

Source-combat provider tests now cover:

- authenticated final source Accuracy/Evasion;
- server-owned integer roll range;
- exact hit/miss comparison;
- neutral condition status being explicit;
- no live application.

The focused runner is extended through v2.69 and now includes the pure formula
test alongside the source-combat service test.

## Local build status

GitHub candidate:

`6c45baec295194ec1fc83535c1c35c92f57c629d`.

The Phase 4 HUD worktree was safely fast-forwarded from GitHub after confirming
there were no tracked or staged local changes. Two unrelated quadruped Python
`__pycache__` directories remain untracked and untouched.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Artifacts:

- `%TEMP%\DungeonMMO_v269_Base.rbxl`;
- `%TEMP%\DungeonMMO_v269_Dungeon.rbxl`.

Focused Studio execution is still required before calling v2.69 GREEN.

## Next backend implementation

After v2.69 focused Studio acceptance:

1. add server-owned normal physical critical roll from final source critical
   rate;
2. map the source critical-power additive/multiplicative components;
3. add source weapon random-damage range;
4. add shield/perfect-shield source handling;
5. add magic failure/resistance;
6. add source elemental resolution;
7. add server-owned shot ownership/consumption;
8. add PvP/source-target modifiers.

Only after these are authoritative should a separate disabled live source
combat executor apply source results to real HP/CP.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
