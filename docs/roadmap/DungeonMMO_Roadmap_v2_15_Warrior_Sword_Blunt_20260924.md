# DungeonMMO backend v2.15 — genuine Warrior sword and blunt family

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.14](DungeonMMO_Roadmap_v2_14_Knight_Common_Craft_C4_20260924.md).
[Exact executed Studio tests](
../testing/ironvow-sword-blunt-mastery-v2-15-20260924.md).

## Implemented and actually verified

- [x] Corrected previously sword-only `IronvowBladeTraining` to
  authorize both genuinely equipped, registered Sword and Blunt
  categories on the real server melee path, with four distinct
  trainer ranks at C4 levels 20/24/28/28. The stable saved ID
  remains unchanged; no duplicate rank family was added.
- [x] Added original Warrior SwordBluntMastery mapping, checked
  wrong/absent weapon and forged first-class denial, real
  earned personal trainer and saved rank ownership. No sword
  equipment is required merely to *learn* the passive.
- [x] Fresh disposable Base/Dungeon Rojo PASS; real Quest/Award/
  Foundation tests 31/81/60 assertions PASS; actual Dungeon
  world NPC HP sword/blunt hits 110 -> 115.6 at rank4 PASS;
  level-30 audit 27 assertions PASS. See exact process logs.
- [ ] Current per-rank 0.014 Roblox damage multiplier is an
  acknowledged source-mathematics *adapter*, not identical
  C4 P.Atk. scaling or established cross-class balance.

## Source-rank schedule mapping, NOT full C4 gameplay parity

| First transfer | C4 rank entries | Training rows mapped | Missing |
|---|---:|---:|---:|
| Human Rogue -> Ashenblade | 59 | 59 | 0 |
| Elf Scout -> Greenward Scout | 77 | 77 | 0 |
| Human Knight -> Oathguard | 55 | 55 | 0 |
| Human Warrior -> Ironvow | 62 | 31 | 31 |

Knight matching all 55 rank schedules does not certify its actual
historical defence/shield/evasion/recipe equations or full end-to-end
player loop. Four of 18 original first-transfer trees have a
recorded level-30 source inventory; **0/18** are release certified.
Other 14 source trees and starter skill ranks 1-19 are pending.

## Next backend priority

Implement distinct Warrior PolearmMastery (4 purchased ranks),
true real equipped polearm and area-hit executor before mapping
SwordBlunt attack skills as substitutes. Continue source-verified
BluntControl, area attack, critical/accuracy toggles, HP recovery
and level-20/28 profession skills in their correct rank bands,
with focused saved-owner tests plus real player/NPC combat.
Audit all boss/world-boss attack dispatch routes for the same
blocked-hit chip/stamina/guard-break invariants; the v2.12
Marauder/Captain proof is *not* a blanket boss pass.

Use C4 as mechanic and rank reference, not a license to copy
player-facing names, art or dialogue. Its balance cannot be
automatically transplanted into Roblox without reproducing
attack/defence formulas, cast times, economy and encounter stats.
Keep one gathering and one chosen creation profession.

All permanent source and roadmap changes through GitHub.
Remote desktop only for safe fast-forward, disposable unpublished
Rojo/Studio and logs. Do not merge main, publish to Roblox,
change production DataStores or touch other animation worktrees.
