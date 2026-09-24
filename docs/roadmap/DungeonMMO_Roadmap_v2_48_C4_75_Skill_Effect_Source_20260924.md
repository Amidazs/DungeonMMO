# DungeonMMO v2.48 — C4 75-skill effect source catalogue

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.47](
DungeonMMO_Roadmap_v2_47_C4_Nine_Path_Skill_Tree_Source_20260924.md).

The C4 source layer now resolves the actual skill XML for **all 75
source skill IDs** used by the nine currently implemented original
paths through level 30. It stores only rank levels that those paths
actually learn in the current level cap, avoiding unrelated high-level
or enchant data.

Each rank resolves factual C4 fields from the pinned source XML:
MP/initial-MP/HP/item costs where present, skill/effect power,
magic level, target, hit/cool/reuse timing, active/passive/toggle
type, cast/effect range, effect type/power/save stat, element,
over-hit and other source sets. Passive/additive/multiplicative
stat operations, effect rows, nested modifiers and source conditions
such as weapon kinds are recorded separately instead of converting
them to custom Roblox percentages.

The generated data is split by original XML range and exposed through
`C4SkillEffectSource`. The source test joins every v2.47 learning
row to its exact source skill/rank, so Human/Elf Fighter/Mystic and
all five first-transfer classes are covered by the same mechanism.

Important: this is a **source catalogue**, not a live rewrite.
The next step is a maintained source-to-creative family map that
compares every current DungeonMMO rank/effect against these C4 facts,
then an equipment/passive calculator implementation and coordinated
live stat/skill migration.

No production combat values changed. No main merge, publish,
production DataStore mutation or animation/art edits.
