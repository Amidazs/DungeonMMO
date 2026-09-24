# DungeonMMO class backend v2.09 — paid Knight defensive stance

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.08](DungeonMMO_Roadmap_v2_08_Oathguard_Shield_Masteries_20260924.md).
[Exact executed acceptance](../testing/oathguard-steadfast-stance-v2-09-20260924.md).
The humanoid and quadruped animation plans are separate and unchanged.

## Implemented and genuinely verified this increment

- [x] Added `OathguardSteadfastStance` as the separate **one rank
  at level 20** historical Knight `DefensiveStance` source family.
  Player-facing ability, description and test content are original
  DungeonMMO terms, not copied source-game text or artwork.
- [x] A valid personal Human Fighter → Oathguard first-transfer
  quest/mentor receipt and paid Fighter `FighterArmorTraining`
  rank 3 are needed for its own physical class-trainer purchase.
  A forged class ID cannot use it. This is a timed active ability,
  **not** free permanent heavy-armour or shield mitigation.
- [x] An actual authenticated client hotbar cast consumes
  **14 stamina**, applies **10% PhysicalGuard** to its own
  living character for **10 seconds**, with a **24-second**
  server cooldown. This shares existing bounded server-owned
  `CombatStatusService` and `DamageService` mechanics.
- [x] Verified a 100-base hostile melee and hostile area hit each
  dealt **90 HP** to the live player during the stance.
  Enemy magic and ordinary player physical hit dealt **100 HP**.
  After expiry, hostile melee returned to **100 HP**. A rapid
  second hotbar cast did not extend the server-owned status expiry.
- [x] Verified on freshly pulled candidate: disposable Base and
  Dungeon Rojo builds PASS, authentic profile quest/trainer
  suite **70 assertions PASS**, skill foundation **67 PASS**,
  strict 18-branch level-30 audit **27 PASS**, actual Play
  `VERIFIED_PLAY_MODE_PASS`. See exact individual process logs.
- [x] The earlier v2.08 self-healing and magical defence also
  passed real client/HP tests: purchased rank 1 heals **30 HP**,
  rank 3 heals **44 HP**, mana is spent and eight genuine test-owned
  rune ranks reduce 100-base hostile magic to **95.2 HP**.
  The previous two-client physical Base run also passed after
  one missed prompt hold was followed by an actual successful
  client/server prompt. See v2.08 evidence; intermittent
  *first-attempt* prompt input is not considered fixed in production.

## Accurate level-30 mapping scope, not release certification

| Audited first-transfer source | Historical rank rows | Trainer-mapped rows | Missing rows |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 38 | 16 |

The Knight's **16 still-unmapped source rows** are:
equipment expertise (1), common item creation (2),
sword/blunt weapon mastery (4), genuine owned-hit life drain (7),
low-health last stand (1) and ranged bow defence (1).
Each requires its own implemented/earned training and actual
distinct effect, not a cosmetically renamed unrelated ability.
No other 14 first-transfer classes have finished original
source-rank inventory/skill implementation. Starter class ranks
1–19 and enforced release level cap 30 still need final audit.
**Zero of 18** first-transfer careers are complete release builds.

## Next backend work

1. Complete the distinct 16 Knight and 35 Warrior source ranks
   without assuming a sword-only executor handles blunt weapons,
   polearm cleaves or owned-hit drain. Check actual equipped tags
   and implement real weapon use before claiming weapon-family parity.
2. Independently implement original other Human, Elf, Dark Elf,
   Orc and Dwarf first-transfer class branches and actual starter
   ranks. Keep one gathering and one crafting profession per user.
3. Run true two-client party-member isolation and genuine saved
   owner trainer/equipment flows for new Knight guard, rune defence
   and self-heal. Test explicitly rejected premature recasts and
   insufficient resources, and one uninterrupted Base → Dungeon
   → Base journey before claiming end-to-end acceptance.
4. No merge to `main`, Roblox place publishing or production
   DataStore mutation without owner authorization. Permanent
   script and roadmap edits stay in GitHub, with desktop only for
   fast-forward pull, disposable build and unpublished Studio tests.
