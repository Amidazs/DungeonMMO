# v1.54 weekly world boss — local foundation and Play verification

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Latest tested code/fixture:** `f51f5df36f61d22999a17cc98d16b8eb1b435051`  
**Status:** Weekly calendar, trusted instance/reward policy and a
**disposable, physically entered guardian prototype** PASS in local
unpublished Studio. Production entry/teleport and event rollout are
**not implemented or enabled**.

## Backend delivered

- `WeeklyWorldBossWindow` derives Monday 00:00 UTC week identity,
  validates exclusive entry-window boundaries, disallows windows
  longer than two hours and prevents crossing a weekly reset.
  **There is no active default weekly event schedule.** A trusted
  server caller must supply explicit start/end timestamps.
- `WeeklyWorldBossService` is composed into existing Base/Dungeon
  `RuntimeServices` but exposes **no client RemoteEvent**.
  It admits a server-approved party of up to four loaded players
  into a unique local encounter snapshot only during the active
  window. No claim that this is a cross-server reserved instance.
- The only registered prototype boss ID is `AncientGuardian`.
  `DungeonWeeklyWorldBossFactory` creates a distinct tagged boss
  by reusing the existing captain combat rig. It carries an
  instance-specific server identity and grants **zero ordinary
  monster gold or XP**. The guardian art, attacks and balance are
  deliberately temporary; the factory is not inserted into a
  normal dungeon pack.
- The weekly service accepts death proof only from a server-tagged
  matching boss model that exists in Workspace and has zero health.
  A defeated server instance can grant its admitted members a
  provisional **100 gold** once per character per calendar week.
  Each reward applies gold and the week receipt in one character
  profile mutation and calls the existing profile save API.
  The receipt is an additive entry under the existing
  `RewardHistory.WeeklyWorldBoss` table, so older V13 profiles
  without this optional field begin with an empty weekly history;
  no destructive migration or schema-version bump was required.
- A different instance in the **same** week cannot pay a character
  again. A new week has a new key. The recorded result survives
  in-memory save/release/reload across newly created profile-service
  objects. A completed instance stops paying 30 minutes after the
  close of its frozen entry window. No client can choose its own
  week key, approved participants, defeat flag or gold amount.

## Actual unpublished Studio results

All output files are disposable local files under
`%TEMP%\DungeonMMO_weekly_world_boss_v1\` and
`%TEMP%\DungeonMMO_weekly_world_boss_v2\`.

| Run | Evidence | Observed result |
| --- | --- | --- |
| Base policy/calendar/weekly reward | `v1/focus_base.log` | 40 assertions PASS; focused 1/1 |
| Dungeon policy/calendar/weekly reward | `v1/focus_default.log` | 40 assertions PASS; focused 1/1 |
| Dungeon policy and actual guardian factory | `v2/factory_policy_final.log` | 40 policy + 8 factory assertions PASS; focused 2/2 |
| Actual client physical gateway → guardian spawn → two defeats | `v2/physical_entry_clean.log` | `CLIENT_WINDOW_ENTRY_PASS`, `FIRST_WEEKLY_REWARD_PASS`, `NO_WEEKLY_REWARD_FARM_PASS`, `VERIFIED_PLAY_MODE_PASS` |
| Existing Base profession regressions | `v2/base_profession_regression.log` | 14/14 PASS |
| Existing general Dungeon regressions | `v2/dungeon_backend_matrix.log` | 30/30 PASS |
| Four Rojo compositions after implementation | terminal build receipt | Dungeon, Base and both published-style layouts PASS |

The actual client held a physical entry ProximityPrompt in a
**temporary, injected Dungeon Studio fixture** while an explicit
server clock window was open. The normal Dungeon runtime loaded
the player's own Studio test profile. The fixture admitted the
player through the shared weekly service, spawned a guardian through
the registered real server factory, and assisted defeat by setting
the boss's health to zero. The first encounter saved 100 gold
into that loaded player profile. The client entered again and
defeated a separate instance but received zero additional weekly
gold. This proves local client entry, server boss identity and
reward anti-farming, **not unassisted boss combat, real reserved
teleport, a production entry portal or cross-server persistence**.

## Corrected test attempts

The first factory contract test checked `RewardGoldMin`/
`RewardGoldMax`; the existing Marauder factory actually stores
`DungeonRewardGoldMin`/`DungeonRewardGoldMax` attributes.
The assertion was corrected **on GitHub**; both suites then passed.

The first physical fixture also ran unrelated Dungeon autorun tests
against its synthetic blockout. `DungeonEncounterBindingsTest`
reported its expected layout mismatch. The test was corrected
on GitHub to disable unit autorun scripts **only in the disposable
DataModel**, and the unchanged dedicated policy/factory tests and
separate 30-suite regression were executed independently.
The final isolated physical run passed without the earlier
layout-test conflict.

## Remaining world-boss release gates

1. Add explicit **server-authorized** weekly schedule and rollout
   controls in the actual Base entry flow. A real Base portal,
   reserved dungeon server and teleport/admission snapshot are not
   wired to this prototype service; no public event is available.
2. Persist instance identity, invited membership, encounter result
   and disconnected members' entitlement across server handoffs
   using the existing session/lease infrastructure. The current
   `_instances` map is server-local, while only claimed weekly
   reward receipts persist through the profile adapter.
3. Tie each player's payout to validated participation/contribution
   rather than invitation alone, define partial-party and retry
   semantics, protect reward writes across real server failures,
   and validate genuine published TEST DataStore handoff.
4. Author guardian-specific combat phases, server attacks, reward
   balancing and art. The existing captain-based guardian is
   deliberately a default-off backend placeholder. The 100-gold
   amount and up-to-two-hour entry duration are provisional.
5. Require separate release approval before publishing or
   enabling live events. No player production DataStore, Roblox
   cloud publish, force-push or main merge occurred.

All source, test-fixture, roadmap and handoff edits were done
through GitHub. Remote Desktop was used only to fast-forward a
clean worktree, build unpublished local Rojo compositions, execute
versioned Studio tests and inspect their output.
