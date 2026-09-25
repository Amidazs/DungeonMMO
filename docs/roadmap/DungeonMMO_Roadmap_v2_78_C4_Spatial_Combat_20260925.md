# DungeonMMO Roadmap v2.78 — C4 Spatial Combat Inputs

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.77](
DungeonMMO_Roadmap_v2_77_C4_PDAM_Criticals_20260925.md).

## Goal

Close the remaining source spatial hit-condition and shield-facing inputs before
building the separately gated live source-combat executor.

## Reviewed C4 behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The reviewed C4 hit-condition source uses:

- Front: +0%;
- Side: +5%;
- Back: +10%;
- High ground above +50 source units: +3%;
- Low ground below -50 source units: -3%;
- Night: -10%;
- Rain data exists at -3%, but the reviewed source explicitly has no active
  rain support.

Front and back classification use 45-degree half-arcs. All remaining
horizontal directions are Side.

Shield facing uses the defender's source shield arc. The launch source base is
120 degrees, meaning +/-60 degrees around defender forward.

## Implementation

A pure `C4CombatSpatialReference` now provides:

- front/side/back classification from authoritative transforms;
- exact reviewed hit-condition composition;
- exact source elevation threshold behaviour;
- server-owned night-state input;
- exact shield-facing eligibility.

The source combat provider now requires trusted spatial context for ordinary
hit resolution and derives shield-facing eligibility itself.

The context deliberately includes `HeightDeltaSourceUnits` instead of
assuming one Roblox stud equals one C4 coordinate unit. The later live executor
must own that conversion explicitly.

Ordinary source attacks now report:

- condition multiplier;
- front/side/back relation;
- elevation relation;
- night state;
- integrated spatial authority.

Shielded PDAM also consumes the same server-owned spatial context instead of a
caller-selected boolean.

## Fresh acceptance

Candidate:

`0b5b724e258d4d6b032c132d148c69d62e1c315e`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Fresh focused Studio:

- Base: **16/16 PASS**;
- Dungeon: **18/18 PASS**;
- combat formula: **51 assertions PASS**;
- spatial reference: **11 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: **PASS**.

## Next backend implementation

Build the separately gated live source-combat executor.

That executor must:

1. remain OFF by default;
2. require source resource cutover on participating players;
3. derive attacker/defender transforms server-side;
4. map Roblox elevation into explicit source coordinate units;
5. derive source-equivalent night state server-side;
6. call the already accepted source calculation provider;
7. route playable damage through CP before HP;
8. never accept client damage, hit, critical, shield or shot outcomes;
9. retain a rollback path to the current combat system.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
