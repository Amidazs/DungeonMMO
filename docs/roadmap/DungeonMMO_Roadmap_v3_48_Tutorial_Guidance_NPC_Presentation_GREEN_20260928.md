# DungeonMMO Roadmap v3.48
## TUTORIAL GUIDANCE + NPC PRESENTATION GREEN
**Date:** 28 September 2026

This is a pre-Section-D polish checkpoint only.

## Tutorial guidance

The Base new-player tutorial now renders a local, non-colliding
iridescent ground route for navigation steps.

The guide:

- uses Roblox pathfinding instead of a straight line through geometry;
- projects route visuals onto the floor;
- draws a thin Neon ribbon;
- adds directional floor arrows;
- cycles hue locally for an iridescent effect;
- refreshes as the player moves;
- retries when navigation is not ready yet;
- never creates collidable guide parts.

Live Worldroot route validation returned:

- 26 guide pieces;
- 15 arrow pieces;
- 26 Neon pieces;
- 26 distinct sampled colours;
- 0 collidable guide pieces.

Live Temple route validation returned:

- 41 guide pieces;
- 24 arrow pieces;
- 0 collidable guide pieces;
- vertical route coverage from approximately Y=15.47 to Y=49.32.

Tutorial copy now explicitly tells the player to follow the shimmering floor
trail and arrows.

## Quest-giver presentation

The eight Adventure quest givers are no longer single block placeholders.

Each generated placeholder is now a simple humanoid model with:

- head;
- torso;
- arms;
- legs;
- Humanoid;
- invisible interaction root;
- role-coloured clothing/accent pieces;
- simple role-specific silhouette details;
- visible role label;
- trusted Talk prompt.

These remain replaceable placeholders, not final character art.

## Wider hub distribution

Quest givers now occupy genuinely separate authored-lobby regions rather than
small offsets around the centre.

The authored TEST Base runtime currently places them approximately at:

- Worldroot Keeper: (-44.0, 35.0, 40.2);
- Village Captain: (-21.0, 30.8, -8.8);
- Huntmaster: (-129.5, 34.4, 34.4);
- Temple Archivist: (1.0, 67.5, 94.9);
- Mine Warden: (99.8, 34.6, 45.9);
- Survey Corps: (104.8, 32.2, 10.9);
- Expedition Pathfinder: (-47.5, 51.7, 149.4);
- Expedition Quartermaster: (75.0, 30.4, -12.9).

The closest pair is 35.44 studs apart.

## Invisible-wall / path safety

Authored-mode placement is now a hard navigation gate.

For every NPC, the server:

1. projects the desired role position onto real ground;
2. rejects a candidate when collidable geometry occupies the standing /
   interaction volume;
3. computes a Roblox path from the player-spawn area;
4. rejects the candidate unless the path succeeds;
5. searches deterministic nearby alternatives when necessary.

This caught an actual problem during implementation: the original Dwarf travel
anchor area was not continuously walkable from spawn. Mine Warden and Survey
Corps were therefore remapped to reachable Dwarf-side village paths instead of
weakening the validation.

Synthetic test environments are allowed to skip the authored-world navigation
requirement because they do not reproduce the full lobby terrain. Authored and
published Base remain strict.

## Published TEST validation

TEST Base/start place: `134132328219009`.

The updated Base was published through the exact authored Studio session.

A brand-new cloud-loaded Base then proved the published source contains:

- humanoid quest-giver runtime;
- wide hub placement definitions;
- `TutorialPathGuide`;
- iridescent HSV trail animation;
- shimmering-trail tutorial copy.

A fresh live run of that published cloud copy returned:

- 8 quest-giver models;
- 8/8 walkable;
- 8/8 approach-clear;
- 8/8 Humanoid objects;
- closest pair 35.44 studs;
- normal authored Base startup with no runtime exception.

TEST Dungeon remains `117293035754309`.

No Dungeon source changed in v3.48. Its existing published cloud copy was
revalidated as current:

- schema 15;
- TutorialDefinitions present;
- DungeonQuestFeedbackRuntime present;
- NewPlayerDungeonTutorial present.

It was intentionally not overwritten from one of the stale duplicate Studio
windows.

## Final build checks

Source checkpoint before this documentation:

`e5517431dafdc12f30c3d37fed408929e214450c`

Fresh checks:

- `git diff --check`: PASS;
- published Base build: PASS;
- published Dungeon build: PASS;
- TEST lobby sync build: PASS.

## HOLD

**Section D is still on hold.**

The next action remains the user's two-player friend test. Do not begin world
boss, raids, guild competition, territory or castle/PvP until the user reports
that test and explicitly releases the hold.
