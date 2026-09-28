# Fluid player-relative tutorial tracker v3.51 evidence

**Date:** 29 September 2026

## Reported requirement

The tutorial target is static, but its source must move with the player. The
route therefore needs to update visually without the repeated destroy/rebuild
behaviour that caused visible snapping.

## Accepted implementation

Pathfinding now supplies a stable corridor. The visual source is driven by the
player's live progress along that corridor.

Visuals are pooled and reused. No ordinary forward movement destroys or
recreates markers or arrows.

Each visible marker and arrow centre is projected onto collidable floor every
frame after progress sampling. This avoids the stair/slope bridging seen when
world-space CFrame interpolation was used.

## Fresh published-cloud proof

TEST Base `134132328219009`:

- `PLAYER_MOVE=12.24`
- `SAME_MARKER_INSTANCE=true`
- `MARKER_SOURCE_ADVANCE=12.24`
- `MAX_MARKER_STEP=1.085`
- `GUIDE_PARTS=42`
- `MARKER_PARTS=24`
- `ARROW_PARTS=18`
- `COLLIDABLE=0`
- `FLOOR_MISSES=0`
- `MAX_FLOOR_GAP=0.090`
- `SURVIVORS=42`
- `REPLACEMENTS=0`

NPC regression proof:

- `NPC_COUNT=8`
- `NPC_WALKABLE=8`
- `NPC_BAD_SUPPORT=0`

## Source/build proof

Gameplay source checkpoint before documentation:

`c0ca45547c49560c42ac38adb9039345e719d8ee`

- `git diff --check`: PASS;
- Base build: PASS;
- published Base build: PASS;
- authored motion/floor validation: PASS;
- clean published-cloud validation: PASS.

Section D remains blocked pending the owner's real friend test.
