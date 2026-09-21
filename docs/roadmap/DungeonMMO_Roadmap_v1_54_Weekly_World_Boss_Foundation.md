# DungeonMMO roadmap v1.54 — weekly world-boss foundation

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** Default-off Base entry source, reserved-server routing,
separate world-boss place and Base return contracts **locally
verified**. Published cross-server travel, dedicated playable combat,
genuine cloud persistence and live event release **remain pending**.

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
destination assertions; a default-off Play-mode check; 30 durable
session assertions in each Base/Dungeon; weekly policy 40, guardian
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

## Next backend milestone — dedicated playable boss encounter

1. Connect the existing combat, player controls, guardian AI,
   server damage and participation recorder to the isolated boss
   place. Author a basic arena anchor and an opt-in Studio fixture
   without changing ordinary Dungeon/Temple encounters.
2. Make rewards resilient to verified boss defeat when eligible
   players disconnect, fail a save or return to Base. Verify
   pending entitlements, session TTL, wipe and retry semantics;
   never pay merely for invitation or untrusted client data.
3. Run isolated, actual multi-client Play-mode boss combat
   including damage/support, two distinct sessions, deaths,
   reconnect and individual return (no assisted boss kill).
4. Only after those checks, configure separate Base/boss TEST
   place IDs, published reserved-server admission, lease and
   DataStore/MemoryStore recovery. Prove Base → boss → Base
   over a real published TEST network before enabling the event.
5. Final guardian-specific phases, raid mechanics, reward
   tuning, event notices and models follow the trusted backend
   contract. Explicit approval is required for any public launch.

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
