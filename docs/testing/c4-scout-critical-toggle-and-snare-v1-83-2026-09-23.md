# C4 Scout critical-power toggle and live snaring arrow — v1.83

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Scope

Closed the outstanding v1.82 real-client Snaring Shot impact check
and implemented the *five original C4 rank entries each* for the
Human Rogue and Elven Scout Critical Power stance. All game
scripts, testing scripts, composition JSON and documentation
were edited through GitHub only. The local authorized desktop
was used for clean fast-forward pulls, read-only log checks,
Luau parsing, disposable local Rojo builds and real unpublished
Roblox Studio test sessions. No `main` merge, forced reset,
Roblox publishing or production DataStore action occurred.

## Actual Snaring Shot gameplay, not source inspection

`scripts/studio/c4_elf_scout_snaring_shot_live.luau` ran with
the original live Dungeon composition in an unpublished local
Studio session. The test equipped the purchased level-36
Elf Ranger longbow ability and sent the actual client
`SkillRequest` to a living tagged NPC in the arrow path.
The test required the NPC's health to fall, its true
`RangerSlowMultiplier` to become 0.65, actual skill cooldown
to begin, and the slow to expire back to 1.0. It returned
`[C4 Elf Scout Live] VERIFIED_REAL_CLIENT_SNARE_PASS`.
This is direct evidence of the complete client-to-NPC projectile
path, not a guarantee of final arrow VFX or PvP behavior.

## New original C4 Critical Power toggle

- `ScoutCriticalPowerToggle` is a separately purchased
  five-rank support skill at levels 20, 24, 28, 32, 36 for
  Human/Elf Ranger/Rogue. Both original Human Rogue and
  original Elven Scout source inventories map one rank entry
  per training bracket, **not** five duplicate free passives.
- Real player `SkillRequest` enables/disables one
  authoritative stance. Activation costs three stamina;
  each full second consumes another three stamina from the
  established server-owned stamina service. A low-stamina
  character loses the stance automatically. A second cast
  disables it without paying again.
- Bought rank one through five grants active bonus
  0.06, 0.08, 0.10, 0.12 or 0.14, respectively, to the
  **actual server critical-damage multiplier** read by
  melee and Ranger projectile damage. Buying a rank alone
  does not grant its stance bonus; an actual client cast
  is required.
- Purchased-rank, race, class, original loadout, currently
  equipped weapon, live Dungeon eligibility, living original
  character, authorized player and source rank equality
  are enforced for activation and during upkeep. A new
  character, death, character removal, skill unlearning,
  rank downgrade, loadout change or Dungeon exclusion
  revokes the bonus. Stamina is deducted via dependency
  injection to avoid a combat/progression circular require.
- The shared runtime dependency is mapped into both
  `base.project.json` and `default.project.json`.
  No second profession slot or recipe-reading bypass occurs.

## Tests actually executed

- Changed-source `luau-compile --only-parse` checks passed;
  the disposable Base and Dungeon Rojo compositions both
  built successfully. These are source/build checks, not
  gameplay tests.
- The targeted unpublished Studio run completed **6/6**:
  new `C4ScoutCriticalPowerToggleTest` (**117 assertions**),
  exact Scout source inventory, strict combined catalogue
  coverage, new Elven Scout support, existing Elf healing/
  threat and the real NPC slow primitive.
- The independent real Dungeon client test
  `scripts/studio/c4_scout_critical_toggle_live.luau`
  returned
  `[C4 Scout Toggle Live] VERIFIED_REAL_CLIENT_TOGGLE_PASS`.
  It requires server-authorized source-rank-five activation,
  an actual 0.14 increase to critical damage, continued
  stamina spending after one second, real client switch-off
  and bonus removal, and automatic bonus removal when a
  test-only player's stamina is exhausted.
- The latest 0-source-logic nil-character safety guard was
  committed after these tests; it does not change successful
  live combat code paths. A final source parse/build check
  should accompany the next touched-runtime acceptance.

## Honest source-rank counts and remaining work

| Original C4 class | Functional / raw | Missing |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partial) | 86 / 99 | 13 |
| Elven Scout (partial) | 117 / 129 | 12 |
| **Six inventoried classes** | **371 / 396** | **25** |

The remaining partially inventoried source families include
Accuracy Toggle (one per class), three profession-constrained
Common Item Creation ranks each, five Lockpicking ranks each,
Equipment Expertise, Lung Capacity and Fall Resistance for
both classes, and Human Rogue's Sprint. None is considered
implemented yet. The other seven original C4 first-transfer
class catalogues remain wholly unmapped; **0/9 original
first-transfer paths are complete**.

The next ranked Accuracy Toggle must use a genuine on/off
server-authorized accuracy/hit calculation plus continuous
resource upkeep. A standalone icon, flag or untested
hit-chance stat must not be counted as a functional analogue.

**Snaring Shot live NPC hit: PASS. Critical Power live client:
PASS. Focused C4 source audits: 6/6 PASS. Entire original
C4 catalogue: INCOMPLETE.**
