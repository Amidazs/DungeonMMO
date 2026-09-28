# Friend-test NPC + guide stability v3.49 evidence

**Date:** 28 September 2026

## Scope

Pre-Section-D correction pass for two owner-reported TEST Base regressions:
unreachable/elevated quest-giver presentation and janky tutorial-guide refresh.

## Authoritative NPC acceptance

Authored TEST Base play returned:

- `COUNT=8`
- `BAD_SUPPORT=0`
- `UNWALKABLE=0`

Measured foot-to-support gaps were approximately 0.000-0.005 studs for all
eight quest-giver placeholders.

After publication, a brand-new cloud-loaded TEST Base returned:

- `COUNT=8`
- `WALKABLE=8`
- `SUPPORTED=8`
- `HUMANOIDS=8`

The cloud run had normal Base startup and no quest-giver runtime exception.

## Tutorial-guide acceptance

Worldroot tutorial route:

- `GuideParts=26`
- `ArrowParts=15`
- `NeonParts=26`
- `CollidableParts=0`

Stable-refresh probe:

- player movement: `6.00` studs;
- old refresh threshold: `5` studs;
- original pieces surviving: `26/26`;
- replacement pieces: `0`.

## Fresh cloud source proof

Freshly opened TEST Base `134132328219009` returned:

- `StableReroute=true`
- `RouteDistanceLogic=true`
- `NoClimbGiverPath=true`
- `GroundSlopeGate=true`

## Build/source proof

Gameplay source checkpoint before documentation:

`c6fdba9da528a2cf18abd55be094f9377755d9cf`

Checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS.

Section D remains intentionally blocked pending the owner's two-player test.
