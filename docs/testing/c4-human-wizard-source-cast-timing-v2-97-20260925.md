# Human Wizard Source Cast Timing v2.97 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — Human Wizard source cast hit/cool timing and shot acceleration are
server-planned exactly; final reuse remains intentionally blocked.**

## Candidate

`3c2984a0c30034a3a71ba36fe709a12d6a3f34f6`.

## Runtime rule additions

`C4SkillRuntimeRules` now includes:

- `magic_cool_time(...)`;
- `skill_reuse_delay(...)`.

Focused source vectors prove:

- 200 ms cool time at M.Atk.Spd 333 stays 200 ms;
- Spiritshot reduces it to 140 ms;
- Blessed Spiritshot also reduces it to 140 ms;
- no 500 ms minimum is applied to cool time;
- authored reuse 6000 at speed 333 and multiplier 1 stays 6000;
- speed 666 reduces that neutral reuse to 3000;
- multiplier 0.5 at speed 333 also produces 3000.

Marker:

`[C4 Skill Runtime Rules] SOURCE_ONLY_PASS: 19 assertions`.

## Human Wizard timing planner

`C4SourceCastTimingService` requires:

- exact current cast contract;
- authenticated source stat boundary;
- positive final source M.Atk.Spd;
- server-owned source shot snapshot.

It refuses a source-scope mismatch or invalid M.Atk.Spd.

### Ember Bolt

Rank-six Ember Bolt at source M.Atk.Spd 333:

- no shot: 4000 ms final hit, 2000 ms interrupt;
- Spiritshot: 2800 ms final hit, 1400 ms interrupt;
- Blessed Spiritshot: 2800 ms final hit.

Shot snapshots remain charged after timing resolution. The planner does not call
the one-use shot-consumption path.

At M.Atk.Spd 666 with no shot:

- final hit time: 2000 ms;
- interrupt window: 1000 ms;
- neutral reuse diagnostic: 3000 ms.

### Frost Lance

Creative Frost Lance rank 2 resolves historical Ice Bolt rank 6.

With Spiritshot at source M.Atk.Spd 333:

- authored hit: 3100 ms;
- final hit: 2170 ms;
- interrupt: 1085 ms;
- authored cool: 200 ms;
- final cool: 140 ms.

This proves cool-time acceleration remains independent of the hit-time minimum.

## Reuse blocker

The planner deliberately refuses to call the neutral reuse diagnostic a final
reuse value.

Current output states:

- `FinalReuseDelayReady=false`;
- `ReuseBlocker="OriginalSkillReuseRateNotIntegrated"`;
- `LiveSchedulingIntegrated=false`.

This is required because Human Wizard Quick Recovery modifies
`MAGICAL_SKILL_REUSE`; that stat is not yet part of the authenticated final
source stat candidate.

Marker:

`[C4 Source Cast Timing] SOURCE_ONLY_PASS: 14 assertions
hit=true cool=true shots=peek reuse=blocked live=false`.

## Complete focused run

The same fresh Base run also passed:

- source cast contract: **11**;
- source cast resource lifecycle: **12**;
- source combat calculator: **43**.

Combined marker:

`[Human Wizard Source Cast] RESULT passed=5 total=5`.

## Build/static acceptance

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths remain the pre-existing quadruped-animation
Python `__pycache__` directories. They were not edited or committed.

## Boundary

No live cast, cooldown, shot consumption or spell damage is enabled by v2.97.

The next gate is to integrate the exact owned `MAGICAL_SKILL_REUSE` passive
modifier into the authenticated source stat candidate, then compute final reuse
without assumptions.
