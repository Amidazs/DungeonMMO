# Four-client dungeon recovery and replay — local acceptance

Date: 21 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Latest gameplay/test source: `a5c0637888f8400703d07290f790a24d3b8406bf`

## Physical party wipe and reward re-entry

At `4465c501fb030da08d7f845b401360465d92f3be`, four
**real unpublished Studio clients** entered the same live
Temple Room1 session. One of its two real enemies was killed
with test-injected lethal damage. The real RewardService produced
one monster transaction receipt for every connected player.
The other monster remained alive and was injured, after which
all four actual player Humanoids died.

The server retired the old enemies, consumed each member's
single automatic free revive, restored four new characters at
the saved checkpoint and kept the dungeon session Active.
A player physically re-entered Room1: a new full-health pack
spawned with new model handles.

The already-rewarded monster was killed again in the **same
session with the same reward transaction ID**. All four
players' Gold, Level, carried XP and recorded bestiary kill
count remained unchanged. This is real profile/reward-service
idempotence, not a stubbed fake-reward test.
Server/Studio markers:

- `SHARED_SESSION_PASS`
- `FIRST_KILL_REWARDS_PASS`
- `FOUR_DEATH_CLEANUP_PASS`
- `FOUR_CHECKPOINT_REVIVES_PASS`
- `FULL_HEALTH_ROOM_REENTRY_PASS`
- `NO_DUPLICATE_REWARDS_PASS`
- `VERIFIED_MULTIPLAYER_PASS`

Fixture: `scripts/studio/dungeon_four_client_room_wipe_live.luau`.

## Ordinary boss recovery

At `3c34e012df355865a2d6002846d877c11ea6db5b`,
four genuine Studio clients cleared Rooms 1 and 2 with
**test-injected prerequisite kills**, entered the authored
Room3 boss trigger and injured the actual boss without
defeating it. All four players died and free-revived.

The previous boss model was destroyed, its spawn guard was
released, the boss encounter returned to Pending and the
first two cleared rooms stayed Cleared. Re-entering Room3
spawned **exactly one different full-health boss** and
preserved the current checkpoint.

Markers: `CLEARED_ROOMS_PRESERVED_PASS`,
`INJURED_BOSS_PASS`, `OLD_BOSS_CLEANUP_PASS`,
`FOUR_BOSS_CHECKPOINT_REVIVES_PASS`,
`FRESH_FULL_HEALTH_BOSS_PASS` and
`VERIFIED_MULTIPLAYER_PASS`.

Fixture: `scripts/studio/dungeon_four_client_boss_wipe_live.luau`.

## Optional event-boss recovery

At `a5c0637888f8400703d07290f790a24d3b8406bf`,
the four-client physical wipe/re-entry also passed for
the Temple's **optional EventArena boss**. Room1 remained
Cleared; Room2 stayed Pending. The interrupted event boss
was removed, released its spawn claim and then respawned as
one new full-health boss after all four checkpoint revives.

The fixture temporarily opened the Temple optional event
gate **only in the disposable unpublished Studio DataModel**
and selected an active event window. The Github game
definition and Mine release gate were not changed or
published. This proves an eligible event boss can recover;
it does not enable events for players.

Fixture: `scripts/studio/dungeon_four_client_optional_wipe_live.luau`.
Server/Studio marker: `VERIFIED_MULTIPLAYER_PASS`.

## Real client-to-server Play again and defect fixed

The first genuine two-client replay-request test at
`000aa40` failed: after a terminal wipe,
`DungeonDeathService:tick` returned `failed=true`
on **every later tick**. The Dungeon runtime repeatedly
broadcast `Failed`, resetting the replay waiting UI so
the first player's Play again vote appeared to disappear.

The production service now returns a failure event only
on the transition to Failed. A focused regression asserts
subsequent ticks do not reannounce the terminal failure.
The corrected two-client fixture passed at
`a2dec810b40f33f61908c1c282f5784d6ac317f2`:
the first authenticated client sent the actual
`ReturnRequest("PlayAgain")` remote and saw
`Waiting for party`; the second client sent the same
request and **both** clients saw `Replay simulated`.
The original terminal run stayed Failed.

This fixture seeds a Failed session and presents its
end screen in the disposable test to exercise actual
client/request/server/consent/UI wiring. It does **not**
perform a literal mouse click, a full two-client combat
loss, or an actual reserved cross-place teleport.
Separate earlier genuine-client UI tests verified that
Play again is available after both a committed victory
and a terminal failure.

Fixture: `scripts/studio/dungeon_two_client_replay_request_live.luau`.

## Same-head regression evidence

At `a5c0637`, all six Rojo compositions built and
Dungeon backend passed **30/30**, including
DungeonDeathService **41 assertions**. At the gameplay
fix head `a2dec81`, focused threat passed
**51 assertions**, Base professions **14/14**
and paid-retry integration **15 assertions**.

## Remaining gates

- An actual **published** multi-client reserved-server
  replay, persisted reward transfer and cross-place
  identity/teleport recovery still require separate user
  authorization. No published journey was tested.
- The four-player boss/event fixtures use test-injected
  prerequisite kills and test-injected boss injury;
  they do not establish ordinary player-attack balance
  or a second boss reward after a post-kill wipe.
- Secret-boss, higher-depth and disconnected-party
  recovery remain separate physical multiplayer gates.
- A paid revival whose persisted grant succeeds but
  character spawning subsequently fails still needs
  its product/refund/recovery policy.

All source, tests and documentation changes were made in
GitHub. The desktop connection was used only to fast-forward
the clean feature worktree, perform local Rojo builds,
run unpublished Studio fixtures and inspect their logs.
No Roblox place was published, no `main` merge or
force-push was made, and no production DataStore was used.
