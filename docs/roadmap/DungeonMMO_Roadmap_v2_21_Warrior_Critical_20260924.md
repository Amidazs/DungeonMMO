# DungeonMMO backend v2.21 — Warrior source critical stance

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Continues [v2.20](DungeonMMO_Roadmap_v2_20_Warrior_Common_Craft_20260924.md).

## Implemented and tested

- [x] Three **separately paid** Warrior critical-damage toggle
  ranks at source levels 20/24/28, retaining C4 flat critical
  power 35/48/64, initial MP 4/5/5 and *continuous MP upkeep*.
  Reference: https://l2hub.info/c4/skills/312-vicious-stance%3A3/levels .
  `IronvowCriticalStance` remains an original DungeonMMO name.
- [x] New independent `IronvowCriticalToggleService` never
  borrows a Rogue/Scout stamina toggle. Server validates genuine
  earned Warrior first-transfer, owned rank, hotbar, living
  character and combat permission at activation and at each
  upkeep tick. Real MP spent at activation and every second;
  death, deactivation, respawn, rank revocation and player
  removal clear the real server bonus. No permanent free
  critical damage from forged client Attributes.
- [x] The server's genuine critical-hit multiplier applies
  a bounded **provisional Roblox** 0.001 × C4 flat
  critical-power conversion, NOT original C4 critical
  damage/physical-attack mechanics.
- [x] Both unpublished Base/Dungeon Rojo builds PASS.
  Initially focused Base fixture failed because new
  service was not mounted in the *explicit* Base Rojo
  projection. Fixed in GitHub, then focused earned Warrior
  Quest/Award/Foundation **31/189/141 assertions PASS**
  at `524ae4b13daa0041073224a43a156f1627cad6da`,
  log `0.740.0.7400927_20260924T121424Z_Studio_52EE2_last.log`.
- [x] Disposable real-client Dungeon Play at
  `d430a156ac637495096cedaf8a0cbbfc7cd69f50`,
  log `0.740.0.7400927_20260924T121628Z_Studio_796C6_last.log`
  confirms actual client hotbar enabled 3rd rank,
  spent **5 MP** plus **2 MP** after 1-second upkeep,
  increased actual 50-base guaranteed-critical NPC
  health damage **82.5 → 85.7**, disabled on genuine
  second client click, restored original critical
  health damage, then denied revoked purchase and
  forged Fighter. `VERIFIED_PLAY_MODE_PASS`.
- [x] Separate strict level-30 audit **27 assertions
  PASS** in log
  `0.740.0.7400927_20260924T121730Z_Studio_3D82C_last.log`.

## Current rank map and remaining scope

Warrior **59/62 source training rows mapped**, three
remaining: `HealthRecovery` (source level24),
`AccuracyStance` (source level24) and
`EnduranceSurge` (source level28).
Knight 55/55, Human Rogue 59/59 and Elven Scout
77/77 training schedules mapped, NOT complete C4
mechanics/balance. Only 4/18 original first-transfer
class inventories through level30 audited;
**0/18 classes release-certified**.
Original starter level1–19 skills, other 14 first
transfers, exact historical C4 attack/defence/economy
math, full uninterrupted save/rejoin, true multiplayer
boss/world-boss blocking exploit tests and cross-class
balance remain OPEN. Never count training rows alone
as complete release tests.

Next implement real Warrior accuracy toggle draining
MP and affecting actual authored evasive-NPC hit
chance, then actual HP recovery passive and temporary
maximum-HP/restore ability. Test focused owner/cost/
HP/expiry, without repeating green unrelated suites.
No main merge, Roblox publish, production DataStores
or editing the separate animation worktrees.
