# C4 base and first-transfer catalogue — current backend acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: Source-backed Human/Elf starting Fighter/Mystic and ALL NINE
distinct original Chronicle 4 first-transfer class choices.
This is a partial, unpublished backend increment, NOT catalogue parity.

## Source references and class-tree boundary

- https://l2hub.info/c4/classes
- https://l2hub.info/c4/quests/1st-class
- https://l2hub.info/c4/classes/rogue
- https://l2hub.info/c4/classes/elven_scout

The original C4 source tree has nine distinct Human/Elf
first-transfer options (Human Warrior/Knight/Rogue/Wizard/Cleric;
Elven Knight/Scout/Wizard/Oracle). The game's current Ranger and
Rogue are independent starting classes and its specialist choices
are original analogues, NOT the exact original nine first transfers.

`C4FirstTransferBranches.luau` now records all nine source choices
without replacing existing saved-character class or trial data.
It marks only Human Rogue and Elven Scout as PARTIAL, with seven
other source class skill inventories still not implemented.
No first-transfer source class is marked complete.

## Actual new first-tier backend

- Both starting Mage races gained three purchased level-one,
  robe-only passives: six-percent faster basic attack rate,
  fifteen-percent faster mana regeneration, and six-percent
  faster magical cast rate (actual `MagicProjectile`/`MageHeal`
  server wind-up; no effect on physical skill timing). Unequipping
  the authored robe or switching to an ineligible class removes
  those bonuses. ManaService derives its actual regen from the
  updated ProgressionRuntimeState; CombatService uses its
  adjusted server-owned cast delay.
- All four Human/Elf Fighter/Mage starting paths gained one
  level-one novice protection analogue: purchased 2% reduction
  to actual physical NPC hits only. The effect terminates at
  level 20, ignores forged foreign-class ranks, and its
  trainer purchase is rejected above level 19.
- Base Rojo now mounts only the additional required
  `CombatStatusService` dependency used by the Core progression
  module. This fixes the earlier missing-Combat load error
  in unpublished Base focused tests; it does not publish or
  replicate a new runtime service to clients.
- The previous first-tier increment added nine genuine
  Fighter bow + nine dagger ranks, four Mystic wind +
  six healing ranks, both early Fighter mastery families,
  and source-backed early buffs/elemental slow.
  Previous focused tests and live Play receipts remain
  in the preceding thread and local TEMP logs.

## Exact scoped coverage, current focused result

| Original C4 source class | Functional analogue rank entries | Total source ranks | Unmapped |
| --- | ---: | ---: | ---: |
| Human Fighter | 36 | 39 | 3 |
| Elven Fighter | 41 | 43 | 2 |
| Human Mystic | 31 | 44 | 13 |
| Elven Mystic | 31 | 42 | 11 |
| Human Rogue, first transfer | 75 | 99 | 24 |
| Elven Scout, first transfer | 102 | 129 | 27 |

Those six source inventories account for 396 rank entries:
316 functional analogues and 80 unmapped. This does NOT
include the seven other original first-transfer class skill
inventories, which are not yet source-enumerated/implemented.

Exact remaining starting-class families:
- Human Fighter: CommonItemCreation 1, RecipeReading 1,
  SittingRecovery 1.
- Elven Fighter: CommonItemCreation 1, RecipeReading 1.
- Human Mystic: BattleHeal 3, CommonItemCreation 1,
  CurePoison 1, LifeDrain 2, PartyHeal 3,
  PhysicalAttackDebuff 1, PoisonCurse 1, RecipeReading 1.
- Elven Mystic: AttackSpeedDebuff 1, BattleHeal 3,
  CommonItemCreation 1, CurePoison 1, PartyHeal 3,
  PhysicalAttackDebuff 1, RecipeReading 1.

Scout's separate Human 24 / Elf 27 pending rank families
remain recorded in `C4ScoutSkillInventory.audit(race_id)`.
No empty names, metadata-only ranks, unrelated race skills,
or missing source class branches are counted as functional.

`C4CatalogueCoverage.report().Completed` returns FALSE
until every supported base rank, both currently mapped
first-transfer inventories AND all nine original C4 first
transfers are complete. The focused test asserts this
fail-closed contract and the current raw/implemented totals.

## Observed unpublished Studio acceptance

- Base source inventory test: **152 assertions PASS**;
  source corrected Elf Fighter level-15 bracket is 15.
- Fighter bow/dagger ranks: **88 assertions PASS**.
- Base Mystic wind/healing ranks: **52 assertions PASS**.
- Fighter physical/armour mastery: **72 assertions PASS**.
- New Mage robe passive/rank/gear/effect test:
  **38 assertions PASS** at final cast-speed source.
- Novice level/defense/expired rank test:
  **36 assertions PASS**.
- Original C4 nine-branch class-tree audit:
  **44 assertions PASS**.
- Final base functional/source audit:
  **63 assertions PASS**, with the exact missing
  source families listed above.
- Final unified completion auditor:
  **7 assertions PASS** with
  `Base=139/168, Scout=177/228, class paths=0/9,
  unmapped=7, overall complete=false`.
- Unpublished Base and Dungeon Rojo builds both succeeded
  after the robe cast-speed integration.

Latest TEMP logs (not uploaded):
`%TEMP%\DungeonMMO_C4_RobeCasting_Current.log`,
`%TEMP%\DungeonMMO_C4_Novice_Current.log`,
`%TEMP%\DungeonMMO_C4_CastingAudit.log`,
`%TEMP%\DungeonMMO_C4_FullCoverage_Current.log`,
`%TEMP%\DungeonMMO_C4_FirstBranches_Current.log`.

The modified robe cast-time gameplay and novice damage reduction
have **focused runtime and source tests plus Rojo builds**; they
have NOT yet been retested through ordinary physical client input,
an actual persisted-player trainer GUI, or published multiplayer.
The prior twelve-ability live Play pass predates these final
changes. Do not claim a new full Dungeon regression pass.

## Open completion gates

1. Implement genuine source-backed crafting/recipe knowledge and
   regeneration/stance mechanics for remaining base Fighter ranks;
   implement real battle heal, party heal, poison cleanse, life
   drain, afflictions and other listed Mystic ranks.
2. Build separate source rank/ability inventories for Human Warrior,
   Human Knight, Human Wizard, Cleric, Elven Knight, Elven Wizard,
   and Elven Oracle, keeping first-transfer class paths distinct.
3. Implement every listed Scout source mechanic currently missing
   (the source audit prints remaining names and exact counts).
4. Integrate actual selection/unlock/quest and trainer flows for
   original first-transfer choices without corrupting existing
   DungeonMMO saved progression; run focused real-client tests.
5. Resolve unrelated Phase2A paid-revive auto-test before release;
   run one broader regression at a real closeout milestone.

No `main` merge, Roblox publish, production DataStore mutation,
paid operation, reset, force-push or unrelated dungeon lifecycle
test loop took place. Code, tests and docs were edited solely
through GitHub. Remote Desktop was used for fast-forward pull,
TEMP builds, unpublished Studio test execution and log reads.
