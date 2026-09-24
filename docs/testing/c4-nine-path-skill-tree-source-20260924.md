# C4 nine-path learning-tree evidence — v2.47

Sources:
- pinned C4 Scions of Destiny `skill_trees.sql` at
  `07f8536384e799f128d44198dd7ab23519660eea`;
- C4 L2Hub automatic/common rows for Expertise D (skill 239) and
  Create Common Item (skill 1320).

The source module contains exactly 476 level<=30 rows across the four
current original starters and five first-transfer classes. It retains
SP and minimum level rather than only counting ranks. The distinction
between SQL rows and automatic/common rows is explicit.

This source inventory is broader than the prior Warden-only effect
sample and provides the join key for the next 75-skill XML effect
extraction. Passing this test must not be reported as effect/damage
parity or live trainer parity.
