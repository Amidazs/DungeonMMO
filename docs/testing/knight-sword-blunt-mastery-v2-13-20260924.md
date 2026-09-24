# v2.13 — actual Knight sword AND blunt mastery

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

C4 original Human Knight reference:
https://l2hub.info/c4/classes/knight
Sword Blunt Mastery ranks 1/2/3/4 are independently offered
at character levels 20, 24, 28 and 28. They should strengthen
sword **and blunt** P.Atk. A sword-only alias must not count.

## Code and actual verification

- Created `OathguardSteelAndStoneTraining`, bought from its
  earned original Knight trainer as four separate genuine rank
  levels 20/24/28/28. Only the currently *server-equipped*
  registered `ItemDefinitions` weapon with Category `Sword`
  or `Blunt` receives its passive damage increase.
- Added separately tagged, independently equippable
  `stonewatch_training_mace`, weapon Category `Blunt`,
  tag `OneHandedBlunt`. The generic melee prototype
  now routes this tag into a true damage-producing
  melee executor (art/animations are still placeholders).
- A dagger whose temporary prototype tool also reports a
  sword-compatible attack tag does **not** receive the
  Knight sword/blunt passive. No weapon, missing paid ranks
  and a copied unawarded Fighter skill also grant no bonus.
- Current per-rank `DamageBonusPerRank = 0.012` is a
  *provisional Roblox conversion*, NOT the documented
  original C4 P.Atk. gain or final level-30 balance.

Actual separate skill-trainer/foundation focused Base test:
`0.740.0.7400927_20260924T094905Z_Studio_10A08_last.log`:
`[Oathguard Quest] PASS: 108 assertions`,
`[Oathguard Foundation] PASS: 103 assertions`,
`VERIFIED_QUEST_AWARD_RANKS_PASS` and both named suites PASS.
Both disposable Base/Dungeon Rojo builds PASS.

Actual full-Dungeon Play driver:
`scripts/studio/c4_oathguard_sword_blunt_mastery_live.luau`
at `6b28cd3d64981a468983943fbac9fb777a0b45fb`.
Process log:
`0.740.0.7400927_20260924T095018Z_Studio_1D696_last.log`:
`SWORD_UNTRAINED_REAL_NPC_HP_PASS 110`,
`SWORD_MASTERED_REAL_NPC_HP_PASS 114.8`,
`BLUNT_UNTRAINED_REAL_NPC_HP_PASS 110`,
`BLUNT_MASTERED_REAL_NPC_HP_PASS 114.8`,
`ALL_REAL_FAMILY_HP_TESTS_PASS`,
`VERIFIED_PLAY_MODE_PASS`.
This measured actual world training-NPC Humanoid health using the
server-owned `DamageService` and real equipped-item categories.
Play seeded an internally verified test Knight advancement/rank
snapshot; it did not prove an inventory-owned, mouse-click-driven
complete blunt equip/animation/hitbox journey.

## Accurate coverage and remaining work

Knight source level-30 rank inventory: **55** (C4 source corrected
to include bow defence rank2 at lvl28). Of these, **52** have
actual earned-class trainer rank schedules and live/authored
server effects; **3** still missing:
`EquipmentExpertise` lvl20 and
`CommonItemCreation` lvl20 and lvl28.
The C4 damage formula and original mastery rank P.Atk numbers
have not been independently verified or implemented; 52/55
means *scheduled ranks*, not C4 numerical/mechanical parity or
full accepted release. Legacy Knight heal, shield mastery,
status immunity and other fields remain adapted, not identical.
There are 18 original first-transfer careers and none are
release-certified through level30. Warrior 27/62 trainer rank
rows mapped, 35 missing, and 14 other branches unreviewed.
Several unrelated automatic full-Dungeon tests emitted errors
during Play: focused suite/individual real-HP PASS must not
be presented as a fully green entire-game regression.

No publishing, main merge or production DataStore mutation.
