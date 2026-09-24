# DungeonMMO backend roadmap v2.08 — Knight shield-mastery candidate

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.07](DungeonMMO_Roadmap_v2_07_Ironvow_Resume_Knight_Magic_Healing_20260924.md).
[Test evidence and pending validation](../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).

## GitHub implementation, not Studio acceptance

- [x] Implemented `OathguardShieldMastery` as a distinct passive
  for a personally awarded Human Fighter → Oathguard.
- [x] Two separately purchased rank opportunities: level 20 and 28.
  A purchased Fighter `ShieldBash` rank 3 is required before training.
  Source category: historical Knight `ShieldMastery`.
- [x] A server-registered, currently equipped OffHand Shield is required;
  a missing, non-shield, wrong-slot or unknown item grants **zero**.
  Each earned rank reduces actual hostile physical `EnemyMelee` and
  `EnemyArea` damage by 0.8%, maximum **1.6%** for two ranks. It does
  not reduce `EnemyMagic` or player combat damage; existing physical
  mitigation caps and server-authoritative equipment snapshots remain.
- [x] Registered the ability in the actual Knight class, own physical
  trainer, rank-mapping audit, server passive resolver, runtime snapshot
  and shared combat damage service.
- [x] Added focused source-owned assertions for correct 20/28 schedule,
  forged/unawarded profiles, real trainer purchase, shield removal,
  real shield equipment and authenticated runtime mitigation.
- [x] Fresh disposable Base and Dungeon Rojo builds PASS; focused
  unpublished Knight quest/foundation **66 + 62 assertions PASS** and
  level-30 source audit **27 PASS**, each in its own process log.
- [x] New full-Dungeon unpublished Play test verified actual spawned
  player HP loses exactly 99.2/98.4 on 100 base hostile physical
  hits with test-owned rank 1/2 shield snapshots; no shield bonus
  on magic, PvP, absent/wrong gear or forged class. See linked evidence.
- [ ] Fresh two-client physical Base test **FAILED**: first Captain
  Rowan prompt was visible and enabled at four studs, but client hold
  did not emit server Triggered. Diagnosis needed before retesting.
- [ ] Real naturally purchased/equipped/player-controlled abilities,
  personal Knight heal and enemy spell-hit effects, multiplayer owner
  isolation, save/rejoin and full cross-place regression remain open.

## Measured scope

| Original level-20/24/28 first transfer | Source rank rows | Trainer-mapped candidate | Remaining unmapped |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 37 | 17 |

These are **registered training schedules**, not completed original C4
gameplay equivalence, release-ready classes, or a verified game-wide
level-30 cap. Only 4 of 18 original first-transfer branches are
source-rank inventoried; **0 of 18** are release certified.

## Continue when Studio is available

1. Diagnose the genuine physical first-NPC prompt hold failure
   without rerunning the entire quest repeatedly. Confirm the exact
   client/server input transport before accepting mentor/trainer flow.
2. Extend the passing real player-HP damage fixture with a naturally
   earned and bought/equipped class path, separately perform pending
   client-originated first/third self-heal and enemy spell-hit damage
   checks from v2.07, and verify a second player's isolation.
3. Finish 17 outstanding Knight and 35 Warrior source ranks with
   distinct implemented gameplay, then source-audit and implement
   the other original first-transfer branches and 1–19 starter
   ranks. Keep independently named DungeonMMO skills/NPCs.
4. Do not merge `main`, publish any Roblox place, mutate production
   DataStores or change the 1-gathering/1-crafting profession rule.
   Keep permanent edits in GitHub; desktop is for fast-forward pull,
   disposable builds, unpublished Studio tests and logs only.

The humanoid/quadruped art roadmaps remain separate and unchanged.
