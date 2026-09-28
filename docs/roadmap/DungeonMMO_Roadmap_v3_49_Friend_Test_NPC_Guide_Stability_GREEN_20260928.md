# DungeonMMO Roadmap v3.49
## FRIEND-TEST NPC + GUIDE STABILITY GREEN

**Date:** 28 September 2026

This is a pre-Section-D friend-test polish checkpoint only.

## Reported regressions

The owner reported two problems after v3.48:

- some quest-giver NPCs appeared elevated or unreachable;
- the tutorial floor guide visibly snapped when its path refreshed.

## Quest-giver placement hardening

Authored quest-giver path validation now sets `AgentCanClimb = false`.

This prevents a candidate from passing the player-accessibility gate only
because Roblox can construct a climb-assisted route to it. Existing authored
ground projection and approach-volume checks remain active.

Acceptance now also measures physical foot support rather than trusting stored
placement flags alone.

Fresh published-cloud validation returned:

- 8 quest-giver models;
- 8/8 walkable;
- 8/8 physically supported;
- 8/8 Humanoid models;
- no Base startup errors.

## Stable tutorial rerouting

The tutorial guide no longer rebuilds simply because the player moved five
studs. The rendered route is retained while the player remains near it and is
recomputed only when the target changes materially, the route is missing, or
the player deviates roughly 9 studs from the current route.

A focused authored-client test moved the player 6.00 studs along the active
Worldroot route, exceeding the old five-stud rebuild threshold.

Result:

- original guide pieces: 26;
- surviving original pieces: 26;
- replacement pieces: 0;
- current guide pieces: 26;
- collidable guide pieces: 0.

## Publication

TEST Base/start place: `134132328219009`.

The verified authored Base session was published, then a brand-new cloud copy
was opened. Fresh cloud source proof confirmed:

- `REROUTE_DISTANCE = 9`;
- route-distance rerouting logic;
- `AgentCanClimb = false` for quest-giver validation;
- the ground-slope acceptance gate.

The fresh cloud playtest then returned 8/8 spawned, walkable, supported
Humanoid quest givers.

TEST Dungeon `117293035754309` had no source delta in this checkpoint and was
not republished.

## Source checkpoint

Gameplay source checkpoint before this documentation:

`c6fdba9da528a2cf18abd55be094f9377755d9cf`

Final source/build checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- published Base Rojo build: PASS;
- authored Base playtest: PASS;
- fresh published-cloud Base playtest: PASS.

## HOLD

**Section D remains on hold.**

The next action is still the owner's real two-player friend test. Do not begin
world boss, raid, guild competition, territory or castle/PvP implementation
until that test is complete and the hold is explicitly released.
