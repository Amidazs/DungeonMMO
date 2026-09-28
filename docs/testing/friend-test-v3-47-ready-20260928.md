# v3.47 Friend Test Ready — Published TEST Evidence
**Date:** 28 September 2026

## Goal

Provide a real published two-player TEST path without opening the experience to
the general public and without beginning roadmap Section D.

## Cloud places

- universe: `10765241947`;
- Base: `134132328219009`;
- Dungeon: `117293035754309`.

### Fresh Base cloud reload

Verified:

- schema 15;
- `TutorialDefinitions` present;
- `QuestGiverDefinitions` present;
- TEST environment;
- TEST Dungeon destination configured.

### Fresh Dungeon cloud reload

Verified after publishing the exact updated authored Dungeon Studio session:

- `Schema=15`;
- `TutorialDefinitions=true`;
- `QuestFeedback=true`;
- `DungeonTutorialClient=true`;
- `Environment=TEST`.

This is independent evidence from a newly opened cloud copy, not the edited
Studio session.

## Audience

Creator Dashboard accessibility state:

- Limited selected;
- Friends checked;
- Playtesters checked;
- Public not selected.

## Tutorial live evidence

Fresh Base Studio play previously returned:

- `VERIFIED_BASE_TUTORIAL_OPEN_PASS 1`;
- `VERIFIED_BASE_TUTORIAL_WAYPOINT_PASS 1`;
- `VERIFIED_BASE_TUTORIAL_ACCEPT_GATE_PASS 1`;
- `VERIFIED_BASE_TUTORIAL_PARTY_STEP_PASS 1`;
- `VERIFIED_BASE_TUTORIAL_COMBAT_STEP_PASS 1`.

Fresh Dungeon Studio play returned:

- `VERIFIED_DUNGEON_TUTORIAL_OPEN_PASS 1`.

## Physical quest-giver evidence

The authored lobby starts with all eight physical Adventure quest givers.

They use semantic hub anchors rather than one Adventure-Board cluster.

The Mine Warden now supports:

- preferred `Base.DwarfQuestHub`;
- fallback `Base.Travel.Dwarves`.

The fallback is used on the current authored TEST lobby and no longer stops
Base startup.

## Release-composition bug fixed

The published Base was initially unable to start after the full current source
sync because progression runtime dependencies under
`ServerScriptService.Combat` were absent from the published/test-sync project
files.

Fixed project files:

- `published-base.project.json`;
- `test-lobby-sync.project.json`.

The exact published Base composition subsequently started successfully.

## Final source/build evidence

Source checkpoint before documentation:

`bb16fb7a1fa278dfcb648941f19019a20e1393a7`

- git diff check: PASS;
- published Base build: PASS;
- published Dungeon build: PASS;
- TEST lobby sync build: PASS.

## Acceptance

**FRIEND TEST READY.**

Section D remains explicitly on hold.
