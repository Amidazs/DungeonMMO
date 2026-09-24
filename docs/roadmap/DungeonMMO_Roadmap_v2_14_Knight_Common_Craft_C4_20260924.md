# DungeonMMO backend v2.14 — original Knight skill rank schedules mapped

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.13](DungeonMMO_Roadmap_v2_13_Knight_Sword_Blunt_20260924.md).
[Precise four-career test evidence](
../testing/knight-common-crafting-v2-14-20260924.md).

## Completed this increment

- [x] C4 level-20/28 Knight two-ranked `OathguardCommonItemCreation`
  in personally earned Oathguard class and its own trainer.
  Both require original level-five source starter common-craft
  and recipe literacy, then exactly one selected creation
  profession; do not grant a second gathering/crafting career.
- [x] Eight separate genuinely ingredient-backed recipes spanning
  Blacksmithing, Alchemy, Leatherworking and Enchanting.
  Actual blacksmith output includes a usable blunt mace at
  first rank and genuinely D-grade wearable body armour at
  second rank. Material usage/output, rank denial and
  server prepare/complete revalidation are authoritative.
- [x] Removed an accidentally interleaved duplicate skill name,
  recipe family and server craft function before testing.
  **One** canonical skill ID remains:
  `OathguardCommonItemCreation`.
- [x] Base/Dungeon disposable Rojo builds PASS; strict source
  inventory audit **27 assertions PASS**. Genuine earned
  Knight quest/foundation tests **247/112 assertions PASS**.
  Four independent server-side career contexts exercise
  eight recipes, wrong-career denials and revoked-rank
  mid-transaction duplication regression.
- [x] Previously implemented anti-invulnerability fix:
  server-authoritative held shield Block costs stamina and
  routes its genuine Blocked outcome through HP damage:
  stacked Knight shield, Majesty and Ultimate Defence with
  blocking still take **25.38 actual HP** from 100 base
  hostile melee (v2.12 evidence). Guard break takes ordinary
  unblocked damage; limited parry/dodge remain separate.
  **Do not make shield Block a permanent iframe**.
- [ ] Full player-originated recipe UI, real-world gathered
  ingredients, multiplayer exploit attempts, boss/world-boss
  block paths, natural save/rejoin and cross-place have not
  passed an end-to-end test for v2.14.

## Source skill-rank audit versus actual release readiness

| Reference first-transfer branch | Historical rows | Training rows mapped | Unmapped |
|---|---:|---:|---:|
| Human Rogue / Ashenblade | 59 | 59 | 0 |
| Elf Scout / Greenward Scout | 77 | 77 | 0 |
| Human Warrior / Ironvow | 62 | 27 | 35 |
| Human Knight / Oathguard | 55 | 55 | 0 |

**These numbers are rank-schedule coverage, not C4 combat,
economy or progression equivalence and not release readiness.**
No other fourteen original first-transfer branches have
finished source-rank inventory or implementation; starter
level-1–19 skill sets still need complete C4 auditing.
Verified-complete/release-certified first-transfer classes:
**0/18**.

Important mismatches requiring follow-up on the Knight's
already mapped rank rows:
- C4's Common Item Creation is **automatically acquired** as
  level milestones are reached; DungeonMMO currently sells
  the later source ranks from its class trainer and gates
  all recipe creation through the chosen WoW-like profession.
  Reconcile intentionally rather than claiming identical
  C4 economy.
- C4 P.Def/M.Def/Evasion are source stats, whereas current
  Roblox effects use provisional damage-reduction and evasion
  percentages. Exact PvE/PvP balance is not imported solely
  from copying C4 rank tables.
- Correct Knight healing power/MP, shield block defence
  calculation and first-transfer attack skill crowd control
  still need mechanical source-verification as separate
  abilities, not renaming.
- Other boss, world-boss and event enemy attack paths must
  pass the same block/guard-break anti-invulnerability test.

## Next implementation order

1. Complete **Warrior's 35 remaining independently ranked
   and functional source entries**, including sword+blunt,
   polearm area attacks, critical/accuracy, HP,
   health recovery and selected profession utility.
2. Review each remaining original racial base-class and
   first-transfer C4 skill path through level 30. Build
   distinct effects, real earned class trainers, server
   authority and focused/live player tests for each.
3. Add one shared source-stat conversion specification and
   representative multi-class group/raid combat tests for
   actual numbers and all simultaneous defensive buffs.
   Keep the separately owned 1-gathering/1-crafting rule.
4. Never merge `main`, publish Roblox places or touch
   production saves unless explicitly authorized. Permanent
   code/document editing in GitHub; remote desktop for
   fast-forward pull, disposable builds and unpublished Play.

Source reference: https://lineage2wiki.com/c4/patch-notes/
and https://l2hub.info/c4/classes/knight.
