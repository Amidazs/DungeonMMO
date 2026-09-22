# C4-style early passive ranks — focused local acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Exact tested gameplay source:
`08710c1ce8e2390804080d826925e5346b1a48a6`

## Implemented gameplay

- **Iron Discipline (Fighter):** six class-exclusive passive ranks;
  three can be purchased at level 5 and three more at level 10.
  Every purchased rank adds 0.01 to server-owned physical damage
  scaling; the last rank adds 0.06. No hotbar slot or cast is required.
- **Arcane Discipline (Mage):** six class-exclusive passive ranks;
  three can be purchased at level 7 and three more at level 14.
  Each purchased rank adds 0.015 to server-owned magical damage
  scaling; rank six adds 0.09.
- Both passives use existing Fighter/Mage trainers, the character's
  skill points, the same profile/skill rank service and level gate.
  As passive skills cannot be cast, their per-skill rank proficiency
  threshold is explicitly zero; purchasing successive levels
  still requires the level bracket and SP. Active skill proficiency
  requirements and advancement quest skill-mastery requirements
  are unchanged.
- `PassiveSkillEffects` reads only the authoritative character's
  purchased skill ranks and present base class. The existing
  `ProgressionRuntimeState` physical/magical multipliers apply the
  bonus for attacks that already use these server getters. It
  supplies zero to an untrained or wrong-class character and
  caps the effect to the registered maximum rank.

The skills are ORIGINAL DungeonMMO names/effects, using the
multi-rank/class-role learning pattern as the Lineage II C4
reference rather than copying source game assets or skill text.

## Focused verification — no old dungeon suite

The local feature worktree was clean and fast-forwarded to the
recorded GitHub gameplay source. One Base Rojo build succeeded.
One unpublished Studio run of
`scripts/studio/c4_passive_rank_effects_tests.luau`
passed **64 assertions**. Checks include unknown-skill invisibility,
failed early direct learning, both level brackets, ranks 1–6
purchased via the existing service, independently measured
no-passive versus server multiplier, maximum rank, save/reload
and no wrong-class inherited bonus. No full dungeon/aggro/
revive/Play Again regression was run.

The source-mapped C4 volume audit was run read-only against the
same built place and gameplay source. It reports:
`brackets=16 mismatched=16 unmapped_skill_ranks=14
PARITY_NOT_YET_COMPLETE`.

| Original reference bracket | Authored rank entries after this slice |
| --- | ---: |
| Human/Elf Fighter level 1 | 0 |
| Human/Elf Fighter level 5 | 10 |
| Human/Elf Fighter level 10 | 10 |
| Human/Elf Fighter level 15 | 7 |
| Human/Elf Mage level 1 | 0 |
| Human/Elf Mage level 5 | 0 |
| Human/Elf Mage level 7 | 7 |
| Human/Elf Mage level 14 | 7 |

These are **explicitly level-mapped authored rank entries**, not
every existing skill, and should not be presented as release
completeness or C4 skill parity. Existing starter skills and
older three-rank families remain partially unmapped in the
audit; other races/class trees remain future content.

## Next distinct content and acceptance boundary

Author real foundational level-1/5 roles and verified rank-level
schedules for existing starter skills; distinguish source-class
counts from the actual DungeonMMO class catalogue. Extend real
defensive/passive/healing/utility/crafting effects without
counting metadata-only ranks. A later representative client
combat test should measure one physical and one magical
trained passive impact. This focused fixture verifies the
server multiplier contract, not full live combat balance.

No `main` merge, Roblox publish, production DataStore,
force-push or purchase operation occurred. All code and docs
were edited directly in GitHub; Desktop Commander was used
for a clean pull, temporary Base build and focused local
test/read-only rank audit only.
