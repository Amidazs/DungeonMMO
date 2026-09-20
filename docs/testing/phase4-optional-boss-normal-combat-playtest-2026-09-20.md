# Phase 4 Temple optional-boss normal-combat playtest

Date: 20 September 2026. Integration branch:
`wip/phase-4-test-hud-integration-v1`.

## Local test method

The test fixtures in `scripts/studio/` were authored on GitHub and
fast-forward pulled into the clean integration worktree. They run only
in an unpublished local Roblox Studio place (`PlaceId=0`,
`GameId=0`). They temporarily enable Temple optional encounters
and shared two-client admission **in the disposable Studio DataModel**.
The server-authoritative real `CombatInputActions.request_attack()`
path was used to inflict damage on Event and Secret. Optional boss
Humanoid health was not directly assigned by the fixtures. The test
driver positioned characters by the boss and selected test room
triggers; prerequisite combat packs and the final boss were
test-assisted. This is automated real combat, not a human-controlled
walkthrough or a fully unassisted entire dungeon run.

## Event result — PASS

`phase4_optional_boss_two_client_normal_combat.luau` was committed
to GitHub at b743dc9, with inherited artificial player-health
assignment removed at a5ede06. The first run failed its health
safety assertion before normal combat and is not counted as a win.
A fresh run with normal character health defeated TempleEventBoss:
boss 120 -> 0 HP; surviving player 34.15 / 113.40 HP.
Server log:
`0.739.0.7390687_20260920T162227Z_Studio_02D56_last.log`
(`EventArena NORMAL_CLIENT_BOSS_DEFEATED`).

The same surviving player then attempted TempleSecretBoss immediately
after Room2, starting injured; boss 120 -> 56.72 HP while the player
died at 0 / 113.40 HP. The combined back-to-back fight **FAILED**.
Do not report the combined two-boss sequence as accepted.

## Secret result — PASS in separate two-client run

`phase4_secret_boss_two_client_normal_combat.luau` was committed
on GitHub at 0596a3b. Both players were kept at normal starting
health. The Event encounter was deliberately test-assisted to
isolate Secret combat. Two clients entered the Secret route; its
boss spawned once. Standard client attack inputs defeated
TempleSecretBoss 120 -> 0 HP; the monitored survivor remained at
70.55 / 113.40 HP. The run then reached dungeon completion.
Parent Studio log:
`0.739.0.7390687_20260920T162426Z_Studio_ECC38_last.log`
(`TWO_CLIENT_NORMAL_SECRET_BOSS_PASS`).
Server log:
`0.739.0.7390687_20260920T162436Z_Studio_F7348_last.log`
(`SecretArena NORMAL_CLIENT_BOSS_DEFEATED`,
`EVENT_REWARD_REPLAY_BLOCKED`, `PEER_FINAL_COMPLETION_PASS`).

## Remaining gameplay acceptance

Both optional bosses have independent, normal-combat local wins.
However, consecutive victories by the same injured solo survivor
have **not** been demonstrated. That scenario requires testing
normal healing, blocking, dodging, party cooperation or combat
balance without artificially increasing player health. True
same-account reconnect and unassisted/manual end-to-end gameplay
also remain open. No cloud publish, DataStore mutation, PROD
change or model/mesh work occurred.
