# DungeonMMO roadmap v1.54 — weekly world-boss foundation

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** Default-off Base entry, reserved-server routing, separate
world-boss place, Base return, real combat and **two-client party
resilience** are locally verified. Published same-account reconnect,
real cross-place travel, cloud persistence and live event release
**remain pending**.

## Goal and progress

Start the larger weekly world-boss/raid lifecycle milestone without
rebuilding any accepted dungeon, party, combat, inventory or profile
services. Players will eventually enter a dedicated instance during a
server-announced time window, defeat a world boss alongside their party
and earn one weekly reward per character.

This increment establishes the first server-owned contract and
a disposable Play-mode acceptance path:

- [x] Default-off weekly event calendar. Monday 00:00 UTC reward
  boundary; trusted explicit start/end, exclusive end and a maximum
  two-hour entry window. No live event date or default cadence enabled.
- [x] Server-only per-instance admission for up to four loaded
  eligible players, with a frozen boss/week/window snapshot. This
  is an **in-server** prototype, not a cross-server reservation.
- [x] Unique `AncientGuardian` prototype factory reusing the
  existing captain combat rig, with a server-owned instance ID and
  no standard monster XP/gold reward. No default pack contains it.
- [x] Server-owned defeat proof: matching, tagged, dead boss
  required before claiming the provisional weekly payout.
- [x] Persistent per-character, per-week claim receipt stored
  alongside the gold award in the existing authoritative profile.
  Repeat kills in the same or another local instance grant no extra
  gold. The following calendar week renews entitlement.
- [x] Four Rojo builds; 40 calendar/reward assertions in Base and
  Dungeon; eight Dungeon factory assertions; 14/14 existing Base
  profession and 30/30 Dungeon gameplay regression suites.
- [x] Disposable unpublished Dungeon Play test: a real Studio client
  enters via a temporary ProximityPrompt during an open window;
  guardian spawns, assisted defeat grants one weekly reward, and
  a second guardian kill grants no additional reward.

The **initial** physical gateway described in this section was
a test fixture only. The later isolated-travel milestone introduces
a separate default-off Base gateway and reserved-place source path;
no published network journey or finished boss encounter is
verified. The guardian still uses the existing combat rig for
backend verification; the provisional 100-gold payout is not
a balanced final reward.

## New local milestone — isolated weekly boss travel and return

Implemented a disabled-by-default Base boss gateway using the
existing DungeonBoard anchor and the shared party, teleport, profile,
lease and dungeon-session services. Server-issued weekly entry
captures an explicit UTC window, reserves the configured **separate
world-boss place**, and saves the destination and party identity
before teleport. A dedicated arrival rule refuses ordinary dungeon
routing, outsiders and other-place snapshots. Ordinary Dungeon
admission also refuses the world-boss session.

Two new Rojo compositions build the isolated world-boss destination.
Its runtime remains disabled unless explicitly enabled and requires
a reserved server and authored arena anchor. A proven defeat opens
a per-member Base return flow without ending other party members'
recoverable session. Base clears a returning member's old session
index only after their arrival and profile load. A failed return
teleport restores that member's boss rejoin route.

**Local acceptance:** six Rojo builds; 18 travel assertions each in
Base and Dungeon; 22 Base return assertions including failed-teleport
rollback; 10 ordinary-Dungeon admission assertions; five isolated
destination assertions; a default-off Play-mode check; 33 durable
session assertions in each Base/Dungeon (including malformed-party
recovery); weekly policy 40, guardian
factory eight; existing Base profession 14/14 and Dungeon gameplay
30/30. Existing real-client material-chain Play regression also
passed on the travel integration source.

**Important correction:** The real contribution service returns
`Damage`, `Tank` and `Support` at its response's top level, not
inside a nested `snapshot` field. Fixed the destination's reward
check and added 14-assertion focused Studio tests in both Base and
Dungeon, including zero/invalid values, actual persisted damage,
independent healing support and simulated service recovery.
These are contract tests, **not** evidence of a playable boss fight.

