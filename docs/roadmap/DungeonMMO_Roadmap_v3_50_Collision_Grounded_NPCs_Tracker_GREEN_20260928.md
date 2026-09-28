# DungeonMMO Roadmap v3.50
## COLLISION-GROUNDED NPCs + TERRAIN-FOLLOWING TRACKER GREEN

**Date:** 28 September 2026

This checkpoint corrects the two remaining pre-Section-D friend-test
presentation regressions.

## NPC grounding correction

The v3.49 check proved each humanoid was touching a surface, but it did not
prove that surface was the real player collision floor.

The authored lobby contains decorative non-colliding meshes above the actual
collision layer. Several quest-giver placeholders were therefore placed on
visual geometry that players could not stand on.

The runtime now:

- raycasts with `RespectCanCollide = true`;
- collects multiple real collision-floor candidates;
- orders candidates by vertical proximity to the semantic anchor height;
- validates the path slightly above the floor surface;
- rejects climb-only navigation;
- uses precise vertical headroom rather than MeshPart bounding-box overlap.

Fresh authored and published-cloud validation now place all eight quest givers
on real collision surfaces.

Published-cloud result:

- `COUNT=8`;
- `WALKABLE=8`;
- `BAD_COLLIDABLE_SUPPORT=0`.

Representative final floor heights:

- Worldroot Keeper floor Y ~16.07;
- Village Captain floor Y ~15.70;
- Huntmaster floor Y ~15.75;
- Survey Corps floor Y ~14.71;
- Mine Warden floor Y ~23.93;
- Temple Archivist floor Y ~48.73;
- Expedition Pathfinder floor Y ~59.55;
- Expedition Quartermaster floor Y ~16.28.

The elevated Temple and Pathfinder placements are now elevated because their
real authored terrace/stair collision is elevated, not because of decorative
floating geometry.

## Tracker redesign

The previous tracker no longer rebuilt while walking, but long straight
segments still bridged uneven terrain and could float several studs above the
floor.

The tracker now:

- calculates the route once per tutorial target;
- remains fixed while the player follows it;
- recalculates only for a new target, failed initial route or respawn;
- uses short glowing `TrailMarker` pieces rather than long ribbon segments;
- projects every marker and every arrow independently onto collidable floor;
- uses slower, narrower iridescent colour variation;
- remains fully non-colliding.

Published-cloud Worldroot route validation:

- 33 total visual pieces;
- 18 short trail markers;
- 15 arrow pieces;
- 0 collidable pieces;
- 0 floor-ray misses;
- maximum measured centre-to-floor gap: 0.183 stud.

A 13.41-stud movement stability test returned:

- 33 original pieces;
- 33 surviving pieces;
- 0 replacements.

## Publication

TEST Base/start place: `134132328219009`.

The corrected authored Base was published and then reopened from a brand-new
cloud copy. The fresh cloud source and live play both contain the accepted
collision-grounding and marker-tracker implementation.

TEST Dungeon `117293035754309` had no source delta and was not republished.

## Source checkpoint

Gameplay source checkpoint before this documentation:

`8e5badfde31d4c39b85bba3110972370c44774f9`

Build checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS;
- authored Base playtest: PASS;
- fresh published-cloud Base playtest: PASS.

## HOLD

**Section D remains on hold.**

World boss, raid, territory, castle and PvP work must not resume until the
owner completes the two-player test and explicitly releases the hold.
