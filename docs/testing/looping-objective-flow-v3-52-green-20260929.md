# Looping objective-ward tutorial flow v3.52 evidence

**Date:** 29 September 2026

## Reported issue

The v3.51 tracker was improved but still felt janky during lateral movement and
while moving away from the objective. The intended presentation is a constant
flow toward the target rather than route pieces merely following player
progress.

## Accepted design

The effect now has two independent systems:

- route geometry: player-relative path shape;
- directional flow: a looping phase that moves only toward the objective.

The live route source is smoothed independently from the flow clock. Local
detours use a live lead-in instead of immediately forcing a full path rebuild.

Markers and arrows are fully pooled before ordinary movement begins.

## Authored acceptance

- stationary flow motion over 0.25 seconds: `1.73` studs;
- sideways peak step: `0.300` stud;
- 12-stud-away peak step: `0.518` stud;
- same marker instance: `true`;
- same shaft instance: `true`;
- surviving pool parts: `74`;
- replacements: `0`;
- floor misses: `0`.

## Published-cloud source proof

Fresh cloud session for place `134132328219009` returned:

- `SourceLoopFlow=true`;
- `SourceSmoothing=true`;
- `SourceSeamFade=true`;
- `SourceDetour=true`;
- `SourcePreallocatedPool=true`;
- `EditorLoopFlow=true`;
- `NpcCollisionGrounding=true`.

## Published-cloud movement proof

- `STATIONARY_FLOW_MOTION=1.73`;
- `SIDE_MAX_MARKER_STEP=0.293`;
- `SAME_MARKER_INSTANCE=true`;
- `SAME_SHAFT_INSTANCE=true`;
- `PLAYER_AWAY_MOVE=12.00`;
- `AWAY_MAX_MARKER_STEP=0.528`;
- `SURVIVORS=74`;
- `REPLACEMENTS=0`;
- `FLOOR_MISSES=0`;
- `MAX_FLOOR_GAP=0.238`.

## Deployment incident

Initial v3.52 publishes appeared to succeed through Studio UI automation but
fresh cloud copies still contained the v3.51 tracker.

Root cause: the script editor buffer and underlying script source had diverged.
After using `ScriptEditorService:UpdateSourceAsync()`, closing the document,
and verifying both editor and stored source, a clean republish produced the
expected v3.52 cloud source.

This is now documented as a future Studio synchronization requirement.

## Source/build proof

Gameplay source checkpoint before documentation:

`b5e403ec9779e66dfa4b22d5e7075b8103afe3b7`

- `git diff --check`: PASS;
- Base build: PASS;
- published Base build: PASS;
- authored stress tests: PASS;
- clean published-cloud source check: PASS;
- clean published-cloud stress tests: PASS.

Section D remains blocked pending the owner's real friend test.