Travel receipt:
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`.
Contribution fix and failed-teleport receipt:
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.

**Remaining blockers:** The separate world-boss place does not yet
have its authored `WorldBossArenaSpawn`, dedicated integrated combat
controller/client, real boss attack/combat contribution loop,
full-party wipe/reward retry acceptance or an approved published
TEST configuration. Thus the currently compiled destination is
**not a playable or releasable weekly encounter**. No actual
cross-place teleport, live MemoryStore/DataStore handoff, full
Base → boss → Base playthrough or production release has occurred.

## New local milestone — real guardian combat and reward path

The isolated world-boss composition now includes the existing full
combat server/client runtime plus the existing captain AI controller,
while excluding the ordinary prototype ArenaBuilder. Admitted boss
players are marked with the frozen weekly encounter ID so the guardian
targets only the correct encounter participants.

Player damage contribution is scoped twice on the server:
`DungeonContributionBridge` accepts only the exact active guardian
model, and `WorldBossCombatAuthority` also verifies active session
membership, connected/non-abandoned state, matching encounter
attributes, live guardian state and the undefeated weekly snapshot.
Healing and wards must target admitted encounter members.

Real Studio Play uncovered and fixed two bugs missed by earlier
contract tests: a missing-event-state nil access and an `event`
variable-shadowing bug that rejected genuine guardian hits. The
post-defeat runtime now also retries unpaid weekly rewards, and a
qualifying player cannot return to Base while their earned reward
remains unsaved.

**Real-client Play acceptance:** using normal client attack input and
the existing CombatService/DamageService path, the player damaged the
guardian, generated persisted server contribution, was damaged by the
guardian AI, defeated the guardian without direct health injection,
received the weekly reward once and received zero on an immediate
duplicate claim. Final markers:
`REAL_CLIENT_HIT_PASS`, `SERVER_CONTRIBUTION_PASS`,
`GUARDIAN_ATTACK_PASS`, `REAL_CLIENT_BOSS_DEFEAT_PASS`,
`WEEKLY_REWARD_ONCE_PASS`, `VERIFIED_PLAY_MODE_PASS`.

Final source head `7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89`
also passed six Rojo builds, seven scoped damage-filter assertions,
default-off boss-place Play, 14 contribution-service assertions,
40 weekly-policy assertions, eight guardian-factory assertions,
Base professions 14/14 and Dungeon backend 30/30.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.

**Remaining blockers:** this proves the isolated combat backend, not
the full networked game journey. The real world-boss place still needs
an authored `WorldBossArenaSpawn`; the accepted fixture manually
creates its disposable session/guardian rather than traversing Base
entry and Roblox ReserveServer. Multi-client fight, party wipe/death,
disconnect/rejoin, published TEST profile lease handoff,
DataStore/MemoryStore recovery and the complete Base → boss → Base
journey remain pending. The event stays disabled by default.

## New local milestone — two-client party resilience

Added an explicitly opt-in geometric `WorldBossArenaLayout` with a
stable `WorldBossArenaSpawn`, floor and closed walls for backend Play
without manufacturing final art. Normal Base/Dungeon places remain
unchanged, and final authored geometry can replace this prototype.

The real Studio multiplayer fixture now uses two actual clients
against one guardian. Both generate persisted server damage and
receive independent once-weekly rewards after the shared kill.
A client-owned Humanoid death is replicated to the server,
persisted as `Dead`, respawned into the same frozen session and
restored to `Active` without another reward. One client may then
leave while the other remains; contribution and reward history remain
intact.

Roblox Studio multiplayer clients use negative UserIds. The
ContributionService and DungeonContributionBridge now accept negative
integral identities **only in Studio**, while production identity
rules remain positive-only. Zero/nonfinite/malformed identities and
invalid contribution events are still denied.

The current prototype wipe policy is explicit: connected dead members
may independently respawn into the same encounter. A wipe does not
reroll boss/event/week identity or weekly entitlement. This policy can
still be tuned later without changing the trusted session/reward
contract.

**Final local acceptance at source
`e83e4fae522582ec98bfc9cf4938ffdca9aa810b`:**
six Rojo builds; multiplayer Play `VERIFIED_MULTIPLAYER_PASS`;
member lifecycle/wipe 14 assertions; contribution 20 assertions;
Base travel 18; Base return 22; Dungeon world-boss session 33;
Base professions 14/14; Dungeon backend 30/30.

Receipt:
`docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.

