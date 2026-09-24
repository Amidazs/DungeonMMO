# DungeonMMO v2.49 — nine-class C4 creative skill linkage and passive source arithmetic

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Tested source head: `d665a3e0730c91b15bca613b5977901e981e88e2`.
Previous: [v2.48](DungeonMMO_Roadmap_v2_48_C4_75_Skill_Effect_Source_20260924.md).

## All nine original paths mapped or explicitly accounted for

The read-only `C4CreativeSkillSourceMap` links exact C4 XML
skill IDs and skill ranks from v2.47/v2.48 to candidate creative
DungeonMMO skill IDs and runtime ranks for all nine implemented
original Human/Elf base and first-transfer paths at character
level 30. Its mapping is explicit per original class, never
based on matching the displayed name. It handles source
Wind Strike's level-one starter rank versus later separately
authored Mystic Wind Bolt, original Rogue/Scout Mortal Blow
and Power Shot ranks 10-18 versus game ranks 1-9, Elven
Knight Elemental Heal source ranks 4-12 versus game ranks
1-9, aura source rank 2 versus first-transfer game rank 1,
and original Create Common Item ranks 2-3 versus first-transfer
game ranks 1-2.

The catalogue originally reported **451 candidate rows and 25
explicitly unresolved rows** across the original **476 class-scoped
learning rows**. Its first unpublished Studio audit passed,
but exposed that Curse Weakness and Wind Shackle definitions
already existed in the Mage trainer while the common Mage class
teachable list omitted them. The latter were then registered
in `ClassProgressionDefinitions.Mage.TeachableSkills` with
their existing race/character-level/proficiency restrictions:
Curse Weakness is shared by both Mystics; Wind Shackle is
Elf-only. No corresponding live damage or debuff numbers
were changed. The final unpublished Base and Dungeon Rojo
builds and the focused Base Studio audit PASS:

- **9** original class scopes and **476** learning rows inspected;
- **454** linked candidate source/creative rank rows;
- **22** explicit source learning-row gaps;
- **0** unexamined, missing-rank, wrong-teachable-class or
  wrong-learning-level linkage issues;
- **94** numeric MP-cost differences identified among candidate
  rows with both source and authored game mana values;
- **exact historical mechanical/HP/MP parity NOT CERTIFIED**.

The 22 gaps include Lucky/Common Craft at the starter levels,
unverified Mystic introductory passive effects, Human Rogue
Vital Force (not equivalent to a resting-stamina passive),
and especially **all nine Elven Scout Elemental Heal ranks**:
the current `ElvenRenewal` custom effect is NOT declared
equivalent just because its rank schedule resembles healing.
The independent creative skill extras outside the exact C4
learning tree remain reported per class. This is source/rank
linkage; it is **not** a claim that 454 effects actually match C4.

## First shared, source-only passive calculator

New `C4PassiveStatReference` applies multiple C4 passive
source modifiers in their actual calculator order. It
supports the currently verified additive 0x40 and
multiplicative 0x30 stat operations, and exact original
`using` equipment-kind conditions (e.g., Bow, Dagger,
Heavy and Light). An equipped Bow cannot receive Dagger
Mastery, Heavy cannot receive Light's evasion bonus,
and naked characters receive no weapon-only mastery.
A later rank of the same passive cannot be added as a
second independent permanent effect; unknown conditions,
operators and absent source stats fail closed. Active
auras cannot be accidentally applied as permanent passives.

The actual pinned C4 sample reference calculations
PASS **9 deterministic assertions** in an unpublished
Base Studio, including:
- Bow Mastery rank 9's real XML P.Atk modifier;
- Dagger Mastery rank 1: +3.6 P.Atk only with a Dagger;
- Knight Heavy Armor Mastery rank 1: +17.7 P.Def with Heavy;
- Scout Light Armor Mastery rank 1: +1.3 P.Def and +4
  evasion with Light;
- Mystic Weapon Mastery rank 1: at example base 100
  P.Atk/100 M.Atk, 0x30 multipliers followed by
  0x40 flat additions give 146.5/118.9.

**This arithmetic is source-only.** The caller must
supply actual source-scale base stats and correctly
classified original equipment. It does not yet implement
all equipped gear, full class buff stacking/trigger rules,
shot effects, target resistance or live combat. Current
game percentage defensive passives and custom HP/MP,
blocking and stamina remain unchanged; do not migrate
single source stat numbers directly into Roblox HP damage.

## Next backend milestones

1. Close or explicitly label the 22 remaining source
   learning-row gaps and review the creative extras.
   Prioritize a genuinely separate Elven Scout nine-rank
   Elemental Heal line and full C4 Mystic starter passives,
   not a renamed custom healing-over-time approximation.
2. Feed real C4 nine-template HP/MP/CP, equipment P.Atk/
   P.Def/M.Atk/M.Def, and passive source operations into
   one read-only unified stat calculation with verified
   item and buff predicates; test all nine classes.
3. Connect and validate the original skill power and
   effect status system through coherent shared physical,
   magical and heal formulas, then migrate all live class
   resource/effect calculations together with appropriate
   Play and exploit checks. Historical source skill power
   is not directly equivalent to inflicted target HP damage.
4. Keep this source-first implementation honest: all nine
   class paths have explicit IDs/rank candidates, but
   no full C4 combat/balance equivalence is certified
   until actual equipped stats, effects and real-client
   outcomes have been verified.

No main merge, public Roblox publish, production DataStore
mutation or animation/art worktree changes. Permanent code
and documents were committed via GitHub; desktop used only
for fast-forward pulling, disposable Rojo builds and Studio
source tests.
