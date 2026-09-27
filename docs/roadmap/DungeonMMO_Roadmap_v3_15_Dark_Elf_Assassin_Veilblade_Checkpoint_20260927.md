# DungeonMMO Roadmap v3.15 — Dark Elf Assassin / Veilblade Checkpoint

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.14](
DungeonMMO_Roadmap_v3_14_Palus_Knight_Duskguard_Level30_20260927.md).

## Status

**GREEN — backend, focused Studio acceptance and unpublished Play rehearsal passed.**

Checkpoint HEAD before documentation:

`519185ca0c41d2969901d2454045d45ea3527315`.

Checkpoint evidence:
[Dark Elf Assassin / Veilblade v3.15](
../testing/c4-dark-elf-assassin-veilblade-v3-15-checkpoint-20260927.md).

## Source catalogue and progression

The C4 Dark Elf Assassin source class is now represented independently as the
creative first-transfer class **Veilblade**.

The current source schedule contains:

- source class ID 35;
- level bands 20 / 24 / 28;
- **72 exact source rank rows** through level 30;
- **23 creative skill families**;
- **0 creative source-map gaps**.

The Veilblade trainer, advancement identity, progression definitions and exact
source-rank schedule are all present. Shared Scout/Wayfinder families remain
reused where the underlying C4 source skill is shared, while Assassin-specific
families keep independent creative names.

## Veilblade-specific active backend

Six Assassin-specific active families are routed through the scheduled
server-owned source cast bridge:

- `VeilbladeUmbralSiphon` — source health drain;
- `VeilbladeDefenseAura` — self buff;
- `VeilbladeVenomHex` — source periodic poison;
- `VeilbladeMindRend` — confusion/control;
- `VeilbladeCrimsonSting` — physical bleed/status;
- `VeilbladeAttackAura` — self buff.

The bridge is disabled by default, keeps hostile targets private/server-bound,
performs cast/effect-range revalidation and delegates only to existing reviewed
source executor families.

## Shared Scout/Wayfinder backend

Veilblade also reuses the already reviewed shared first-transfer systems for:

- Mortal Blow / Wayfinder Cut;
- Power Shot / Wayfinder Arrow;
- Unlock / Scout Lockpicking;
- bow and dagger masteries;
- light-armour mastery;
- long-range bow training;
- movement/evasion/fall/lung passives;
- accuracy and critical-power toggles;
- Evasive Focus;
- Wayfinder Wound.

A compatibility defect discovered during Studio validation was fixed:
`AllowedFirstTransferClasses` now requires an earned original transfer receipt
for Fighter/Mage original-base paths without breaking the older legacy
Ranger/Rogue test identities that still exist in the repository.

## Exact Dark Elf primary stats

The exact Assassin class-35 primary-stat template is now part of the common C4
primary-stat reference:

- STR 41;
- DEX 34;
- CON 32;
- INT 25;
- WIT 12;
- MEN 26.

The exact level-30 Veilblade resource vector is also regression-covered:

- HP 831;
- MP 325;
- CP 337.

The primary-stat reference now contains 15 verified source templates / growth
curves through level 30.

## Source cast timing

Veilblade active skills use the same source scheduler corrected during the
Duskguard batch. Physical skills use P.Atk.Spd and physical skill reuse;
magical skills continue to use M.Atk.Spd and magical skill reuse.

Source DEX is exposed to the reviewed C4 blow-resolution path so Assassin
dagger/blow behavior can use the correct primary-stat input rather than an
invented substitute.

## Test checkpoint

A dedicated unpublished runner now exists:

`scripts/studio/c4_dark_elf_assassin_backend_focus.luau`.

It contains **29 suites** covering the C4 combat formula, Veilblade foundation, active routing,
shared Scout/Rogue behavior, source tables, progression, primary stats,
resource/cast timing, combat calculation/execution and Dungeon composition.

A pre-fix Studio run exposed four concrete regressions:

1. stale Assassin source-row expectation;
2. stale primary-stat template count;
3. legacy Scout passive eligibility blocked by the new original-transfer gate;
4. legacy Human Scout critical training blocked by the same gate.

All four causes were corrected. Launch coverage was also updated for the
Dark Elf Assassin branch, and the focused runner's temporary ModuleScript
source append was corrected to use an executable `"\nreturn true\n"`.

## Static validation

Fresh validation on checkpoint HEAD:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- repository worktree clean except the existing quadruped Python
  `__pycache__` folders.

## Final acceptance

Fresh acceptance on the completed v3.15 implementation:

- `git diff --check`: PASS;
- fresh Dungeon Rojo build: PASS;
- focused Studio acceptance: **29 / 29 PASS**;
- genuine unpublished Play rehearsal: **PASS**;
- Scout Fleet Foot live movement multiplier: **1.06**;
- Defense Aura source duration: **1200 seconds**;
- Umbral Siphon: live NPC damage plus caster healing: PASS;
- Venom Hex: live source poison application: PASS;
- Wayfinder Cut / Mortal Blow: live C4 `BLOW` resolution: PASS,
  observed **79.8%** rear-position chance from DEX 34 and **870.1875**
  live damage on the accepted roll;
- Crimson Sting: live physical damage plus bleed/status: PASS;
- final `VERIFIED_PLAY_MODE_PASS`: PASS;
- final project CreatorErrors in the accepted Play log: **0**.

The acceptance pass also closed a previously hidden source-combat gap. Mortal
Blow was correctly mapped to source skill 16 but the live calculator only
accepted `PDAM`. v3.15 now implements the pinned C4 BLOW success rule,
separate blow-damage formula, real miss semantics, raw DEX propagation and
neutral `BLOW_RATE` through the source stat pipeline.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
