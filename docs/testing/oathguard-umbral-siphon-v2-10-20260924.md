# v2.10 — Human Knight seven-rank drain, actually executed

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Source-fidelity scope

Primary historical source (C4, not later chronicles):
https://l2hub.info/c4/classes/knight

Rank-specific source values and 20%-of-dealt-damage life return:
https://l2hub.info/c4/skills/70-drain-energy%3A2/levels

| C4 Knight rank | Source character level | C4 power | C4 MP cost | Heal on actual damage |
|---|---:|---:|---:|---:|
| 1 | 20 | 20 | 12 | 20% |
| 2 | 20 | 22 | 13 | 20% |
| 3 | 24 | 24 | 14 | 20% |
| 4 | 24 | 26 | 15 | 20% |
| 5 | 28 | 28 | 15 | 20% |
| 6 | 28 | 29 | 17 | 20% |
| 7 | 28 | 31 | 17 | 20% |

DungeonMMO player-facing name: **Umbral Siphon**.
Distinct from `OathguardMendingOath`, which heals without damaging
an enemy. This ability is an offensive magical hit, not a heal button:
the existing authoritative magic projectile checks enemy collision,
deals actual damage, then heals only its genuine, still-present caster
for 20% of **damage actually applied**. A miss, immunity or dead target
cannot give free healing. No wand is required for the Knight to cast
its own learned spell.

The seven reference rank power and total MP rows are recorded exactly
in the skill definition and separately purchased at the level
20/24/28 source brackets. Source power is currently passed through
the Roblox flat-damage-times-magical-multiplier executor, **not**
Lineage 2's magical attack/defence/damage formula. Existing projectile
range, hitbox, cast time, cooldown and graphics are Roblox adaptations
unless separately verified against C4. This is **source skill effect
and training-schedule fidelity**, not proven identical overall balance.

## Actual verification

Fresh candidate `2cd6d40`, disposable unpublished Base and Dungeon
Rojo builds: **PASS**. The prior local worktree's quadruped
`__pycache__` folders were left untouched.

- Focused Base quest/trainer test:
  `0.740.0.7400927_20260924T085306Z_Studio_C99F1_last.log`;
  **88 assertions PASS**, including personally earned Knight trainer
  purchases of each of the seven ranks, refusal of early 24/28
  rank attempts, and final skill ownership/save.
- Focused Base class/effect test: same log;
  **84 assertions PASS**, including all seven power/MP/20% rows and
  forged or unawarded Fighter denial.
- Strict incomplete level-30 audit:
  `0.740.0.7400927_20260924T085329Z_Studio_4FED0_last.log`;
  **27 assertions PASS**, `VERIFIED_SOURCE_RANK_AUDIT_PASS`,
  with Knight **45/54 mapped training rows, 9 still missing**.
- New Play driver:
  `scripts/studio/c4_oathguard_drain_client_live.luau`
  at `472ac0a784f9139a008459c4aeb595fa0bc7890f`, against
  disposable full Dungeon.
  Process log
  `0.740.0.7400927_20260924T085445Z_Studio_DAACB_last.log`:
  `REAL_CLIENT_RANK_1_DAMAGE_TO_HEAL_PASS damage=20 ownerHeal=4`
  and
  `REAL_CLIENT_RANK_7_DAMAGE_TO_HEAL_PASS damage=31 ownerHeal=6.20001220703125`.
  Both were genuine client hotbar requests, actual server NPC HP loss,
  real owner Humanoid heal pulse and rank-specific server mana spend.
  `FORGED_CLASS_DENIED_PASS`,
  `ALL_REAL_CLIENT_DRAIN_CHECKS_PASS` and
  `VERIFIED_PLAY_MODE_PASS` were emitted.

**Limits:** The Play driver starts from a test-owned, internally valid
Knight advancement and purchased-rank snapshot, *not* a natural
uninterrupted real-client quest-to-dungeon save journey. The genuine
trainer purchase itself was independently verified in the focused
Base test. This test does not establish whole-game balance, player
versus player damage, drop-loop proof, 2-client owner isolation,
spellbook acquisition, or graphics/animation equivalence.

No production DataStore, public publish or `main` merge.
