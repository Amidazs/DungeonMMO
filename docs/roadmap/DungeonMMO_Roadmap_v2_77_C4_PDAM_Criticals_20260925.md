# DungeonMMO Roadmap v2.77 — C4 PDAM Skill Criticals

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.76](
DungeonMMO_Roadmap_v2_76_C4_Normal_Attack_PvP_Composition_20260925.md).

## Goal

Close the remaining physical-skill critical branch in the reviewed C4 PDAM
handler before live source-combat work.

## Reviewed C4 behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

`SkillPdam` does not use the ordinary character physical-critical rate.
Instead, when the source skill has `baseCritRate > 0`, it calculates:

`baseCritRate * 10 * STR bonus`

and passes that raw value directly to `calcCrit`.

The comparison is strict against a server random integer from 0 through 999.
The normal `MaxPCritRate=500` cap is not applied to this skill-specific rate.

When the PDAM skill critical succeeds, the source first calculates ordinary
`calcPhysDam(..., crit=false, ...)` and then doubles the final damage. It does
not use the normal physical critical-power/additive branch.

## GitHub implementation

The authenticated migration boundary now exposes the source STR bonus alongside
the already-used DEX bonus.

`C4CombatFormulaReference` now provides
`resolve_physical_skill_critical(...)` with the exact uncapped source
comparison.

`C4SourceCombatCalculationService.physical_skill(...)` now:

- reads authored `baseCritRate`, defaulting to the source PDAM default zero;
- uses the authenticated source STR bonus when the authored rate is positive;
- owns the 0–999 roll server-side;
- runs ordinary PDAM first;
- doubles the final PDAM result only after a successful skill critical;
- exposes rate/roll/source evidence;
- remains source-only and never changes live HP/CP.

The current reviewed Power Strike/Iron Cleave rank has source
`baseCritRate=0`, so it correctly remains non-critical while the general
source rule is now available for future reviewed PDAM skills.

## Fresh acceptance

Candidate:

`971dbd3dffc41cfee64b52ee1efc7c2e57f3d704`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Fresh focused Studio:

- Base: **15/15 PASS**;
- Dungeon: **17/17 PASS**;
- combat formula: **51 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: **PASS**.

Source-combat marker includes:

`pdamcrit=true`.

## Remaining source-combat boundaries

The important remaining gaps before a broad live executor are now mainly
world/target context rather than core player-vs-player arithmetic:

- source hit-condition position/elevation/night resolution;
- authoritative shield-facing resolution from world transforms;
- NPC race-specific physical modifiers;
- any future target-conditioned critical effects not represented in the
  current launch scope;
- live damage application.

## Next backend implementation

Close the source spatial condition/facing inputs, then build the separately
gated live source-combat executor and run controlled player/NPC cutover tests.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
