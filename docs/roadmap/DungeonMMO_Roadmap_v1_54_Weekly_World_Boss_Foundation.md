# DungeonMMO roadmap v1.54 — weekly world-boss foundation

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** Local backend policy and opt-in physical prototype
**verified**; normal-game event entry, reserved server and release
**not implemented or enabled**.

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

The first physical gateway is a **test fixture only**. It is not a
normal Base portal, public event, reserved-server route or finished
boss encounter. The guardian uses the existing combat rig for
backend verification; the 100-gold payout is a provisional test
value, not a balanced final reward.

## Next backend milestone — make entry and reward recoverable

1. **Event issuance and Base entry:** add a default-off server
   schedule/release configuration and Base portal adapter. Reuse
   existing party/session/teleport infrastructure; issue a single
   authoritative event token at the moment of entry, independent
   of any client-supplied success or calendar value.
2. **Reserved instance and recovery:** bind event ID, week key,
   party membership, frozen entry time, dedicated boss encounter,
   checkpoint, completion and pending per-player rewards to the
   existing durable session adapter. Rejoin must not reroll event
   state or create another weekly entitlement.
3. **Eligibility/reward delivery:** authorize participation using
   real session membership and encounter contribution. Define
   disconnect, wipe, expired-event, ineligible-member, late-arrival
   and retry semantics before enabling cloud travel. Keep the weekly
   claim in one atomic profile mutation and verify persistence
   across genuine new-server profile leases.
4. **Physical Play acceptance:** exercise Base portal → reserved
   Dungeon arrival → real boss combat/reward → return, including
   separate party instances, two-client completion, defeated-player
   eligibility, duplicate-kill protection and disconnect/retry.
   Studio-only fixtures are not substitutes for cross-server TEST.
5. **Only then expand raid mechanics:** phased attacks, coordinated
   group mechanics, independent encounter phases/checkpoints and
   broader raid reward rules. Dedicated guardian meshes/animations,
   event calendar announcement, reward tuning and UI can follow
   independently of the server contract.

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
