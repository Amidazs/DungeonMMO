# Human Wizard Source Cast Scheduler v2.99 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — private server scheduling now bridges exact source timing to the
split-MP launch boundary without applying damage or consuming shots.**

## Candidate

`051f3916998c795dcbcb1aecdb9142a36e40fbff`.

## Deterministic cast schedule

The scheduler accepts a server-owned player, creative skill ID and optional
deterministic process timestamp.

It first resolves the exact source timing plan. Only when final reuse is ready
does it ask the split-MP resource lifecycle to begin the cast.

The scheduler then stores a private pending record keyed by owner.

For the accepted 4000/2000/140/4500 ms fixture at t=100:

- `StartedAt=100`;
- `InterruptAt=102`;
- `LaunchAt=104`;
- `FinalizerAt=104.14`;
- `ReuseReadyAt=104.5`.

## Early launch gate

At t=103.999:

- launch is denied with `C4SourceCastNotReady`;
- launch-time MP commit count remains zero;
- the pending receipt remains valid.

At t=104.0:

- the split-MP resource lifecycle commits;
- the launch payload reports 21 MP launch spend;
- the pending scheduler receipt is removed;
- the payload becomes eligible for a later source-effect executor handoff.

A second launch attempt with the same receipt is rejected.

## Cancellation/reuse

Cancellation removes the pending scheduler/resource receipt but intentionally
does not remove the source reuse deadline.

A cast started at t=200 remains reuse-blocked at t=204.499 and becomes eligible
at t=204.5.

This matches the already-reviewed source lifecycle where reuse begins at cast
start.

## Fail-closed cases

Acceptance covers:

- unresolved final reuse -> no resource begin and no initial MP mutation;
- timing/resource source-rank mismatch -> resource receipt immediately
  cancelled and no scheduler record retained;
- launch authority change -> pending record consumed once, no replay;
- overlapping cast -> rejected before a second resource begin;
- owner teardown -> pending and reuse state cleared.

## Launch payload boundary

Successful launch evidence is deliberately marked:

- `ReadyForSourceEffectExecution=true`;
- `LiveDamageIntegrated=false`;
- `ShotStateConsumed=false`.

This is an internal server handoff, not a client cast result.

## Fresh focused evidence

Marker:

`[C4 Source Cast Scheduler] SOURCE_ONLY_PASS: 15 assertions
deadline=true reuse=true cancel=true replay=true live=false`.

Complete focused result:

`[Human Wizard Source Cast] RESULT passed=9 total=9`.

The other eight source dependency suites remained green in the same fresh run.

## Build/static acceptance

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths remain the pre-existing quadruped-animation
Python `__pycache__` directories. They were not edited or committed.

## Boundary

No source spell damage, status effect or shot consumption is enabled here.

The next gate is one disabled-by-default direct-MDAM launch handoff using the
scheduler payload and the existing source combat executor.
