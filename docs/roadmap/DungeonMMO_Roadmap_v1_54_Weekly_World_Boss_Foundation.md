# DungeonMMO roadmap v1.54 — weekly world-boss foundation

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** Default-off Base entry, reserved-server routing, separate
world-boss place, Base return, existing combat integration and a real
single-client guardian defeat/reward path are **locally verified**.
Published cross-server travel, authored arena content, multi-client
network recovery, genuine cloud persistence and live event release
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

## Next backend milestone — party resilience and published TEST gate

1. Add an authored minimal `WorldBossArenaSpawn` and basic enclosed
   arena to the dedicated place without replacing accepted combat.
2. Exercise actual multi-client boss Play with at least two real
   Studio clients: shared guardian damage, support contribution,
   player death/respawn or wipe semantics, and independent weekly
   eligibility.
3. Harden disconnect/rejoin around the live fight and post-kill
   reward path, including one player leaving while others continue,
   reconnect after defeat, failed reward save retry and individual
   return to Base.
4. Only after those local tests, configure separate TEST-only Base
   and world-boss place IDs and run the first published
   Base → ReserveServer boss → Base journey. Verify real profile
   lease handoff and DataStore/MemoryStore recovery there.
5. Guardian-specific phases, event announcements, reward tuning,
   final meshes/animations and public schedule remain separate
   release work. Explicit approval is required before live rollout.

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
