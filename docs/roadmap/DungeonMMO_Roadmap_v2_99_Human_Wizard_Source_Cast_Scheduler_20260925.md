# DungeonMMO Roadmap v2.99 — Human Wizard Source Cast Scheduler

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.98](
DungeonMMO_Roadmap_v2_98_Human_Wizard_Source_Reuse_20260925.md).

## Status

**GREEN — Human Wizard source casts now have a private, deterministic,
server-owned scheduler boundary. Damage and shot consumption remain separate.**

Acceptance:
[Human Wizard source cast scheduler v2.99](
../testing/c4-human-wizard-source-cast-scheduler-v2-99-20260925.md).

## New scheduler

`C4SourceCastSchedulerService` composes the accepted source timing and
split-MP resource services without exposing a client-owned timer.

A scheduled cast records:

- private cast receipt;
- creative and historical source skill/rank identity;
- cast-start time;
- interrupt deadline;
- exact source hit deadline;
- finalizer deadline;
- source reuse-ready deadline;
- final hit/cool/reuse durations.

All timestamps are server process-clock deadlines. Tests can inject a supplied
timestamp for deterministic verification.

## Start ordering

The scheduler deliberately resolves timing before any source MP mutation.

A cast begins only when:

1. there is no existing pending cast for the owner;
2. the creative skill's source reuse gate has expired;
3. the source timing plan resolves from the authenticated current rank;
4. final reuse is ready;
5. the split-MP resource lifecycle accepts the cast;
6. the resource receipt still matches the timing plan's creative/source rank.

Only then is the pending scheduler record stored.

If timing/reuse is unresolved, the resource service is never called, so no
initial MP is spent.

## Exact deadlines

The current Human Wizard acceptance fixture uses rank-six Ember Bolt with:

- final hit time: **4000 ms**;
- interrupt window: **2000 ms**;
- final cool time: **140 ms** in the scheduler fixture;
- final reuse: **4500 ms**.

At cast start time 100.0 this produces:

- interrupt: **102.0**;
- source hit/launch: **104.0**;
- finalizer: **104.14**;
- reuse ready: **104.5**.

The scheduler rejects a launch at 103.999 and permits the resource commit at
104.0.

## Reuse semantics

Source reuse begins at cast start rather than at spell hit.

This means cancellation does not erase the reuse gate. A cancelled cast that
started at 200.0 with 4500 ms reuse remains blocked until exactly 204.5.

Owner teardown is different: `clear_owner` removes both pending cast and reuse
state because the server owner itself is leaving the scheduler.

## Replay and authority safety

The scheduler maintains one pending cast per owner.

It rejects:

- overlapping source casts;
- early launch;
- cancelled/replayed receipts;
- timing/resource source-rank disagreement;
- launch authority changes returned by the resource lifecycle.

The scheduler clears its pending receipt before resource commit at the hit
deadline. A failed launch revalidation therefore cannot be retried with the same
receipt.

## Source effect handoff boundary

A successful deadline commit returns an immutable payload marked:

- `ReadyForSourceEffectExecution=true`;
- `LiveDamageIntegrated=false`;
- `ShotStateConsumed=false`.

This is the next safe boundary for wiring one direct MDAM cast to the existing
source executor. It is not itself a damage cast.

## Fresh verification

Accepted candidate:

`051f3916998c795dcbcb1aecdb9142a36e40fbff`.

Fresh results:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- source scheduler: **15 assertions PASS**;
- complete Human Wizard source-cast runner: **9/9 PASS**.

The full focused runner also kept green:

- owned passive source resolver;
- unified source stats;
- resource migration boundary;
- source runtime rules;
- source cast contract;
- split-MP resource lifecycle;
- source cast timing;
- source combat calculation.

The scheduler implementation and test scenarios were refactored after the first
green run so cast-start responsibilities remain split into small validation,
resource-receipt and evidence helpers. The refactored candidate reran green.

## Safety boundary

v2.99 does **not**:

- call the source combat executor;
- consume Spiritshot/Blessed Spiritshot;
- apply damage or status effects;
- expose cast deadlines to client authority;
- enable source combat by default;
- publish any Roblox place;
- implement companion/servitor rows.

## Next implementation

The next bounded gate is **one Human Wizard direct-MDAM launch handoff**.

Use the scheduler's successful launch payload to:

1. revalidate the target at hit time;
2. consume the already-charged magical shot exactly once at the correct source
   action boundary;
3. pass the captured source skill/rank and shot state into the existing
   `C4SourceCombatExecutor`;
4. apply only one reviewed direct MDAM family first;
5. keep status/control/AOE/recovery/passive families out of this first live
   rehearsal;
6. keep the entire path disabled by default and source-cutover-participant
   scoped.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
