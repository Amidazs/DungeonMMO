# C4-style Fighter vitality and Mage restoration training

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Focused tested source: `3be5de3316c16a531537feb175d119f171a44b67`

## New actual gameplay content

The existing level-gated, SP-paid passive/trainer/profile foundation
now contains two further six-rank training lines:

| Character | New skill | Levels offering ranks | Authority-backed result at rank 6 |
| --- | --- | --- | --- |
| Fighter | Stalwart Training | 1–3 at 5; 4–6 at 10 | +30 flat maximum health |
| Mage | Restorative Training | 1–3 at 7; 4–6 at 14 | +0.072 additive healing multiplier |

Both require the player's own matching base class, character level
and SP. They are passives: proficiency from casting cannot be required
or earned by repeatedly pressing an inert passive button. Every
purchased rank changes server-side `get_max_health` or
`get_heal_multiplier`, respectively; the existing Base progression
action refreshes the live character's authoritative runtime stats.

Reused existing `SkillProgressionService`, `TrainerCatalogues`,
`ClassProgressionDefinitions`, `ProfileService`,
`ProgressionRuntimeState` and `PassiveSkillEffects`. The original
damage passive API is preserved and now shares a small class-safe
rank resolver with health and healing effects. Unknown skills
stay hidden from the trainer below their first level, and direct
service calls cannot bypass the purchase gate. Advanced skill
mastery and advancement quest requirements are unchanged.

## Focused testing and earlier failure

The first disposable Base Studio run exposed an actual missing
integration: the new names were registered in the trainer list
but not in the base class's authorized `TeachableSkills`. The
server correctly rejected direct learning. This mismatch was
fixed **in GitHub**; no service eligibility guard was weakened.

At `3be5de3`, a clean fast-forward and one Base Rojo build passed.
The focused `c4_vitality_restoration_tests.luau` runner passed
**64 assertions** across both classes: hidden level gates,
direct-call denial, six SP purchases, second-bracket lock,
per-rank measured server stat gain, rank cap, class
exclusivity and save/reload. The directly affected existing
damage-passive test passed a further **64 assertions** at the
same source head. No dungeon wipe/aggro/Play Again matrix was run.

## C4 reference-count audit — NOT parity

The read-only `c4_skill_volume_audit.luau` ran at the same source:
**16 mapped brackets, 13 count mismatches and 14 unmapped skill-rank
occurrences**. Selected verified early bracket counts:

| DungeonMMO mapped class / level | C4 rank target | Explicit authored ranks |
| --- | ---: | ---: |
| Human Fighter 5 | 13 | 13 |
| Human Fighter 10 | 12 | 13 |
| Elf Fighter 5 | 13 | 13 |
| Elf Fighter 10 | 13 | 13 |
| Human/Elf Fighter 15 | 12 / 12 | 7 / 7 |
| Human/Elf Fighter 1 | 2 / 2 | 0 / 0 |
| Human/Elf Mage 7 | 15 / 14 | 10 / 10 |
| Human/Elf Mage 14 | 21 / 20 | 10 / 10 |

This count audit measures explicitly scheduled rank *entries*; it
does not itself prove that every authored rank is player-reachable
or has an individual effect. A coincidentally equal count is not
C4 skill-content parity, and Human Fighter level 10 now has an
**overcount of one**, which must be addressed by actual class/rank
mapping rather than removing useful working gameplay or inventing
source entries.

The four verified C4 source-class links and count method remain in
`docs/design/C4_Skill_Count_Parity_20260922.md`. Later levels,
unmapped skill families, differing Human/Elf class trees and the
Ranger/Rogue shared ancestry remain unresolved.

## Next content, not old regression

Complete authored starter-rank schedules and genuine early
physical/defensive/healing/support families at the mapped
C4 level brackets. In particular, resolve Fighter level 1/15,
Mage level 1/5/7/14 and the Human Fighter level-10 overcount
using a per-family source mapping. Build a visible progression
preview only after defining whether unknown future skills
are hidden in trainer lists versus revealed as locked in a
separate skill-tree view. Reserve the full backend matrix
for a real milestone closeout.

This is local unpublished Base service/stat acceptance, not a
full in-client health/healing combat or balance playtest.
No published place, merge to `main`, production DataStore
or Robux transaction was performed. All scripts and documents
were edited in GitHub; Remote Desktop was used solely for
clean pull, builds and focused Studio/read-only audits.
