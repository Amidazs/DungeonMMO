# Collision-grounded NPCs + tracker v3.50 evidence

**Date:** 28 September 2026

## Root cause: floating humanoid placeholders

The previous ground ray accepted non-colliding decorative lobby geometry.
Examples from the published v3.49 map included the Cove geological perimeter
foundation well above the real collision floor.

The corrected runtime uses collision-only floor candidates and no longer uses
large MeshPart bounding boxes as the standing-area clearance test.

Fresh published-cloud Base:

- `COUNT=8`
- `WALKABLE=8`
- `BAD_COLLIDABLE_SUPPORT=0`

Measured visible-body foot gaps to the real collidable support surface are
approximately 0.000-0.005 studs.

## Root cause: janky tracker

The stable v3.49 route still used long segments whose endpoints were grounded
but whose interiors crossed uneven terrain.

Before redesign, measured visual centre gaps reached approximately 3.466
studs.

The v3.50 tracker uses individually floor-projected short markers and arrows.

Fresh published-cloud Worldroot route:

- `GUIDE_PARTS=33`
- `MARKER_PARTS=18`
- `ARROW_PARTS=15`
- `COLLIDABLE=0`
- `FLOOR_MISSES=0`
- `MAX_FLOOR_GAP=0.183`

Movement stability:

- `MOVE_DISTANCE=13.41`
- `CURRENT_PARTS=33`
- `SURVIVORS=33`
- `REPLACEMENTS=0`

## Source/build proof

Gameplay source checkpoint before documentation:

`8e5badfde31d4c39b85bba3110972370c44774f9`

Checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS;
- fresh authored play: PASS;
- fresh published-cloud play: PASS.

Section D remains intentionally blocked pending the owner's real friend test.