**Remaining blockers:** Studio cannot prove a genuine reconnect of
the exact same Roblox account across a new reserved server. Published
TEST Base → ReserveServer boss → Base travel, lease handoff,
MemoryStore/DataStore recovery and cross-server reward recovery remain
pending. Two-client real healing/ward skill execution also remains
unverified, although support-event authority has focused coverage.
Production event flags remain off.

## Earlier local milestone — frozen session and contribution-gated reward

The next default-off backend layer is implemented and locally
verified. `WeeklyWorldBossSessionBridge` uses the existing
`DungeonSessionService` to issue a frozen event/party/week snapshot,
persist a verified boss defeat, and rehydrate that encounter after
a simulated service restart. It refuses unauthorized and duplicate
issuance, outsiders and invited non-contributors. Once an existing
server-side session has certified a member's completion
eligibility, that member can claim their independent weekly
reward. A new service reading the same in-memory session map
and previously saved same-UserId profile cannot grant it twice.

**Acceptance:** four Rojo compositions; 30 session assertions
in Base and 30 in Dungeon; original weekly policy 40 assertions
in each composition; guardian factory eight assertions; existing
professions 14/14 and Dungeon backend 30/30 PASS.

**Boundary at this earlier checkpoint:** This was session
persistence contract testing with the real session service
against a **shared Studio in-memory adapter**. At that time,
normal Base entry and reserved-boss destination source had not
yet been implemented; the newer isolated-travel milestone above
documents their default-off integration. Published cross-server
MemoryStore/DataStore acceptance is still pending. The
disposable TestDungeon session used by the contract test
does not turn ordinary TestDungeon encounters into world bosses.

Receipt:
`docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Next backend milestone — published TEST handoff gate

1. Configure dedicated **TEST-only** Base and world-boss place IDs,
   with the weekly event still disabled by default outside the
   controlled acceptance window.
2. Run the first real Base → ReserveServer world-boss → Base journey
   using the existing party/session/lease handoff. Verify destination
   admission, real Roblox reserved access code, return handoff and
   per-member session cleanup.
3. Prove same-account reconnect and post-defeat reward recovery using
   genuine new-server profile leases plus TEST DataStore/MemoryStore,
   including one member disconnecting while others continue.
4. Add genuine two-client healing/ward Play against the guardian so
   support contribution is proven through the client skill pipeline,
   not only through focused server contracts.
5. Only after the published TEST journey is green should guardian
   phases, event announcements, reward tuning, final art/animations
   and live scheduling move toward release. Explicit approval remains
   required before any production rollout.

## Separate future/release gates

Actual same-account network reconnect, profile lease handoff,
Roblox published TEST/PROD, real-player DataStore migration,
public event scheduling, guardian-specific combat balancing,
unassisted full-party fights and final world-boss models are
**not** claimed as completed.

The accepted local v1.53 profession backend remains unchanged:
Skinning is animal-only, and the profession crafting, multiplayer
and interrupted-request recovery suites remain part of regression.
No user-visible code or art has been replaced.

**Local test receipt:**
`docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`.

**Operational rule:** author all source, test fixtures, roadmap
and handoff edits through GitHub. Use Remote Desktop only for
clean fast-forward pulls, local Rojo builds, unpublished Studio
tests and read-only diagnostics. No default event enabled,
cloud publish, production DataStore use, force-push or main merge.
