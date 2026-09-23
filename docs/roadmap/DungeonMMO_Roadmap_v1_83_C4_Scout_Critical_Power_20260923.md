# DungeonMMO roadmap v1.83 — tested critical stance and NPC snare

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Precedence and unchanged commitments

This is the latest **backend and original C4 class source-rank**
supplement after [v1.82 Elven Scout support](
DungeonMMO_Roadmap_v1_82_Elven_Scout_Support_20260923.md).
It does not supersede the separately maintained newer
humanoid/quadruped animation and art roadmap. One gathering
and **one crafting profession per character** remain mandatory;
marketplace/resource/material dependencies continue to apply.
All code/doc edits are GitHub-first. Do not merge into `main`,
publish Roblox places or alter production DataStores until
explicitly requested.

## Verified backend additions

- [x] Completed the previously unverified **real client-to-NPC
  Snaring Shot** check. An admitted Elf Ranger's purchased
  skill hit a living tagged NPC via the real bow projectile,
  reduced health, applied 35% actual timed movement reduction,
  started cooldown and expired to normal NPC speed.
- [x] Implemented a true **Critical Power Toggle** with five
  distinct bought original C4 ranks at levels 20, 24, 28,
  32 and 36 for Human Rogue and Elven Scout analogues.
  This is not the unrelated existing passive Critical Power.
- [x] A genuine client SkillRequest activates/deactivates the
  toggle; the existing authoritative stamina service takes
  an initial cost of three and recurring upkeep of three
  per second. Exhaustion disables it automatically.
- [x] Critical damage scaling (0.06, 0.08, 0.10, 0.12,
  0.14) is applied only while the stance is active in
  actual server-side melee and bow attack calculations.
  Absent, unearned, expired or deliberately switched-off
  stances grant **no free damage**. A respec, loadout
  change, rank downgrade, character death/respawn or
  Dungeon member exclusion disables it.
- [x] Both class trainer catalogues, purchased-rank
  progression, combat definitions, Base/Dungeon Rojo
  compositions and the six-class source audit were
  updated without creating any profession bypass.
- [x] Disposable unpublished Studio focused tests:
  **6/6 passed**, including **117** new skill contract
  assertions and strict original source count.
- [x] Actual unpublished Studio Dungeon client toggle
  acceptance **passed**, validating activation, rank-five
  critical-hit multiplier, continuous real stamina
  deductions, deliberate OFF and resource-exhaustion
  auto-off. See the [executed test record](
../testing/c4-scout-critical-toggle-and-snare-v1-83-2026-09-23.md).
- [x] Scripts, JSON and docs edited through GitHub only;
  local desktop was limited to clean fast-forward pulls,
  parsing, disposable Rojo and Studio playtests, and
  read-only test log checks.

## Current original C4 source-rank audit

| Class | Functional / raw | Remaining |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue, partial first transfer | 86 / 99 | 13 |
| Elven Scout, partial first transfer | 117 / 129 | 12 |
| **Six inventoried classes** | **371 / 396** | **25** |

The original four starter-class inventories remain **168/168**.
The other seven original first-transfer class catalogues have
not been enumerated/implemented and are not included in these
remaining 25 ranks. **0/9 first-transfer class paths have
reached full completion.**

## Remaining backend tasks

- [ ] Build real active `Accuracy Toggle` (one source rank
  each for Human Rogue and Elven Scout) with purchased
  source class/level restrictions, actual player-on/off
  input, real stamina upkeep, real server-authoritative
  PvE hit determination for melee and bow, cooldown/
  anti-spam/character lifecycle, and live hit/miss proof.
  Do not mark source rank complete until tested.
- [ ] Build three ranked first-transfer
  `Common Item Creation` improvements per source class
  at original levels 20/28/36. Require actual selected
  single crafting career, earned previous recipes and
  authentic ingredient inventory; never grant another
  crafting profession or unlimited material generation.
- [ ] Add five `Lockpicking` ranks per class behind real
  dungeon/world lock interactions with server distance
  and ownership validation; no access to other players'
  bank/trade/auction-house items or profession-locked
  gathering nodes.
- [ ] Implement original `Equipment Expertise`,
  `Lung Capacity`, `Fall Resistance`, and Human-only
  `Sprint` as true progression-gated world/combat
  effects with focused and real gameplay verification.
- [ ] Source-inventory and implement the seven additional
  distinct original C4 first-transfer class paths,
  including the class-quest/level/full-prerequisite gates.
- [ ] The independent v1.78 Mystic hostile-weakening
  client-to-NPC acceptance and previously documented
  unrelated `SkillProgressionServiceTest` proficiency
  assertion remain separate release gates. Avoid repeating
  accepted dungeon wipe/aggro/paid revive regressions
  when no related subsystem changed.

**v1.83 paid Critical Power Toggle: real live gameplay PASS.
Remaining original C4 class work: NOT COMPLETE.**
