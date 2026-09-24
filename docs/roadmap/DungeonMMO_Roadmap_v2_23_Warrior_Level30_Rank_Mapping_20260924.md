# DungeonMMO backend v2.23 — Warrior level-30 source-row checkpoint

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Continues [v2.20](
DungeonMMO_Roadmap_v2_20_Warrior_Common_Craft_20260924.md)
and [v2.21 critical stance](
DungeonMMO_Roadmap_v2_21_Warrior_Critical_20260924.md).
[Exact latest focused and actual Play evidence](
../testing/ironvow-final-utilities-v2-23-20260924.md).

## Source rank milestones reached, not full release

- [x] Warrior critical stance: all 3 independently
  purchased 20/24/28 ranks; real client MP activation/
  upkeep, genuine NPC critical HP and rank-revocation
  checks previously passed.
- [x] Warrior accuracy stance: level-24 separate
  MP toggle with actual client, resource and
  deterministic evasion/accuracy checks previously passed.
- [x] Warrior passive HP recovery: level-24 purchased
  owner gains genuine 1.1 HP per second with server
  max-HP cap. Current Play PASS after fixing only
  the test's unparented spectator avatar fixture.
  Server still rejects invalid/detached or dead players,
  forged classes and revoked ranks.
- [x] Warrior endurance surge: level-28 purchased
  client cast spends 13 MP, nonstacking +10% actual
  MaxHealth and one 10% max-HP restoration. The
  real-client Play verified 108->118.8 MaxHealth,
  one 11.88 HP heal, a 100-damage enemy melee
  hit, no rapid recast/free heal/expiry refresh,
  rank-revocation removal and forged Fighter denial.
  The 600-second expiry timestamp was checked, but
  natural wall-clock expiry was not played for 600s.
- [x] Fresh Base and Dungeon disposable Rojo PASS;
  authentic quest / trainer / in-memory save
  31 / 198 / 160 focused assertions PASS; strict
  27-assertion source-rank audit PASS.

| Audited original C4 first-transfer class | Rank rows | Mapped | Missing |
|---|---:|---:|---:|
| Human Warrior -> Ironvow | 62 | 62 | 0 |
| Human Knight -> Oathguard | 55 | 55 | 0 |
| Human Rogue -> Ashenblade | 59 | 59 | 0 |
| Elven Scout -> Greenward Scout | 77 | 77 | 0 |

**These counts certify only training-rank schedule mapping.**
Four of 18 original first-transfer paths have source
inventories recorded. Other 14 original first-transfer
branches and original starter (level 1–19) skill
catalogues remain to audit, implement and playtest.
**0/18 first-transfer classes have completed whole-game
mechanical equivalence and release acceptance.**

## Remaining backend priority

1. Audit the existing four class families for mechanical
   source/effect parity rather than counting renamed
   rank rows as original C4 ability equivalence.
   Especially correct the provisional C4 stat/attack/
   defence/dodge/HP formula adapters and confirm any
   intentional WoW-style profession/economy differences.
2. Run an **actual** natural fresh-character
   level1->30 quest/trainer/equipment/skills
   Base->Dungeon->Base save/rejoin acceptance;
   the isolated in-memory source tests are not
   that full journey.
3. Test player/party/boss/world-boss defensive
   stacking: genuine blocked melee must consume
   stamina and deal bounded chip HP even with shield,
   mastery, timed guard and HP surge. Prior
   Marauder/Captain checks passed, but other hostile
   dispatch pipelines remain unverified. Verify
   PvP owner isolation, illegal weapon pairs,
   stun-refresh and simultaneous party interactions.
4. Audit and implement the remaining 14 C4 first-
   transfer inventories and starting 1–19 classes,
   with separately purchased skills and actual server
   effect/cost authority; do targeted playtests per
   new effect family. Do not infer C4 balance merely
   from matching reference skill power/rank numbers.
5. Finish HUD presentation, art, animation,
   persistent migration and controlled deployment
   only after source and multiplayer acceptance.

No `main` merge, Roblox publication, production
DataStore mutation or separate humanoid/quadruped
animation project edits. Source/roadmap changes
through GitHub; Remote Desktop only for safe
fast-forward, disposable Rojo builds and unpublished
Studio/test logs. Do not repeat unchanged broad suites.

## Follow-up after v2.23: stored character protection

GitHub commit [39ba212](https://github.com/Amidazs/DungeonMMO/commit/39ba212654431c529b56309d6187e615e5fbb9b4)
tightens Warrior HP recovery and endurance surge to require the actual
owner character to be descended from Workspace. A stored or detached
Player.Character cannot regenerate or pass the surge's pre-MP-spend
activation check. The previous world-parented owner, purchased-rank,
living-Humanoid, no-stack and expiry checks remain intact.

The existing disposable recovery and genuine-client surge drivers now
exercise a temporarily ServerStorage-parented character and require
recovery denial and surge precharge denial, followed by valid restored
character acceptance. These **new test assertions have not yet been
executed in Studio**. The earlier v2.23 real-client success remains
evidence for the prior source revision only. Both Base and Dungeon
disposable Rojo builds succeeded locally after fast-forward to 39ba212;
a PowerShell quoting diagnostic also appeared in the wrapper, not in
either Rojo build. No production-place or production-save changes.

The 62/62 Warrior, 55/55 Knight, 59/59 Rogue and 77/77 Scout numbers
remain historical rank-row schedules only. Full C4 formula/effect parity,
natural persistent Base->Dungeon->Base->rejoin journey, boss/world-boss
stacking acceptance and 14 remaining source class inventories are OPEN.
No main merge, public publish or animation-project edits.

