# DungeonMMO backend v2.28 — Elven Knight owned passive skill families

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.27](DungeonMMO_Roadmap_v2_27_Elven_Knight_Quest_Transactions_20260924.md).

## Authored source rank schedules and server effects

The distinct earned Greenward Warden trainer offers three original
Elven Knight level-20/24/28 families, with independent class, race,
personal mentor receipt, purchased-rank and character-level gates:

| Historical source family | Level 20 | Level 24 | Level 28 | Mapped ranks |
|---|---:|---:|---:|---:|
| Sword/blunt mastery | 1 | 1 | 2 | 4 |
| Heavy armour mastery | 3 | 3 | 3 | 9 |
| Magic resistance | 2 | 3 | 3 | 8 |
| **Total** | **6** | **7** | **8** | **21** |

Skill IDs: `GreenwardWardenSteelTraining`,
`GreenwardWardenHeavyArmorTraining` and
`GreenwardWardenMagicResistance`. They use the existing server-owned
passive purchase service and actual weapon/Body equipment state.
A real registered Sword or Blunt is mandatory for sword mastery damage;
the dagger's borrowed sword animation does not qualify. Heavy armour
training mitigates only hostile physical damage while a registered
HeavyArmor Body item is equipped. Magic resistance affects only hostile
magic damage in the existing bounded DamageService pipeline. The
individual physical and magical reduction adapters are **provisional
Roblox formulas**, not certified original C4 combat balance.

The independent Elven Knight coverage record is now **21/56
training ranks mapped**, with **35 still missing**. No credit is
claimed for missing Elemental Heal, Charm, Aggression, shield,
auras, cleanse, Ultimate Defence or common creation; no release or
end-to-end real enemy effect certification is claimed. The previous
four first-transfer rank schedules remain unchanged. The original
18-class report still has five inventoried and four completely
schedule-mapped branches; mechanical/release certification remains zero.

## Test and deployment constraints

The existing first-transfer class test and foundation source-audit
assertions now expect exactly the three new passives and 21/56 rank
schedule mapping. These are authored static and source test conditions,
**not yet actual in-Studio passed assertions**. Run targeted
unpublished Base Studio tests with an earned owner, then a genuine
hostile melee/magic/weapon and cross-race forgery regression before
claiming functional Play acceptance. The full six-stage Greenward
Warden quest transaction is implemented in isolated server code, but
physical dungeon encounters and real client quest Play remain open.

No main merge, publish, production DataStore, or unrelated animation
worktree changes. Permanent script/roadmap edits in GitHub.

## Targeted server regression source added

`C4GreenwardWardenPassiveTrainingTest` and disposable Base runner
`c4_greenward_warden_passive_training_focus.luau` now exercise
an independently minted one-use mentor receipt, all 21 rank purchases
through the real profile/skill services, unarmed/dagger/sword equipment
effects, actual HeavyArmor Body ownership and removal, server runtime
combat-stat hooks and copied-race/class/receipt denial. **Not yet
executed in Studio**; Rojo builds alone do not pass these assertions.
