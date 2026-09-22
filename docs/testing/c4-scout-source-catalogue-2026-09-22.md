# C4 Scout source catalogue, race gates and combat effects

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: Human Rogue and Elven Scout **first-transfer** source levels
20, 24, 28, 32 and 36. Do not mistake these for all Chronicle 4 careers.

## Audited source and implemented effects

The source inventory at
`src/ReplicatedStorage/Core/Shared/C4ScoutSkillInventory.luau`
uses the Chronicle 4 Rogue and Elven Scout skill lists:
- https://l2hub.info/c4/classes/rogue
- https://l2hub.info/c4/classes/elven_scout

The two C4 first-transfer classes contain bow and dagger rows within
one original class. DungeonMMO has **two independent Ranger/Rogue
base classes**, so the inventory counts each source row exactly once
instead of duplicating the entire source count in both game classes.
Rank names, costs, damage and some mechanics are original game
adaptations; these are not a faithful C4 game binary or full parity.

Current source and functional counts, from the last focused Studio
source audit:

| C4 source class | Raw rank rows | Mapped functional analogues | Unmapped |
| --- | ---: | ---: | ---: |
| Human Rogue | 99 | 75 | 24 |
| Elven Scout | 129 | 102 | 27 |

These numbers concern **only source-mapped first-transfer rows**.
They do not measure the earlier Fighter/Mage brackets, all second- or
third-transfer classes, or every DungeonMMO character's reachable
skill count. The game implementation still has class-specific
weapon and race gates, original skills and progression thresholds.

Previously verified original-game skill families include authentic
Rogue dagger strikes and bleeding, bow attacks, bow and dagger
mastery, real worn light-armour mitigation, two-target slowing,
single-target stagger, bow range and flight speed, Elf self-regen
and actual Elf arrow threat reduction.

This increment additionally implements C4-inspired:
- Human level-24/32 critical-power ranks, granting +0.08 critical
  damage multiplier each through the real server critical-hit path;
- human level-28 and Elf level-32 race-exclusive critical-rate ranks,
  granting +0.02 actual critical chance each. Foreign-race saved
  ranks do not grant stats or appear at trainers;
- shared Ranger/Rogue level-28 Scout Fleet Foot, with purchased
  rank increasing the server's real Humanoid locomotion speed by
  6% without bypassing movement locks;
- Human level-36 Scout Rapid Hands, a bought 6% increase in the
  actual server basic attack rate and shorter basic attack timings.

All four families are server-owned, authored with correct source
levels/race requirements and exposed by both class trainers.
`C4ScoutSkillInventory.audit(race_id)` also returns exact
`MissingFamilies` counts, allowing acceptance to fail closed
until every source family has a genuine registered mechanic.

## Verified local tests

Unpublished Base Rojo build:
- `C4ScoutPassivesTest`: **254 assertions PASS** after adding
  critical damage, race-specific critical chance and movement;
- `C4ScoutInventoryTest`: **1066 assertions PASS**, including raw
  per-level source totals, real analogues and the exact unmapped
  family-ledger sum;
- `C4ScoutCriticalTrainingTest`: **38 assertions PASS** using
  production SkillProgressionService with detached in-memory
  profiles, including below-level denial, foreign-race denial,
  rank-two training and real save/release/reload.

An unpublished Dungeon Rojo build and actual Studio Play client
passed the eight earlier targeted client-to-server skill effects
(Briar Volley, Disrupting Cut, Thunder Shot, Lacerating Cut,
Scout Focused Shot, Rogue Finishing Cut, Elven Calming Shot and
Elven Renewal), plus physical-only light-armour mitigation,
**actual server Humanoid speed after an authenticated client skill
transition**, and **actual guaranteed critical damage** dealt to
a tagged NPC after a purchased critical-power rank. The client
fixture printed `SCOUT_REAL_MOVEMENT_SPEED_PASS`,
`HUMAN_CRIT_REAL_DAMAGE_PASS` and
`VERIFIED_PLAY_MODE_PASS`.

The game character and client progression snapshots in this Play
fixture were deliberately synthetic; it was not a real player
trainer-GUI transaction, physical keyboard ergonomics test or
published multiplayer acceptance. The real SkillProgressionService
trainer/persistence tests used isolated test profiles, never PROD.

Local receipts (not uploaded):
- `%TEMP%\C4_FleetFootPassives.log`
- `%TEMP%\C4_FleetFootInventory.log`
- `%TEMP%\DungeonMMO_C4_CriticalTrainerCurrent.log`
- `%TEMP%\DungeonMMO_C4_ScoutMovementLive.log`

## Explicitly remaining — do not claim overall C4 completion

The current read-only audit prints these source families as **unmapped**:

Human (24): AccuracyToggle 1; ActiveEvasion 1;
CommonItemCreation 3; CriticalPowerToggle 5; EquipmentExpertise 1;
EvasionPassive 1; FallResistance 1; Lockpicking 5; LungCapacity 1;
RunningEvasion 1; RunningRecovery 1; SittingRecovery 2; Sprint 1.

Elf (27): AccuracyToggle 1; ActiveEvasion 1; AttackBuff 1;
CommonItemCreation 3; CriticalPowerToggle 5; CurePoison 1;
CureWounds 1; DefenseBuff 1; EquipmentExpertise 1;
EvasionPassive 1; FallResistance 1; Lockpicking 5; LungCapacity 1;
MovementSlow 1; RunningEvasion 1; RunningRecovery 1; SpeedBuff 1.

The remaining categories need working combat-state/resource,
crafting, lock/door/key, environment, and support/status-effect
executors before they may be counted functional. Merely
inserting skill names or rank metadata is not acceptance.
Do not equate this first-transfer inventory with complete C4:
Fighter/Mage reference audit previously had 13/16 mismatched
base-class brackets, other first-transfer paths and later
career/skill branches have not been fully source-mapped or built.

The separate unrelated `Phase2AFailurePathTest` paid-revive
automatic failure has not been closed by these focus tests.
No general dungeon regression, main merge, Roblox publish,
paid operation or production DataStore modification occurred.
All scripts and documents were edited through GitHub only;
Remote Desktop was used only for clean pull, TEMP Rojo builds,
unpublished Studio tests and diagnostic logs.
