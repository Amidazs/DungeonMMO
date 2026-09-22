# C4 conditional recovery v1.76 — source ranks with real Stamina

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous checkpoint: `docs/testing/c4-source-catalogue-v1-75-2026-09-22.md`

## New functional source-ranked backend

- Human starting Fighter gains one level-five
  `FighterRestingRecovery` rank. Its purchased 15% Stamina
  regeneration bonus applies only when the actual server-owned
  Humanoid is seated.
- Human first-transfer Scout gains two
  `HumanScoutRestingRecovery` ranks at levels 24 and 32,
  providing 10% seated Stamina regeneration per purchased rank.
  Elf and non-Scout classes cannot gain the bonus from forged
  or foreign-race saved ranks.
- Human Rogue and Elven Scout gain one
  `ScoutRunningRecovery` rank at source level 36, providing
  10% faster Stamina regeneration only while the actual
  server-owned Humanoid is moving and not seated.
- The accepted `StaminaService` regeneration Heartbeat
  multiplies its normal recovered Stamina per second by the
  bounded purchased modifier. Its normal post-spend delay,
  regeneration pause, maximum Stamina and resource ownership
  are unchanged. Bare skill previews and fake generic
  Instances receive no bonus.
- These are genuine DungeonMMO **Stamina analogues** of C4
  sitting/running recovery categories; they do not assert
  precise Chronicle 4 HP/MP regeneration values or behaviours.

## Focused unpublished Studio evidence

- `C4ConditionalRecoveryTest`: **42 assertions PASS**
  for level/race/class gates, purchased ranks and conditional
  multiplier isolation.
- `C4ScoutInventoryTest`: **1,079 assertions PASS**;
  Human Rogue 81/99, Elven Scout 107/129 functional analogues.
- `C4BaseImplementationAuditTest`: **55 assertions PASS**;
  Human Fighter 37/39, Elven Fighter 41/43, Human Mystic
  36/44 and Elven Mystic 34/42.
- `C4CatalogueCoverageTest`: **7 assertions PASS**,
  Base=148/168, Scout=188/228, original class paths=0/9,
  unenumerated paths=7, `Completed=false`.
- Both unpublished Base and Dungeon Rojo builds succeeded.
- An isolated unpublished real Studio Play client
  physically occupied a temporary Seat with its own
  live Humanoid. After the exact same authoritative
  Stamina spend/sample, the purchased Fighter recovery
  rank increased actual server Heartbeat regeneration.
  The log printed `REAL_SEATED_STAMINA_PASS` and
  `VERIFIED_PLAY_MODE_PASS`. Running recovery was
  verified in focused purchased-rank/runtime tests,
  not through actual client movement in this fixture.

Latest TEMP logs (not uploaded):
`%TEMP%\DungeonMMO_C4_RecoveryGates.log`,
`%TEMP%\DungeonMMO_C4_RecoveryInventory.log`,
`%TEMP%\DungeonMMO_C4_RecoveryBaseAudit.log`,
`%TEMP%\DungeonMMO_C4_RecoveryCoverage.log`,
`%TEMP%\DungeonMMO_C4_Recovery_Live.log`.

## Exact current scope and remaining work

| Original source class | Functional analogue ranks | Raw ranks | Missing |
| --- | ---: | ---: | ---: |
| Human Fighter | 37 | 39 | 2 |
| Elven Fighter | 41 | 43 | 2 |
| Human Mystic | 36 | 44 | 8 |
| Elven Mystic | 34 | 42 | 8 |
| Human Rogue | 81 | 99 | 18 |
| Elven Scout | 107 | 129 | 22 |
| **Six enumerated classes** | **336** | **396** | **60** |

The remaining **20 base** ranks primarily need shared real
crafting/recipe, party healing, poison/debuff systems.
The remaining **40 Scout** ranks need source-specific critical
and accuracy toggles with resource upkeep, lock/key mechanics,
equipment/environment skills, crafting, and Elf support buffs
and cleanses. Seven separate original first-transfer source
class inventories remain unenumerated/unimplemented; **0/9**
first-transfer class paths are complete.

The earlier isolated paid-revive Phase2A automatic failure,
normal persisted-player class-transfer/trainer UI,
actual multiplayer/party effects, published/cloud validation
and full milestone-wide dungeon regression remain open.

All scripts and documents were authored directly in GitHub;
the remote machine was used only for fast-forward pull,
disposable TEMP Rojo builds, focused unpublished Studio
tests and read-only logs. No `main` merge, Roblox publish,
paid operation or production DataStore mutation occurred.
