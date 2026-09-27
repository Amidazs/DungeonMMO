# DungeonMMO Roadmap v3.18 — Shillien Oracle / Duskseer GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.17](
DungeonMMO_Roadmap_v3_17_Dark_Wizard_Nightweaver_GREEN_20260927.md).

## Status

**GREEN — Shillien Oracle / Duskseer backend accepted through level 30.**

Evidence:
[Duskseer v3.18 green acceptance](
../testing/c4-shillien-oracle-duskseer-v3-18-green-20260927.md).

Accepted code/test HEAD before documentation:
`95204b9278b4637f380bb29d1c53ae047bd67ca4`.

## Class and source coverage

Duskseer is the independent DungeonMMO career for the original Shillien Oracle
first-transfer branch:

- race: Dark Elf;
- base family: Mage;
- source class: Shillien Oracle;
- source class ID: 42;
- transfer branch: `ShillienOracle`;
- creative class: `Duskseer`;
- exact level-30 source rows: **92 / 92 mapped**;
- source brackets: **26 / 32 / 34** at levels **20 / 25 / 30**;
- distinct reviewed source families: **26**;
- source-map gaps: **0**.

The source inventory remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Tracked level-30 source coverage is now **16 paths / 1058 learning rows /
124 unique source skill IDs**. Launch audit coverage is **13 / 18
first-transfer branches source-audited** and **13 / 18 rank schedules mapped**.

## Exact class-42 stats

The accepted Duskseer source template preserves:

- STR 23 / DEX 23 / CON 24;
- INT 44 / WIT 19 / MEN 37;
- level-30 resources: **732 HP / 482 MP / 368 CP**;
- CON bonus **0.90**;
- MEN bonus **1.45**.

All eight genuine passive families now cross the owned-passive, unified-stat
and resource-migration boundaries with their exact source ranks.

## Skill/runtime completion

The 26 reviewed source families are independently named and trainer-gated under
Duskseer. Existing shared runtime mechanics are reused only where the source
skill ID is the same.

The two class-42 source effects not already present from Cleric/Elven Oracle
work were added exactly:

- Greater Empower 1059:1 -> creative `DuskseerEmpower`, 1200-second target
  buff, `MAGICAL_ATTACK x1.55`;
- Vampiric Rage 1268:1 -> creative `DuskseerBloodRite`, 1200-second target
  buff, `ABSORB_DAMAGE_PERCENT +6`.

Support routing covers healing, recharge, resurrection and the reviewed target
buff families. Hostile routing covers the reviewed undead attack, Sleep,
Dryad Root and Wind Shackle paths.

## Vampiric Rage melee semantics

Acceptance checked the pinned C4 normal-attack path rather than treating the
6-percent stat as decorative.

For a successful ordinary attack, Vampiric Rage now:

- applies to non-bow normal attacks;
- works against both player and NPC targets;
- does not apply to PDAM skills;
- heals from the final source normal-attack damage value;
- truncates the percentage result to an integer;
- caps the effective heal at missing caster HP.

The validation also exposed an NPC overkill bookkeeping defect. A lethal
Humanoid could temporarily report negative HP, making "actual HP removed"
larger than the target's remaining health. NPC live damage now clamps health
to zero before calculating applied HP loss. Raw source damage remains
available separately, so Vampiric Rage still uses source damage while drains,
contribution and other applied-HP consumers receive the real remaining HP.

## Fresh validation

Final closure at the accepted code/test HEAD:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused Duskseer/backend acceptance: **18 / 18 PASS**;
- source-effect regression: **1076 assertions**, **124 skills**,
  **476 unique rank/effect pairs**;
- accepted Play log: **0 CreatorErrors**.

Only the pre-existing quadruped Python `__pycache__` folders remain
untracked locally.

## Genuine unpublished Play rehearsal

`C4ShillienOracleLiveHarness` passed against a fresh unpublished Dungeon
build and the real source cutover/cast runtime.

Accepted markers:

- `WIND_SHACKLE_PASS rate=0.2 duration=15`;
- `EMPOWER_PASS duration=1200 matk=40.916`;
- `BLOOD_RITE_PASS absorb=6 healed=2`;
- `MANA_RECHARGE_PASS restored=52`;
- `SHACKLE_PLUS_EMPOWER_PLUS_BLOOD_RITE_PLUS_RECHARGE_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The rehearsal used real inventory-backed Spiritshots and Soulshots, a reviewed
Marauder source boundary, real active-source stat composition and clean
cutover/owner rollback.

## Next backend class

Continue source order with Dark Elf completion behind us and begin **Orc
Raider** source audit.

Orc is not currently a playable race. Preserve the same fail-closed gate:
source audit first; do not unlock Orc creation merely because source rows have
been inventoried.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
