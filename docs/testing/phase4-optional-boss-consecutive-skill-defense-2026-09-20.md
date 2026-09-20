# Phase 4 — consecutive optional bosses, co-op, dodge and healing

Date: 20 September 2026. Development branch:
`wip/phase-4-test-hud-integration-v1`.

## Scope and approach

All new fixture source was authored in GitHub and fast-forward pulled
into the existing Windows integration worktree before local Studio tests.
Both tests ran against an unpublished, disposable Dungeon Rojo build,
with the Temple optional rollout enabled only in the loaded temporary
DataModel. Existing production source, authored assets, published places,
and player DataStores were not modified.

These are automated two-client gameplay tests with ordinary player health
and the established CombatInputActions client-to-server combat path.
The driver places characters near the encounters. Room1, Room2 and
the final-room boss are test-assisted, so the tests are NOT manual
navigation or unassisted end-to-end dungeon acceptance.

## Test A — consecutive ordinary-health co-op: PASS

Fixture: `scripts/studio/phase4_event_secret_consecutive_coop_combat.luau`
(committed at `86f1a09e46ba5fe6a6fccf0151ccf06d532acc78`).

Two Studio clients joined one frozen eligible Temple run. Both fought
Event with regular attack inputs and both survived. Monitored player:
85.71/113.40 HP after Event; ally 62.97/113.40 HP. They then defeated
Secret using regular client attack inputs without resetting player or
optional boss health; monitored player 64.58/113.40 HP after Secret.
Duplicate boss and Event reward replay assertions remained active.
The assisted final-room completion check passed.

Parent log: `0.739.0.7390687_20260920T163120Z_Studio_74A69_last.log`
records `NORMAL_EVENT_THEN_SECRET_PASS`.
Child server log:
`0.739.0.7390687_20260920T163129Z_Studio_DF2FD_last.log`.

The earlier injured SOLO survivor failure remains a separate, unpassed
scenario. This result proves ordinary-health party cooperation, not a
single player's ability to solo both encounters back-to-back.

## Test B — real dodge, equipped heal and consecutive co-op: PASS

Fixture: `scripts/studio/phase4_optional_boss_skill_defense_coop_combat.luau`.
The initial variant (commit `a7d7073`) passed but checked only a
small health increase, which could have been passive regeneration.
It was strengthened at `c445611` to require a server-confirmed
equipped healing skill plus at least 12 HP of recovery. Only the
strengthened rerun is cited as proof of skill-based healing.

Both clients defeated Event using ordinary client attacks and
normal HP. The surviving player requested dodge via
`CombatInputActions.request_dodge()`; the server-replicated
`CombatState == "Dodging"` confirmed acceptance. The client then
requested its equipped heal through
`CombatInputActions.request_skill_slot(3)`. The server confirmed
the active healing skill and the party recovered approximately 32 HP
in total, without directly assigning humanoid health in the fixture.
Both then defeated Secret with normal attacks; monitored player
75.74/113.40 HP afterward. The reward-replay and assisted final
completion checks passed.

Parent log: `0.739.0.7390687_20260920T163528Z_Studio_5079C_last.log`
records `DODGE_HEAL_EVENT_SECRET_PASS`.
Child server log:
`0.739.0.7390687_20260920T163538Z_Studio_ED606_last.log`
records `SERVER_DODGE_ACCEPTED`, `HEAL_SERVER_ACCEPTED`,
`REAL_SKILL_HEAL_PASS`, `SecretArena boss=0` and
`PEER_FINAL_COMPLETION_PASS`. Client log
`0.739.0.7390687_20260920T163402Z_Studio_9CEC8_last.log`
from the first run confirms the normal dodge and equipped-skill input
paths; the strengthened rerun uses the same unchanged input code.

## Remaining acceptance

Normal-defense and healing-assisted two-client consecutive optional
combat has now passed locally. The initial injured single survivor
without party assistance still died in Secret and is not accepted.
Actual same-account cross-server reconnect, unassisted combat for
all required rooms, manual navigation, a complete live reward economy
test and published cloud verification remain separate tasks.
