# Four-client, two-enemy support-threat multiplayer acceptance

Date: 21 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Fresh test head: `65b0fc062cc5865da2a36f210195222c99f46afc`

## Actual Studio gameplay evidence

Ran `scripts/studio/four_player_room_support_aggro_live.luau`
in the unpublished `default.project.json` Dungeon composition with
**four actual Studio client processes**, two real Training Marauder
controllers and authoritative CombatService/ThreatService.

The fixture successfully completed these ordered checkpoints:

- `REAL_FOUR_CLIENT_FALLBACK_PASS`: nearest living player selected
  while four real players were within the first enemy's encounter.
- `IDLE_ENEMY_ISOLATION_PASS`: client Taunt engaged enemy A and a
  real client MageHeal generated support threat only on enemy A.
  Enemy B's idle threat remained zero.
- `REAL_SECOND_ENEMY_DAMAGE_PASS`: a different real client attacked
  enemy B. Its real damage created B-specific threat while the
  same DPS player's A-ledger remained untouched.
- `REAL_TWO_ENEMY_HEAL_PASS`: after both enemies were genuinely
  engaged and eligible, the healer used MageHeal again. Effective
  support increased the healer's threat on both enemies separately.
- `REAL_TANK_RETAKE_PASS`: the Fighter retook enemy A using a
  genuine second client Taunt after its server cooldown expired.
- `DEAD_HEALER_FALLBACK_PASS`: the healer died on their owning
  client and enemy B selected the remaining eligible DPS.
- Overall runner: `VERIFIED_FOUR_CLIENT_PASS`.

The first attempt exposed a fixture timing error: its second
Fighter Taunt was sent while the eight-second server cooldown
was still active and was correctly rejected by CombatService.
The GitHub fixture now waits for cooldown plus recovery before
the second genuine client request; the corrected four-client run
passed. No server authority/cooldown checks were weakened.

At that same head all six Rojo compositions built, the feature
worktree was clean and `git diff --check` succeeded.

## Scope and remaining work

This proves real four-client threat and eligibility interactions
using the current training-enemy controllers; the earlier simulated
four-role ledger contract remains complementary, not a substitute.
The test uses disposable server-side positioning/health setup to
create reproducible conditions, but damage, skills, healing and
NPC selection in the assertions run through actual game code.

It does **not** yet prove a full-party wipe automatically resets
the live enemy controllers, a real player-disconnect/return lifecycle,
or a full four-person production dungeon session with persistent
rewards. Those remain separate local acceptance gates.

All source, fixture and documentation edits were made in GitHub.
Remote Desktop was limited to fast-forward pulls, TEMP Rojo builds,
unpublished Studio Play and read-only diagnostics. Nothing was
published to Roblox, merged to main or written to production
DataStores.
