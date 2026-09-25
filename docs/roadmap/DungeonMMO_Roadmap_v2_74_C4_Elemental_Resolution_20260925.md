# DungeonMMO Roadmap v2.74 — C4 Elemental Resolution

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.73](
DungeonMMO_Roadmap_v2_73_C4_Magic_Failure_Critical_20260925.md).

## Goal

Integrate Chronicle 4 magical elemental vulnerability into the disabled
source-combat provider for authenticated player targets.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

`Formulas.calcElementalVulnerability` selects the target vulnerability stat
from the source skill element:

- FIRE -> `FIRE_VULN`;
- WIND -> `WIND_VULN`;
- WATER -> `WATER_VULN`;
- EARTH -> `EARTH_VULN`;
- HOLY -> `HOLY_VULN`;
- DARK -> `DARK_VULN`.

The target template provides the base value and the C4 stat calculator then
applies matching vulnerability modifiers.

The current player-character source template defaults all six elemental
vulnerabilities to 1.0. Wind Strike rank 1 is explicitly `element=WIND`, so
it resolves against the target's final `WIND_VULN`.

## GitHub implementation

`C4UnifiedStatReference` now includes all six authenticated source elemental
vulnerability bases at 1.0, allowing later source passives/active effects to
compose in the existing calculator.

`C4CombatFormulaReference.elemental_vulnerability(...)` now maps the exact
six C4 elements to their final target source vulnerability stat and fails
closed on unsupported elements or missing values.

`C4SourceCombatCalculationService.magic_skill(...)` now:

- takes the source element only from the reviewed source skill rank;
- takes target vulnerability only from the authenticated final source stat
  candidate;
- applies the resolved multiplier to the C4 MDAM formula;
- exposes source element and multiplier evidence;
- remains source-only and disabled by default.

This milestone covers the current source-ready **player-target** provider.
NPC-template elemental vulnerabilities remain a later live/NPC source-boundary
concern and are not guessed here.

## Fresh acceptance

Candidate:

`a1684927b9df6489644fa469f00a550855ae4a93`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- `git diff --check`: PASS.

Fresh Studio:

- Base: **14/14 PASS**;
- Dungeon: **16/16 PASS**;
- formula: **49 assertions PASS**;
- source combat: **24 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Source-combat marker:

`hit=true critical=true variance=true shield=true magiccrit=true magicfailure=true element=true pdam=true mdam=true heal=true live=false`.

## Safety boundary

No source combat result is applied to live HP/CP. No client may provide source
skill elements or target vulnerability values.

## Next backend implementation

Next integrate server-authoritative shot ownership/consumption:

1. Soulshot for physical damage;
2. Spiritshot/Blessed Spiritshot for magic damage;
3. Spiritshot/Blessed Spiritshot heal modifiers;
4. exact consumption and fail-closed inventory authority.

After shots: PvP/source-target modifiers, then a separately gated live source
combat executor.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
