# DungeonMMO v2.47 — exact C4 nine-path learning tree

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.46](
DungeonMMO_Roadmap_v2_46_C4_Combat_Formula_Reference_20260924.md).

The source layer now covers every learning row through character level
30 for **all nine currently implemented original C4 paths**, rather
than focusing on Greenward Warden.

The pinned C4 `skill_trees.sql` contributes 457 class-tree rows.
C4 L2Hub class/skill pages supply 19 automatic/common rows that this
particular server SQL does not repeat: Create Common Item rank1 at
level5 for the four starters; Expertise D rank1 plus Create Common
Item ranks2/3 at levels20/28 for each of the five first transfers.
Combined source inventory: **476 learning rows / 75 unique source
skill IDs / nine original paths**.

| Source path | Rows <=30 |
| --- | ---: |
| Human Fighter | 39 |
| Human Mystic | 44 |
| Elven Fighter | 43 |
| Elven Mystic | 42 |
| Human Warrior | 62 |
| Human Knight | 54 |
| Human Rogue | 59 |
| Elven Knight | 56 |
| Elven Scout | 77 |

Every row retains source skill ID, source skill level, historical name,
SP cost, minimum character level and whether it comes from the pinned
C4 SQL or an automatic/common C4 class-page row.

This does not mean the current DungeonMMO trainer values/effects match
all 476 rows. The next step is to resolve these 75 source skill IDs
against the pinned C4 skill XML and produce per-rank power, MP/HP
cost, target, reuse/cast, effect, passive-stat, weapon/equipment and
status metadata, then map those source facts to the existing creative
DungeonMMO skill IDs.

No live trainer, stat or combat values changed. No main merge, publish,
production DataStore mutation or animation/art edits.
