# DungeonMMO class backend v2.11 — closer C4 defensive skill fidelity

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.10](DungeonMMO_Roadmap_v2_10_C4_Skill_Fidelity_Knight_Drain_20260924.md).
[Executed current test evidence](
../testing/oathguard-c4-majesty-v2-11-20260924.md).

## Source-game rule

Follow **Lineage 2 Chronicle 4** per original starter class,
first-transfer class and individually purchased skill rank through
level 30, using independently named abilities, quests, characters,
artwork, assets and descriptions in DungeonMMO. Keep different
reference abilities separate even when they reuse executor code.
Use documented C4 rank levels, MP/HP costs, skill power, target
selection, effects, duration, cooldown and prerequisites *where
verified*. Never claim exact C4 balance until its attack, defence,
accuracy, skill timing, regeneration, enemy statistics and economy
are also faithfully represented or tested under an explicit
conversion model. A mapped training rank is **not** equivalent
to a validated gameplay mechanic.

## Completed in v2.11

- [x] Corrected the earned Knight's independently named
  `OathguardSteadfastStance` (C4 reference Majesty level one)
  from prior temporary 10%/10s/14-stamina buff to the verified
  source **+7% physical defence**, **-2 Evasion**, **10 MP**
  and approximately **5-minute** timed effect. Removed the
  invented mandatory Fighter Armor Training rank-three gate.
  Source: https://l2hub.info/c4/skills/82-majesty%3A1/levels
- [x] The server owns the physical-guard duration and separate,
  expiring owner Evasion penalty. Its existing hostile-melee
  evasion resolution subtracts the active penalty; the actual
  incoming physical damage service consumes guard protection.
- [x] Fresh disposable Base and Dungeon Rojo builds PASS,
  focused earned Knight Quest/Foundation **87 + 84** assertions
  PASS, and real-client Play HP/cost/status/expiry checks PASS:
  **93 HP** actual hostile physical damage from 100 base while
  protected; magic and PvP-style damage 100, expiry restores
  normal physical damage. The 5-minute status duration was
  verified via its server expiry timestamp, and its end via
  test-only forced expiry rather than a five-minute wait.
- [x] The separately authored seven-rank C4-source Knight
  `OathguardUmbralSiphon` passed actual client rank-one
  (20 NPC HP damage → 4 owner HP heal) and rank-seven
  (31 NPC HP damage → 6.2 owner HP heal) tests in v2.10.

## Accuracy and release scope

The original C4 +7% **P.Def** is implemented as a 7%
Roblox incoming hostile physical damage reduction and C4
-2 **Evasion stat** is temporarily modelled as -2 percentage
points of the existing evasion chance. These are explicitly
**not mathematically identical** to C4's formula.
A provisional three-second cooldown also lacks full C4
timing validation. Do not present earlier v2.09 90-HP,
14-stamina tests as applying to the corrected version.
Full wall-clock five-minute expiration, other-player
isolation and natural persisted cross-place play remain open.

| Audited original class branch | Historical rank rows | Trainer mapped | Missing |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 45 | 9 |

**Knight's still unmapped nine source rows:** original level-20
Equipment Expertise (1), Common Item Creation at 20 and 28
(2), genuine sword **and blunt** weapon mastery (4),
separate immobile physical+magical Ultimate Defence at
20 (1), original Bow Defense at 24 (1). Other previously
mapped skills—including source Heal, Magic Resistance, Shield
Mastery, Shield Stun and the newly converted Majesty—still
require precise C4 formula, targeting and mechanical parity.
**0/18** first-transfer careers have passed complete,
natural level-1→30 game/release acceptance.

## Next backend task

Implement the **separate** original level-20 Knight
Ultimate Defence analogue, not by reusing a physical-only
guard buff. C4 reference grants +1800 physical and +1350
magical defence, 19 MP and immobility; duration/reuse
timings and conversions need independent primary-source
verification before declaring identical game balance:
https://l2hub.info/c4/skills/110-ultimate-defence%3A1/enchanting-1

Then the Knight's other eight rank rows and true
sword/blunt/bow/crafting effects, followed by Warrior's
35 missing ranks and the other original classes.
Keep the one-gathering/one-crafting profession limit.
All source/docs editing goes through GitHub; desktop
is only for fast-forward pull, disposable Rojo builds
and unpublished Studio Play/logs. Do not merge main,
publish Roblox places or touch production DataStores
without express authorization. Humanoid/quadruped
animation worktrees and roadmaps are separate.
