# DungeonMMO roadmap v1.65 — Chronicle 4 skill volume

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
First verified reference-gap gameplay commit:
`29d117a0bbe9e54817b2a06577585ef3ca88ebb9`

## Requirement: same skill-rank volume per level and mapped class

The user's target is **Lineage II Chronicle 4's number of
skill-rank offerings at each class training level**, not
a handful of new abilities or a single new hotbar skill
per level. For example, the C4 Human Fighter table
contains **13 rank entries at level 5**: multiple new
skills, passive/crafting entries and several ranks of
the same active ability. The result must include real
DungeonMMO ability effects/passive modifiers, not
inert skills created merely to make a counter green.

Use [C4 source-count, class-mapping and gap spec](
../design/C4_Skill_Count_Parity_20260922.md).
That spec records the first 16 individually verified
race/base-class level brackets. Follow the **C4** source,
not Interlude, High Five or a fan-made merged table.

## Work carried out so far

- [x] Confirmed how C4 counts repeated ranked entries;
  distinguished per-level offerings from unique skills
  and cumulative learned abilities.
- [x] Authored a source-backed first volume manifest for
  Human/Elf Fighter and Mystic level-1-to-15 brackets.
  A missing bracket is UNVERIFIED, never an assumed zero.
- [x] Compared actual explicit rank-level assignments
  against the verified source, with a focused report
  listing **16/16 missing parity brackets** and existing
  unmapped legacy skill families. Do not claim that
  the current four new basics achieve C4 skill density.
- [x] Aligned initial new basic skill milestones to
  Fighter-style 5/10/15 and Mystic-style 7/14/20
  instead of the previous generic 8/14/20. Unknown
  locked skills remain hidden and purchases remain
  server-validated for level, proficiency and class.
- [x] One focused Base Rojo build and the affected
  SkillMasteryGates contract passed after changing
  the level brackets. The read-only C4 skill-volume
  test reported all 16 gaps instead of inventing
  a passing content-parity result.

## Remaining substantial new content (NOT COMPLETE)

- [ ] Verify the full C4 skill-rank catalogue for all
  corresponding levels and class branches. The
  present DungeonMMO Ranger/Rogue each start at
  level 1, unlike C4's shared Rogue/Elven Scout
  level-20 hybrid class; map their shared bow/dagger
  roots and later level-40 specializations before
  counting the same C4 source twice.
- [ ] Expand rank scheduling beyond the present
  three-rank prototype where C4 has more levels
  for a skill. Rank effects must scale in the
  actual combat/passive/crafting services.
- [ ] Add **real** basic attack, control, healing,
  defensive, passive and utility families at every
  reference level, with earned proficiency, SP
  costs, prerequisites and appropriate class trainers.
  Count each implemented rank only once per class.
- [ ] Extend source targets to C4's first-transfer
  and later skill brackets; match the associated
  class-tree phase, not a convenient aggregate
  across unrelated classes.
- [ ] Complete advanced-class dependencies and
  level-gated advancement after the actual full
  basic-skill content exists.
- [ ] Make progression/journal UX show only currently
  unlockable skills and provide a separate optional
  future-requirement preview. A hidden icon is
  not a substitute for server authorization.

## Stop rule

Do not call the catalogue C4-volume-equivalent until
all mapped class/level reference rows have a real,
reachable DungeonMMO counterpart and the matching
progression audit passes. Do not rerun old dungeon
wipe/aggro/Play Again tests while adding skill data:
run the affected skill/character progression contract
and one relevant ability/passive gameplay check per
new family. Retain no-production-publish and no-main-
merge constraints.
