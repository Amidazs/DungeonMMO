# Phase 4 optional-boss two-client local Studio playtest

## Scope

On 20 September 2026, run from the unchanged, clean integration
source checkpoint c571552d065a3e732271fb897f2eac2ad4c426a0 on
wip/phase-4-test-hud-integration-v1. The disposable local
Dungeon Rojo build was produced at
C:/Users/Remko/AppData/Local/Temp/DungeonMMO_OptionalTwoClient_20260920.rbxl.

The source-controlled driver is
scripts/studio/phase4_optional_boss_two_client_fight.luau.
It runs only when PlaceId and GameId are zero. It temporarily enables
Temple optional encounters, server-run event/secret eligibility,
replaceable physical placeholders and shared two-client Studio
admission in the loaded local DataModel. These temporary mutations
are NOT written to DungeonRuntime, release flags or any published
place. Ordinary source remains rollout-locked.

## Two-client gameplay

Two distinct simulated Studio client processes joined the same
server-authoritative session. Both were admitted into a frozen
Room1 -> EventArena -> Room2 -> SecretArena -> Room3 plan.

- Room1 cleared, both clients approached EventArena and one boss
  spawned. A second arrival did not spawn a duplicate.
- One simulated player was disconnected with a server kick while
  the Event boss was Active. The departing member was marked
  disconnected by the actual DungeonRuntime PlayerRemoving path.
  The remaining member stayed connected; the same run, checkpoint
  and Active Event state remained in place.
- A detached recovery sequencer constructed from the saved interrupted
  snapshot correctly returned Event to Pending and kept Room1
  Cleared. This was NOT a live same-user network reconnect or a
  replacement of the active controller while the peer was fighting.
- The surviving player defeated Event (test-assisted Humanoid defeat),
  received the Event reward and an explicit replay of its existing
  reward transaction returned already_applied without increasing
  reward-history size.
- The surviving player cleared Room2, encountered exactly one Secret
  boss, cleared it and completed the final Room3 boss. The saved
  session entered Complete and the surviving player received a
  Secret-boss reward.

## Receipts

The original disposable two-client run passed in parent Studio log
20260920T160951Z_Studio_235E4_last.log and child server log
20260920T161000Z_Studio_4460F_last.log.

A fresh rerun added detached interrupted-Event recovery validation.
Parent Studio log
20260920T161203Z_Studio_B6E09_last.log records
MULTIPLAYER_OPTIONAL_FIGHT_PASS. Child server log
20260920T161212Z_Studio_F969B_last.log records TWO_CLIENT_PLAN_PASS,
EVENT_ONE_BOSS_TWO_CLIENTS_PASS,
EVENT_DISCONNECT_PEER_ACTIVE_PASS,
INTERRUPTED_EVENT_RECOVERY_PASS, EVENT_REWARD_REPLAY_BLOCKED,
SECRET_PEER_ONE_BOSS_PASS and PEER_FINAL_COMPLETION_PASS.

## Not proven

Combat defeats were assisted; this is not an unassisted combat/balance
test. Same-account rejoin, recreation of the live DungeonRuntime in
a new server with both clients, cross-place handoff, cloud deployment
and published multiplayer release acceptance remain untested.
No TEST Lobby, TEST Dungeon, PROD or player DataStore was modified.
