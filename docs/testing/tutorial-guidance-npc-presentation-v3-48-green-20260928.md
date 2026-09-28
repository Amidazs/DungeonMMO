# v3.48 Tutorial Guidance + NPC Presentation Evidence
**Date:** 28 September 2026

## Authored-lobby NPC gate

Live authored TEST Base:

- quest givers: 8;
- walkable: 8/8;
- approach-clear: 8/8;
- Humanoid silhouette present: 8/8;
- closest pair: 35.44 studs.

The path/clearance gate rejected the first Dwarf placement because the original
travel anchor was not continuously reachable from spawn. The Dwarf quest
givers were moved onto reachable paths and the gate then passed.

## Tutorial ground guide

Worldroot Keeper route:

- 26 visual pieces;
- 15 arrow pieces;
- all 26 visual pieces Neon;
- 26 distinct sampled colours;
- 0 collidable parts.

Temple route:

- 41 visual pieces;
- 24 arrow pieces;
- 0 collidable parts;
- route follows the authored elevation change.

The guide uses PathfindingService and floor raycasts rather than drawing
through walls.

## Published-cloud evidence

A newly opened TEST Base cloud copy contains:

- `create_humanoid_giver`;
- `TutorialPathGuide`;
- `Color3.fromHSV` iridescent animation;
- wide-placement definitions;
- updated shimmering-trail tutorial copy.

A live run from that fresh cloud copy returned:

`COUNT=8`
`WALKABLE=8`
`CLEAR=8`
`HUMANOIDS=8`
`CLOSEST=35.44`

TEST Dungeon cloud revalidation returned:

- schema 15;
- tutorial definitions present;
- quest feedback runtime present;
- Dungeon tutorial client present.

## Source/build evidence

Source checkpoint before documentation:

`e5517431dafdc12f30c3d37fed408929e214450c`

- git diff check: PASS;
- published Base build: PASS;
- published Dungeon build: PASS;
- TEST lobby sync build: PASS.

## Acceptance

**v3.48 GREEN — FRIEND TEST BUILD READY.**

Section D remains on hold.
