# DungeonMMO backend v2.24 — Human and Elven Fighter class-tree checkpoint

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous checkpoint: [v2.23](DungeonMMO_Roadmap_v2_23_Warrior_Level30_Rank_Mapping_20260924.md).

## Keep starting classes distinct from first transfers

Our level-1–19 starter class ID is `Fighter` for both currently
supported races, but its Human and Elven historical skill inventories
are separate source data in `C4BaseSkillInventory`. Do not add a
fresh-character `Warrior` starter: in the C4 structure, Human Warrior
is already one of the level-20 **first transfers**.

| Race | Level 1–19 starting path | Level 20 first-transfer source | Existing game career |
|---|---|---|---|
| Human | Human Fighter | Human Warrior | Ironvow — 62/62 source-rank rows mapped |
| Human | Human Fighter | Human Knight | Oathguard — 55/55 source-rank rows mapped |
| Human | Human Fighter | Human Rogue | Ashenblade — 59/59 source-rank rows mapped |
| Elf | Elven Fighter | Elven Scout | Greenward Scout — 77/77 source-rank rows mapped |
| Elf | Elven Fighter | Elven Knight | **Missing playable career and level-20–30 source-rank audit** |

The Elven Scout is the existing agile/dagger-and-bow option; it is
**not** an Elven Knight. The proposed player-facing name
`Greenward Warden` can be used for the Elven Knight role, but
do not rename `GreenwardScout` or conflate either saved class ID.
Only add a permanent new class ID after separately implementing
the Elven Knight's historical source inventory, advancement quest,
trainer, equipped-weapon authority, skills and migration rules.
There is no completed source rank count to credit to Elven Knight.

The existing `ClassProgressionDefinitions.Fighter` and
`C4BaseSkillInventory` already include distinct Elven starter
abilities. Their complete source effect/mechanical parity and the
natural persistent level-1–19 journey remain **uncertified**.
Do not infer base-class completion from first-transfer rank counts.

## Actionable backend queue

1. Finish the pending v2.23 stored-character recovery/surge
   real Studio Play regressions (new assertions are not yet passed).
2. Audit **Elven Knight** original C4 level-20/24/28 abilities from
   traceable historical source rows, then implement a distinct earned
   quest/trainer/skill path, separate from the Human Oathguard and
   Elven Scout. Preserve one gathering and one crafting profession.
3. Verify Human and Elven Fighter level-1–19 source-skill effect
   differences, training, saved quest progression and genuine
   Base->Dungeon->Base/rejoin progression.
4. Audit other unimplemented first transfers, boss/world-boss block
   stacking and multi-client owner isolation without marking source
   rank schedules as numerical/mechanical C4 equivalence.

`C4Level30LaunchCoverageTest` now explicitly asserts the Human
3-branch and Elf 2-branch Fighter trees, both starter source
inventories and Elven Knight's **unimplemented** coverage state.
These new assertions have not yet been run in Studio.

Previously mapped four first-transfer rank schedules remain
62/62, 55/55, 59/59 and 77/77. Across the whole original
18 first transfers, only 4 source inventories are fully recorded,
14 are still unaudited, and 0 have full mechanical and release
acceptance.

No `main` merge, Roblox publication, production DataStore
mutation or separate animation-worktree edits. Permanent edits
via GitHub; Remote Desktop only for safe fast-forward/disposable
unpublished builds and targeted Studio Play when available.
