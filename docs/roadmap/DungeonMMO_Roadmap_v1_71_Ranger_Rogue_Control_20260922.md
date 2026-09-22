# DungeonMMO roadmap v1.71 — Ranger/Rogue control progression

Date: 22 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`
Focus receipt:
[Real control-skill effects and training tests](../testing/c4-ranger-rogue-control-skills-2026-09-22.md).

## New locally verified backend slice

- [x] Ranger **Briar Volley**, offered at 5/10/15 with
  actual two-target penetrating damage and a server-authored
  race-specific slow that increases in duration by rank.
- [x] Rogue **Disrupting Cut**, offered at 5/10/15 with
  actual melee damage and rank-dependent server stagger.
- [x] Both abilities require their own class/trainer, correct
  equipment, sequential purchased ranks and use-earned
  proficiency 40/110 for ranks 2/3.
- [x] The existing server projectile/melee executors apply
  the effects on confirmed combat hits. A real unpublished
  Play client slowed **two** physical targets with one Briar
  Volley and staggered the real target with Disrupting Cut.
- [x] Isolated Studio contracts: 41 skill-definition/level
  assertions; 46 actual service purchase/reload assertions;
  45 corrected Rogue trainer/earned-advanced-class assertions.
- [x] Unpublished Base and Dungeon Rojo compositions built.
  No production content unlock or Roblox publish occurred.

## Explicitly incomplete

This is a small authentic mechanical increment, **not**
quantitative C4 catalogue parity. The prior read-only
Fighter/Mage reference audit had 13/16 mismatched brackets;
Ranger/Rogue C4 rank-count targets are not source-mapped.
New skills are original game abilities analogous to C4's
class-role and rank progression, not names or exact balance
transcribed from Chronicle 4.

The live Play fixture uses temporary server character
state and simulated client progression snapshots. Actual
saved-character trainer GUI and normal physical keypress
acceptance, additional race/class skills, level-20
shared-to-specialist class mapping and later level-40
branches remain open.

The outdated RogueDefinitionsTest was corrected and
focused-tested; a separate automatic
Phase2AFailurePathTest paid-revive failure remains
open for its own scoped diagnosis. Do not mistake
focused control-skill evidence for a fully green
Dungeon regression/release.

## Next backend gate

Source-map representative C4 Rogue/Elven Scout level-20
shared branches and how Ranger/Rogue split original
bow/dagger skills, then add real missing utility/control/
passive rank families and later specialist training.
Do not duplicate one reference rank count into both
base classes. Add an actual saved-profile trainer-to-combat
Play path only when the relevant trainer UI and ranks
are integrated. Preserve unrelated Dungeon
wipe/revive/aggro/Play Again acceptance; rerun only
regressions directly affected by new code.

No `main` merge, cloud TEST/PROD publishing or live
DataStore changes are authorized by this working roadmap.
