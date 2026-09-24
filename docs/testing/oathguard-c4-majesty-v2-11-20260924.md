# v2.11 Knight defensive stance correction — executed acceptance

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Verified local source: `fbbfb8bf7d8938648d426bd1fefea5785e421f84`

## C4 source and contract

Reference: https://l2hub.info/c4/skills/82-majesty%3A1/levels

The earlier v2.09 `OathguardSteadfastStance` was a short
10% physical-damage, ten-second, 14-stamina buff and did **not**
match the original Knight Majesty mechanics. That earlier successful
live playtest is **historical only**; it must not be used to accept
the corrected build.

The corrected one-rank, earned Knight level-20 stance now carries
the original +7% P.Def, -2 Evasion and 10 MP skill parameters,
using an approximately five-minute timed status. Its invented
Fighter-armor-rank-3 unlock was removed; the proper personal
Knight class/quest and minimum level are still required.
The old 14-stamina charge was removed.

**Conversion disclosure:** DungeonMMO currently converts +7%
P.Def to 7 percentage points of mitigation for hostile physical
melee/area hits and converts -2 Evasion *stat points* to -2
percentage points of the existing Roblox chance to evade.
This is a live, internally consistent effect **but NOT** an
identical C4 defence/Evasion formula. The generic historical
C4 cooldown is not independently established here; Roblox's
current 3-second cooldown is a provisional adapter setting.

## Fresh builds and focused Studio verification

- `base.project.json` and `default.project.json` disposable
  unpublished Rojo builds **PASS**; unchanged canonical place file.
- The first freshly executed focused Quest test failed
  `IdentityIncomplete` because its new negative test forced
  an already awarded level-20 Knight down to level 19 in
  its **persisted** profile. This invalidates the earned class
  receipt. The fixture was corrected in GitHub to check source
  eligibility on a *detached* level-19 character clone, keeping
  the genuine awarded profile intact. The second negative test
  required either the genuine `OriginalFirstTransferRequired`
  or the character-level gate, rather than wrongly insisting
  the latter must run first.
- Corrected focused Base run log
  `0.740.0.7400927_20260924T090843Z_Studio_92080_last.log`:
  `[Oathguard Quest] PASS: 87 assertions`;
  `[Oathguard Foundation] PASS: 84 assertions`;
  all Quest/Skill verification markers present.

## Genuine player-health Play verification

The existing source-controlled
`scripts/studio/c4_oathguard_stance_client_live.luau` was
updated in GitHub to test the *new* C4 source parameters,
then executed on a freshly rebuilt, unpublished disposable
full Dungeon at `fbbfb8b`. Specific Studio process log:
`0.740.0.7400927_20260924T090917Z_Studio_414B9_last.log`.

- Actual local client hotbar cast applied the own-player
  server status, spent at least 9.5 of the 10 MP, and gave
  the owner the separate -2-point evasion metadata.
- Actual spawned owner Humanoid took **93 HP** from 100-base
  hostile melee and area damage while the status was active.
- Hostile magic and ordinary player-style melee damage were
  **100 HP** (no protection from this *physical-only* stance).
- Verified the 300-second expiry timestamp and an immediate
  second cast did not extend the server status. Expiration
  was tested with **test-only forced expiry attributes**, not
  by waiting five minutes of real wall-clock gameplay;
  the latter remains pending.
- After forced expiration hostile melee returned to
  **100 HP**; unearned Fighter copied ability was rejected.
- Exact `REAL_EnemyMelee_93_PASS`,
  `REAL_EnemyArea_93_PASS`,
  `REAL_EnemyMagic_100_PASS`,
  `REAL_Melee_100_PASS`,
  `REAL_EnemyMelee_100_PASS`,
  `ALL_REAL_CLIENT_TIMED_GUARD_PASS` and
  `VERIFIED_PLAY_MODE_PASS` all appear in that log.

**Limits:** synthetic internally valid Knight progression and
hotbar snapshot in live Play, not uninterrupted persisted natural
quest → trainer purchase → Dungeon cast. Full C4 damage/evasion
balance equivalence has not been proved. A separate Ultimate
Defence analogue is **still missing**: its actual C4 level-20
effect is +1800 physical defence, +1350 magical defence, 19 MP,
and cannot move. Do not treat Steadfast Stance as a replacement:
https://l2hub.info/c4/skills/110-ultimate-defence%3A1/enchanting-1

No production saves, `main` merge or Roblox publishing.
