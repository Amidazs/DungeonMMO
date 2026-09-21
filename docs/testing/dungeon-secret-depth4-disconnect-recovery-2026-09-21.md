# Local dungeon secret, higher depth and peer-leave recovery

Date: 21 September 2026
GitHub branch: `wip/phase-4-test-hud-integration-v1`
Latest focused tested commit:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`

## Four-player secret-boss wipe and restart

At `5f005bd32fe70e7c37f9fac5fb8917fb49338f6b`,
four actual unpublished Studio clients entered a disposable
Temple test dungeon with an eligible secret boss. The fixture
temporarily enabled optional content **inside Studio only**,
cleared the authored Room1, EventArena and Room2
prerequisites using test-injected lethal enemy damage,
then entered the physical SecretArena trigger.

The actual secret boss was injured, all four real player
Humanoids died, its old model retired and the four players
automatically revived at the checkpoint. Previously cleared
encounters remained Cleared. SecretArena returned to Pending;
re-entry spawned one different, full-health secret boss.

Server/client logs included `CLEARED_ROOMS_PRESERVED_PASS`,
`OLD_BOSS_CLEANUP_PASS`,
`FOUR_BOSS_CHECKPOINT_REVIVES_PASS`,
`FRESH_FULL_HEALTH_BOSS_PASS`, and the Studio parent
`VERIFIED_MULTIPLAYER_PASS`.

Fixture:
`scripts/studio/dungeon_four_client_secret_wipe_live.luau`.

## Depth4 mini-boss and six-encounter plan

At `e8d4fe251a272e979aa2049dcacee2937819f2ae`,
four live unpublished Studio clients entered the **Depth4**
Temple placeholder layout. Its six-encounter plan remained
intact. The physical Depth4 Room1 was cleared, then
the Room2 mini-boss was injured and the whole party died.

The old mini-boss model was retired and every player
automatically revived. Room1 remained Cleared; the
Room2 mini-boss returned to Pending and the subsequent
Room3 combat encounter stayed Pending. Re-entering the
correct authored `Temple.Depth4.Room2.Trigger` spawned
a new, single, full-health mini-boss.

The initial draft of the fixture incorrectly used Depth1
`Temple.Room1/Room2.Trigger` anchors. It was corrected
to the actual Depth4-specific triggers; the test no longer
treats a Depth1 physical room as evidence of Depth4
gameplay. Fixture assertions now wait for persisted
encounter rollback after multi-client revive rather than
expecting its write at an arbitrary intermediate tick.

Parent Studio log: `VERIFIED_MULTIPLAYER_PASS`.
Fixture:
`scripts/studio/dungeon_four_client_depth4_miniboss_wipe_live.luau`.

Depth4 content is TEST placeholder content here, **not a
published difficulty unlock**.

## Real party-member disconnect during a boss

At `e8d4fe2`, four real Studio clients reached Temple's
Depth1 Room3 boss after clearing the prior two rooms with
test-injected enemy defeats. While the boss was active and
injured, a genuine participant was kicked from the
disposable Studio test. The runtime's actual
`Players.PlayerRemoving` callback persisted their
`Connected=false` status.

The boss and the run remained active for the remaining
three participants. Only those three were killed;
their collective wipe cleaned up the boss and their
three automatic free revives returned them to the
saved boss checkpoint. The absent fourth member's
free revive was **not consumed**. Earlier rooms stayed
Cleared, the interrupted boss went Pending and
physical re-entry spawned one different full-health
boss. The fixture's asynchronous session state checks
now await eventual persistence to avoid a false-negative
mid-transaction read seen in its first diagnostic run.

Markers: `PEER_BOSS_CONTINUES_PASS`,
`OLD_BOSS_CLEANUP_PASS`,
`FOUR_BOSS_CHECKPOINT_REVIVES_PASS`,
`FRESH_FULL_HEALTH_BOSS_PASS` and
`VERIFIED_MULTIPLAYER_PASS`.

Fixture:
`scripts/studio/dungeon_four_client_boss_disconnect_wipe_live.luau`.

**This test does not reconnect the identical Roblox account.**
A fresh same-account reconnect into a published running
server remains a separate acceptance gate.

## One-shot terminal failure regression

The previous production fix means
`DungeonDeathService:tick` emits terminal failure only
at the actual transition, not on every subsequent server
tick (which had overwritten the Play again waiting UI).

A pre-existing service test for both dungeons, Depth2
and Depth4, and one-, two- and four-member parties had
still expected the old repeated notification. Its
expectation was updated in GitHub without changing the
production behavior again. The focused
`dungeon_optional_depth_wipe_tests.luau` runner passed
**392 assertions** at `9a63c6d`.

## Final builds and boundaries

At `e8d4fe2`, all **six** Rojo compositions built,
the Dungeon backend matrix passed **30/30** and
DungeonDeathService passed **41 assertions**. The
four-player boss-disconnect and Depth4 mini-boss Play
fixtures were rerun successfully at the **same head**;
the secret-boss fixture had passed at `5f005bd`.
At `9a63c6d`, the focused higher-depth wipe suite
passed its **392 assertions** after the test correction.

These fixtures use genuine separate Studio clients and
physical encounter models, but test-injected enemy injury,
enemy defeats and player deaths. They do not prove
ordinary attack/damage balance, production cloud
persistence, repeat paid purchases or a published
reserved-server replay.

All repository scripts, tests and documents were edited
directly in GitHub. Remote Desktop was used for read-only
diagnostics and clean pulls, local Rojo builds and
unpublished Studio tests only. No Roblox place was
published, no `main` merge or force-push was made and
no production DataStore was mutated.
