# DungeonMMO Roadmap v3.51
## FLUID PLAYER-RELATIVE TUTORIAL TRACKER GREEN

**Date:** 29 September 2026

This checkpoint corrects the remaining tutorial-guide behaviour reported during
the pre-Section-D friend-test polish pass.

## Behaviour

The destination remains static, but the guide source now advances continuously
with the player.

Pathfinding defines the structural corridor. Normal movement no longer causes
that path to be destroyed or recomputed. Instead, the client determines the
player's progress along the route every render frame and advances pooled guide
visuals from that progress.

The implementation now uses:

- pooled trail markers;
- pooled three-piece directional arrows;
- client-side PreRender updates;
- smoothed player route progress;
- no destroy/recreate cycle during ordinary movement;
- structural rerouting only after a target change, respawn, missing route or
  genuine route deviation;
- live collision-floor projection for every moving marker and arrow centre.

## Why this differs from v3.50

v3.50 correctly removed path redraw flicker but froze the source of the route.

v3.51 keeps the path corridor stable while moving its visible source with the
player. This produces the expected shrinking/advancing route without repeated
path replacement.

World-space CFrame smoothing was deliberately rejected because it could cut
across steps and lift visuals above the terrain. Only route progress is
smoothed; final visual positions are floor-locked every frame.

## Authored acceptance

Controlled Worldroot movement returned:

- player movement: approximately 12.24 studs;
- source-marker advance: approximately 12.24 studs;
- same first marker instance throughout: true;
- 0 route-object replacement;
- 0 collidable guide parts;
- maximum measured centre-to-floor gap: 0.09 stud.

## Published-cloud acceptance

TEST Base/start place: `134132328219009`.

A clean cloud-loaded Base confirmed the published source contains:

- PreRender-driven visual updates;
- route-progress smoothing;
- pooled marker instances;
- pooled arrow instances;
- live floor locking;
- existing collision-grounded NPC placement.

Fresh cloud play returned:

- `PLAYER_MOVE=12.24`;
- `SAME_MARKER_INSTANCE=true`;
- `MARKER_SOURCE_ADVANCE=12.24`;
- `GUIDE_PARTS=42`;
- `MARKER_PARTS=24`;
- `ARROW_PARTS=18`;
- `COLLIDABLE=0`;
- `FLOOR_MISSES=0`;
- `MAX_FLOOR_GAP=0.090`;
- `SURVIVORS=42`;
- `REPLACEMENTS=0`.

Quest-giver regression:

- `NPC_COUNT=8`;
- `NPC_WALKABLE=8`;
- `NPC_BAD_SUPPORT=0`.

TEST Dungeon `117293035754309` had no source delta and was not republished.

## Source checkpoint

Gameplay source checkpoint before this documentation:

`c0ca45547c49560c42ac38adb9039345e719d8ee`

Build checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS;
- authored Base playtest: PASS;
- fresh published-cloud Base playtest: PASS.

## HOLD

**Section D remains on hold.**

World boss, raid, territory, castle and PvP work must not resume until the
owner completes the two-player friend test and explicitly releases the hold.
